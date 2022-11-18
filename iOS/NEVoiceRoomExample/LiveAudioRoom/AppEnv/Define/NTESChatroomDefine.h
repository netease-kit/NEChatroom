// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#ifndef NTESChatroomDefine_h
#define NTESChatroomDefine_h

#define kNTESChatroomPauseMusicNotification @"kNTESChatroomPauseMusicNotification"
#define kNTESChatroomResumeMusicNotification @"kNTESChatroomResumeMusicNotification"
#define kNTESChatroomPauseMusicOperatorUserInfoKey @"kNTESChatroomPauseMusicOperatorUserInfoKey"
#define kNTESChatroomResumeMusicOperatorUserInfoKey @"kNTESChatroomResumeMusicOperatorUserInfoKey"

typedef NS_ENUM(NSInteger, NTESChatroomCustomNotificationType) {
  NTESChatroomCustomNotificationTypeRequestConnect = 1,  // 申请连麦
  NTESChatroomCustomNotificationTypeDropMic = 2,         // 连麦者主动下麦
  NTESChatroomCustomNotificationTypeCancelConnect = 3,   // 取消申请连麦
};

typedef NS_ENUM(NSUInteger, NTESActionType) {
  NTESActionTypeExit,
  NTESActionTypeSoundMute,
  NTESActionTypeMicMute,
  NTESActionTypeNoSpeaking,
  NTESActionTypeDropMic,
  NTESActionTypeSetting,
};

#endif /*NTESChatroomDefine_h */
