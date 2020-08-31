//
//  NTESSelectViewController.h
//  NERtcAudioChatroom
//
//  Created by Netease on 2019/3/22.
//  Copyright © 2019年 netease. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NTESNavBar.h"
#import "NTESChatroomStateView.h"

NS_ASSUME_NONNULL_BEGIN

@interface NTESSelectViewController : UIViewController <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong)NTESNavBar *navBar;

@property (nonatomic, strong)UITableView *tableview;

@property (nonatomic, strong)NTESChatroomStateView *emptyView;

@property (nonatomic, strong)NSMutableArray <NIMChatroomMember *> *showMembers;

- (void)didSetUpUI;

- (void)didMemberChanged:(BOOL)enter member:(NIMChatroomNotificationMember *)member;

@end

NS_ASSUME_NONNULL_END
