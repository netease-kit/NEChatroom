//
//  NTESMicInviteeListViewController.h
//  NERtcAudioChatroom
//
//  Created by Simon Blue on 2019/1/29.
//  Copyright © 2019年 netease. All rights reserved.
//

#import "NTESSelectViewController.h"
#import "NTESMicInfo.h"

NS_ASSUME_NONNULL_BEGIN

@protocol NTESMicInviteeListViewControllerDelegate <NSObject>

- (void)onSelectInviteeUserWithMicInfo:(NTESMicInfo *)micInfo;

@end

@interface NTESMicInviteeListViewController : NTESSelectViewController

@property (nonatomic, weak)id<NTESMicInviteeListViewControllerDelegate> delegate;

- (instancetype)initWithChatroom:(NIMChatroom *)chatroom
                      micMembers:(NSMutableArray <NTESMicInfo *> *)micMembers
                      dstMicInfo:(NTESMicInfo *)dstMicInfo;

@end

NS_ASSUME_NONNULL_END
