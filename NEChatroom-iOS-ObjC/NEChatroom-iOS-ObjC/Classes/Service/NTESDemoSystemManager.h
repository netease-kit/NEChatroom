//
//  NTESDemoSystemManager.h
//  NERtcAudioChatroom
//
//  Created by Netease on 2019/3/13.
//  Copyright © 2019年 netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Reachability.h>

NS_ASSUME_NONNULL_BEGIN

@interface NTESDemoSystemManager : NSObject

+ (instancetype)shareInstance;

- (void)start;

- (NetworkStatus)netStatus;

@end

NS_ASSUME_NONNULL_END
