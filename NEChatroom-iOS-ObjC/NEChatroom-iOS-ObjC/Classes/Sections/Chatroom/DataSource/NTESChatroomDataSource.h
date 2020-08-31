//
//  NTESChatroomDataSource.h
//  NERtcAudioChatroom
//
//  Created by Netease on 2019/3/7.
//  Copyright © 2019年 netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NTESChatroomInfo.h"
#import "NTESAccountInfo.h"
#import "NTESMicInfo.h"
#import "NTESChatroomDefine.h"

NS_ASSUME_NONNULL_BEGIN

@class NERtcAudioVolumeInfo;

#define NTESChatroomAudioQuality  @"chatroomAudioQuality"

@interface NTESChatroomDataSource : NSObject

@property (nonatomic,strong) NTESChatroomInfo *chatroomInfo;
@property (nonatomic,strong) NTESAccountInfo *myAccountInfo;
@property (nonatomic,assign) NTESUserMode userMode;

//@property (nonatomic,readonly) NIMNetCallMeetingapp *meeting;

@property (nonatomic,strong) NIMChatroom *chatroom;
@property (nonatomic,strong) NSMutableArray<NTESMicInfo *> *micInfoArray;    //已上麦的列表
@property (nonatomic,strong) NSMutableArray<NTESMicInfo *> *connectorArray;  //请求连麦的列表
@property (nonatomic,strong) NTESMicInfo *myMicInfo;

@property (nonatomic,assign) BOOL isMuteAll; //是否全部禁言
@property (nonatomic,assign) BOOL meIsMute;  //自己是否禁言
@property (nonatomic,assign) BOOL isMasked;  //是否被语音屏蔽
@property (nonatomic,assign) BOOL isAllSoundMute; //所有声音关闭（主播）

@property (nonatomic,strong) NSArray <NERtcAudioVolumeInfo *> *onSoundUsers;

- (BOOL)userIsCreator:(NSString *)userId;

- (void)buildMicInfoDataWithChatroomQueue:(NSArray<NSDictionary<NSString *,NSString *> *> *)chatroomQueue;

//用户是否在上麦列表里
- (NTESMicInfo *)userInfoOnMicInfoArray:(NSString *)userId;

//用户是否在请求连麦列表里
- (NTESMicInfo *)userInfoOnConnectorArray:(NSString *)userId;

//根据micOrder清除连麦请求者
- (void)cleanConnectorOnMicOrder:(NSInteger)micOrder;

@end


@interface NTESUserOnSoundModel : NSObject

@property (nonatomic, copy) NSString *userId;
@property (nonatomic, assign) BOOL isOnSound;

@end

NS_ASSUME_NONNULL_END
