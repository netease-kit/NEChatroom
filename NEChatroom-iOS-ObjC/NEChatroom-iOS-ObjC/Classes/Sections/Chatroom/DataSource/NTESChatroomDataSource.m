//
//  NTESChatroomDataSource.m
//  NERtcAudioChatroom
//
//  Created by Netease on 2019/3/7.
//  Copyright © 2019年 netease. All rights reserved.
//

#import "NTESChatroomDataSource.h"
#import "NTESChatroomQueueHelper.h"
#import "NSString+NTES.h"

#define kDatasourceSonghandleQueue            "com.netease.song.handle.queue"

@interface NTESChatroomDataSource ()
{
//    NIMNetCallMeeting *_meeting;
}

/// 点歌服务
@property (nonatomic, strong, readwrite)   NTESPickMusicService    *pickService;

// 歌曲变化
- (void)musicQueueDidChange:(NSNotification *)notification;

@end

@implementation NTESChatroomDataSource

- (instancetype)init {
    if (self = [super init]) {
        
        //connectorArray
        _connectorArray = [NSMutableArray array];
        
        //myMicInfo
        _myMicInfo = [[NTESMicInfo alloc] init];
        _myMicInfo.userInfo = [[NTESUserInfo alloc] init];
        
        //micInfoArray
        _micInfoArray = [NSMutableArray array];
        for (int i = 0; i < 8; i++) {
            NTESMicInfo *micInfo = [[NTESMicInfo alloc] init];
            micInfo.micStatus = NTESMicStatusNone;
            micInfo.micReason = NTESMicReasonNone;
            micInfo.micOrder = i + 1;
            [_micInfoArray addObject:micInfo];
        }
        
        _pickService = [[NTESPickMusicService alloc] init];
        _rtcConfig = [[NTESRtcConfig alloc] init];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(musicQueueDidChange:) name:kChatroomKtvMusicQueueChanged object:nil];
    }
    return self;
}

- (void)dealloc  {
    [NSNotificationCenter.defaultCenter removeObserver:self name:kChatroomKtvMusicQueueChanged object:nil];
}

- (void)setMyAccountInfo:(NTESAccountInfo *)myAccountInfo {
    _myAccountInfo = myAccountInfo;
    _myMicInfo.userInfo = [[NTESUserInfo alloc] initWithAccountInfo:myAccountInfo];
    
    _pickService.userInfo = myAccountInfo;
}

#pragma mark - setter/getter

- (void)setChatroomInfo:(NTESChatroomInfo *)chatroomInfo
{
    _chatroomInfo = chatroomInfo;
    
    _pickService.chatroomId = chatroomInfo.roomId;
}

- (BOOL)userIsCreator:(NSString *)userId {
    BOOL ret = NO;
    if (userId) {
        ret = [userId isEqualToString:_chatroom.creator];
    }
    return ret;
}

- (void)setUserMode:(NTESUserMode)userMode
{
    _userMode = userMode;
    _pickService.userMode = userMode;
}

- (NTESMicInfo *)userInfoOnMicInfoArray:(NSString *)userId {
    __block NTESMicInfo *ret = nil;
    if (userId) {
        [_micInfoArray enumerateObjectsUsingBlock:^(NTESMicInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.userInfo.account isEqualToString:userId]
                && [obj isOnMicStatus]) {
                ret = obj;
                *stop = YES;
            }
        }];
    }
    return ret;
}

- (NTESMicInfo *)userInfoOnConnectorArray:(NSString *)userId {
    __block NTESMicInfo *ret = nil;
    [_connectorArray enumerateObjectsUsingBlock:^(NTESMicInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.userInfo.account isEqualToString:userId]) {
            ret = obj;
            *stop = YES;
        }
    }];
    return ret;
}

- (void)cleanConnectorOnMicOrder:(NSInteger)micOrder {
    NSMutableIndexSet *delIndex = [NSMutableIndexSet indexSet];
    [_connectorArray enumerateObjectsUsingBlock:^(NTESMicInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.micOrder == micOrder) {
            [delIndex addIndex:idx];
        }
    }];
    if (delIndex.count != 0) {
        [_connectorArray removeObjectsAtIndexes:delIndex];
    }
}

- (void)buildMicInfoDataWithChatroomQueue:(NSArray<NSDictionary<NSString *,NSString *> *> *)chatroomQueue {
    if (chatroomQueue && chatroomQueue.count) {
        for (NSDictionary *dic in chatroomQueue) {
            for (NSString *key in [dic allKeys]) {
                if ([key hasPrefix:@"music_"]) {
                    continue;
                }
                NSString *obj = [dic objectForKey:key];
                if (obj && [obj isKindOfClass:[NSString class]]) {
                    NTESMicInfo *micInfo = [NTESChatroomQueueHelper micInfoByChatroomQueueValue:obj];
                    NSInteger index = micInfo.micOrder - 1;
                    if (index < _micInfoArray.count) {
                        [_micInfoArray replaceObjectAtIndex:index withObject:micInfo];
                    }
                }
            }
        }
    }
    
}

- (void)setCurrentBackgroundMusic:(NTESBackgroundMusic *)currentBackgroundMusic {
    _currentBackgroundMusic = currentBackgroundMusic;
    _isBackgroundMusicPaused = NO;
}

- (void)musicQueueDidChange:(NSNotification *)notification {
    if (self.pickService.pickSongs.count > 0) {
        self.isBackgroundMusicPaused = NO;
        self.currentBackgroundMusic = nil;
    }
}

@end


@implementation NTESUserOnSoundModel

@end
