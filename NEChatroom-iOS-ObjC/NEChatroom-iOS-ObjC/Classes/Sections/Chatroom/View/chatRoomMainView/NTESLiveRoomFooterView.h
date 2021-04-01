//
//  NTESLiveRoomFooterView.h
//  NEChatroom-iOS-ObjC
//
//  Created by vvj on 2021/2/4.
//  Copyright © 2021 netease. All rights reserved.
//

#import "NTESBaseView.h"
#import "NTESChatroomDataSource.h"

NS_ASSUME_NONNULL_BEGIN


typedef NS_ENUM(NSInteger,NTESFunctionArea) {
    NTESFunctionAreaUnknown = 10000,
    NTESFunctionAreaInput,//输入框
    NTESFunctionAreaRequestSong,//点歌
    NTESFunctionAreaMicrophone,//麦克风
    NTESFunctionAreaBanned,//禁言
    NTESFunctionAreaMore//更多
};

typedef NS_ENUM(NSUInteger, NTESMuteType){
    NTESMuteTypeAll = 0,//全部静音
    NTESMuteTypeSelf,//自己静音
};

@protocol NETSFunctionAreaDelegate <NSObject>

//点歌事件
- (void)footerDidReceiveRequestSongAciton;

//麦克静音事件
- (void)footerDidReceiveMicMuteAction:(BOOL)mute;

//禁言事件
- (void)footerDidReceiveNoSpeekingAciton;

//menu点击事件
- (void)footerDidReceiveMenuClickAciton;

//输入框点击事件
- (void)footerInputViewDidClickAction;

@end

@interface NTESLiveRoomFooterView : NTESBaseView

@property (nonatomic, weak) id<NETSFunctionAreaDelegate> delegate;

@property (nonatomic, assign) NTESCreateRoomType roomType;
//设置用户身份
@property (nonatomic, assign) NTESUserMode userMode;

- (instancetype)initWithContext:(NTESChatroomDataSource *)context;
//设置静音
- (void)setMuteWithType:(NTESMuteType)type;
//取消静音
- (void)cancelMute;
@end

NS_ASSUME_NONNULL_END
