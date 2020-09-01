//
//  NTESUserInfo.h
//  NERtcAudioChatroom
//
//  Created by Simon Blue on 2019/1/23.
//  Copyright © 2019年 netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NTESAccountInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface NTESUserInfo : NSObject <NSCopying>

@property (nonatomic,copy) NSString *account;
@property (nonatomic,copy) NSString *nickName;
@property (nonatomic,copy) NSString *icon;
@property (nonatomic,copy) NSString *sid;
@property (nonatomic,assign) int64_t uid;

- (instancetype)initWithAccountInfo:(NTESAccountInfo *)accountInfo;

@end

NS_ASSUME_NONNULL_END
