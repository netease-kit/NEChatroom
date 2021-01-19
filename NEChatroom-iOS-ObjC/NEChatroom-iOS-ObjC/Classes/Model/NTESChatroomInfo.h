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
//cdn配置模型
@interface NTESCDNLiveConfigModel : NSObject
//以下三个拉流地址，则其一即可。
@property (nonatomic, copy) NSString *httpPullUrl;
@property (nonatomic, copy) NSString *rtmpPullUrl;
@property (nonatomic, copy) NSString *hlsPullUrl;
//推流地址
@property (nonatomic, copy) NSString *pushUrl;

@end


@interface NTESChatroomInfo : NSObject<NSCoding>

@property (nonatomic,copy) NSString *roomId;
@property (nonatomic,copy) NSString *name;
@property (nonatomic,copy) NSString *creator;
@property (nonatomic,copy) NSString *thumbnail;
@property (nonatomic,assign) NSInteger onlineUserCount;
@property (nonatomic,assign) uint64_t createTime;
@property (nonatomic,assign) BOOL micMute;
//0：CDN推流， 1：rtc推流
@property (nonatomic, assign) NSInteger pushType;
//CDN配置信息
//@property(nonatomic, strong) NSDictionary *liveConfig;
@property(nonatomic, strong) NTESCDNLiveConfigModel *liveConfig;

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
