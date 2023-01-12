// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEListenTogetherAnimationView.h"
#import <Lottie/LOTAnimationView.h>
#import "UIImage+ListenTogether.h"

@interface NEListenTogetherAnimationView ()

/// 保护队列
@property(nonatomic, strong) dispatch_queue_t queue;
/// 礼物集合
@property(nonatomic, strong) NSMutableArray *gifts;
/// 动画控件
@property(nonatomic, strong) LOTAnimationView *animationView;

@end

@implementation NEListenTogetherAnimationView

- (instancetype)init {
  CGRect rect = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width,
                           [UIScreen mainScreen].bounds.size.height);
  self = [super initWithFrame:rect];
  if (self) {
    _queue = dispatch_queue_create(0, DISPATCH_QUEUE_SERIAL);
    _gifts = [NSMutableArray array];
    [self addSubview:self.animationView];
    self.userInteractionEnabled = NO;
  }
  return self;
}

- (void)addGift:(NSString *)gift {
  dispatch_sync(_queue, ^{
    [self.gifts addObject:gift];
    [self _play];
  });
}

- (void)_removeFirstGift {
  dispatch_sync(_queue, ^{
    if ([self.gifts count] > 0) {
      [self.gifts removeObjectAtIndex:0];
    }
  });
}

- (void)_play {
  if (self.animationView.isAnimationPlaying || [self.gifts count] == 0) {
    return;
  }
  NSString *gift = [self.gifts firstObject];
  NSString *path = [[NSBundle mainBundle]
      pathForResource:@"Frameworks/NEListenTogetherUIKit.framework/NEListenTogetherUIKit"
               ofType:@"bundle"];
  NSBundle *bundle = [NSBundle bundleWithPath:path];
  [self.animationView setAnimationNamed:gift inBundle:bundle];
  dispatch_async(dispatch_get_main_queue(), ^{
    self.animationView.hidden = NO;
    [self.animationView playWithCompletion:^(BOOL animationFinished) {
      if (!animationFinished) {
        return;
      }
      self.animationView.hidden = YES;
      [self _removeFirstGift];
      [self _play];
    }];
  });
}

#pragma mark - lazy load

- (LOTAnimationView *)animationView {
  if (!_animationView) {
    CGRect rect = CGRectMake(0, (CGRectGetHeight(self.frame) - CGRectGetWidth(self.frame)) / 2,
                             CGRectGetWidth(self.frame), CGRectGetWidth(self.frame));
    _animationView = [[LOTAnimationView alloc] initWithFrame:rect];
  }
  return _animationView;
}

@end
