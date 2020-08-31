//
//  NTESDemoConfig.m
//  NERtcAudioChatroom
//
//  Created by Simon Blue on 2019/1/16.
//  Copyright © 2019年 netease. All rights reserved.
//

#import "NTESDemoConfig.h"

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
        _appKey = @"";
        _apiURL = @"";
        _rtcAppKey = @"";
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

- (NSString *)rtcAppKey
{
    NSAssert((_rtcAppKey.length != 0), @"请填入RTCAPPKEY");
    return _rtcAppKey;
}

- (NSString *)cerName
{
    return nil;
}

@end
