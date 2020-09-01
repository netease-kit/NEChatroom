//
//  NTESChatroomHandler.m
//  NERtcAudioChatroom
//
//  Created by Simon Blue on 2019/1/25.
//  Copyright © 2019年 netease. All rights reserved.
//

#import "NTESChatroomNotificationHandler.h"
#import "NSDictionary+NTESJson.h"
#import "NSString+NTES.h"
#import "NTESChatroomDefine.h"
#import "NTESMicInfo.h"

@interface NTESChatroomNotificationHandler ()

@property (nonatomic, weak)id<NTESChatroomNotificationHandlerDelegate> delegate;

@end


@implementation NTESChatroomNotificationHandler

- (instancetype)initWithDelegate:(id<NTESChatroomNotificationHandlerDelegate>)delegate
{
    if (self = [super init]) {
        _delegate = delegate;
    }
    return self;
}

- (void)dealWithCustomNotification:(NIMCustomSystemNotification *)notification
{
    NSString *content  = notification.content;
    NSDictionary *dict = [content jsonObject];
    NTESChatroomCustomNotificationType type = [dict jsonInteger:@"command"];
    NTESMicInfo *micInfo = [[NTESMicInfo alloc] init];
    NTESUserInfo *userInfo = [[NTESUserInfo alloc] init];
    micInfo.userInfo = userInfo;
    
    micInfo.micOrder = [[dict objectForKey:@"index"] integerValue] + 1;
    micInfo.userInfo.account = notification.sender;
    micInfo.userInfo.nickName = [dict objectForKey:@"nick"];
    micInfo.userInfo.icon = [dict objectForKey:@"avatar"];

    switch (type) {
        case NTESChatroomCustomNotificationTypeRequestConnect:
        {
            if (self.delegate && [self.delegate respondsToSelector:@selector(didReceiveRequestConnect:)]) {
                [self.delegate didReceiveRequestConnect:micInfo];
            }
        }
            break;
        case NTESChatroomCustomNotificationTypeDropMic:
        {
            if (self.delegate && [self.delegate respondsToSelector:@selector(didReceiveMicBeDropped:)]) {
                [self.delegate didReceiveMicBeDropped:micInfo];
            }
        }
            break;
        case NTESChatroomCustomNotificationTypeCancelConnect:
        {
            if (self.delegate && [self.delegate respondsToSelector:@selector(didReceiveConnectBeCanceled:)]) {
                [self.delegate didReceiveConnectBeCanceled:micInfo];
            }
        }
            break;
        default:
            break;
    }
}

- (void)dealWithNotificationMessage:(NIMMessage *)message
{
    NIMNotificationObject *object = (NIMNotificationObject *)message.messageObject;
    switch (object.notificationType) {
        case NIMNotificationTypeChatroom:{
            NIMChatroomNotificationContent *content = (NIMChatroomNotificationContent *)object.content;
            if (content.eventType == NIMChatroomEventTypeQueueChange)
            {
                NSDictionary *dict = content.ext;
                NSString *key = [dict objectForKey:NIMChatroomEventInfoQueueChangeItemKey];
                NSString *value = [dict objectForKey:NIMChatroomEventInfoQueueChangeItemValueKey];
                if (_delegate && [_delegate respondsToSelector:@selector(didUpdateChatroomQueueWithMicInfokey:micInfoValue:)]) {
                    [self.delegate didUpdateChatroomQueueWithMicInfokey:key micInfoValue:value];
                }
            }
            else if (content.eventType == NIMChatroomEventTypeEnter) { //进入聊天室
                NIMChatroomNotificationMember *member = content.source;
                if (_delegate && [_delegate respondsToSelector:@selector(didChatroomMember:enter:)]) {
                    [_delegate didChatroomMember:member enter:YES];
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:kChatroomUserEnter object:member];
            }
            else if (content.eventType == NIMChatroomEventTypeExit) { //离开聊天室
                NIMChatroomNotificationMember *member = content.source;
                if (_delegate && [_delegate respondsToSelector:@selector(didChatroomMember:enter:)]) {
                    [_delegate didChatroomMember:member enter:NO];
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:kChatroomUserLeave object:member];
            }
            else if (content.eventType == NIMChatroomEventTypeAddMuteTemporarily) { //禁言
                NIMChatroomNotificationMember *member = [content.targets lastObject];
                if (_delegate && [_delegate respondsToSelector:@selector(didChatroomMember:mute:)]) {
                    [_delegate didChatroomMember:member mute:YES];
                }
            }
            else if (content.eventType == NIMChatroomEventTypeRemoveMuteTemporarily) { //取消禁言
                NIMChatroomNotificationMember *member = [content.targets lastObject];
                if (_delegate && [_delegate respondsToSelector:@selector(didChatroomMember:mute:)]) {
                    [_delegate didChatroomMember:member mute:NO];
                }
            }
            else if (content.eventType == NIMChatroomEventTypeRoomMuted) { //聊天室被禁言
                if (_delegate && [_delegate respondsToSelector:@selector(didChatroomMute:)]) {
                    [_delegate didChatroomMute:YES];
                }
            }
            else if (content.eventType == NIMChatroomEventTypeRoomUnMuted) { //聊天室不在禁言状态
                if (_delegate && [_delegate respondsToSelector:@selector(didChatroomMute:)]) {
                    [_delegate didChatroomMute:NO];
                }
            }
            else if (content.eventType == NIMChatroomEventTypeClosed) { //聊天室被关闭
                if (_delegate && [_delegate respondsToSelector:@selector(didChatroomClosed)]) {
                    [_delegate didChatroomClosed];
                }
            } else if (content.eventType == NIMChatroomEventTypeInfoUpdated) {
                NSString *ext = content.notifyExt;
                NSDictionary *dict = [ext jsonObject];
                NSInteger anchorMicMuteInt = dict ? [dict[@"anchorMute"] boolValue] : 0;
                BOOL anchorMicMute = (anchorMicMuteInt ==  1 ? YES : NO);
                if (_delegate && [_delegate respondsToSelector:@selector(didChatroomAnchorMicMute:)]) {
                    [_delegate didChatroomAnchorMicMute:anchorMicMute];
                }
            }
        }
            break;
        default:
            break;
    }
}

#pragma mark - NIMSystemNotificationManagerDelegate
- (void)onReceiveCustomSystemNotification:(NIMCustomSystemNotification *)notification {
    [self dealWithCustomNotification:notification];
}

#pragma mark - NIMChatManagerDelegate
- (void)willSendMessage:(NIMMessage *)message
{
    switch (message.messageType) {
        case NIMMessageTypeText:
            if (_delegate && [_delegate respondsToSelector:@selector(didShowMessages:)]) {
                [_delegate didShowMessages:@[message]];
            }
            break;
        default:
            break;
    }
}

- (void)onRecvMessages:(NSArray *)messages
{
    for (NIMMessage *message in messages) {
        if (![message.session.sessionId isEqualToString:_roomId]
            && message.session.sessionType == NIMSessionTypeChatroom) {
            //不属于这个聊天室的消息
            return;
        }
        switch (message.messageType) {
            case NIMMessageTypeText:
                if (_delegate && [_delegate respondsToSelector:@selector(didShowMessages:)]) {
                    [_delegate didShowMessages:@[message]];
                }
                break;
            case NIMMessageTypeCustom:
            {
                break;
            }
            case NIMMessageTypeNotification:{
                [self dealWithNotificationMessage:message];
            }
                break;
            default:
                break;
        }
    }
}

- (void)chatroomBeKicked:(NIMChatroomBeKickedResult *)result {
    if (![result.roomId isEqualToString:_roomId]) {
        return;
    }
    if (result.reason == NIMChatroomKickReasonInvalidRoom) {
        if (_delegate && [_delegate respondsToSelector:@selector(didChatroomClosed)]) {
            [_delegate didChatroomClosed];
        }
    }
}

@end
