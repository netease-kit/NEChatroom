// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEListenTogetherAuthorityHelper.h"
#import "NEListenTogetherViewController.h"
NS_ASSUME_NONNULL_BEGIN

@interface NEListenTogetherViewController (Utils)
/// 加入房间
- (void)joinRoom;
/// 开启麦克风
- (void)unmuteAudio:(BOOL)showToast;
/// 关闭麦克风
- (void)muteAudio:(BOOL)showToast;
/// 网络状态监听
- (void)addNetworkObserver;
/// 销毁网络监听
- (void)destroyNetworkObserver;
/// 检查麦克风权限
- (void)checkMicAuthority;

- (NSArray<NEListenTogetherSeatItem *> *)simulatedSeatData;
/// 是房主
- (BOOL)isAnchor;
/// 处理静音操作
- (void)handleMuteOperation:(BOOL)isMute;
- (NSString *)fetchLyricContentWithSongId:(NSString *)songId channel:(SongChannel)channel;
- (NSString *)fetchPitchContentWithSongId:(NSString *)songId channel:(SongChannel)channel;
- (NSString *)fetchOriginalFilePathWithSongId:(NSString *)songId channel:(SongChannel)channel;
- (NSString *)fetchAccompanyFilePathWithSongId:(NSString *)songId channel:(SongChannel)channel;
/// 获取观众userUuid
- (NSString *)getAnotherAccount;
- (void)networkStatusChange;
@end

NS_ASSUME_NONNULL_END
