//
//  NTESChatroomDefine.h
//  NERtcAudioChatroom
//
//  Created by Simon Blue on 2019/1/25.
//  Copyright © 2019年 netease. All rights reserved.
//

#ifndef NTESChatroomDefine_h
#define NTESChatroomDefine_h

#define kNTESChatroomPauseMusicNotification @"kNTESChatroomPauseMusicNotification"
#define kNTESChatroomResumeMusicNotification @"kNTESChatroomResumeMusicNotification"
#define kNTESChatroomPauseMusicOperatorUserInfoKey @"kNTESChatroomPauseMusicOperatorUserInfoKey"
#define kNTESChatroomResumeMusicOperatorUserInfoKey @"kNTESChatroomResumeMusicOperatorUserInfoKey"


typedef NS_ENUM(NSInteger,NTESChatroomCustomNotificationType)
{
    NTESChatroomCustomNotificationTypeRequestConnect = 1,    //申请连麦
    NTESChatroomCustomNotificationTypeDropMic  = 2,    //连麦者主动下麦
    NTESChatroomCustomNotificationTypeCancelConnect = 3, //取消申请连麦
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



#endif /*NTESChatroomDefine_h */
