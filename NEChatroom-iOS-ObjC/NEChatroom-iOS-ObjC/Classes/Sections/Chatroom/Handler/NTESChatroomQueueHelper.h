//
//  NTESChatroomQueueHelper.h
//  NERtcAudioChatroom
//
//  Created by Simon Blue on 2019/1/29.
//  Copyright © 2019年 netease. All rights reserved.
//

#import <Foundation/Foundation.h>

#define NTESMicInfoKeyIndex  @"index"
#define NTESMicInfoKeyStatus  @"status"
#define NTESMicInfoKeyReason  @"reason"
#define NTESMicInfoKeyMember  @"member"
#define NTESMicInfoKeyAccount  @"account"
#define NTESMicInfoKeyNick  @"nick"
#define NTESMicInfoKeyAvatar  @"avatar"
#define NTESMicInfoKeyMicMute @"micMute"

NS_ASSUME_NONNULL_BEGIN

@class NTESMicInfo;

@interface NTESChatroomQueueHelper : NSObject

+ (NTESMicInfo *)micInfoByChatroomQueueValue:(NSString *)value;

+ (BOOL)checkMicEmptyWithMicInfo:(NTESMicInfo *)micInfo;

+ (void)updateChatroomQueueWithRoomId:(NSString *)roomId
                              micInfo:(NTESMicInfo *)micInfo;

@end

NS_ASSUME_NONNULL_END
