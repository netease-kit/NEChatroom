//
//  NTESPickSongVC.h
//  NEChatroom-iOS-ObjC
//
//  Created by Think on 2021/2/1.
//  Copyright © 2021 netease. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NTESChatroomDefine.h"

NS_ASSUME_NONNULL_BEGIN

@class NTESPickMusicService, NTESMicInfo;

/**
 点歌视图
 */
@interface NTESPickSongVC : UIViewController

/**
 实例化点歌控制器
 @param service     - 点歌服务
 */
- (instancetype)initWithService:(NTESPickMusicService *)service;

@end

NS_ASSUME_NONNULL_END
