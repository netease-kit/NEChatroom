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
#import "NTESPickSongModel.h"
#import "NTESAccountInfo.h"

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

+ (void)updateChatroomQueueWithRoomId:(NSString *)roomId
                              micInfo:(NTESMicInfo *)micInfo
                           complation:(void(^)(NSError * _Nullable))complation
{
    void(^updateQueueReq)(void) = ^(void) {
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
        NELPLogInfo(@"更新聊天室队列, dict: %@， thread: %@", dict, [NSThread currentThread]);
        [[NIMSDK sharedSDK].chatroomManager updateChatroomQueueObject:request completion:^(NSError * _Nullable error) {
            if (error) {
                NELPLogError(@"updateChatroomQueueObject error:%@", error);
            }
        }];
    };
    
    // 校验状态
    [[NIMSDK sharedSDK].chatroomManager fetchChatroomQueue:roomId
                                                completion:^(NSError * _Nullable error, NSArray<NSDictionary<NSString *,NSString *> *> * _Nullable info) {
        if (error) {
            if (complation) { complation(error); }
            return;
        }
        
        NSArray *mics = [self _micsWithQueueInfo:info];
        BOOL check = [self _checkMicWithMicList:mics destMic:micInfo];
        if (!check) {
            if (complation) {
                NSError *error = [NSError errorWithDomain:@"ntes.chttroom.updQueue" code:-1000 userInfo:@{ NSLocalizedDescriptionKey: @"麦位状态不允许当前操作" }];
                complation(error);
            }
            return;
        }
        
        updateQueueReq();
    }];
}

+ (nullable NSArray<NTESMicInfo *> *)_micsWithQueueInfo:(NSArray<NSDictionary<NSString *,NSString *> *> * _Nullable)info
{
    if (!info) { return nil; }
    
    NSMutableArray *res = [NSMutableArray array];
    for (NSDictionary *dic in info) {
        for (NSString *key in [dic allKeys]) {
            if ([key hasPrefix:@"music_"]) {
                continue;
            }
            NSString *obj = [dic objectForKey:key];
            if (obj && [obj isKindOfClass:[NSString class]]) {
                NTESMicInfo *micInfo = [NTESChatroomQueueHelper micInfoByChatroomQueueValue:obj];
                [res addObject:micInfo];
            }
        }
    }
    return [res copy];
}

+ (BOOL)_checkMicWithMicList:(nullable NSArray<NTESMicInfo *> *)micList destMic:(NTESMicInfo *)destMic
{
    if (!micList) { return NO; }
    NTESMicStatus destStatus = destMic.micStatus;

    for (NTESMicInfo *item in micList) {
        NTESMicStatus status = item.micStatus;
        if (item.userInfo
            && [item.userInfo isEqual:destMic.userInfo]
            && item.micOrder == destMic.micOrder
            && !(status == NTESMicStatusNone || status == NTESMicStatusClosed || status == NTESMicStatusMasked)) {
            return NO;
        }
        else if ([item.userInfo isEqual:destMic.userInfo]
                 && item.micOrder == destMic.micOrder
                 && ![self _checkMicStatusWithSource:status dest:destStatus]) {
            return NO;
        }
        else if ([item.userInfo isEqual:destMic.userInfo]
                   && item.micOrder != destMic.micOrder
                   && !(status == NTESMicStatusNone || status == NTESMicStatusClosed || status == NTESMicStatusMasked)) {
            return NO;
        }
    }
    return YES;
}

+ (BOOL)_checkMicStatusWithSource:(NTESMicStatus)source dest:(NTESMicStatus)dest
{
    if (source == NTESMicStatusNone || dest == NTESMicStatusNone) {
        return YES;
    }
    if (source == NTESMicStatusConnecting && (dest == NTESMicStatusConnectFinished || dest == NTESMicStatusClosed || dest == NTESMicStatusMasked)) {
        return YES;
    }

    if (source == NTESMicStatusConnectFinished && (dest == NTESMicStatusConnectFinishedWithMasked || dest == NTESMicStatusConnectFinishedWithMuted || dest == NTESMicStatusConnectFinishedWithMutedAndMasked)) {
        return YES;
    }

    if (source == NTESMicStatusMasked && (dest == NTESMicStatusConnecting || dest == NTESMicStatusConnectFinished || dest == NTESMicStatusConnectFinishedWithMasked || dest == NTESMicStatusConnectFinishedWithMuted || dest == NTESMicStatusConnectFinishedWithMutedAndMasked)) {
        return YES;
    }

    if (source == NTESMicStatusConnectFinishedWithMasked && (dest == NTESMicStatusConnectFinished || dest == NTESMicStatusConnectFinishedWithMuted || dest == NTESMicStatusConnectFinishedWithMutedAndMasked || dest == NTESMicStatusMasked)) {
        return YES;
    }

    if (source == NTESMicStatusConnectFinishedWithMuted && (dest == NTESMicStatusConnectFinished || dest == NTESMicStatusConnectFinishedWithMasked || dest == NTESMicStatusConnectFinishedWithMutedAndMasked)) {
        return YES;
    }

    if (source == NTESMicStatusConnectFinishedWithMutedAndMasked && (dest == NTESMicStatusConnectFinished || dest == NTESMicStatusConnectFinishedWithMasked || dest == NTESMicStatusConnectFinishedWithMuted || dest == NTESMicStatusMasked)) {
        return YES;
    }

    return NO;
}

+ (void)updateQueueWithRoomId:(NSString *)roomId
                         song:(NTESPickSongModel *)song
                 countTimeSec:(int32_t)countTimeSec
                       picker:(NTESAccountInfo *)picker
                   complation:(void(^)(NSError * _Nullable))complation
{
    NSString *key = nil;
    NSString *val = nil;
    [self _queueObjWithSong:song countTimeSec:countTimeSec picker:picker keyPtr:&key valPtr:&val];
    if (key == nil || val == nil) {
        if (complation) {
            NSString *msg = [NSString stringWithFormat:@"点歌失败, key: %@, val: %@", key ?: @"nil", val ?: @"nil"];
            NSError *err = [NSError errorWithDomain:@"NTESChatroomQueueHelper" code:-1000 userInfo:@{NSLocalizedDescriptionKey: msg}];
            complation(err);
        }
    }
    
    NIMChatroomQueueUpdateRequest *request = [[NIMChatroomQueueUpdateRequest alloc] init];
    request.key = key;
    request.value = val;
    request.roomId = roomId;
    request.transient = YES;
    
    [[NIMSDK sharedSDK].chatroomManager updateChatroomQueueObject:request completion:complation];
}

+ (nullable NTESQueueMusic *)songForQueueKey:(NSString *)key
                                       value:(NSString *)value
{
    if (![key hasPrefix:@"music_"]) {
        return nil;
    }
    NSDictionary *valueDic = [value jsonObject];
    if (!valueDic) {
        return nil;
    }
    return [NTESQueueMusic yy_modelWithDictionary:valueDic];
}

+ (void)removePickedMusic:(NTESQueueMusic *)music
                   roomId:(NSString *)roomId
               completion:(nullable NIMChatroomQueueRemoveHandler)completion
{
    NSString *key = [NSString stringWithFormat:@"music_%@_%@", music.musicId, music.userId];
    
    NIMChatroomQueueRemoveRequest *request = [[NIMChatroomQueueRemoveRequest alloc] init];
    request.key = key;
    request.roomId = roomId;
    
    [[NIMSDK sharedSDK].chatroomManager removeChatroomQueueObject:request completion:completion];
}

+ (void)updateQueueMusic:(NTESQueueMusic *)music
                  roomId:(NSString *)roomId
              completion:(void(^)(NSError * _Nullable))completion
{
    NSString *key = [NSString stringWithFormat:@"music_%@_%@", music.musicId, music.userId];
    NSString *val = [music yy_modelToJSONString];

    if (key == nil || val == nil) {
        if (completion) {
            NSString *msg = [NSString stringWithFormat:@"更新队列对象失败, key: %@, val: %@", key ?: @"nil", val ?: @"nil"];
            NSError *err = [NSError errorWithDomain:@"NTESChatroomQueueHelper" code:-1000 userInfo:@{NSLocalizedDescriptionKey: msg}];
            completion(err);
        }
        return;
    }
    
    NIMChatroomQueueUpdateRequest *request = [[NIMChatroomQueueUpdateRequest alloc] init];
    request.key = key;
    request.value = val;
    request.roomId = roomId;
    request.transient = YES;
    
    [[NIMSDK sharedSDK].chatroomManager updateChatroomQueueObject:request completion:completion];
}

#pragma mark - private method

/// 构造歌曲队列数据结构
+ (void)_queueObjWithSong:(NTESPickSongModel *)song
             countTimeSec:(int32_t)countTimeSec
                   picker:(NTESAccountInfo *)picker
                   keyPtr:(NSString * __nullable *)keyPtr
                   valPtr:(NSString * __nullable *)valPtr
{
    *keyPtr = [NSString stringWithFormat:@"music_%@_%@", song.sid, picker.account];
    NSDictionary *dict = @{
        @"musicId"      : song.sid ?: @"",
        @"userId"       : picker.account ?: @"",
        @"countTimeSec" : [NSString stringWithFormat:@"%d", countTimeSec],
        @"musicName"    : song.name ?: @"",
        @"musicAuthor"  : song.singer ?: @"",
        @"userNickname" : picker.nickName ?: @"",
        @"musicAvatar"  : song.avatar ?: @"",
        @"userAvatar"   : picker.icon ?: @"",
        @"musicLyricUrl": song.lyricUrl ?: @"",
        @"musicUrl"     : song.url ?: @"",
        @"musicDuriation": song.duration
    };
    *valPtr = [dict jsonBody];
}

@end
