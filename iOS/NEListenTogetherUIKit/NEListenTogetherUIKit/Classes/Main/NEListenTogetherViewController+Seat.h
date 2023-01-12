// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEListenTogetherViewController.h"
NS_ASSUME_NONNULL_BEGIN

@interface NEListenTogetherViewController (Seat)
/// 获取麦位信息
- (void)getSeatInfo;
/// 是否在麦上
- (BOOL)isOnSeat;
/// 获取麦位信息，断网重连调用，包含unmute等操作
- (void)getSeatInfoWhenRejoinChatRoom;
/// 主播操作麦位
- (void)anchorOperationSeatItem:(NEListenTogetherSeatItem *)seatItem;
/// 观众操作麦位
- (void)audienceOperationSeatItem:(NEListenTogetherSeatItem *)seatItem;

/// 获取麦位上的成员
- (NEListenTogetherMember *_Nullable)getMemberOnTheSeat:(NEListenTogetherSeatItem *)seatItem;

@end

NS_ASSUME_NONNULL_END
