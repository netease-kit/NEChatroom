//
//  NTESMusicPanelViewController.h
//  NEChatroom-iOS-ObjC
//
//  Created by Wenchao Ding on 2021/1/26.
//  Copyright © 2021 netease. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NTESChatroomDefine.h"
#import "NTESChatroomDataSource.h"
    
@class NTESMusicPanelViewController;

NS_ASSUME_NONNULL_BEGIN

@interface NTESMusicPanelViewController : UIViewController

/**
 初始化
 */
- (instancetype)initWithContext:(NTESChatroomDataSource *)context;

@end

NS_ASSUME_NONNULL_END
