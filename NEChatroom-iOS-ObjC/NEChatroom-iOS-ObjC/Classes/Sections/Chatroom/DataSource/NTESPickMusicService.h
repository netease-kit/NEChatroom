//
//  NTESPickMusicService.h
//  NEChatroom-iOS-ObjC
//
//  Created by Think on 2021/2/5.
//  Copyright © 2021 netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NTESQueueMusic.h"
#import "NTESPickSongModel.h"

NS_ASSUME_NONNULL_BEGIN

@class NTESAccountInfo;

/// 顶部歌曲变化通知
extern NSString * const kChatroomKtvTopMusicChanged;
/// 顶部歌曲userinfo中music键名
extern NSString * const kChatroomKtvTopMusicKey;

/// 歌曲队列变化通知
extern NSString * const kChatroomKtvMusicQueueChanged;
/// 歌曲队列键名
extern NSString * const kChatroomKtvMusicQueueKey;

/**
 点歌服务类
 */
@interface NTESPickMusicService : NSObject

/// 音乐播放位置
@property (nonatomic, assign)   uint64_t    musicPosition;
/// 点歌队列
@property (nonatomic, strong, readonly) NSArray<NTESQueueMusic *>  *pickSongs;
/// 聊天室ID
@property (nonatomic, copy)     NSString    *chatroomId;
/// 用户信息
@property (nonatomic, strong)   NTESAccountInfo *userInfo;
/// 用户角色
@property (nonatomic, assign)   NTESUserMode    userMode;

/**
点歌
@param music           - 点歌曲
@param successBlock    - 点歌成功闭包
@param failedBlock     - 点歌失败闭包
*/
- (void)pickMusic:(NTESPickSongModel *)music
     successBlock:(nullable void(^)(void))successBlock
      failedBlock:(nullable void(^)(NSError * _Nullable))failedBlock;

/**
 跳过当前歌曲(切歌)
 @param successBlock    - 切歌成功闭包
 @param failedBlock     - 切歌失败闭包
 */
- (void)removeTopMusicWithSuccessBlock:(nullable void(^)(NTESQueueMusic *))successBlock
                           failedBlock:(nullable NIMChatroomQueueRemoveHandler)failedBlock;

/**
 移除指定用户所点的歌曲
 @param accountId           - 用户账号ID
 @param serverSensitive - 对服务端结果敏感
 */
- (void)removeMusicWithAccountId:(NSString *)accountId
                 serverSensitive:(BOOL)serverSensitive;

/**
 取消已点歌曲
 @param music           - 取消的已点歌曲
 @param successBlock    - 取消成功闭包
 @param failedBlock     - 取消失败闭包
 */
- (void)cancelPickedSong:(NTESQueueMusic *)music
            successBlock:(nullable void(^)(NTESQueueMusic *))successBlock
             failedBlock:(nullable NIMChatroomQueueRemoveHandler)failedBlock;

/**
 队列中点歌对象发生改变
 @param key             - 变更键
 @param value           - 变更值
 @param type            - 变更类型
 @param complation      - 完成闭包
 */
- (void)didChangedMusicWithKey:(NSString *)key
                         value:(NSString *)value
                          type:(NIMChatroomQueueChangeType)type
                    complation:(nullable void(^)(NSError * _Nullable))complation;

/**
 解析队列点歌对象(刷新队列时调用)
 @param chatroomQueue   - 聊天室队列
 */
- (void)buildPickedSongDataWithChatroomQueue:(NSArray<NSDictionary<NSString *,NSString *> *> *)chatroomQueue;

/**
 获取点歌队列队首音乐
 @param complation      - 完成闭包
 */
- (void)fetchTopMusicWithComplation:(void(^)(NTESQueueMusic * _Nullable))complation;

@end

NS_ASSUME_NONNULL_END
