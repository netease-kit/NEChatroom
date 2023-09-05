// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>
#import <NEVoiceRoomKit/NEVoiceRoomKit-Swift.h>
#import "NEUIBackgroundMusicModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface NEUIRtcConfig : NSObject
/// 耳返开关
@property(nonatomic, assign) BOOL earbackOn;
/// 麦克风开关
@property(nonatomic, assign) BOOL micOn;
/// 扬声器开关
@property(nonatomic, assign) BOOL speakerOn;
/// 效果音量
@property(nonatomic, assign) uint32_t effectVolume;
/// 伴音音量
@property(nonatomic, assign) uint32_t audioMixingVolume;
/// 人声（采集音量）
@property(nonatomic, assign) uint32_t audioRecordVolume;
@end

/// 语聊房 房间上下文
@interface NEUIChatroomContext : NSObject
/// 用户角色
@property(nonatomic, assign) NEVoiceRoomRole role;
/// 麦位信息
@property(nonatomic, strong) NEVoiceRoomSeatInfo *seatInfo;
// 是否全部禁言
@property(nonatomic, assign) BOOL isMuteAll;
// 自己是否禁言
@property(nonatomic, assign) BOOL meIsMute;
// 是否被语音屏蔽
@property(nonatomic, assign) BOOL isMasked;
// 所有声音关闭（主播）
@property(nonatomic, assign) BOOL isAllSoundMute;
/// 当前背景音乐
@property(nonatomic, strong, nullable) NEUIBackgroundMusicModel *currentBgm;
// 当前背景乐是否暂停
@property(nonatomic, assign) BOOL isBackgroundMusicPaused;
/// rtc 配置
@property(nonatomic, strong) NEUIRtcConfig *rtcConfig;
@end

NS_ASSUME_NONNULL_END
