//
//  NTESMoreViewController.h
//  NEChatroom-iOS-ObjC
//
//  Created by Wenchao Ding on 2021/1/26.
//  Copyright © 2021 netease. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NTESChatroomDefine.h"
#import "NTESChatroomDataSource.h"

NS_ASSUME_NONNULL_BEGIN

@protocol NTESMoreSettingDelegate <NSObject>

/**
 设置麦克风开关
 @param micOn   - 麦克风开关状态
 */
- (void)didSetMicOn:(BOOL)micOn;

@end

@interface NTESMoreViewController : UIViewController

@property (nonatomic, weak) id<NTESMoreSettingDelegate> delegate;

/**
 初始化方法
 @param context 聊天室上下文数据
 */
- (instancetype)initWithContext:(NTESChatroomDataSource *)context;

@end

NS_ASSUME_NONNULL_END
