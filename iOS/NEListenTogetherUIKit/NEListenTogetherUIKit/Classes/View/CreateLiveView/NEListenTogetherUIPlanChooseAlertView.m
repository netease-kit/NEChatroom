// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEListenTogetherUIPlanChooseAlertView.h"
#import <Masonry/Masonry.h>
#import "NEListenTogetherGlobalMacro.h"
#import "NEListenTogetherUI.h"
#import "UIView+NEListenTogether.h"
@interface NEListenTogetherUIPlanChooseAlertView () <UITableViewDataSource, UITableViewDelegate>
@property(nonatomic, strong) UIView *planContainerView;
@property(nonatomic, strong) UILabel *titleLable;
@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) UIButton *cancelButton;
@property(nonatomic, strong) NSArray *imageArray;
@property(nonatomic, strong) NSArray *titleArray;

@end

@implementation NEListenTogetherUIPlanChooseAlertView

- (instancetype)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    [self addSubviews];
  }
  return self;
}

- (void)addSubviews {
  self.backgroundColor = UIColorFromRGBA(0x000000, 0.3);
  [UIView animateWithDuration:0.35
                   animations:^{
                     [self addSubview:self.planContainerView];
                     [self.planContainerView addSubview:self.tableView];
                     [self.planContainerView addSubview:self.cancelButton];
                   }];

  [self.planContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.right.bottom.equalTo(self);
    make.height.mas_equalTo(250);
  }];

  [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.left.right.equalTo(self.planContainerView);
    make.height.mas_equalTo(180);
  }];

  [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(self.tableView.mas_bottom);
    make.left.right.bottom.equalTo(self.planContainerView);
  }];
}

/** 删除视图 */
- (void)dismissFromSuperView {
  [self removeFromSuperview];
}

- (void)layoutSubviews {
  [super layoutSubviews];
  [self.planContainerView cutViewRounded:UIRectCornerTopLeft | UIRectCornerTopRight
                             cornerRadii:CGSizeMake(5, 5)];
}

#pragma mark - UITableViewDelegate UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *const reuseIdentifier = @"NETSChoosePlanCell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
  if (!cell) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                  reuseIdentifier:reuseIdentifier];
  }
  cell.textLabel.text = self.titleArray[indexPath.row];
  cell.textLabel.font = [UIFont systemFontOfSize:16];
  cell.textLabel.textColor = HEXCOLOR(0x222222);
  cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  cell.imageView.image = [NEListenTogetherUI ne_listen_imageName:self.imageArray[indexPath.row]];

  UIView *divideView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UIScreenWidth, 1)];
  divideView.backgroundColor = HEXCOLOR(0xF0F0F2);
  [cell.contentView addSubview:divideView];
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  // 1是rtc 0是cdn
  //  NTESPushType selectIndex = indexPath.row == 0 ? NTESPushTypeRtc : NTESPushTypeCdn;
  if (_delegate && [_delegate respondsToSelector:@selector(planChooseResult)]) {
    [_delegate planChooseResult];
  }
  [self dismissFromSuperView];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  return self.titleLable;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 48;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
  return 48;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
  UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UIScreenWidth, 8)];
  footerView.backgroundColor = HEXCOLOR(0xF0F0F2);
  return footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
  return 8;
}

#pragma mark - lazyMethod

- (UIView *)planContainerView {
  if (!_planContainerView) {
    _planContainerView = [[UIView alloc] init];
    _planContainerView.backgroundColor = UIColor.whiteColor;
  }
  return _planContainerView;
}

- (UILabel *)titleLable {
  if (!_titleLable) {
    _titleLable = [[UILabel alloc] init];
    _titleLable.text = @"方案选择";
    _titleLable.textColor = HEXCOLOR(0x222222);
    _titleLable.font = [UIFont fontWithName:@"PingFangSC-Medium" size:16];
    _titleLable.textAlignment = NSTextAlignmentCenter;
    _titleLable.backgroundColor = UIColor.whiteColor;
  }
  return _titleLable;
}

- (UITableView *)tableView {
  if (!_tableView) {
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = HEXCOLOR(0xF0F0F2);
    _tableView.scrollEnabled = NO;  // 设置tableview 不能滚动
  }
  return _tableView;
}

- (UIButton *)cancelButton {
  if (!_cancelButton) {
    _cancelButton = [[UIButton alloc] init];
    _cancelButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [_cancelButton setTitleColor:HEXCOLOR(0x222222) forState:UIControlStateNormal];
    [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [_cancelButton addTarget:self
                      action:@selector(dismissFromSuperView)
            forControlEvents:UIControlEventTouchUpInside];
  }
  return _cancelButton;
}

- (NSArray *)imageArray {
  if (!_imageArray) {
    _imageArray = @[ @"icon_RTC", @"icon_CDN" ];
  }
  return _imageArray;
}

- (NSArray *)titleArray {
  if (!_titleArray) {
    _titleArray = @[ @"RTC", @"CDN" ];
  }
  return _titleArray;
}
@end
