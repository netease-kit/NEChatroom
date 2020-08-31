//
//  NTESCustomNotificationHelper.h
//  NERtcAudioChatroom
//
//  Created by Simon Blue on 2019/1/25.
//  Copyright © 2019年 netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NTESMicInfo;
@class NTESAccountInfo;
NS_ASSUME_NONNULL_BEGIN

@interface NTESCustomNotificationHelper : NSObject

+ (void)sendRequestMicNotication:(NSString *)creater
                         micInfo:(NTESMicInfo *)micInfo
                     accountInfo:(NTESAccountInfo *)accountInfo;

+ (void)sendDropMicNotication:(NSString *)creater
                      micInfo:(NTESMicInfo *)micInfo;

+ (void)sendCancelMicNotication:(NSString *)creater
                        micInfo:(NTESMicInfo *)micInfo;

@end

@interface NTESChatroomMessageHelper : NSObject

+ (void)sendTextMessage:(NSString *)roomId text:(NSString *)text;

+ (void)sendSystemMessage:(NSString *)roomId text:(NSString *)text;

+ (NIMMessage *)systemMessageWithText:(NSString *)text;

@end

@interface NTESChatroomInfoHelper : NSObject

+ (void)updateChatroom:(NIMChatroom *)chatroom anchorMicMuteStatus:(BOOL)micMute;

@end

NS_ASSUME_NONNULL_END
