//
//  NTESAuthorityHelper.h
//  NERtcAudioChatroom
//
//  Created by Netease on 2019/3/20.
//  Copyright © 2019年 netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NTESAuthorityHelper : NSObject

+ (void)startNetworkAuthorityLinstener;

+ (BOOL)checkMicAuthority;

@end

NS_ASSUME_NONNULL_END
