// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEListenTogetherAnimationButton.h"
#import "UIColor+NEUIExtension.h"

@interface NEListenTogetherAnimationButton ()

@property(nonatomic, weak) CALayer *animationLayer;
@property(nonatomic, assign) BOOL isAnimating;
@property(nonatomic, strong) UILabel *valueLab;
@end

@implementation NEListenTogetherAnimationButton

- (instancetype)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    [self addSubview:self.valueLab];
  }
  return self;
}

- (void)layoutSubviews {
  [super layoutSubviews];
  if (!CGRectEqualToRect(self.bounds, self.valueLab.frame)) {
    self.valueLab.frame = self.bounds;
  }
}

- (void)startCustomAnimation {
  if (_isAnimating) {
    return;
  }
  CALayer *animationLayer = [CALayer layer];
  NSMutableArray<CALayer *> *pulsingLayers = [self setupAnimationLayers:self.frame];
  [pulsingLayers
      enumerateObjectsUsingBlock:^(CALayer *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        [animationLayer addSublayer:obj];
      }];
  [self.layer addSublayer:animationLayer];
  _animationLayer = animationLayer;
  _isAnimating = YES;
}

- (void)stopCustomAnimation {
  if (!_isAnimating) {
    return;
  }
  [_animationLayer.sublayers enumerateObjectsUsingBlock:^(__kindof CALayer *_Nonnull obj,
                                                          NSUInteger idx, BOOL *_Nonnull stop) {
    [obj removeAllAnimations];
  }];
  [_animationLayer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
  [_animationLayer removeFromSuperlayer];
  _animationLayer = nil;
  _isAnimating = NO;
  self.info = nil;
}

- (NSMutableArray<CALayer *> *)setupAnimationLayers:(CGRect)rect {
  NSMutableArray<CALayer *> *ret = [NSMutableArray array];
  NSInteger pulsingCount = 5;
  double animationDuration = 3;
  for (int i = 0; i < pulsingCount; i++) {
    CALayer *pulsingLayer = [CALayer layer];
    pulsingLayer.frame = CGRectMake(0, 0, rect.size.width, rect.size.height);
    pulsingLayer.borderColor = [UIColor ne_colorWithHex:0x35A4FF].CGColor;
    pulsingLayer.borderWidth = 1;
    pulsingLayer.cornerRadius = rect.size.height / 2;

    CAMediaTimingFunction *defaultCurve =
        [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.fillMode = kCAFillModeBackwards;
    animationGroup.beginTime =
        CACurrentMediaTime() + (double)i * animationDuration / (double)pulsingCount;
    animationGroup.duration = animationDuration;
    animationGroup.repeatCount = HUGE;
    animationGroup.timingFunction = defaultCurve;

    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.fromValue = @1.0;
    scaleAnimation.toValue = @1.5;

    CAKeyframeAnimation *opacityAnimation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.values = @[ @1, @0.9, @0.8, @0.7, @0.6, @0.5, @0.4, @0.3, @0.2, @0.1, @0 ];
    opacityAnimation.keyTimes = @[ @0, @0.1, @0.2, @0.3, @0.4, @0.5, @0.6, @0.7, @0.8, @0.9, @1 ];

    animationGroup.animations = @[ scaleAnimation, opacityAnimation ];
    [pulsingLayer addAnimation:animationGroup forKey:@"plulsing"];
    [ret addObject:pulsingLayer];
  }
  return ret;
}

- (void)setInfo:(NSString *)info {
  _info = info;
  _valueLab.text = info ? info : @"";
}

- (UILabel *)valueLab {
  if (!_valueLab) {
    _valueLab = [[UILabel alloc] init];
    _valueLab.textColor = [UIColor redColor];
    _valueLab.font = [UIFont systemFontOfSize:10.0];
    _valueLab.textAlignment = NSTextAlignmentCenter;
    _valueLab.hidden = YES;
  }
  return _valueLab;
}

@end
