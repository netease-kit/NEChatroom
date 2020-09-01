//
//  NTESAccountInfo.h
//  NERtcAudioChatroom
//
//  Created by Simon Blue on 2019/1/16.
//  Copyright © 2019年 netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NTESAccountInfo : NSObject<NSCoding>

@property (nonatomic,copy) NSString *account;
@property (nonatomic,copy) NSString *token;
@property (nonatomic,copy) NSString *nickName;
@property (nonatomic,copy) NSString *icon;
@property (nonatomic,copy) NSString *sid;
@property (nonatomic,assign) int64_t uid;
@property (nonatomic,assign) int64_t availableTime;

- (instancetype)initWithDictionary:(NSDictionary *)dic;

- (BOOL)valid;

@end

NS_ASSUME_NONNULL_END
