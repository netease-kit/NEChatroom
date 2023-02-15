// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <NEListenTogetherKit/NEListenTogetherKit-Swift.h>
#import <NEUIKit/NEUIBaseViewController.h>
#import <NEUIKit/NEUICommon.h>
#import "NEListenTogetherAnimationView.h"
#import "NEListenTogetherChatView.h"
#import "NEListenTogetherContext.h"
#import "NEListenTogetherFooterView.h"
#import "NEListenTogetherHeaderView.h"
#import "NEListenTogetherKeyboardToolbarView.h"
#import "NEListenTogetherLyricActionView.h"
#import "NEListenTogetherLyricControlView.h"
#import "NEListenTogetherMicQueueView.h"
#import "NEListenTogetherReachability.h"
#import "NEListenTogetherTaskQueue.h"
#import "NEListenTogetherUIAlertView.h"
#import "NEListenTogetherUIConnectListView.h"

#import <NEAudioEffectKit/NEAudioEffectManager.h>
NS_ASSUME_NONNULL_BEGIN

/// 歌曲播放状态
typedef enum : NSUInteger {
  PlayingStatus_default,
  PlayingStatus_pause,
  PlayingStatus_playing,
} PlayingStatus;

/// 歌曲下载完成状态标记位，歌曲基于什么情况下开始
typedef enum : NSUInteger {
  PlayingAction_default,
  PlayingAction_join_half_way,
  PlayingAction_switchSong,
} PlayingAction;

/// 语聊房vc
@interface NEListenTogetherViewController : NEUIBaseViewController <NEListenTogetherListener>
@property(nonatomic, strong) NEListenTogetherInfo *detail;

@property(nonatomic, assign) NEListenTogetherRole role;
/// 背景图
@property(nonatomic, strong) UIImageView *bgImageView;
/// 控制器头部视图
@property(nonatomic, strong) NEListenTogetherHeaderView *roomHeaderView;
/// 控制器尾部视图
@property(nonatomic, strong) NEListenTogetherFooterView *roomFooterView;
/// 键盘辅助视图
@property(nonatomic, strong) NEListenTogetherKeyboardToolbarView *keyboardView;
/// 麦位视图
@property(nonatomic, strong) NEListenTogetherMicQueueView *micQueueView;
/// 内容视图
@property(nonatomic, strong) NEListenTogetherChatView *chatView;
/// 上下文
@property(nonatomic, strong) NEListenTogetherContext *context;
/// 网络监听
@property(nonatomic, strong) NEListenTogetherReachability *reachability;
/// alert弹框
@property(nonatomic, strong) NEListenTogetherUIAlertView *alertView;
/// 主播顶部弹框
@property(nonatomic, strong) NEListenTogetherUIConnectListView *connectListView;
/// 自己状态
@property(nonatomic, assign) NEListenTogetherSeatItemStatus selfStatus;
@property(nonatomic, strong) NEListenTogetherAnimationView *giftAnimation;  // 礼物动画
@property(nonatomic, strong) NSMutableArray *connectorArray;
@property(nonatomic, strong) NEListenTogetherSeatItem *lastSelfItem;  /// 上次记录麦位角色信息
@property(nonatomic, assign) bool mute;  /// 上次是否进行了Mute操作

@property(nonatomic, strong) NEListenTogetherTaskQueue *taskQueue;
// 歌词及打分
@property(nonatomic, strong) NEListenTogetherLyricActionView *lyricActionView;
@property(nonatomic, strong) NEListenTogetherLyricControlView *lyricControlView;

@property(nonatomic, strong) NEAudioEffectManager *audioManager;

@property(nonatomic, assign) NSInteger time;

@property(nonatomic, assign) PlayingStatus playingStatus;
@property(nonatomic, assign) PlayingAction playingAction;

/// 初始化
/// @param role 角色
/// @param detail 房间详情
- (instancetype)initWithRole:(NEListenTogetherRole)role detail:(NEListenTogetherInfo *)detail;

/// 离开或关闭房间
- (void)closeRoom;
@end

NS_ASSUME_NONNULL_END
