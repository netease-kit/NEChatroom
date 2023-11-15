// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <NEAudioEffectKit/NEAudioEffectManager.h>
#import <NEOrderSong/NEOrderSong-Swift.h>
#import <NEVoiceRoomKit/NEVoiceRoomKit-Swift.h>
#import "NEUIChatroomContext.h"
#import "NEUIConnectListView.h"
#import "NEUIKeyboardToolbarView.h"
#import "NEUIMicQueueView.h"
#import "NEVoiceRoomAnimationView.h"
#import "NEVoiceRoomFooterView.h"
#import "NEVoiceRoomHeaderView.h"
#import "NEVoiceRoomReachability.h"
#import "NEVoiceRoomSendGiftViewController.h"
#import "NEVoiceRoomUIAlertView.h"
@import NESocialUIKit;

NS_ASSUME_NONNULL_BEGIN

/// 歌曲播放状态
typedef enum : NSUInteger {
  PlayingStatus_default,
  PlayingStatus_pause,
  PlayingStatus_playing,
} PlayingStatus;

/// 语聊房vc
@interface NEVoiceRoomViewController : UIViewController <NEVoiceRoomListener, NEOrderSongListener>
@property(nonatomic, strong) NEVoiceRoomInfo *detail;

@property(nonatomic, assign) NEVoiceRoomRole role;
/// 背景图
@property(nonatomic, strong) UIImageView *bgImageView;
/// 控制器头部视图
@property(nonatomic, strong) NEVoiceRoomHeaderView *roomHeaderView;
/// 控制器尾部视图
@property(nonatomic, strong) NEVoiceRoomFooterView *roomFooterView;
/// 键盘辅助视图
@property(nonatomic, strong) NEUIKeyboardToolbarView *keyboardView;
/// 麦位视图
@property(nonatomic, strong) NEUIMicQueueView *micQueueView;
/// 内容视图
@property(nonatomic, strong) NESocialChatroomView *chatView;
/// 上下文
@property(nonatomic, strong) NEUIChatroomContext *context;
/// 网络监听
@property(nonatomic, strong) NEVoiceRoomReachability *reachability;
/// alert弹框
@property(nonatomic, strong) NEVoiceRoomUIAlertView *alertView;
/// 主播顶部弹框
@property(nonatomic, strong) NEUIConnectListView *connectListView;
/// 自己状态
@property(nonatomic, assign) NEVoiceRoomSeatItemStatus selfStatus;
@property(nonatomic, strong) NEVoiceRoomAnimationView *giftAnimation;  // 礼物动画
@property(nonatomic, strong) NSMutableArray *connectorArray;

@property(nonatomic, assign) PlayingStatus playingStatus;

/// 断网 之类的操作 判断是否在聊天室中
@property(nonatomic, assign) bool isInChatRoom;

@property(nonatomic, strong) NEAudioEffectManager *audioManager;

// 礼物控制器
@property(nonatomic, strong) NEVoiceRoomSendGiftViewController *giftViewController;

/// 初始化
/// @param role 角色
/// @param detail 房间详情
- (instancetype)initWithRole:(NEVoiceRoomRole)role detail:(NEVoiceRoomInfo *)detail;

/// 离开或关闭房间
- (void)closeRoom;
- (void)closeRoomWithViewPop:(BOOL)changeView callback:(void (^)(void))callabck;

/// 是否返回到列表页
@property(nonatomic, assign) BOOL isBackToList;

@end

NS_ASSUME_NONNULL_END
