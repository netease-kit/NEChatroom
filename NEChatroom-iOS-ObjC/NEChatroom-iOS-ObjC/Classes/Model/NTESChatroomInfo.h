//
//  NTESChatroomInfo.h
//  NERtcAudioChatroom
//
//  Created by Simon Blue on 2019/1/17.
//  Copyright © 2019年 netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, NTESAudioQuality){
    NTESAudioQualityNormal = 0,
    NTESAudioQualityHD,
    NTESAudioQualityHDMusic,
};

@interface NTESChatroomInfo : NSObject<NSCoding>

@property (nonatomic,copy) NSString *roomId;
@property (nonatomic,copy) NSString *name;
@property (nonatomic,copy) NSString *creator;
@property (nonatomic,copy) NSString *thumbnail;
@property (nonatomic,assign) NSInteger onlineUserCount;
@property (nonatomic,assign) uint64_t createTime;
@property (nonatomic,assign) BOOL micMute;
@property (nonatomic,assign) NTESAudioQuality audioQuality;

- (instancetype)initWithDictionary:(NSDictionary *)dic;

- (BOOL)valid;

- (void)updateByChatroom:(NIMChatroom *)chatroom;

@end

@interface NTESChatroomList : NSObject

@property (nonatomic, assign) NSInteger total;

@property (nonatomic, strong) NSMutableArray <NTESChatroomInfo *> *list;

- (instancetype)initWithDictionary:(NSDictionary *)dic;

@end

NS_ASSUME_NONNULL_END
