//
//  NTESCustomNotificationHelper.h
//  NERtcAudioChatroom
//
//  Created by Simon Blue on 2019/1/25.
//  Copyright © 2019年 netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NTESCustomAttachment.h"

@class NTESMicInfo;
@class NTESAccountInfo;
NS_ASSUME_NONNULL_BEGIN

@interface NTESCustomNotificationHelper : NSObject

+ (void)sendRequestMicNotication:(NSString *)creater
                         micInfo:(NTESMicInfo *)micInfo
                     accountInfo:(NTESAccountInfo *)accountInfo;

/**
 发送 下麦 通知
 @param creater - 创建者ID
 @param micInfo - 麦位信息
 @param completion - 完成闭包
 */
+ (void)sendDropMicNotication:(NSString *)creater
                      micInfo:(NTESMicInfo *)micInfo
                   completion:(nullable NIMSystemNotificationHandler)completion;

+ (void)sendCancelMicNotication:(NSString *)creater
                        micInfo:(NTESMicInfo *)micInfo;

@end

@interface NTESChatroomMessageHelper : NSObject

+ (void)sendTextMessage:(NSString *)roomId text:(NSString *)text;

+ (void)sendSystemMessage:(NSString *)roomId text:(NSString *)text;

+ (NIMMessage *)systemMessageWithText:(NSString *)text;

+ (void)sendCustomMessage:(NSString *)roomId type:(NTESVoiceChatAttachmentType)type;

+ (void)sendCustomMessage:(NSString *)roomId type:(NTESVoiceChatAttachmentType)type operator:(nullable NSString *)operator error:(NSError * _Nullable *)error;

@end

@interface NTESChatroomInfoHelper : NSObject

+ (void)updateChatroom:(NIMChatroom *)chatroom anchorMicMuteStatus:(BOOL)micMute;

@end

NS_ASSUME_NONNULL_END
