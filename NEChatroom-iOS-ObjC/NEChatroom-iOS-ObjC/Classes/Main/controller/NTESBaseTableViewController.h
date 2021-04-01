//
//  NTESBaseTableViewController.h
//  NLiteAVDemo
//
//  Created by I am Groot on 2020/11/17.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NTESBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN
@interface NTESBaseTableViewController : NTESBaseViewController<UITableViewDelegate,UITableViewDataSource>
@property(strong,nonatomic)UITableView *tableView;
@end

NS_ASSUME_NONNULL_END
