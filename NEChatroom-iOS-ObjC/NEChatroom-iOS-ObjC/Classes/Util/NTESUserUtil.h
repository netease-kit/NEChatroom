//
//  NTESUserUtil.h
//  NERtcAudioChatroom
//
//  Created by Netease on 2019/3/6.
//  Copyright © 2019年 netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NTESUserUtil : NSObject

+ (NSString *)fromNickNameWithMessage:(NIMMessage *)message;

+ (UInt64)randomUid;

@end

NS_ASSUME_NONNULL_END
