//
//  NTESBackgroundMusicViewController.h
//  NEChatroom-iOS-ObjC
//
//  Created by Wenchao Ding on 2021/1/29.
//  Copyright © 2021 netease. All rights reserved.
//
//  背景音乐

#import <UIKit/UIKit.h>
#import "NTESChatroomDataSource.h"

NS_ASSUME_NONNULL_BEGIN

@interface NTESBackgroundMusicViewController : UIViewController

/**
 初始化背景音乐界面
 @param context 上下文数据
 */
- (instancetype)initWithContext:(NTESChatroomDataSource *)context;

@end

NS_ASSUME_NONNULL_END
