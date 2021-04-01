//
//  NTESUserInfo.m
//  NERtcAudioChatroom
//
//  Created by Simon Blue on 2019/1/23.
//  Copyright © 2019年 netease. All rights reserved.
//

#import "NTESUserInfo.h"


@implementation NTESUserInfo

- (id)copyWithZone:(NSZone *)zone {
    NTESUserInfo *ret = [[[self class] allocWithZone:zone] init];
    ret.account = _account;
    ret.nickName = _nickName;
    ret.icon = _icon;
    ret.sid = _sid;
    return ret;
}

- (instancetype)initWithAccountInfo:(NTESAccountInfo *)accountInfo {
    if (self = [super init]) {
        _account = accountInfo.account;
        _nickName = accountInfo.nickName;
        _icon = accountInfo.icon;
        _sid = accountInfo.sid;
    }
    return self;
}

- (int64_t)uid {
    if ([_account hasPrefix:@"user"]) {
        return [[_account substringFromIndex:4] longLongValue];
    }
    return [_account longLongValue];
}

- (BOOL)isEqual:(id)object
{
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[NTESUserInfo class]]) {
        return NO;
    }
    
    return [self _isEqualToUserInfo:(NTESUserInfo *)object];
}

- (BOOL)_isEqualToUserInfo:(nullable NTESUserInfo *)userInfo
{
    if (!userInfo) {
        return NO;
    }
    return [_account isEqualToString:userInfo.account] && [_nickName isEqualToString:userInfo.nickName] && [_icon isEqualToString:userInfo.icon] && [_sid isEqualToString:userInfo.sid];
}

@end
