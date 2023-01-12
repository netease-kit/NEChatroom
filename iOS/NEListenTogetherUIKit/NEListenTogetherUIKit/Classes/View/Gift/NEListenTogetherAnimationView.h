// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 打赏展示礼物动画视图
 */
@interface NEListenTogetherAnimationView : UIView

/**
 添加动画
 @param gift    - 动画资源名
 */
- (void)addGift:(NSString *)gift;

@end

NS_ASSUME_NONNULL_END
