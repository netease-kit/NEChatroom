//
//  NTESDataCenter.h
//  NERtcAudioChatroom
//
//  Created by Netease on 2019/3/6.
//  Copyright © 2019年 netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NTESAccountInfo.h"
#import "NTESChatroomInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface NTESDataCenter : NSObject

+ (instancetype)shareCenter;

@property (nullable, nonatomic, strong) NTESAccountInfo *myAccount;

@property (nullable, nonatomic, strong) NTESChatroomInfo *myCreateChatroom;

@end

NS_ASSUME_NONNULL_END
