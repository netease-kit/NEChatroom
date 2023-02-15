// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>
#import <NECopyrightedMedia/NECopyrightedMedia.h>
#import <NEListenTogetherKit/NEListenTogetherKit-Swift.h>
NS_ASSUME_NONNULL_BEGIN

@protocol NESongPointProtocol <NSObject>
@optional
/// 数据刷新协议
/// @param index 下标
/// @param isSonsList 是否为主列表
- (void)onSourceReloadIndex:(NSIndexPath *)index isSonsList:(BOOL)isSonsList;

/// 进度数据刷新协议
/// @param index 下标
/// @param progress 进度
- (void)onSourceReloadIndex:(NSIndexPath *)index process:(float)progress;

/// 点歌接口协议
/// @param errorMessage 有则失败 无则成功
- (void)onOrderSong:(NEListenTogetherOrderSongModel *)songModel
              error:(NSString *_Nullable)errorMessage;

// Token过期
- (void)onVoiceRoomSongTokenExpired;

/// 已点歌曲列表更新
- (void)onOrderSongRefresh;

@end

typedef void (^SongListBlock)(NSError *_Nullable error);

@interface NEListenTogetherPickSongEngine : NSObject

/// 点歌列表数据
@property(nonatomic, strong) NSMutableArray *pickSongArray;
/// 已点列表数据
@property(nonatomic, strong) NSMutableArray *pickedSongArray;

/// 点歌列表数据 展示状态数组
@property(nonatomic, strong) NSMutableArray *pickSongDownloadingArray;

/// 推荐页码
@property(nonatomic, assign) NSInteger pageNum;

/// 搜索页码
@property(nonatomic, assign) NSInteger searchPageNum;

/// 是否有更多数据
@property(nonatomic, assign) bool noMore;

/// 当前点歌数据列表
@property(nonatomic, strong) NSMutableArray *currentOrderSongArray;

/// 本地存储songModel模型
@property(nonatomic, strong) NEListenTogetherSongModel *_Nullable currrentSongModel;

+ (instancetype)sharedInstance;

// 数据进度刷新协议
- (void)addObserve:(id<NESongPointProtocol>)observe;

// 移出数据进度刷新协议
- (void)removeObserve:(id<NESongPointProtocol>)observe;

/// 获取推荐数据
- (void)getKaraokeSongList:(SongListBlock)callback;

/// 获取已点数据
- (void)getKaraokeSongOrderedList:(SongListBlock)callback;

/// 上下滑动刷新搜索数据
- (void)getKaraokeSearchSongList:(NSString *)searchString callback:(SongListBlock)callback;

- (void)updateSongArray;

- (void)resetPageNumber;

- (void)updatePageNumber:(BOOL)isSearching;

////上麦成功数据处理
//- (void)applySuccessWithSong:(NEListenTogetherSongItem *)songItem complete:(void
//(^)(void))complete;

/**
 * 预加载 Song 数据
 *
 * @param songId 歌曲id
 * @param channel 渠道
 */
- (void)preloadSong:(NSString *)songId channel:(SongChannel)channel;

- (NEListenTogetherOrderSongModel *)getNextSong;
@end

NS_ASSUME_NONNULL_END
