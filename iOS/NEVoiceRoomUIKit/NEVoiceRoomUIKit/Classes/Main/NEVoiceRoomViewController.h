// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <NEUIKit/NEUIBaseViewController.h>
#import <NEUIKit/NEUICommon.h>
#import <NEVoiceRoomKit/NEVoiceRoomKit-Swift.h>
#import "NEUIChatroomContext.h"
#import "NEUIConnectListView.h"
#import "NEUIKeyboardToolbarView.h"
#import "NEUIMicQueueView.h"
#import "NEVoiceRoomChatView.h"
#import "NEVoiceRoomFooterView.h"
#import "NEVoiceRoomHeaderView.h"
#import "NEVoiceRoomReachability.h"
#import "NEVoiceRoomUIAlertView.h"

NS_ASSUME_NONNULL_BEGIN

/// 语聊房vc
@interface NEVoiceRoomViewController : NEUIBaseViewController <NEVoiceRoomListener>
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
@property(nonatomic, strong) NEVoiceRoomChatView *chatView;
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
@property(nonatomic, strong) NSMutableArray *connectorArray;

/// 初始化
/// @param role 角色
/// @param detail 房间详情
- (instancetype)initWithRole:(NEVoiceRoomRole)role detail:(NEVoiceRoomInfo *)detail;

/// 离开或关闭房间
- (void)closeRoom;
@end

NS_ASSUME_NONNULL_END
