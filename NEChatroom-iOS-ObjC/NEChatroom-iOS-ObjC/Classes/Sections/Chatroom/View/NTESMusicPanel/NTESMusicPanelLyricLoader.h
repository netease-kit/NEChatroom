//
//  NTESMusicPanelLyricLoader.h
//  NEChatroom-iOS-ObjC
//
//  Created by Wenchao Ding on 2021/2/3.
//  Copyright © 2021 netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^NTESMusicPanelLoadLyricCompletionBlock)(NSString *content);



@interface NTESMusicPanelLyricLoader : NSObject

/**
 加载歌词
 */
- (void)loadWithURL:(NSURL *)URL completion:(NTESMusicPanelLoadLyricCompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END
