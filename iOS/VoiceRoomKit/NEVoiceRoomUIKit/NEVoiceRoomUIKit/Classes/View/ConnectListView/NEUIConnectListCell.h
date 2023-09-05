// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <NEVoiceRoomKit/NEVoiceRoomKit-Swift.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^NEUIConnectListCellActionBlock)(NEVoiceRoomSeatItem *);

@interface NEUIConnectListCell : UITableViewCell
@property(nonatomic, copy) NEUIConnectListCellActionBlock acceptBlock;
@property(nonatomic, copy) NEUIConnectListCellActionBlock rejectBlock;

/// 创建cell
/// @param tableView 列表控件
/// @param datas 数据
/// @param indexPath 索引
+ (NEUIConnectListCell *)cellWithTableView:(UITableView *)tableView
                                     datas:(NSArray<NEVoiceRoomSeatItem *> *)datas
                                 indexPath:(NSIndexPath *)indexPath;
@end

NS_ASSUME_NONNULL_END
