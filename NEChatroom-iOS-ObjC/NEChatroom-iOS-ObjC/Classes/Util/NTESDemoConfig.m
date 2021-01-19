//
//  NTESDemoConfig.m
//  NERtcAudioChatroom
//
//  Created by Simon Blue on 2019/1/16.
//  Copyright © 2019年 netease. All rights reserved.
//

#import "NTESDemoConfig.h"

//测试环境
NSString *const kAppKey = @"56813bdfbaa1c2a29bbea391ffbbe27a";
NSString *const kApiHost = @"https://yiyong-qa.netease.im/voicechat";
NSString *const kRtcAppKey = @"5887359c380d534ad99b33a07d8723e5";

//正式环境
//NSString *const kAppKey = @"";
//NSString *const kApiHost = @"";

@implementation NTESDemoConfig

+ (instancetype)sharedConfig
{
    static NTESDemoConfig *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NTESDemoConfig alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    if (self = [super init])
    {
        _appKey = kAppKey;
        _apiURL = kApiHost;
        _rtcAppKey = kRtcAppKey;
        
    }
    return self;
}

- (NSString *)appKey
{
    NSAssert((_appKey.length != 0), @"请填入APPKEY");
    return _appKey;
}

- (NSString *)apiURL
{
    NSAssert((_apiURL.length != 0), @"请填入APIURL");
    return _apiURL;
}

- (NSString *)rtcAppKey {
    NSAssert((_rtcAppKey.length != 0), @"请填入rtc的APPKEY");
    return _rtcAppKey;
}
@end
