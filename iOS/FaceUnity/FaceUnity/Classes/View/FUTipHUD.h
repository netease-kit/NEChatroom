// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FUTipHUD : NSObject

/// 文字提示（默认3秒后自动消失）
/// @param tipsString 文字
+ (void)showTips:(NSString *)tipsString;

/// 文字提示
/// @param tipsString 文字
/// @param delay 自动消失时间，单位: 秒
+ (void)showTips:(NSString *)tipsString dismissWithDelay:(NSTimeInterval)delay;

@end

NS_ASSUME_NONNULL_END
