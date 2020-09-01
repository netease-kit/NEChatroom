//
//  NTESMicInfo.h
//  NERtcAudioChatroom
//
//  Created by Simon Blue on 2019/1/23.
//  Copyright © 2019年 netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NTESUserInfo.h"
NS_ASSUME_NONNULL_BEGIN


typedef NS_ENUM(NSUInteger, NTESMicStatus) {
    //麦位无人
    NTESMicStatusNone = 0,
    //正在申请
    NTESMicStatusConnecting = 1,
    //申请完成，上麦
    NTESMicStatusConnectFinished = 2,
    //麦位被关闭 用户不能上麦
    NTESMicStatusClosed = 3,
    //麦位被屏蔽,麦位没人,可以上麦
    NTESMicStatusMasked = 4,
    //上麦,但是被屏蔽
    NTESMicStatusConnectFinishedWithMasked = 5,
    //上麦,但是用户自己关闭了话筒
    NTESMicStatusConnectFinishedWithMuted = 6,
    //上麦,但是用户自己关闭了话筒,且被主播屏蔽
    NTESMicStatusConnectFinishedWithMutedAndMasked = 7,
};

typedef NS_ENUM(NSUInteger, NTESMicReason) {
    //无原因
    NTESMicReasonNone = 0,
    //被同意上麦
    NTESMicReasonConnectAccepted = 1,
    //被抱麦
    NTESMicReasonConnectInvited = 2,
    //被踢
    NTESMicReasonMicKicked = 3,
    //主动下麦
    NTESMicReasonDropMic = 4,
    //主动取消连麦
    NTESMicReasonCancelConnect = 5,
    //被拒绝
    NTESMicReasonConnectRejected = 6,
    //上麦之前被屏蔽
    NTESMicReasonMicMasked = 7,
    //恢复语音
    NTESMicReasonResumeMasked = 8,
    //打开麦位
    NTESMicReasonOpenMic = 9,
};


@interface NTESMicInfo : NSObject <NSCopying>

@property (nonatomic,assign) NSInteger micOrder;
@property (nonatomic,assign) NTESMicStatus micStatus;
@property (nonatomic,assign) NTESMicReason micReason;
@property (nonatomic,strong) NTESUserInfo *userInfo;
@property (nonatomic,assign) BOOL isMicMute;

- (BOOL)isOnMicStatus;

- (BOOL)isOffMicStatus;

@end

NS_ASSUME_NONNULL_END
