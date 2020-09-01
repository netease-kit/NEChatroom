//
//  NTESDemoService.h
//  NERtcAudioChatroom
//
//  Created by Simon Blue on 2019/1/15.
//  Copyright © 2019年 netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NTESDemoTask.h"

NS_ASSUME_NONNULL_BEGIN

@interface NTESDemoService : NSObject

+ (instancetype)sharedService;

//账号信息
- (void)requestUserAccount:(nullable NSString *)sid
                completion:(NTESAccountHandler)completion;

//房间列表
- (void)requestChatrommListWithLimit:(NSInteger)limit
                              offset:(NSInteger)offset
                          completion:(NTESChatroomHandler)completion;

//创建房间
- (void)createChatroomWithSid:(NSString *)sid
                     roomName:(NSString *)roomName
                   completion:(NTESCreateChatroomHandler)completion;


//关闭房间
- (void)closeChatroomWithSid:(NSString *)sid
                      roomId:(NSInteger )roomId
                   completion:(NTESCommonHandler)completion;

//全员禁言
- (void)muteChatroomWithSid:(NSString *)sid
                     roomId:(NSInteger)roomId
                       mute:(BOOL)mute
                 completion:(NTESCommonHandler)completion;

@end

NS_ASSUME_NONNULL_END
