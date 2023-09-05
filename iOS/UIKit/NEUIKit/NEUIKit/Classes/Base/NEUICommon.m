// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEUICommon.h"

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
