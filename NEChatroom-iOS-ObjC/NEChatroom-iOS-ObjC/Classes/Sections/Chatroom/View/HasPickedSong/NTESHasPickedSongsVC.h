//
//  NTESHasPickedSongsVC.h
//  NEChatroom-iOS-ObjC
//
//  Created by Think on 2021/2/3.
//  Copyright © 2021 netease. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class NTESPickMusicService;

/**
 已点过的歌曲 控制器
 */
@interface NTESHasPickedSongsVC : UIViewController

/**
 实例化已点过的歌曲控制器
 @param service  - 点歌服务
 */
- (instancetype)initWithService:(NTESPickMusicService *)service;

@end

NS_ASSUME_NONNULL_END
