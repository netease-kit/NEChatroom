//
//  NTESChatroomViewController.h
//  NERtcAudioChatroom
//
//  Created by Simon Blue on 2019/1/18.
//  Copyright © 2019年 netease. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NTESChatroomDefine.h"

@class NTESChatroomInfo;
@class NTESAccountInfo;


NS_ASSUME_NONNULL_BEGIN

@protocol NTESChatroomVCDelegate <NSObject>

- (void)didRoomClosed:(NTESChatroomInfo *)roomInfo;

- (void)didDestoryChatroom:(NTESChatroomInfo *)roomInfo;

@end

@interface NTESChatroomViewController : UIViewController

@property (nonatomic, weak) id <NTESChatroomVCDelegate> delegate;

- (instancetype)initWithChatroomInfo:(NTESChatroomInfo *)chatroomInfo
                         accountInfo:(NTESAccountInfo *)accountInfo
                            userMode:(NTESUserMode)userMode;

@end

NS_ASSUME_NONNULL_END
