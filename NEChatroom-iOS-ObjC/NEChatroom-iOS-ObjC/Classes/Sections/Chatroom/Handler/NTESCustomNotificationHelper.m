//
//  NTESCustomNotificationHelper.m
//  NERtcAudioChatroom
//
//  Created by Simon Blue on 2019/1/25.
//  Copyright © 2019年 netease. All rights reserved.
//

#import "NTESCustomNotificationHelper.h"
#import "NTESMicInfo.h"
#import "NTESAccountInfo.h"

#import "NTESChatroomDefine.h"
#import "NSDictionary+NTESJson.h"

@implementation NTESCustomNotificationHelper

+ (void)sendRequestMicNotication:(NSString *)creater
                         micInfo:(NTESMicInfo *)micInfo
                     accountInfo:(NTESAccountInfo *)accountInfo {
    
    NELPLogInfo(@"[demo] Send Request Mic Request Notication");
    
    NIMCustomSystemNotification *notification = [NTESCustomNotificationHelper notificationWithRequestConnect:micInfo
                                                                                                    accountInfo:accountInfo];
    NIMSession *session = [NIMSession session:creater
                                         type:NIMSessionTypeP2P];
    [[NIMSDK sharedSDK].systemNotificationManager sendCustomNotification:notification
                                                               toSession:session
                                                              completion:nil];
}

+ (void)sendDropMicNotication:(NSString *)creater
                      micInfo:(NTESMicInfo *)micInfo
                   completion:(nullable NIMSystemNotificationHandler)completion
{
    NELPLogInfo(@"[demo] Send Drop Mic Request Notication");
    
    NIMCustomSystemNotification *notification = [NTESCustomNotificationHelper notificationWithDropMic:micInfo];
    NIMSession *session = [NIMSession session:creater
                                         type:NIMSessionTypeP2P];
    [[NIMSDK sharedSDK].systemNotificationManager sendCustomNotification:notification
                                                               toSession:session
                                                              completion:completion];
}


+ (void)sendCancelMicNotication:(NSString *)creater
                        micInfo:(NTESMicInfo *)micInfo {
    
    NELPLogInfo(@"[demo] Send Cancel Mic Request Notication");
    
    NIMCustomSystemNotification *notification = [NTESCustomNotificationHelper notificationWithCancelConnect:micInfo];
    NIMSession *session = [NIMSession session:creater
                                         type:NIMSessionTypeP2P];
    [[NIMSDK sharedSDK].systemNotificationManager sendCustomNotification:notification
                                                               toSession:session
                                                              completion:nil];
}

#pragma mark - Notication
+ (NIMCustomSystemNotification *)notificationWithRequestConnect:(NTESMicInfo *)micInfo
                                                    accountInfo:(NTESAccountInfo *)accountInfo
{
    NSString *content = [@{
                           @"command":@(NTESChatroomCustomNotificationTypeRequestConnect),
                           @"index" : @(micInfo.micOrder - 1),
                           @"nick":(accountInfo.nickName ?: @""),
                           @"avatar":(accountInfo.icon ?: @"")
                           } jsonBody];
    NIMCustomSystemNotification *notification = [[NIMCustomSystemNotification alloc] initWithContent:content];
    notification.sendToOnlineUsersOnly = NO;
    return notification;
}

+ (NIMCustomSystemNotification *)notificationWithDropMic:(NTESMicInfo *)micInfo
{
    NSString *content = [@{
                           @"command":@(NTESChatroomCustomNotificationTypeDropMic),
                           @"index" : @(micInfo.micOrder - 1)
                           } jsonBody];
    NIMCustomSystemNotification *notification = [[NIMCustomSystemNotification alloc] initWithContent:content];
    notification.sendToOnlineUsersOnly = NO;
    return notification;
}

+ (NIMCustomSystemNotification *)notificationWithCancelConnect:(NTESMicInfo *)micInfo
{
    NSString *content = [@{
                           @"command":@(NTESChatroomCustomNotificationTypeCancelConnect),
                           @"index" : @(micInfo.micOrder - 1)
                           } jsonBody];
    NIMCustomSystemNotification *notification = [[NIMCustomSystemNotification alloc] initWithContent:content];
    notification.sendToOnlineUsersOnly = NO;
    return notification;
}


@end


@implementation NTESChatroomMessageHelper

+ (void)sendTextMessage:(NSString *)roomId text:(NSString *)text {
    NELPLogInfo(@"[demo] Send Text Message: %@", text);
    NIMMessage *textMessage = [[NIMMessage alloc] init];
    textMessage.text = text;
    NIMSession *session = [NIMSession session:roomId type:NIMSessionTypeChatroom];
    [[NIMSDK sharedSDK].chatManager sendMessage:textMessage toSession:session error:nil];
}

+ (void)sendSystemMessage:(NSString *)roomId text:(NSString *)text {
    NELPLogInfo(@"[demo] Send System Message: %@", text);
    NIMMessage *textMessage = [self systemMessageWithText:text];
    NIMSession *session = [NIMSession session:roomId type:NIMSessionTypeChatroom];
    [[NIMSDK sharedSDK].chatManager sendMessage:textMessage toSession:session error:nil];
}

+ (NIMMessage *)systemMessageWithText:(NSString *)text {
    NIMMessage *textMessage = [[NIMMessage alloc] init];
    textMessage.text = text;
    textMessage.remoteExt = @{@"type":@(1)};
    return textMessage;
}

+ (void)sendCustomMessage:(NSString *)roomId type:(NTESVoiceChatAttachmentType)type {
    [self sendCustomMessage:roomId type:type operator:nil error:nil];
}

+ (void)sendCustomMessage:(NSString *)roomId type:(NTESVoiceChatAttachmentType)type operator:(nullable NSString *)operator error:(NSError * _Nullable __autoreleasing * _Nullable)error {
    NIMSession *session = [NIMSession session:roomId type:NIMSessionTypeChatroom];
    NIMMessage *message = [[NIMMessage alloc] init];
    NTESCustomAttachment *attachment = [[NTESCustomAttachment alloc] init];
    attachment.type = type;
    attachment.operator = operator;
    NIMCustomObject *object = [[NIMCustomObject alloc] init];
    object.attachment = attachment;
    message.messageObject = object;
    [[NIMSDK sharedSDK].chatManager sendMessage:message toSession:session error:error];
}

@end

@implementation NTESChatroomInfoHelper

+ (void)updateChatroom:(NIMChatroom *)chatroom anchorMicMuteStatus:(BOOL)micMute {
    
    NSDictionary *dic = @{@"anchorMute": micMute ? @(1) : @(0)};
    NSString *dicStr = [dic jsonBody];
    NIMChatroomUpdateRequest *request = [[NIMChatroomUpdateRequest alloc] init];
    request.roomId = chatroom.roomId;
    request.updateInfo = @{
                           @(NIMChatroomUpdateTagExt) : dicStr,
                           };
    request.needNotify = YES;
    request.notifyExt = dicStr;
    [[NIMSDK sharedSDK].chatroomManager updateChatroomInfo:request
                                                completion:^(NSError * _Nullable error) {
        if (error) {
            NELPLogError(@"[demo] updateChatroomInfo error: %@", error);
        }
    }];
}

@end
