//
//  NTESPickMusicService.m
//  NEChatroom-iOS-ObjC
//
//  Created by Think on 2021/2/5.
//  Copyright © 2021 netease. All rights reserved.
//

#import "NTESPickMusicService.h"
#import "NTESAccountInfo.h"
#import "NTESChatroomQueueHelper.h"
#import "NSString+NTES.h"

NSString * const kChatroomKtvTopMusicChanged = @"kChatroomKtvTopMusicChanged";
NSString * const kChatroomKtvTopMusicKey = @"kChatroomKtvTopMusicKey";

NSString * const kChatroomKtvMusicQueueChanged = @"kChatroomKtvMusicQueueChanged";
NSString * const kChatroomKtvMusicQueueKey = @"kChatroomKtvMusicQueueKey";

/// 歌曲操作队列名
#define kDatasourceSonghandleQueue            "com.netease.song.handle.queue"

/// 全部点歌最大值
static int32_t kTotalPickMusicMax = 99;
/// 个人点歌最大值
static int32_t kSelfPickMusicMax = 20;

@interface NTESPickMusicService ()

/// 点歌队列
@property (nonatomic, strong, readwrite) NSArray<NTESQueueMusic *>  *pickSongs;
/// 歌曲操作队列
@property (nonatomic, strong) dispatch_queue_t      songQueue;

@end

@implementation NTESPickMusicService

- (instancetype)init
{
    self = [super init];
    if (self) {
        _pickSongs = @[];
        _songQueue = dispatch_queue_create(kDatasourceSonghandleQueue, DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

#pragma mark - public method

- (void)pickMusic:(NTESPickSongModel *)music
     successBlock:(nullable void(^)(void))successBlock
      failedBlock:(nullable void(^)(NSError * _Nullable))failedBlock
{
    void(^mainSuccessBlock)(void) = ^(void) {
        if (successBlock) {
            ntes_main_async_safe(^{
                successBlock();
            });
        }
    };
    
    void(^mainFailedBlock)(NSError * _Nullable) = ^(NSError * _Nullable error) {
        if (failedBlock) {
            ntes_main_async_safe(^{
                failedBlock(error);
            });
        }
    };
    
    if (isEmptyString(_chatroomId)) {
        NSError *err = [NSError errorWithDomain:@"NTESChatroomPickSong" code:-900 userInfo:@{NSLocalizedDescriptionKey: @"点歌失败: 聊天室ID为空"}];
        mainFailedBlock(err);
        return;
    }
    
    dispatch_async(_songQueue, ^() {
        // 总歌单不得超过90首
        if ([self.pickSongs count] >= kTotalPickMusicMax) {
            NSString *msg = [NSString stringWithFormat:@"点歌失败: 总歌单已超过或达到%d首", kTotalPickMusicMax];
            NSError *err = [NSError errorWithDomain:@"NTESChatRoomDataSource" code:-901 userInfo:@{NSLocalizedDescriptionKey: msg}];
            mainFailedBlock(err);
            return;
        }
        
        int32_t myPickedNum = 0;
        BOOL isExist = NO;
        int32_t idx = -1;
        NSError *err = nil;
        
        for (int32_t i = 0; i < [self.pickSongs count]; i++) {
            NTESQueueMusic *obj = self.pickSongs[i];
            
            // 计算自己点的歌曲数量
            if ([obj.userId isEqualToString:self.userInfo.account]) {
                myPickedNum += 1;
                if (myPickedNum >= 20) {
                    NSString *msg = [NSString stringWithFormat:@"点歌失败: 个人点歌已达到或超过%d首", kSelfPickMusicMax];
                    err = [NSError errorWithDomain:@"NTESChatRoomDataSource" code:-902 userInfo:@{NSLocalizedDescriptionKey: msg}];
                    break;
                }
            }
            
            // 判断有无点过
            if ([obj.musicId isEqualToString:music.sid] && [obj.userId isEqualToString:self.userInfo.account]) {
                isExist = YES;
                idx = i;
                
                YXAlogInfo(@"点歌失败: 您已点过该曲目, idx: %d", i);
                err = [NSError errorWithDomain:@"NTESChatRoomDataSource" code:-903 userInfo:@{NSLocalizedDescriptionKey: @"点歌失败: 您已点过该曲目"}];
                break;
            }
        }
        
        if (err) {
            mainFailedBlock(err);
            return;
        }
        
        // 执行点歌请求
        [NTESChatroomQueueHelper updateQueueWithRoomId:self.chatroomId song:music countTimeSec:3 picker:self.userInfo complation:^(NSError * _Nullable error) {
            if (error) {
                mainFailedBlock(error);
            } else {
                mainSuccessBlock();
            }
        }];
    });
}

- (void)removeTopMusicWithSuccessBlock:(nullable void(^)(NTESQueueMusic *))successBlock
                           failedBlock:(nullable NIMChatroomQueueRemoveHandler)failedBlock
{
    @weakify(self);
    [self fetchTopMusicWithComplation:^(NTESQueueMusic * _Nullable music) {
        @strongify(self);
        [self cancelPickedSong:music successBlock:successBlock failedBlock:failedBlock];
    }];
}

- (void)removeMusicWithAccountId:(NSString *)accountId
                 serverSensitive:(BOOL)serverSensitive
{
    dispatch_async(_songQueue, ^() {
        NSMutableArray *removes = [NSMutableArray array];
        for (NTESQueueMusic *item in self.pickSongs) {
            if ([item.userId isEqualToString:accountId]) {
                [removes addObject:item];
            }
        }
        
        // 删除本地
        void(^removeLocal)(void) = ^() {
            for (NTESQueueMusic *needRemove in removes) {
                [self _removeMusic:needRemove complation:nil];
            }
        };
        
        // 发出移除请求
        for (NTESQueueMusic *needRemove in removes) {
            [NTESChatroomQueueHelper removePickedMusic:needRemove roomId:self.chatroomId completion:^(NSError * _Nullable error, NSDictionary<NSString *,NSString *> * _Nullable element) {
                YXAlogInfo(@"移除队列音乐, element: %@, error: %@", element, error);
                if (!serverSensitive || !error) {
                    removeLocal();
                }
            }];
        }
    });
}

- (void)cancelPickedSong:(NTESQueueMusic *)music
            successBlock:(nullable void(^)(NTESQueueMusic *))successBlock
             failedBlock:(nullable NIMChatroomQueueRemoveHandler)failedBlock
{
    void(^mainSuccessBlock)(NTESQueueMusic *) = ^(NTESQueueMusic *music) {
        if (successBlock) {
            ntes_main_async_safe(^{
                successBlock(music);
            });
        }
    };
    
    void(^mainFailedBlock)(NSError * __nullable, NSDictionary<NSString *, NSString *> * __nullable) = ^(NSError * __nullable error, NSDictionary<NSString *, NSString *> * __nullable element) {
        if (failedBlock) {
            ntes_main_async_safe(^{
                failedBlock(error, element);
            });
        }
    };
    
    if (!music) {
        NSError *err = [NSError errorWithDomain:@"NTESChatroomPickSong" code:-1004 userInfo:@{NSLocalizedDescriptionKey: @"切歌失败: 点歌队列为空"}];
        mainFailedBlock(err, nil);
        return;
    }
    
    // 校验切歌权限
    if (_userMode != NTESUserModeAnchor && ![music.userId isEqualToString:self.userInfo.account]) {
        NSError *err = [NSError errorWithDomain:@"NTESChatroomPickSong" code:-1005 userInfo:@{NSLocalizedDescriptionKey: @"切歌失败: 非主播不能切别人点的歌"}];
        mainFailedBlock(err, nil);
        return;
    }
    
    // 发送移除队列请求
    [NTESChatroomQueueHelper removePickedMusic:music roomId:self.chatroomId completion:^(NSError * _Nullable error, NSDictionary<NSString *,NSString *> * _Nullable element) {
        if (error) {
            mainFailedBlock(error, nil);
            return;
        }
        
        NSString *key = [element allKeys].firstObject;
        if (isEmptyString(key) || ![key hasPrefix:@"music_"]) {
            NSError *err = [NSError errorWithDomain:@"NTESChatroomPickSong" code:-1001 userInfo:@{NSLocalizedDescriptionKey: @"被切歌曲键名错误"}];
            mainFailedBlock(err, nil);
            return;
        }
        
        NSString *val = [element objectForKey:key];
        if (isEmptyString(val)) {
            NSError *err = [NSError errorWithDomain:@"NTESChatroomPickSong" code:-1002 userInfo:@{NSLocalizedDescriptionKey: @"被切歌曲键值为空"}];
            mainFailedBlock(err, nil);
            return;
        }
        
        NSDictionary *dict = [val jsonObject];
        NTESQueueMusic *music = [NTESQueueMusic yy_modelWithDictionary:dict];
        if (!music) {
            NSError *err = [NSError errorWithDomain:@"NTESChatroomPickSong" code:-1003 userInfo:@{NSLocalizedDescriptionKey: @"被切歌曲模型转化失败"}];
            mainFailedBlock(err, element);
            return;
        }
        mainSuccessBlock(music);
    }];
}

- (void)buildPickedSongDataWithChatroomQueue:(NSArray<NSDictionary<NSString *,NSString *> *> *)chatroomQueue
{
    dispatch_async(_songQueue, ^() {
        NSMutableArray *temp = [NSMutableArray array];
        for (NSDictionary *dict in chatroomQueue) {
            NTESQueueMusic *item = [self _parsePickedSongWithQueueDict:dict];
            if (item) { [temp addObject:item]; }
        }
        // 点歌队列赋值
        self.pickSongs = [temp copy];
    });
}

- (void)fetchTopMusicWithComplation:(void(^)(NTESQueueMusic * _Nullable))complation
{
    dispatch_async(_songQueue, ^() {
        NTESQueueMusic *music = [self.pickSongs firstObject];
        if (complation) {
            ntes_main_async_safe(^{
                complation(music);
            });
        }
    });
}

- (void)didChangedMusicWithKey:(NSString *)key
                         value:(NSString *)value
                          type:(NIMChatroomQueueChangeType)type
                    complation:(nullable void(^)(NSError * _Nullable))complation
{
    if (![key hasPrefix:@"music_"]) {
        return;
    }
    
    void(^safeCompletion)(NSError * _Nullable) = ^(NSError * _Nullable error) {
        if (complation) {
            ntes_main_async_safe(^{
                complation(error);
            });
        }
    };
    
    NSDictionary *dict = [value jsonObject];
    NTESQueueMusic *music = [NTESQueueMusic yy_modelWithDictionary:dict];
    if (!music) {
        if (complation) {
            NSError *error = [NSError errorWithDomain:@"NTESChatRoomDataSource" code:-1000 userInfo:@{NSLocalizedDescriptionKey: @"队列音乐变更失败: 解析音乐对象失败"}];
            safeCompletion(error);
        }
        return;
    }
    switch (type) {
        case NIMChatroomQueueChangeTypeOffer:
            [self _addMusic:music complation:safeCompletion];
            break;
        case NIMChatroomQueueChangeTypePoll:
            [self _removeMusic:music complation:safeCompletion];
            break;
        case NIMChatroomQueueChangeTypeUpdate:
            [self _updMusic:music complation:safeCompletion];
            break;
            
        default:
            break;
    }
}

#pragma mark - getter/setter

- (void)setPickSongs:(NSArray<NTESQueueMusic *> *)pickSongs
{
    // 获取顶部音乐元素
    NTESQueueMusic *oldTop = [_pickSongs firstObject];
    NTESQueueMusic *newTop = [pickSongs firstObject];
    
    // 点歌队列重新赋值
    _pickSongs = pickSongs;
    
    ntes_main_async_safe(^{
        // 发出歌曲队列变化通知
        NSDictionary *queueChangedInfo = nil;
        if (pickSongs) {
            queueChangedInfo = @{kChatroomKtvMusicQueueKey: pickSongs};
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:kChatroomKtvMusicQueueChanged object:nil userInfo:queueChangedInfo];
        
        // 发出顶部歌曲变化通知
        if (![oldTop isEqualToMusic:newTop]) {
            NSDictionary *topChangedInfo = nil;
            if (newTop) {
                topChangedInfo = @{kChatroomKtvTopMusicKey: newTop};
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:kChatroomKtvTopMusicChanged object:nil userInfo:topChangedInfo];
        }
    });
}

#pragma mark - private method

/// 把队列中结构体解析成音乐模型
- (nullable NTESQueueMusic *)_parsePickedSongWithQueueDict:(NSDictionary *)dict
{
    NSArray *keys = [dict allKeys];
    if ([keys count] != 1) {
        return nil;
    }
    NSString *key = [[keys firstObject] description];
    if (isEmptyString(key) || ![key hasPrefix:@"music_"]) {
        return nil;
    }
    NSString *value = [dict objectForKey:key];
    NSDictionary *valueDic = [value jsonObject];
    if (!valueDic) {
        return nil;
    }
    return [NTESQueueMusic yy_modelWithDictionary:valueDic];
}

/// 从点歌队列中添加歌曲
- (void)_addMusic:(NTESQueueMusic *)music complation:(void(^)(NSError * _Nullable))complation
{
    dispatch_async(_songQueue, ^() {
        // 歌单判重
        BOOL isExist = NO;
        NSInteger idx = -1;
        [self _scanForMusic:music isExistPtr:&isExist idxPtr:&idx];
        if (isExist) {
            if (complation) {
                
                NSString *msg = @"";
                if (music.countTimeSec != 3) {
                    msg = @"倒计时消息, 本地音乐队列不添加";
                    YXAlogInfo(@"倒计时消息, 本地音乐队列不添加, countTimeSec: %d, 队列中已存在该曲目, idx: %zd", music.countTimeSec, idx);
                } else {
                    msg = @"添加失败, 队列中已存在该曲目";
                    YXAlogInfo(@"添加失败, countTimeSec: %d, 队列中已存在该曲目, idx: %zd", music.countTimeSec, idx);
                }
                NSError *error = [NSError errorWithDomain:@"NTESChatRoomDataSource" code:-1000 userInfo:@{NSLocalizedDescriptionKey: msg}];
                complation(error);
            }
            return;
        }
        
        // 执行添加
        NSMutableArray *tmp = [NSMutableArray arrayWithArray:self.pickSongs];
        [tmp addObject:music];
        self.pickSongs = [tmp copy];
        
        if (complation) { complation(nil); }
    });
}

/// 从点歌队列中移除歌曲
- (void)_removeMusic:(NTESQueueMusic *)music complation:(void(^)(NSError * _Nullable))complation
{
    dispatch_async(_songQueue, ^() {
        BOOL isExist = NO;
        NSInteger idx = -1;
        [self _scanForMusic:music isExistPtr:&isExist idxPtr:&idx];
        
        if (!isExist || idx >= [self.pickSongs count]) {
            if (complation) {
                NSError *error = [NSError errorWithDomain:@"NTESChatRoomDataSource" code:-1000 userInfo:@{NSLocalizedDescriptionKey: @"移除失败: 已点歌曲中无该曲目"}];
                complation(error);
            }
            return;
        }
        
        if (idx > -1) {
            NSMutableArray *tmp = [NSMutableArray arrayWithArray:self.pickSongs];
            [tmp removeObjectAtIndex:idx];
            self.pickSongs = [tmp copy];
        }
        
        if (complation) { complation(nil); }
    });
}

/// 更新点歌队列中歌曲
- (void)_updMusic:(NTESQueueMusic *)music complation:(void(^)(NSError * _Nullable))complation
{
    dispatch_async(_songQueue, ^() {
        BOOL isExist = NO;
        NSInteger idx = -1;
        [self _scanForMusic:music isExistPtr:&isExist idxPtr:&idx];
        
        if (isExist && idx > -1 && idx < [self.pickSongs count]) {
            if (complation) {
                NSError *error = [NSError errorWithDomain:@"NTESChatRoomDataSource" code:-1000 userInfo:@{NSLocalizedDescriptionKey: @"移除失败: 已点歌曲中无该曲目"}];
                complation(error);
            }
            return;
        }
        
        NSMutableArray *tmp = [NSMutableArray arrayWithArray:self.pickSongs];
        [tmp replaceObjectAtIndex:idx withObject:music];
        self.pickSongs = [tmp copy];
        
        if (complation) { complation(nil); }
    });
}

/// 遍历歌曲列表,查找有无指定歌曲(必须在_songQueue队列中调用)
- (void)_scanForMusic:(NTESQueueMusic *)music isExistPtr:(BOOL *)isExistPtr idxPtr:(NSInteger *)idxPtr
{
    *isExistPtr = NO;
    *idxPtr = -1;
    for (NSInteger i = 0; i < [self.pickSongs count]; i++) {
        NTESQueueMusic *obj = [self.pickSongs objectAtIndex:i];
        if ([obj isEqualToMusic:music]) {
            *isExistPtr = YES;
            *idxPtr = i;
            return;
        }
    }
}

@end
