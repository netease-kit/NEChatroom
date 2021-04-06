//
//  NTESChatroomQueueHelper.h
//  NERtcAudioChatroom
//
//  Created by Simon Blue on 2019/1/29.
//  Copyright © 2019年 netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NTESQueueMusic.h"

#define NTESMicInfoKeyIndex  @"index"
#define NTESMicInfoKeyStatus  @"status"
#define NTESMicInfoKeyReason  @"reason"
#define NTESMicInfoKeyMember  @"member"
#define NTESMicInfoKeyAccount  @"account"
#define NTESMicInfoKeyNick  @"nick"
#define NTESMicInfoKeyAvatar  @"avatar"
#define NTESMicInfoKeyMicMute @"micMute"

NS_ASSUME_NONNULL_BEGIN

@class NTESMicInfo, NTESPickSongModel, NTESAccountInfo;

@interface NTESChatroomQueueHelper : NSObject

+ (NTESMicInfo *)micInfoByChatroomQueueValue:(NSString *)value;

+ (BOOL)checkMicEmptyWithMicInfo:(NTESMicInfo *)micInfo;

/**
 更新麦位队列
 @param roomId  - 聊天室ID
 @param micInfo    - 麦位信息
 @param complation      - 完成闭包
 */
+ (void)updateChatroomQueueWithRoomId:(NSString *)roomId
                              micInfo:(NTESMicInfo *)micInfo
                           complation:(void(^)(NSError * _Nullable))complation;

/**
 点歌
 @param roomId  - 聊天室ID
 @param song    - 歌曲信息
 @param countTimeSec    - 准备倒计时信息
 @param picker          - 点歌人信息
 @param complation      - 完成闭包
 */
+ (void)updateQueueWithRoomId:(NSString *)roomId
                         song:(NTESPickSongModel *)song
                 countTimeSec:(int32_t)countTimeSec
                       picker:(NTESAccountInfo *)picker
                   complation:(void(^)(NSError * _Nullable))complation;

/**
 根据队列信息获取点歌信息
 @param key     - 键名
 @param value   - 键值
 */
+ (nullable NTESQueueMusic *)songForQueueKey:(NSString *)key
                                       value:(NSString *)value;

/**
 跳过当前歌曲(切歌)
 @param music    - 歌曲
 @param roomId  - 聊天室ID
 @param completion  - 完成闭包
 */
+ (void)removePickedMusic:(NTESQueueMusic *)music
                   roomId:(NSString *)roomId
               completion:(nullable NIMChatroomQueueRemoveHandler)completion;

/**
 更新歌曲信息(更新歌曲倒计时等)
 @param music                      - 待更新的歌曲信息
 @param roomId                  - 聊天室ID
 @param completion          - 完成闭包
 */
+ (void)updateQueueMusic:(NTESQueueMusic *)music
                  roomId:(NSString *)roomId
              completion:(void(^)(NSError * _Nullable))completion;

@end

NS_ASSUME_NONNULL_END
