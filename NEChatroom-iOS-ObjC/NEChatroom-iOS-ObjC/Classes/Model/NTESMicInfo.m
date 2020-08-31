//
//  NTESMicInfo.m
//  NERtcAudioChatroom
//
//  Created by Simon Blue on 2019/1/23.
//  Copyright © 2019年 netease. All rights reserved.
//

#import "NTESMicInfo.h"
#import "NTESAccountInfo.h"

@implementation NTESMicInfo

- (instancetype)init {
    if (self = [super init]) {
        _isMicMute = YES;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    NTESMicInfo *ret = [[[self class] allocWithZone:zone] init];
    ret.micOrder = _micOrder;
    ret.micStatus = _micStatus;
    ret.micReason = _micReason;
    ret.userInfo = [_userInfo copy];
    return ret;
}

- (BOOL)isOnMicStatus {
    return (_micStatus == NTESMicStatusConnectFinished
            || _micStatus == NTESMicStatusConnectFinishedWithMasked
            || _micStatus == NTESMicStatusConnectFinishedWithMuted
            || _micStatus == NTESMicStatusConnectFinishedWithMutedAndMasked);
}

- (BOOL)isOffMicStatus {
    return (_micStatus == NTESMicStatusNone
            || _micStatus == NTESMicStatusClosed
            || _micStatus == NTESMicStatusMasked);
}

- (NSString *)description {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"micOrder"] = @(_micOrder);
    dic[@"micStatus"] = @(_micStatus);
    dic[@"micReason"] = @(_micReason);
    dic[@"userInfo.account"] = _userInfo.account ?: @"";
    dic[@"userInfo.nickName"] = _userInfo.nickName ?: @"";
    dic[@"userInfo.sid"] = _userInfo.sid ?: @"";
    return [dic description];
}

@end
