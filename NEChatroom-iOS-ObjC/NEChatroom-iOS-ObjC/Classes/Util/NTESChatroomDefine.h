//
//  NTESChatroomDefine.h
//  NERtcAudioChatroom
//
//  Created by Simon Blue on 2019/1/25.
//  Copyright © 2019年 netease. All rights reserved.
//

#ifndef NTESChatroomDefine_h
#define NTESChatroomDefine_h

typedef NS_ENUM(NSInteger,NTESChatroomCustomNotificationType)
{
    NTESChatroomCustomNotificationTypeRequestConnect = 1,    //申请连麦
    NTESChatroomCustomNotificationTypeDropMic  = 2,    //连麦者主动下麦
    NTESChatroomCustomNotificationTypeCancelConnect = 3, //取消申请连麦
};

typedef NS_ENUM(NSUInteger, NTESUserMode) {
    //主播
    NTESUserModeAnchor = 0,
    //观众
    NTESUserModeAudience = 1,
    //连麦者
    NTESUserModeConnector = 2,
};

typedef NS_ENUM(NSUInteger, NTESActionType)
{
    NTESActionTypeExit,
    NTESActionTypeSoundMute,
    NTESActionTypeMicMute,
    NTESActionTypeNoSpeaking,
    NTESActionTypeDropMic,
    NTESActionTypeSetting,
};

typedef NS_ENUM(NSUInteger, NTESPushType)
{
    NTESPushTypeCdn = 0,//cdn方案
    NTESPushTypeRtc,//rtc方案

};

#endif /*NTESChatroomDefine_h */
