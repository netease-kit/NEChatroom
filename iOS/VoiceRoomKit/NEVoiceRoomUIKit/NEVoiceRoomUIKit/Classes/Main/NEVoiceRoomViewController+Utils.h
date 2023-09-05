// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <NECopyrightedMedia/NECopyrightedMedia.h>
#import "NEVoiceRoomAuthorityHelper.h"
#import "NEVoiceRoomViewController.h"
NS_ASSUME_NONNULL_BEGIN

@interface NEVoiceRoomViewController (Utils)
/// 加入房间
- (void)joinRoom;
/// 开启麦克风
- (void)unmuteAudio;
/// 关闭麦克风
- (void)muteAudio;
/// 网络状态监听
- (void)addNetworkObserver;
/// 销毁网络监听
- (void)destroyNetworkObserver;
/// 检查麦克风权限
- (void)checkMicAuthority;

- (NSArray<NEVoiceRoomSeatItem *> *)simulatedSeatData;
/// 是房主
- (BOOL)isAnchor;
/// 处理静音操作
- (void)handleMuteOperation:(BOOL)isMute;
- (NSString *)fetchLyricContentWithSongId:(NSString *)songId channel:(SongChannel)channel;
- (NSString *)fetchPitchContentWithSongId:(NSString *)songId channel:(SongChannel)channel;
- (NSString *)fetchOriginalFilePathWithSongId:(NSString *)songId channel:(SongChannel)channel;
- (NSString *)fetchAccompanyFilePathWithSongId:(NSString *)songId channel:(SongChannel)channel;

/// 更新礼物栏麦位信息
- (void)updateGiftAnchorSeat:(NEVoiceRoomSeatItem *)anchorSeat;
- (void)updateGiftOtherDatas:(NSArray<NEVoiceRoomSeatItem *> *)otherDatas;
// 更新房间信息
- (void)updateRoomInfo;
// 获取歌曲信息
- (void)getSongInfo;
@end

NS_ASSUME_NONNULL_END
