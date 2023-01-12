// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (NEListenTogetherVoiceRoom)

/**
 视图切圆角

 @param roundingCorners 指定圆角
 */
- (void)cutViewRounded:(UIRectCorner)roundingCorners cornerRadii:(CGSize)cornerRadii;

@end

NS_ASSUME_NONNULL_END
