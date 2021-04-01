//
//  NTESQueueMusic.h
//  NEChatroom-iOS-ObjC
//
//  Created by Think on 2021/2/3.
//  Copyright © 2021 netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 队列音乐信息
 */
@interface NTESQueueMusic : NSObject <NSCopying>

@property (nonatomic, copy)     NSString    *musicId;
@property (nonatomic, assign)   int32_t     countTimeSec;
@property (nonatomic, copy)     NSString    *musicName;
@property (nonatomic, copy)     NSString    *musicAuthor;
@property (nonatomic, copy)     NSString    *musicAvatar;
@property (nonatomic, copy)     NSString    *musicLyricUrl;
@property (nonatomic, copy)     NSString    *musicUrl;
@property (nonatomic, copy)     NSString    *musicDuriation;
@property (nonatomic, copy)     NSString    *userId;
@property (nonatomic, copy)     NSString    *userNickname;
@property (nonatomic, copy)     NSString    *userAvatar;
@property (nonatomic, assign)   NSInteger   status; // 1表示暂停中
@property (nonatomic, assign)   uint64_t    timestamp; // 暂停时更新次字段

/**
 自定义判等方法
 @param music   - 音乐队列对象
 @return 是否相等
 */
- (BOOL)isEqualToMusic:(NTESQueueMusic *)music;

@end

NS_ASSUME_NONNULL_END
