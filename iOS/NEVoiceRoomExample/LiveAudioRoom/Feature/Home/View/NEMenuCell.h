// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^NEMenuCellBlock)(void);

/// 主页 菜单Cell 模型
@interface NEMenuCellModel : NSObject
// 主标题
@property(nonatomic, copy) NSString *title;
// 副标题
@property(nonatomic, copy) NSString *subtitle;
// 头像
@property(nonatomic, copy) NSString *icon;

@property(nonatomic, copy) NEMenuCellBlock block;

- (instancetype)initWithTitle:(NSString *)title
                     subtitle:(NSString *)subtitle
                         icon:(NSString *)icon
                        block:(NEMenuCellBlock)block;

@end

///

@interface NEMenuCell : UITableViewCell

+ (NEMenuCell *)cellWithTableView:(UITableView *)tableView
                        indexPath:(NSIndexPath *)indexPath
                             data:(NEMenuCellModel *)data;

+ (CGFloat)height;

@end

NS_ASSUME_NONNULL_END
