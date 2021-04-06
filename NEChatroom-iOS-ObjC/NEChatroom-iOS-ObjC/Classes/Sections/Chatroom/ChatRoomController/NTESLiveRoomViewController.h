//
//  NTESLiveRoomViewController.h
//  NEChatroom-iOS-ObjC
//
//  Created by vvj on 2021/2/4.
//  Copyright © 2021 netease. All rights reserved.
//

#import "NTESBaseViewController.h"
#import "NTESChatroomDefine.h"

NS_ASSUME_NONNULL_BEGIN
@class NTESChatroomInfo,NTESAccountInfo;

@interface NTESLiveRoomViewController : NTESBaseViewController


/// 初始化方法
/// @param chatroomInfo 房间信息
/// @param accountInfo 账号信息
/// @param userMode 角色类型
/// @param pushType 流模式
/// @param roomType 房间类型
 - (instancetype)initWithChatroomInfo:(NTESChatroomInfo *)chatroomInfo
                          accountInfo:(NTESAccountInfo *)accountInfo
                             userMode:(NTESUserMode)userMode
                             pushType:(NTESPushType)pushType
                             roomType:(NTESCreateRoomType)roomType;


@end

NS_ASSUME_NONNULL_END
