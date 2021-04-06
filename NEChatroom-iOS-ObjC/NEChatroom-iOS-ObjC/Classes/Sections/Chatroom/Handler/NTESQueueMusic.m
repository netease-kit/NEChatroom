//
//  NTESQueueMusic.m
//  NEChatroom-iOS-ObjC
//
//  Created by Think on 2021/2/3.
//  Copyright © 2021 netease. All rights reserved.
//

#import "NTESQueueMusic.h"

@implementation NTESQueueMusic

- (BOOL)isEqualToMusic:(NTESQueueMusic *)music
{
    return [_musicId isEqualToString:music.musicId] && [_userId isEqualToString:music.userId];
}

- (id)copyWithZone:(NSZone *)zone
{
    NTESQueueMusic *res = [[NTESQueueMusic alloc] init];
    res.musicId = _musicId;
    res.countTimeSec = _countTimeSec;
    res.musicName = _musicName;
    res.musicAuthor = _musicAuthor;
    res.musicAvatar = _musicAvatar;
    res.musicLyricUrl = _musicLyricUrl;
    res.musicUrl = _musicUrl;
    res.musicDuriation = _musicDuriation;
    res.userId = _userId;
    res.userAvatar = _userAvatar;
    res.userNickname = _userNickname;
    
    return res;
}

@end
