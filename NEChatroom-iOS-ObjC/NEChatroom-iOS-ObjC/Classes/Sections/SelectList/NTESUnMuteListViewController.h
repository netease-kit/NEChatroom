//
//  NTESUnMuteListViewController.h
//  NERtcAudioChatroom
//
//  Created by Netease on 2019/3/7.
//  Copyright © 2019年 netease. All rights reserved.
//

#import "NTESSelectViewController.h"

NS_ASSUME_NONNULL_BEGIN

@protocol NTESUnMuteListVCDelegate <NSObject>

- (void)didSelectMember:(NIMChatroomMember *)member;

@end

@interface NTESUnMuteListViewController : NTESSelectViewController

@property (nonatomic, weak) id <NTESUnMuteListVCDelegate> delegate;

- (instancetype)initWithMembers:(nullable NSMutableArray <NIMChatroomMember *> *)members;

@end

NS_ASSUME_NONNULL_END
