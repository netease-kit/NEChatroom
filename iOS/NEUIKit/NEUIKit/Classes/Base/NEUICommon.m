// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEUICommon.h"

@interface UIApplication ()
+ (CGFloat)ne_statusBarHeight;
@end

@implementation UIApplication (NEUIKit)
+ (CGFloat)ne_statusBarHeight {
  CGFloat statusBarHeight = 0.0;
  if (@available(iOS 13.0, *)) {
    UIWindow *window = UIApplication.sharedApplication.windows.firstObject;
    statusBarHeight = window.windowScene.statusBarManager.statusBarFrame.size.height;
  } else {
    statusBarHeight = UIApplication.sharedApplication.statusBarFrame.size.height;
  }
  return statusBarHeight;
}
@end

@implementation NEUICommon
+ (CGFloat)ne_screenWidth {
  return UIScreen.mainScreen.bounds.size.width;
}
/// 屏幕 高度
+ (CGFloat)ne_screenHeight {
  return UIScreen.mainScreen.bounds.size.height;
}
/// 状态栏 高度
+ (CGFloat)ne_statusBarHeight {
  return UIApplication.ne_statusBarHeight;
}
/// 导航栏 高度
+ (CGFloat)ne_navigationBarHeight {
  return 44;
}
/// 状态栏 + 导航栏 高度
+ (CGFloat)ne_topBarHeight {
  return UIApplication.ne_statusBarHeight + self.ne_navigationBarHeight;
}
/// Tabbar 高度
+ (CGFloat)ne_tabbarHeight {
  return 49.0;
}
/// Tabbar + 底部安全区域高度
+ (CGFloat)ne_bottomBarHeight {
  return self.ne_statusBarHeight > 20.0 ? 83.0 : 49.0;
}
/// 底部安全区域高度
+ (CGFloat)ne_bottomSafeAreaHeight {
  return self.ne_statusBarHeight > 20.0 ? 34.0 : 0.0;
}

+ (UIImage *)ne_imageName:(NSString *)imageName bundleName:(NSString *)bundleName {
  NSString *bundlePath = [[NSBundle bundleForClass:[self class]].resourcePath
      stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.bundle", bundleName]];
  NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];

  if (@available(iOS 13.0, *)) {
    return [UIImage imageNamed:imageName inBundle:bundle withConfiguration:nil];
  }
  return [UIImage imageNamed:imageName inBundle:bundle compatibleWithTraitCollection:nil];
}

+ (void)ne_adjustsInsets:(UIScrollView *)scrollView vc:(UIViewController *)vc {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
  if ([UIScrollView
          instancesRespondToSelector:NSSelectorFromString(@"setContentInsetAdjustmentBehavior:")]) {
    NSMethodSignature *signature = [UIScrollView
        instanceMethodSignatureForSelector:@selector(setContentInsetAdjustmentBehavior:)];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    NSInteger argumet = 2;
    invocation.target = scrollView;
    invocation.selector = @selector(setContentInsetAdjustmentBehavior:);
    [invocation setArgument:&argumet atIndex:2];
    [invocation invoke];
  } else {
    vc.automaticallyAdjustsScrollViewInsets = NO;
  }
#pragma clang diagnostic pop
}
@end
