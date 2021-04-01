//
//  NTESHomeTableVIewCell.h
//  NEChatroom-iOS-ObjC
//
//  Created by vvj on 2021/2/1.
//  Copyright © 2021 netease. All rights reserved.
//

#import "NTESBaseTabViewCell.h"

NS_ASSUME_NONNULL_BEGIN
@class NTESHomePageCellModel;

@interface NTESHomeTableViewCell : NTESBaseTabViewCell

/// 加载首页cell
/// @param tableView tableview
+ (instancetype)loadHomePageCellWithTableView:(UITableView *)tableView;

@property(nonatomic, strong) NTESHomePageCellModel *homePageModel;

@end

NS_ASSUME_NONNULL_END
