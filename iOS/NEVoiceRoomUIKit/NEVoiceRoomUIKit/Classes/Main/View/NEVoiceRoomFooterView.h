// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <NEVoiceRoomKit/NEVoiceRoomKit-Swift.h>
#import "NEUIBaseView.h"
#import "NEUIChatroomContext.h"
NS_ASSUME_NONNULL_BEGIN

//角色枚举
typedef NS_ENUM(NSUInteger, NTESUserMode) {
  //主播
  NTESUserModeAnchor = 0,
  //观众
  NTESUserModeAudience = 1,
  //连麦者
  NTESUserModeConnector = 2,
};

typedef NS_ENUM(NSInteger, NEUIFunctionArea) {
  NEUIFunctionAreaUnknown = 10000,
  NEUIFunctionAreaInput,       //输入框
  NEUIFunctionAreaMicrophone,  //麦克风
  NEUIFunctionAreaBanned,      //禁言
  NEUIFunctionAreaMore         //更多
};

typedef NS_ENUM(NSUInteger, NEUIMuteType) {
  NEUIMuteTypeAll = 0,  //全部静音
  NEUIMuteTypeSelf,     //自己静音
};

@protocol NEVoiceRoomFooterFunctionAreaDelegate <NSObject>
@optional
//麦克静音事件
- (void)footerDidReceiveMicMuteAction:(BOOL)mute;
//禁言事件
- (void)footerDidReceiveNoSpeekingAciton;
// menu点击事件
- (void)footerDidReceiveMenuClickAciton;
//输入框点击事件
- (void)footerInputViewDidClickAction;
@end

@interface NEVoiceRoomFooterView : NEUIBaseView

@property(nonatomic, weak) id<NEVoiceRoomFooterFunctionAreaDelegate> delegate;
/// 用户角色
@property(nonatomic, assign) NEVoiceRoomRole role;

- (instancetype)initWithContext:(NEUIChatroomContext *)context;
//- (instancetype)initWithContext:(NTESChatroomDataSource2 *)context;
//设置静音
- (void)setMuteWithType:(NEUIMuteType)type;
//取消静音
- (void)cancelMute;
/// 上下麦 更新 观众的操作按钮
- (void)updateAudienceOperatingButton:(BOOL)isOnSeat;
@end

NS_ASSUME_NONNULL_END
