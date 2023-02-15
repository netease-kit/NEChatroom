// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEListenTogetherUIActionSheetNavigationController.h"
#import <NEUIKit/UIImage+NEUIExtension.h>
#import "NEListenTogetherUIActionSheetTransitioningDelegate.h"
@interface NEListenTogetherUIActionSheetNavigationController ()

// 圆角遮罩
@property(nonatomic, strong) CAShapeLayer *navigationBarMask;

// 转场动画代理
@property(nonatomic, strong) NEListenTogetherUIActionSheetTransitioningDelegate *transitioning;

@end

@implementation NEListenTogetherUIActionSheetNavigationController

@dynamic dismissOnTouchOutside;

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController {
  self = [super initWithRootViewController:rootViewController];
  if (self) {
    self.navigationBar.tintColor = UIColor.blackColor;
    self.navigationBar.clipsToBounds = YES;
    self.navigationBar.translucent = NO;
    self.navigationBar.shadowImage = [UIImage ne_imageWithColor:[UIColor colorWithRed:242 / 255.0
                                                                                green:243 / 255.0
                                                                                 blue:245 / 255.0
                                                                                alpha:1.0]];
    [self.navigationBar
        setTitleTextAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:16]}];
    self.navigationBarMask = [[CAShapeLayer alloc] init];
    self.transitioning = [[NEListenTogetherUIActionSheetTransitioningDelegate alloc] init];
    self.modalPresentationStyle = UIModalPresentationCustom;
    self.transitioningDelegate = self.transitioning;
    if (@available(iOS 15.0, *)) {
      UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];

      [appearance configureWithOpaqueBackground];

      NSMutableDictionary *textAttribute = [NSMutableDictionary dictionary];
      textAttribute[NSForegroundColorAttributeName] = [UIColor blackColor];  // 标题颜色
      textAttribute[NSFontAttributeName] = [UIFont systemFontOfSize:16];     // 标题大小
      [appearance setTitleTextAttributes:textAttribute];

      // 去除底部黑线
      [appearance setShadowImage:[UIImage ne_imageWithColor:[UIColor colorWithRed:242 / 255.0
                                                                            green:243 / 255.0
                                                                             blue:245 / 255.0
                                                                            alpha:1.0]]];

      UIColor *color = [UIColor whiteColor];
      appearance.backgroundColor = color;

      self.navigationBar.standardAppearance = appearance;
      self.navigationBar.scrollEdgeAppearance = appearance;
    }
  }
  return self;
}

- (void)viewDidLayoutSubviews {
  [super viewDidLayoutSubviews];
  self.navigationBar.frame =
      CGRectMake(0, 0, self.view.frame.size.width, 48);  // 按照设计图高度是48
  self.navigationBarMask.frame = self.navigationBar.bounds;
  UIBezierPath *maskCornor =
      [UIBezierPath bezierPathWithRoundedRect:self.navigationBar.bounds
                            byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight
                                  cornerRadii:CGSizeMake(12, 12)];
  self.navigationBarMask.path = maskCornor.CGPath;
  self.navigationBar.layer.mask = self.navigationBarMask;
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
  if ([self.transitioning respondsToSelector:aSelector]) {
    return self.transitioning;
  }
  return [super forwardingTargetForSelector:aSelector];
}

@end
