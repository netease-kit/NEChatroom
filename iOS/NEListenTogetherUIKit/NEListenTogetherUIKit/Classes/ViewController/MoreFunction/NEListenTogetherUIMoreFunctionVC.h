// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <NEListenTogetherKit/NEListenTogetherKit-Swift.h>
#import <UIKit/UIKit.h>
#import "NEListenTogetherContext.h"
NS_ASSUME_NONNULL_BEGIN

@protocol NEUIMoreSettingDelegate <NSObject>
@optional

/// 设置麦克风开关
/// @param micOn 开关状态
- (void)didSetMicOn:(BOOL)micOn;

/// 设置耳返开关
/// @param earBackOn 开关状态
- (void)didEarbackOn:(BOOL)earBackOn;
/// 结束直播
- (void)endLive;
@end

/// 更多功能
@interface NEListenTogetherUIMoreFunctionVC : UIViewController
@property(nonatomic, weak) id<NEUIMoreSettingDelegate> delegate;
- (instancetype)initWithContext:(NEListenTogetherContext *)context;
@end

NS_ASSUME_NONNULL_END
