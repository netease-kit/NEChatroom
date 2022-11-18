// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEUIBaseView.h"

NS_ASSUME_NONNULL_BEGIN

@protocol NEVoiceRoomHeaderDelegate <NSObject>

// 退出事件
- (void)headerExitAction;
////点击公告
//- (void)liveRoomHeaderClickNoticeAction;

@end

@interface NEVoiceRoomHeaderView : NEUIBaseView
// 事件回调
@property(nonatomic, weak) id<NEVoiceRoomHeaderDelegate> delegate;
// 在线人数
@property(nonatomic, assign) NSInteger onlinePeople;
// 直播间标题
@property(nonatomic, copy) NSString *title;

@end

NS_ASSUME_NONNULL_END
