//
//  NTESChatroomQueueHelper.m
//  NERtcAudioChatroom
//
//  Created by Simon Blue on 2019/1/29.
//  Copyright © 2019年 netease. All rights reserved.
//

#import "NTESChatroomQueueHelper.h"
#import "NTESMicInfo.h"
#import "NSString+NTES.h"
#import "NSDictionary+NTESJson.h"

@implementation NTESChatroomQueueHelper

+ (NTESMicInfo *)micInfoByChatroomQueueValue:(NSString *)value
{
    NSDictionary *valueDic = [value jsonObject];
    NSInteger index =  [[valueDic objectForKey:NTESMicInfoKeyIndex] integerValue];
    
    NTESMicStatus status = (NTESMicStatus)[[valueDic objectForKey:NTESMicInfoKeyStatus] integerValue];
    NTESMicReason reason = (NTESMicReason)[[valueDic objectForKey:NTESMicInfoKeyReason] integerValue];
    NSDictionary *userDic = [valueDic objectForKey:NTESMicInfoKeyMember];
    NSString *account = [userDic objectForKey:NTESMicInfoKeyAccount];
    NSString *nickName = [userDic objectForKey:NTESMicInfoKeyNick];
    NSString *icon = [userDic objectForKey:NTESMicInfoKeyAvatar];
    
    BOOL micMute = YES;
    id micMuteNum = [valueDic objectForKey:NTESMicInfoKeyMicMute];
    if (micMuteNum) {
        micMute = [micMuteNum boolValue];
    }
    
    NTESMicInfo *micInfo = [[NTESMicInfo alloc] init];
    micInfo.micOrder = index + 1;
    micInfo.micStatus = status;
    micInfo.micReason = reason;
    micInfo.isMicMute = micMute;
    
    NTESUserInfo *userInfo = [[NTESUserInfo alloc] init];
    userInfo.account = account;
    userInfo.nickName = nickName;
    userInfo.icon = icon;
    micInfo.userInfo = userInfo;
    
    return micInfo;
}

+ (BOOL)checkMicEmptyWithMicInfo:(NTESMicInfo *)micInfo
{
    return (micInfo.micStatus == NTESMicStatusNone || micInfo.micStatus == NTESMicStatusClosed || micInfo.micStatus == NTESMicStatusMasked);
}

+ (void)updateChatroomQueueWithRoomId:(NSString *)roomId micInfo:(NTESMicInfo *)micInfo {
    NIMChatroomQueueUpdateRequest *request = [[NIMChatroomQueueUpdateRequest alloc] init];
    request.key = [NSString stringWithFormat:@"queue_%d",(int)micInfo.micOrder - 1];
    NSDictionary *dict = @{
                           NTESMicInfoKeyStatus : @(micInfo.micStatus),
                           NTESMicInfoKeyIndex : @(micInfo.micOrder - 1),
                           NTESMicInfoKeyReason : @(micInfo.micReason),
                           NTESMicInfoKeyMember : @{
                                   NTESMicInfoKeyAccount:micInfo.userInfo.account ? : @"",
                                   NTESMicInfoKeyNick:micInfo.userInfo.nickName ? : @"",
                                   NTESMicInfoKeyAvatar:micInfo.userInfo.icon ? : @"",
                                   },
                           NTESMicInfoKeyMicMute: @(micInfo.isMicMute)
                           };
    request.value = [dict jsonBody];
    request.roomId = roomId;
    
    //更新聊天室队列
    NELPLogInfo(@"[demo] updateChatroomQueue.");
    [[NIMSDK sharedSDK].chatroomManager updateChatroomQueueObject:request completion:^(NSError * _Nullable error) {
        if (error) {
            NELPLogError(@"updateChatroomQueueObject error:%@", error);
        }
    }];
}

@end
