// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEUIBaseViewController.h"
NS_ASSUME_NONNULL_BEGIN

/// Tableview 控制器
@interface NEUIBaseTableViewController
    : NEUIBaseViewController <UITableViewDelegate, UITableViewDataSource>
@property(nonatomic, strong) UITableView *tableView;
@end

NS_ASSUME_NONNULL_END
