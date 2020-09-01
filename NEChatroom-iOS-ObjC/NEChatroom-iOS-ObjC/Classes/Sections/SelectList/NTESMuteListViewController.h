//
//  NTESMuteListViewController.h
//  NERtcAudioChatroom
//
//  Created by Netease on 2019/3/6.
//  Copyright © 2019年 netease. All rights reserved.
//

#import "NTESSelectViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class NTESMuteListViewController;

@protocol NTESMuteListVCDelegate <NSObject>
@required
- (void)didMuteMember:(NIMChatroomMember *)member mute:(BOOL)mute;

- (void)didMuteAll:(BOOL)mute vc:(NTESMuteListViewController *)vc;

@end

@interface NTESMuteListViewController : NTESSelectViewController

@property (nonatomic, weak) id <NTESMuteListVCDelegate> delegate;

- (instancetype)initWithChatroom:(NIMChatroom *)chatroom
                    chatroomMute:(BOOL)chatroomMute;

- (void)reloadWithChatroomMute:(BOOL)chatroomMute;

@end

NS_ASSUME_NONNULL_END
