//
//  NTESChatroomHandler.h
//  NERtcAudioChatroom
//
//  Created by Simon Blue on 2019/1/25.
//  Copyright © 2019年 netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class NTESMicInfo;

@protocol NTESChatroomNotificationHandlerDelegate <NSObject>

- (void)didReceiveRequestConnect:(NTESMicInfo *)micInfo;
- (void)didReceiveMicBeDropped:(NTESMicInfo *)micInfo;
- (void)didReceiveConnectBeCanceled:(NTESMicInfo *)micInfo;

/**
 麦位变化代理方法
 @param key         - 变化麦位键名
 @param value       - 变化麦位键值
 @param changeType  - 麦位变化类型
 */
- (void)didUpdateChatroomQueueWithMicInfokey:(NSString *)key
                                micInfoValue:(NSString *)value
                                  changeType:(NIMChatroomQueueChangeType)changeType;

- (void)didChatroomMember:(NIMChatroomNotificationMember *)member enter:(BOOL)enter;
- (void)didChatroomMember:(NIMChatroomNotificationMember *)member mute:(BOOL)mute;
- (void)didChatroomMute:(BOOL)mute;
- (void)didChatroomClosed;
- (void)didChatroomAnchorMicMute:(BOOL)micMute;
- (void)didChatroomEnter;

- (void)didShowMessages:(NSArray<NIMMessage *> *)messages;
//接收发送的自定义消息
- (void)didReceiveCustomMessage:(NIMMessage *)customMessage;

@end

@interface NTESChatroomNotificationHandler : NSObject <NIMSystemNotificationManagerDelegate, NIMChatManagerDelegate, NIMChatroomManagerDelegate>

@property (nonatomic, copy) NSString *roomId;

- (instancetype)initWithDelegate:(id<NTESChatroomNotificationHandlerDelegate>)delegate;

- (void)dealWithCustomNotification:(NIMCustomSystemNotification *)notification;
- (void)dealWithNotificationMessage:(NIMMessage *)message;

@end

NS_ASSUME_NONNULL_END
