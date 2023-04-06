// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEMenuCell.h"
#import <Masonry/Masonry.h>
@implementation NEMenuCellModel

- (instancetype)initWithTitle:(NSString *)title
                     subtitle:(NSString *)subtitle
                         icon:(NSString *)icon
                        block:(NEMenuCellBlock)block {
  self = [super init];
  if (self) {
    _title = title;
    _subtitle = subtitle;
    _icon = icon;
    _block = block;
  }
  return self;
}

@end

///

@interface NEMenuCell ()

@property(strong, nonatomic) UILabel *titleLabel;
@property(strong, nonatomic) UILabel *subTitleLabel;
@property(strong, nonatomic) UIImageView *iconView;

@end

@implementation NEMenuCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier {
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    [self initUI];
  }
  return self;
}
- (void)initUI {
  NSInteger padding = 20;
  NSInteger arrowLeft = 14;

  CGFloat width = [UIScreen mainScreen].bounds.size.width;
  if (width <= 320) {
    padding = 10;
    arrowLeft = 4;
  }
  self.backgroundColor = [UIColor clearColor];
  self.selectionStyle = UITableViewCellSelectionStyleNone;
  UIView *bgView = [[UIView alloc] init];
  bgView.layer.cornerRadius = 16;
  bgView.backgroundColor = [UIColor colorWithRed:50 / 255.0
                                           green:55 / 255.0
                                            blue:89 / 255.0
                                           alpha:1.0];
  [self.contentView addSubview:bgView];
  [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.edges.mas_equalTo(UIEdgeInsetsMake(8, padding, 8, padding));
  }];

  [bgView addSubview:self.iconView];
  [bgView addSubview:self.titleLabel];
  [bgView addSubview:self.subTitleLabel];
  UIImageView *arrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"menu_arrow"]];
  arrow.contentMode = UIViewContentModeCenter;
  [bgView addSubview:arrow];

  [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.mas_equalTo(bgView.mas_left).offset(24);
    make.centerY.mas_equalTo(0);
    make.size.mas_equalTo(CGSizeMake(48, 48));
  }];

  [arrow mas_makeConstraints:^(MASConstraintMaker *make) {
    make.right.mas_equalTo(-arrowLeft);
    make.centerY.mas_equalTo(0);
    make.size.mas_equalTo(CGSizeMake(7, 13));
  }];

  [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.mas_equalTo(12);
    make.left.mas_equalTo(self.iconView.mas_right).offset(14);
  }];

  [self.subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(self.titleLabel.mas_bottom).offset(5);
    make.left.equalTo(self.titleLabel);
    make.right.equalTo(arrow.mas_left).offset(-10);
  }];
}

- (void)installWithModel:(NEMenuCellModel *)model indexPath:(NSIndexPath *)indexPath {
  self.titleLabel.text = model.title;
  self.subTitleLabel.text = model.subtitle;
  self.iconView.image = [UIImage imageNamed:model.icon];
}

+ (NEMenuCell *)cellWithTableView:(UITableView *)tableView
                        indexPath:(NSIndexPath *)indexPath
                             data:(NEMenuCellModel *)data {
  NEMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:[NEMenuCell description]];
  if (cell == nil) {
    cell = [[NEMenuCell alloc] initWithStyle:UITableViewCellStyleDefault
                             reuseIdentifier:[NEMenuCell description]];
  }
  [cell installWithModel:data indexPath:indexPath];
  return cell;
}

+ (CGFloat)height {
  return 125;
}

#pragma mark - lazy load

- (UIImageView *)iconView {
  if (!_iconView) {
    _iconView = [[UIImageView alloc] init];
  }
  return _iconView;
}
- (UILabel *)titleLabel {
  if (!_titleLabel) {
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.font = [UIFont boldSystemFontOfSize:18];
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
  }
  return _titleLabel;
}

- (UILabel *)subTitleLabel {
  if (!_subTitleLabel) {
    _subTitleLabel = [[UILabel alloc] init];
    _subTitleLabel.font = [UIFont boldSystemFontOfSize:14];
    _subTitleLabel.textColor = [UIColor whiteColor];
    _subTitleLabel.textAlignment = NSTextAlignmentLeft;
    _subTitleLabel.numberOfLines = 0;
  }
  return _subTitleLabel;
}
@end
