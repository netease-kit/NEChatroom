//
//  NTESChatroomRemoteFileManager.h
//  NEChatroom-iOS-ObjC
//
//  Created by Wenchao Ding on 2021/2/2.
//  Copyright © 2021 netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^NTESChatroomLoadLyricCompletionBlock)(NSString *);

@interface NTESChatroomRemoteFileManager : NSObject

/**
 单例
 */
+ (instancetype)sharedManager;

/**
 根据URL加载歌词内容
 */
- (void)loadWithURL:(NSURL *)URL completion:(NTESChatroomLoadLyricCompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END
