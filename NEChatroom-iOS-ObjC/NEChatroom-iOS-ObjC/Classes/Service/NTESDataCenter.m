//
//  NTESDataCenter.m
//  NERtcAudioChatroom
//
//  Created by Netease on 2019/3/6.
//  Copyright © 2019年 netease. All rights reserved.
//

#import "NTESDataCenter.h"

@implementation NTESDataCenter

- (instancetype)init {
    if (self = [super init]) {
        _myAccount = [self accountInfoFromLocation];
        _myCreateChatroom = [self chatroomInfoFromLocation];
    }
    return self;
}

+ (instancetype)shareCenter {
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NTESDataCenter alloc] init];
    });
    return instance;
}

- (void)setMyAccount:(NTESAccountInfo *)myAccount {
    _myAccount = myAccount;
    [self saveAccountToLocation:myAccount];
}

- (void)setMyCreateChatroom:(NTESChatroomInfo *)myCreateChatroom {
    _myCreateChatroom = myCreateChatroom;
    [self saveChatroomToLocation:myCreateChatroom];
}

- (void)saveAccountToLocation:(NTESAccountInfo *)info {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    if (info) {
        NSData *infoData = [NSKeyedArchiver archivedDataWithRootObject:info];
        [userDefault setObject:infoData forKey:@"kAccountInfo"];
    } else {
        [userDefault removeObjectForKey:@"kAccountInfo"];
    }
}

- (NTESAccountInfo *)accountInfoFromLocation {
    NTESAccountInfo *ret = nil;
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSData *infoData = [userDefault objectForKey:@"kAccountInfo"];
    if (infoData) {
        ret = [NSKeyedUnarchiver unarchiveObjectWithData:infoData];
    }
    return ret;
}

- (void)saveChatroomToLocation:(NTESChatroomInfo *)info {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    if (!info) {
        [userDefault removeObjectForKey:@"kChatroomInfo"];
    } else {
        NSData *infoData = [NSKeyedArchiver archivedDataWithRootObject:info];
        [userDefault setObject:infoData forKey:@"kChatroomInfo"];
    }
}

- (NTESChatroomInfo *)chatroomInfoFromLocation {
    NTESChatroomInfo *ret = nil;
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSData *infoData = [userDefault objectForKey:@"kChatroomInfo"];
    if (infoData) {
        ret = [NSKeyedUnarchiver unarchiveObjectWithData:infoData];
        if (![ret valid]) { //失效了
            [self saveChatroomToLocation:nil];
        }
    }
    return ret;
}

@end
