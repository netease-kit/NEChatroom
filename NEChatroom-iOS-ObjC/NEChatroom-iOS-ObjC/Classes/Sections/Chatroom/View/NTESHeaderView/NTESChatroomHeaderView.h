//
//  NTESChatroomHeaderView.h
//  NERtcAudioChatroom
//
//  Created by Netease on 2019/3/5.
//  Copyright © 2019年 netease. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NTESChatroomDefine.h"

@class NTESChatroomInfo;
@class NTESAccountInfo;

NS_ASSUME_NONNULL_BEGIN

@protocol NTESChatroomHeaderDelegate <NSObject>

//退出事件
- (void)headerDidReceiveExitAction;

//下麦事件
- (void)headerDidReceiveDropMicAction;

//声音静音事件
- (void)headerDidReceiveSoundMuteAction:(BOOL)mute;

//麦克静音事件
- (void)headerDidReceiveMicMuteAction:(BOOL)mute;

//禁言事件
- (void)headerDidReceiveNoSpeekingAciton;

//设置事件
- (void)headerDidReceiveSettingAciton;

@end

@interface NTESChatroomHeaderView : UIView

//事件回调
@property (nonatomic, weak) id <NTESChatroomHeaderDelegate> delegate;

//房间信息
@property (nonatomic, weak) NTESChatroomInfo *chatroomInfo;

//用户信息
@property (nonatomic, weak) NTESAccountInfo *accountInfo;

//用户身份
@property (nonatomic, assign) NTESUserMode userMode;

- (CGFloat)calculateHeightWithWidth:(CGFloat)width;

//开始声音动画
- (void)startAnimationWithValue:(NSInteger)value;

//停止声音动画
- (void)stopSoundAnimation;

@end

NS_ASSUME_NONNULL_END
