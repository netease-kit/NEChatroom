//
//  NTESDemoSystemManager.m
//  NERtcAudioChatroom
//
//  Created by Netease on 2019/3/13.
//  Copyright © 2019年 netease. All rights reserved.
//

#import "NTESDemoSystemManager.h"

@interface NTESDemoSystemManager ()
@property (nonatomic, strong) Reachability *reachability;
@end

@implementation NTESDemoSystemManager

+ (instancetype)shareInstance {
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NTESDemoSystemManager alloc] init];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        NSString *remoteHostName = @"www.baidu.com";
        _reachability = [Reachability reachabilityWithHostname:remoteHostName];
        [_reachability startNotifier];
    }
    return self;
}

- (void)start {}

- (NetworkStatus)netStatus {
    return [_reachability currentReachabilityStatus];
}

@end
