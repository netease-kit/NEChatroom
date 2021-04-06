//
//  NTESLiveRoomHeaderView.h
//  NEChatroom-iOS-ObjC
//
//  Created by vvj on 2021/2/4.
//  Copyright © 2021 netease. All rights reserved.
//

#import "NTESBaseView.h"

NS_ASSUME_NONNULL_BEGIN

@class NTESChatroomInfo,NTESAccountInfo;
@protocol NTESLiveRoomHeaderDelegate <NSObject>

//退出事件
- (void)liveRoomHeaderDidReceiveExitAction;
////点击公告
//- (void)liveRoomHeaderClickNoticeAction;

@end

@interface NTESLiveRoomHeaderView : NTESBaseView
//事件回调
@property (nonatomic, weak) id <NTESLiveRoomHeaderDelegate> delegate;
//房间信息
@property (nonatomic, weak) NTESChatroomInfo *chatroomInfo;
//用户信息
@property (nonatomic, weak) NTESAccountInfo *accountInfo;


@end

NS_ASSUME_NONNULL_END
