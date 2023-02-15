// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NEUICommon : NSObject
#pragma mark------------------------  System  ---------------------------
/// 屏幕 宽度
+ (CGFloat)ne_screenWidth;
/// 屏幕 高度
+ (CGFloat)ne_screenHeight;
/// 状态栏 高度
+ (CGFloat)ne_statusBarHeight;
/// 导航栏 高度
+ (CGFloat)ne_navigationBarHeight;
/// 状态栏 + 导航栏 高度
+ (CGFloat)ne_topBarHeight;
/// Tabbar 高度
+ (CGFloat)ne_tabbarHeight;
/// Tabbar + 底部安全区域高度
+ (CGFloat)ne_bottomBarHeight;
/// 底部安全区域高度
+ (CGFloat)ne_bottomSafeAreaHeight;

/// 调整scrollview insets
+ (void)ne_adjustsInsets:(UIScrollView *)scrollView vc:(UIViewController *)vc;

/// 从 bundle中 获取image
+ (UIImage *)ne_imageName:(NSString *)imageName bundleName:(NSString *)bundleName;
@end

NS_ASSUME_NONNULL_END
