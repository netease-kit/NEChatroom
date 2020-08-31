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

- (void)didUpdateChatroomQueueWithMicInfokey:(NSString *)key micInfoValue:(NSString *)value;
- (void)didChatroomMember:(NIMChatroomNotificationMember *)member enter:(BOOL)enter;
- (void)didChatroomMember:(NIMChatroomNotificationMember *)member mute:(BOOL)mute;
- (void)didChatroomMute:(BOOL)mute;
- (void)didChatroomClosed;
- (void)didChatroomAnchorMicMute:(BOOL)micMute;

- (void)didShowMessages:(NSArray<NIMMessage *> *)messages;

@end

@interface NTESChatroomNotificationHandler : NSObject <NIMSystemNotificationManagerDelegate, NIMChatManagerDelegate, NIMChatroomManagerDelegate>

@property (nonatomic, copy) NSString *roomId;

- (instancetype)initWithDelegate:(id<NTESChatroomNotificationHandlerDelegate>)delegate;

- (void)dealWithCustomNotification:(NIMCustomSystemNotification *)notification;
- (void)dealWithNotificationMessage:(NIMMessage *)message;

@end

NS_ASSUME_NONNULL_END
