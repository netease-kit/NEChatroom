//
//  NTESMusicConsoleViewController.h
//  NEChatroom-iOS-ObjC
//
//  Created by Wenchao Ding on 2021/1/28.
//  Copyright © 2021 netease. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NTESChatroomDataSource.h"

NS_ASSUME_NONNULL_BEGIN

@interface NTESMusicConsoleViewController : UIViewController

/**
 创建实例
 @param context 聊天室上下文
 
 @raturn 实例
 */
- (instancetype)initWithContext:(NTESChatroomDataSource *)context;

@end

NS_ASSUME_NONNULL_END
