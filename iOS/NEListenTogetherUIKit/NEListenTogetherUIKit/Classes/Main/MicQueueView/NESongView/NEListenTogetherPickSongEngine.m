// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEListenTogetherPickSongEngine.h"
#import <AVFoundation/AVFoundation.h>
#import <NEListenTogetherKit/NEListenTogetherKit-Swift.h>
#import <YYModel/YYModel.h>
#import "NEListenTogetherLocalized.h"
#import "NEListenTogetherPickSongColorDefine.h"
#import "NEListenTogetherSongItem.h"
#import "NEListenTogetherUILog.h"

static int NEPageSize = 20;

@interface NEListenTogetherPickSongEngine () <NEListenTogetherCopyrightedMediaEventHandler,
                                              NEListenTogetherListener,
                                              NEListenTogetherCopyrightedMediaListener>

@property(nonatomic, strong) NSPointerArray *observeArray;

@property(nonatomic, assign) uint64_t retrtLater;

@end

@implementation NEListenTogetherPickSongEngine

+ (instancetype)sharedInstance {
  static dispatch_once_t onceToken;
  static NEListenTogetherPickSongEngine *pickSongEngine = nil;
  dispatch_once(&onceToken, ^{
    pickSongEngine = [[NEListenTogetherPickSongEngine alloc] init];
    [pickSongEngine initData];
    [[NEListenTogetherKit getInstance] addVoiceRoomListener:pickSongEngine];
    [[NEListenTogetherKit getInstance] setCopyrightedMediaEventHandler:pickSongEngine];
  });
  return pickSongEngine;
}

- (void)initData {
  self.pickSongArray = [NSMutableArray array];
  self.pickSongDownloadingArray = [NSMutableArray array];
  self.pickedSongArray = [NSMutableArray array];
  self.pageNum = 0;
  self.observeArray = [NSPointerArray weakObjectsPointerArray];
  self.currentOrderSongArray = [NSMutableArray array];
}

- (void)addObserve:(id<NESongPointProtocol>)observe {
  bool hasAdded = NO;
  for (id<NESongPointProtocol> item in self.observeArray) {
    if (item == observe) {
      hasAdded = YES;
      break;
    }
  }
  if (!hasAdded) {
    [self.observeArray addPointer:(__bridge void *)(observe)];
  }
}

- (void)removeObserve:(id<NESongPointProtocol>)observe {
  bool hasAdded = NO;
  int observeIndex = 0;
  for (int index = 0; index < self.observeArray.count; index++) {
    id<NESongPointProtocol> item = [self.observeArray pointerAtIndex:index];
    if (item == observe) {
      hasAdded = YES;
      observeIndex = index;
      break;
    }
  }
  if (hasAdded) {
    [self.observeArray removePointerAtIndex:observeIndex];
  }
}

- (void)clearData {
  [self.pickSongArray removeAllObjects];
  [self.pickedSongArray removeAllObjects];
  [self.pickSongDownloadingArray removeAllObjects];
}
// 获取已点数据
- (void)getKaraokeSongOrderedList:(SongListBlock)callback {
  [[NEListenTogetherKit getInstance]
      getOrderedSongsWithCallback:^(
          NSInteger code, NSString *_Nullable msg,
          NSArray<NEListenTogetherOrderSongModel *> *_Nullable orderSongs) {
        if (code != 0) {
          callback([NSError errorWithDomain:@"getVoiceRoomSongOrderedList" code:code userInfo:nil]);
        } else {
          self.pickedSongArray = [orderSongs mutableCopy];
          callback(nil);
        }
      }];
}

- (void)getKaraokeSongList:(SongListBlock)callback {
  [[NEListenTogetherKit getInstance]
      getSongList:nil
          channel:nil
          pageNum:@(self.pageNum)
         pageSize:@(NEPageSize)
         callback:^(NSArray<NECopyrightedSong *> *_Nonnull songList, NSError *_Nonnull error) {
           if (error) {
             callback(error);
           } else {
             @synchronized(self) {
               NSMutableArray *tempItems = [NSMutableArray array];
               NSMutableArray *tempLoading = [NSMutableArray array];
               NSMutableArray *tempCurrentOrderingArray = [NSMutableArray array];
               for (NEListenTogetherSongItem *item in self.currentOrderSongArray) {
                 [tempCurrentOrderingArray addObject:item.songId];
               }
               for (NECopyrightedSong *songItem in songList) {
                 NEListenTogetherSongItem *item =
                     [self changeCopyrightedToKaraokeSongItem:songItem];
                 if (item.hasAccompany) {
                   BOOL isDownloading = NO;
                   if ([tempCurrentOrderingArray containsObject:item.songId]) {
                     isDownloading = YES;
                   }

                   if (isDownloading) {
                     [tempLoading addObject:@"1"];
                   } else {
                     [tempLoading addObject:@"0"];
                   }
                   [tempItems addObject:item];
                 }
               }
               dispatch_async(dispatch_get_main_queue(), ^{
                 [self.pickSongArray addObjectsFromArray:tempItems];
                 [self.pickSongDownloadingArray addObjectsFromArray:tempLoading];
                 self.noMore = songList.count <= 0;
                 callback(nil);
               });
             }
           }
         }];
}

- (void)updateSongArray {
  @synchronized(self) {
    [self.pickSongArray removeAllObjects];
    [self.pickSongDownloadingArray removeAllObjects];
  }
}

- (void)resetPageNumber {
  self.pageNum = 0;
  self.searchPageNum = 0;
}
- (void)updatePageNumber:(BOOL)isSearching {
  if (isSearching) {
    self.searchPageNum += 1;
  } else {
    self.pageNum += 1;
  }
}

// 上下滑动刷新搜索数据
- (void)getKaraokeSearchSongList:(NSString *)searchString callback:(SongListBlock)callback {
  [[NEListenTogetherKit getInstance]
      searchSong:searchString
         channel:nil
         pageNum:@(self.searchPageNum)
        pageSize:@(NEPageSize)
        callback:^(NSArray<NECopyrightedSong *> *_Nonnull songList, NSError *_Nonnull error) {
          if (error) {
            callback(error);
          } else {
            @synchronized(self) {
              NSMutableArray *tempItems = [NSMutableArray array];
              NSMutableArray *tempLoading = [NSMutableArray array];
              NSMutableArray *tempCurrentOrderingArray = [NSMutableArray array];
              for (NEListenTogetherSongItem *item in self.currentOrderSongArray) {
                [tempCurrentOrderingArray addObject:item.songId];
              }
              for (NECopyrightedSong *songItem in songList) {
                NEListenTogetherSongItem *item = [self changeCopyrightedToKaraokeSongItem:songItem];
                if (item.hasAccompany) {
                  [tempItems addObject:item];
                  BOOL isDownloading = NO;
                  if ([tempCurrentOrderingArray containsObject:item.songId]) {
                    isDownloading = YES;
                  }

                  if (isDownloading) {
                    [tempLoading addObject:@"1"];
                  } else {
                    [tempLoading addObject:@"0"];
                  }
                }
              }
              dispatch_async(dispatch_get_main_queue(), ^{
                [self.pickSongArray addObjectsFromArray:tempItems];
                [self.pickSongDownloadingArray addObjectsFromArray:tempLoading];
                self.noMore = songList.count <= 0;
                callback(nil);
              });
            }
          }
        }];
}

- (void)onSongListChanged {
  for (id<NESongPointProtocol> obj in self.observeArray) {
    if (obj && [obj conformsToProtocol:@protocol(NESongPointProtocol)] &&
        [obj respondsToSelector:@selector(onOrderSongRefresh)]) {
      [obj onOrderSongRefresh];
    }
  }
}

/**
 * 预加载 Song 数据
 *
 * @param songId 歌曲id
 * @param channel 渠道
 */
- (void)preloadSong:(NSString *)songId channel:(SongChannel)channel {
  [[NEListenTogetherKit getInstance] preloadSong:songId channel:channel observe:self];
}
#pragma mark <NESongPreloadProtocol>

- (void)voiceroom_onPreloadStart:(NSString *)songId channel:(SongChannel)channel {
  [NEListenTogetherUILog successLog:ListenTogetherUILog
                               desc:[NSString stringWithFormat:@"%@开始加载", songId]];
}

- (void)voiceroom_onPreloadProgress:(NSString *)songId
                            channel:(SongChannel)channel
                           progress:(float)progress {
  NEListenTogetherSongItem *songItem;
  @synchronized(self) {
    for (NEListenTogetherSongItem *item in self.pickSongArray) {
      if ([item.songId isEqualToString:songId]) {
        songItem = item;
        songItem.downloadProcess = progress;
        break;
      }
    }
  }

  //  if (progress > 0.5 && progress < 0.6) {
  //    NSString *progressLogInfo =
  //        [NSString stringWithFormat:@"下载中,songId:%@,\n progress:%.2f, \n songItem:%@, \n  "
  //                                   @"currentOrderSongArray:%@ ,\n pickSongArray:%@",
  //                                   songId, progress, songItem, self.currentOrderSongArray,
  //                                   self.pickSongArray];
  //    [NEListenTogetherUILog successLog:ListenTogetherUILog desc:progressLogInfo];
  //  }

  if (songItem) {
    unsigned long index = [self.pickSongArray indexOfObject:songItem];
    @synchronized(self) {
      [[NEListenTogetherPickSongEngine sharedInstance].pickSongDownloadingArray
          replaceObjectAtIndex:index
                    withObject:@"0"];
    }

    for (id<NESongPointProtocol> obj in self.observeArray) {
      if (obj && [obj conformsToProtocol:@protocol(NESongPointProtocol)] &&
          [obj respondsToSelector:@selector(onSourceReloadIndex:process:)]) {
        [obj onSourceReloadIndex:[NSIndexPath indexPathForRow:index inSection:0] process:progress];
      }
    }
  }
}

- (void)voiceroom_onPreloadComplete:(NSString *)songId
                            channel:(SongChannel)channel
                              error:(NSError *_Nullable)preloadError {
  NSString *infoString =
      [NSString stringWithFormat:@"songid = %@;error = %@", songId,
                                 preloadError.description ? preloadError.description : @"scuuess"];
  [NEListenTogetherUILog infoLog:ListenTogetherUILog desc:infoString];
  // 获取Item 刷新UI
  @synchronized(self) {
    NEListenTogetherSongItem *songItem;
    for (NEListenTogetherSongItem *song in self.pickSongArray) {
      if ([songId isEqualToString:song.songId]) {
        songItem = song;
        break;
      }
    }

    if (songItem) {
      long index = [self.pickSongArray indexOfObject:songItem];
      [[NEListenTogetherPickSongEngine sharedInstance].pickSongDownloadingArray
          replaceObjectAtIndex:index
                    withObject:@"0"];
      // 此处添加数据回调
      // 回调抛出
      for (id<NESongPointProtocol> obj in self.observeArray) {
        if (obj && [obj conformsToProtocol:@protocol(NESongPointProtocol)] &&
            [obj respondsToSelector:@selector(onSourceReloadIndex:isSonsList:)]) {
          [obj onSourceReloadIndex:[NSIndexPath indexPathForRow:index inSection:0] isSonsList:YES];
        }
      }
    }

    NSMutableArray *songItemArray = [NSMutableArray array];
    NEListenTogetherSongItem *currentSongitem;
    for (NEListenTogetherSongItem *song in self.currentOrderSongArray) {
      if ([songId isEqualToString:song.songId]) {
        currentSongitem = song;
        [songItemArray addObject:song];
      }
    }
    if (preloadError) {
      if (preloadError.code == ERR_CANCEL) {
        [NEListenTogetherUILog successLog:ListenTogetherUILog
                                     desc:NELocalizedString(@"用户取消下载")];
        for (id<NESongPointProtocol> obj in self.observeArray) {
          if (obj && [obj conformsToProtocol:@protocol(NESongPointProtocol)] &&
              [obj respondsToSelector:@selector(onOrderSong:error:)]) {
            [obj onOrderSong:nil error:NELocalizedString(@"用户取消下载")];
          }
        }
      } else {
        [NEListenTogetherUILog successLog:ListenTogetherUILog
                                     desc:NELocalizedString(@"文件加载失败")];
        for (id<NESongPointProtocol> obj in self.observeArray) {
          if (obj && [obj conformsToProtocol:@protocol(NESongPointProtocol)] &&
              [obj respondsToSelector:@selector(onOrderSong:error:)]) {
            [obj onOrderSong:nil error:NELocalizedString(@"文件加载失败")];
          }
        }
      }
      if (currentSongitem) {
        [NEListenTogetherUILog
            successLog:ListenTogetherUILog
                  desc:[NSString
                           stringWithFormat:
                               @"加载中数据移除, songId:%@ ,itemArray:%@,当前下载中列表数据:%@",
                               songId, songItemArray, self.currentOrderSongArray]];
        [self.currentOrderSongArray removeObjectsInArray:songItemArray];
      }
      return;
    }
    [NEListenTogetherUILog successLog:ListenTogetherUILog desc:NELocalizedString(@"文件加载完成")];

    if (!currentSongitem) {
      return;
    }
    NEListenTogetherOrderSongModel *orderSong = [NEListenTogetherOrderSongModel new];
    orderSong.songId = songId;
    orderSong.songName = [NSString stringWithFormat:@"%@", currentSongitem.songName];
    orderSong.songCover = [NSString stringWithFormat:@"%@", currentSongitem.songCover];

    if (currentSongitem.singers.count > 0) {
      NECopyrightedSinger *singer = currentSongitem.singers.firstObject;
      if (singer) {
        orderSong.singer = singer.singerName;
      }
    }

    orderSong.oc_channel = channel;

    // 获取歌曲长度
    NSString *songPath = [[NEListenTogetherKit getInstance] getSongURI:songId
                                                               channel:(SongChannel)channel
                                                           songResType:TYPE_ACCOMP];
    NSData *data = [NSData dataWithContentsOfFile:songPath];
    if (!data.length) {
      songPath = [[NEListenTogetherKit getInstance] getSongURI:songId
                                                       channel:(SongChannel)channel
                                                   songResType:TYPE_ORIGIN];
      data = [NSData dataWithContentsOfFile:songPath];
    }

    if (channel == MIGU) {
      if (songPath) {
        orderSong.oc_songTime =
            [self getAudioDurationWithAudioURL:[NSURL fileURLWithPath:songPath]] * 1000;
      }
    } else {
      AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithData:data error:nil];
      orderSong.oc_songTime = player.duration * 1000;
    }

    [NEListenTogetherUILog
        successLog:ListenTogetherUILog
              desc:[NSString stringWithFormat:
                                 @"加载中数据移除, songId:%@ ,itemArray:%@,当前下载中列表数据:%@",
                                 songId, songItemArray, self.currentOrderSongArray]];
    [self.currentOrderSongArray removeObjectsInArray:songItemArray];

    [[NEListenTogetherKit getInstance]
        orderSong:orderSong
         callback:^(NSInteger code, NSString *_Nullable msg,
                    NEListenTogetherOrderSongModel *_Nullable object) {
           if (code != 0) {
             NSString *message = nil;
             if (code == SONG_ERROR_SONG_POINTED) {
               message = NELocalizedString(@"歌曲已点");
             } else if (code == SONG_ERROR_SONG_POINTED_USER_LIMIT) {
               message = NELocalizedString(@"已达到单人点歌数上限");
             } else if (code == SONG_ERROR_SONG_POINTED_ROOM_LIMIT) {
               message = NELocalizedString(@"已达到房间点歌数上限");
             } else {
               message = NELocalizedString(@"点歌失败");
             }

             // 此处添加数据回调
             // 回调抛出
             for (id<NESongPointProtocol> obj in self.observeArray) {
               if (obj && [obj conformsToProtocol:@protocol(NESongPointProtocol)] &&
                   [obj respondsToSelector:@selector(onOrderSong:error:)]) {
                 [obj onOrderSong:nil error:message];
               }
             }

           } else {
             // 此处添加数据回调
             // 回调抛出
             [NEListenTogetherUILog successLog:ListenTogetherUILog desc:@"点歌成功"];
             for (id<NESongPointProtocol> obj in self.observeArray) {
               if (obj && [obj conformsToProtocol:@protocol(NESongPointProtocol)] &&
                   [obj respondsToSelector:@selector(onOrderSong:error:)]) {
                 [obj onOrderSong:object error:nil];
               }
             }
           }
         }];
  }
}

// 上麦成功数据处理
- (void)applySuccessWithSong:(NEListenTogetherSongItem *)songItem
                    complete:(void (^)(void))complete {
  if (songItem) {
    NSNumber *index = nil;
    for (NEListenTogetherSongItem *item in self.pickSongArray) {
      if ([item.songId isEqualToString:songItem.songId]) {
        index = [NSNumber numberWithLong:[self.pickSongArray indexOfObject:item]];
      }
    }

    if (index == nil) {
      return;
    }

    [[NEListenTogetherPickSongEngine sharedInstance].pickSongDownloadingArray
        replaceObjectAtIndex:[index intValue]
                  withObject:@"1"];

    // 此处添加数据回调
    // 回调抛出
    for (id<NESongPointProtocol> obj in self.observeArray) {
      if (obj && [obj conformsToProtocol:@protocol(NESongPointProtocol)] &&
          [obj respondsToSelector:@selector(onSourceReloadIndex:isSonsList:)]) {
        [obj onSourceReloadIndex:[NSIndexPath indexPathForRow:[index intValue] inSection:0]
                      isSonsList:YES];
      }
    }
    if (complete) {
      complete();
    }
  }
}

- (NEListenTogetherSongItem *)changeCopyrightedToKaraokeSongItem:(NECopyrightedSong *)songItem {
  NEListenTogetherSongItem *item = [[NEListenTogetherSongItem alloc] init];
  item.songId = songItem.songId;
  item.songName = songItem.songName;
  item.songCover = songItem.songCover;
  item.singers = songItem.singers;
  item.albumName = songItem.albumName;
  item.albumCover = songItem.albumCover;
  item.originType = songItem.originType;
  item.channel = songItem.channel;
  item.hasAccompany = songItem.hasAccompany;
  item.hasOrigin = songItem.hasOrigin;
  return item;
}

- (void)voiceroom_onTokenExpired {
  [NEListenTogetherUILog infoLog:ListenTogetherUILog desc:@"收到token过期回调"];
  for (id<NESongPointProtocol> obj in self.observeArray) {
    if (obj && [obj conformsToProtocol:@protocol(NESongPointProtocol)] &&
        [obj respondsToSelector:@selector(onVoiceRoomSongTokenExpired)]) {
      [obj onVoiceRoomSongTokenExpired];
    }
  }
}

- (CGFloat)getAudioDurationWithAudioURL:(NSURL *)audioURL {
  NSDictionary *opts =
      [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES]
                                  forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
  AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:audioURL options:opts];
  CGFloat second = urlAsset.duration.value * 1.0 / urlAsset.duration.timescale;
  return second;
}

- (NEListenTogetherOrderSongModel *)getNextSong {
  NSMutableArray *tempPickedSongArray = [[self pickedSongArray] mutableCopy];
  BOOL songMatched = NO;
  NEListenTogetherOrderSongModel *nextSong;
  for (NEListenTogetherOrderSongModel *orderSongModel in tempPickedSongArray) {
    if (songMatched) {
      nextSong = orderSongModel;
      break;
    }
    if ([orderSongModel.songId isEqualToString:self.currrentSongModel.playMusicInfo.songId] &&
        orderSongModel.oc_channel == self.currrentSongModel.playMusicInfo.oc_channel) {
      songMatched = YES;
    }
  }
  if (nextSong == nil) {
    nextSong = tempPickedSongArray.firstObject;
  }
  return nextSong;
}

@end
