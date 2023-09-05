// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <NEVoiceRoomKit/NEVoiceRoomKit-Swift.h>
#import <UIKit/UIKit.h>
#import "NEUIEmptyView.h"
#import "NEVoiceRoomUINavigationBar.h"

NS_ASSUME_NONNULL_BEGIN

@interface NEUISelectViewController
    : UIViewController <UITableViewDataSource, UITableViewDataSource>
@property(nonatomic, strong) NEVoiceRoomUINavigationBar *navBar;
@property(nonatomic, strong) UITableView *tableview;
@property(nonatomic, strong) NEUIEmptyView *emptyView;
@property(nonatomic, strong) NSMutableArray<NEVoiceRoomMember *> *showMembers;

@end

NS_ASSUME_NONNULL_END
