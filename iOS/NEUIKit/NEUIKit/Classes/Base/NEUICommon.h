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
@end

NS_ASSUME_NONNULL_END
