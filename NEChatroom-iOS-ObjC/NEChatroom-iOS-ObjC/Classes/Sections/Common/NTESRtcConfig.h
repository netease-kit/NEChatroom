//
//  NTESRtcConfig.h
//  NEChatroom-iOS-ObjC
//
//  Created by Wenchao Ding on 2021/2/3.
//  Copyright © 2021 netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NTESRtcConfig : NSObject

/**
 耳返开关
 */
@property (nonatomic, assign) BOOL earbackOn;

/**
 麦克风开关
 */
@property (nonatomic, assign) BOOL micOn;

/**
 扬声器开关
 */
@property (nonatomic, assign) BOOL speakerOn;

/**
 效果音量
 */
@property (nonatomic, assign) uint32_t effectVolume;

/**
 伴音音量
 */
@property (nonatomic, assign) uint32_t audioMixingVolume;

/**
 人声（采集音量）
 */
@property (nonatomic, assign) uint32_t audioRecordVolume;

@end

NS_ASSUME_NONNULL_END
