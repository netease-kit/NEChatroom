// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEListenTogetherUIConnectListView.h"
#import <NEUIKit/NEUICommon.h>
#import <NEUIKit/UIColor+NEUIExtension.h>
#import <NEUIKit/UIView+NEUIExtension.h>
#import "NEListenTogetherLocalized.h"
#import "NEListenTogetherUI.h"
#import "NEListenTogetherUIConnectAlertView.h"
#import "NEListenTogetherUIConnectListCell.h"

static CGFloat cellHeight = 48.0;
static CGFloat connectAlertViewHeight = 38.0;
static CGFloat connectAlertViewWidth = 120.0;
static CGFloat titleLabelHeight = 51.0;
// cellHeight * 4 + cellHeight / 2
static CGFloat tableviewMaxHeight = 216.0;
static CGFloat foldBtnHeight = 38;

@interface NEListenTogetherUIConnectListView () <UITableViewDataSource, UITableViewDelegate> {
  CGRect _preRect;
}
@property(nonatomic, strong) UIView *bar;
@property(nonatomic, strong) UITableView *listView;
@property(nonatomic, strong) UILabel *titleLable;
@property(nonatomic, strong) NSMutableArray *dataArray;
@property(nonatomic, strong) NEListenTogetherUIConnectAlertView *connectAlertView;
@property(nonatomic, strong) UIView *coverView;
@property(nonatomic, assign) BOOL listViewPushed;
@property(nonatomic, assign) BOOL isShown;
@property(nonatomic, strong) UIButton *foldBtn;
@end

@implementation NEListenTogetherUIConnectListView
- (instancetype)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    [self addTarget:self
                  action:@selector(onTapBackground:)
        forControlEvents:UIControlEventTouchUpInside];
  }
  return self;
}

- (void)onTapBackground:(id)sender {
  [self dismiss];
}
- (void)showAsAlertOnView:(UIView *)view {
  if (_isShown) return;

  [view addSubview:self];
  // 先刷新宽高
  [self layoutIfNeeded];
  self.bottom = 0;
  self.listView.hidden = YES;
  self.titleLable.hidden = YES;
  self.foldBtn.hidden = YES;
  [UIView animateWithDuration:0.25
                   animations:^{
                     self.bottom = [NEUICommon ne_statusBarHeight] + connectAlertViewHeight;
                   }];
  self.listViewPushed = NO;
  [self.connectAlertView refreshAlertView:self.listViewPushed];
  _isShown = YES;
}

- (void)showListView {
  self.listView.hidden = NO;
  self.titleLable.hidden = NO;
  self.foldBtn.hidden = NO;
  self.bottom = 0;
  [self forceLayoutSubviews];
  [UIView animateWithDuration:0.25
      animations:^{
        self.top = 0;
      }
      completion:^(BOOL finished) {
        self.listViewPushed = YES;
        [self.connectAlertView refreshAlertView:self.listViewPushed];
      }];
}

- (void)dismissListView {
  [UIView animateWithDuration:0.25
      animations:^{
        self.bottom = [NEUICommon ne_statusBarHeight] + connectAlertViewHeight;
      }
      completion:^(BOOL finished) {
        self.listView.hidden = YES;
        self.titleLable.hidden = YES;
        self.foldBtn.hidden = YES;
        self.listViewPushed = NO;
        [self.connectAlertView refreshAlertView:self.listViewPushed];
      }];
}

- (void)dismiss {
  if (!_isShown) return;

  [UIView animateWithDuration:0.25
      animations:^{
        self.bottom = 0;
      }
      completion:^(BOOL finished) {
        [self removeFromSuperview];
        self.listViewPushed = NO;
      }];
  _isShown = NO;
}

- (void)refreshWithDataArray:(NSMutableArray *)dataArray {
  if (!dataArray.count) {
    [self dismiss];
    return;
  }
  self.dataArray = dataArray;
  [self.connectAlertView updateConnectCount:self.dataArray.count];
  [self.titleLable setText:[NSString stringWithFormat:@"%@(%ld)", NELocalizedString(@"申请上麦"),
                                                      self.dataArray.count]];
  [self.listView reloadData];
  [self forceLayoutSubviews];
}

- (void)forceLayoutSubviews {
  if (!_listView.hidden) {
    self.height = self.barHeight;
    self.bar.frame = CGRectMake(0, 0, self.width, self.height);
    self.coverView.frame = CGRectMake(
        0, 0, self.width,
        self.bar.height - self.listViewHeight - titleLabelHeight - connectAlertViewHeight);
    self.titleLable.frame = CGRectMake(0, self.coverView.bottom ?: 0, self.width, titleLabelHeight);

    self.listView.frame = CGRectMake(0, self.titleLable.bottom, self.width, self.listViewHeight);
    self.foldBtn.frame = CGRectMake(0, self.listView.bottom, self.width, foldBtnHeight);
    [self.foldBtn ne_cornerRadii:CGSizeMake(8, 8)
                  addRectCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight];

    self.connectAlertView.width = connectAlertViewWidth;
    self.connectAlertView.height = connectAlertViewHeight;
    self.connectAlertView.centerX = self.width / 2;
    self.connectAlertView.bottom = self.bar.bottom;
  }
}

- (void)layoutSubviews {
  [super layoutSubviews];
  if (!CGRectEqualToRect(_preRect, self.bounds)) {
    [self forceLayoutSubviews];
    _preRect = self.bounds;
  }
}

- (CGFloat)listViewHeight {
  CGFloat tableviewHeight = self.dataArray.count * cellHeight;
  return MIN(tableviewHeight, tableviewMaxHeight);
}

- (CGFloat)barHeight {
  return self.listViewHeight + connectAlertViewHeight + titleLabelHeight +
         [NEUICommon ne_statusBarHeight];
}

#pragma mark - <UITableViewDelegate, UITableViewDataSource>
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return cellHeight;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  NEListenTogetherUIConnectListCell *cell =
      [NEListenTogetherUIConnectListCell cellWithTableView:tableView
                                                     datas:self.dataArray
                                                 indexPath:indexPath];
  __weak typeof(self) weakSelf = self;
  cell.acceptBlock = ^(NEListenTogetherSeatItem *_Nonnull seatItem) {
    __strong typeof(self) strongSelf = weakSelf;
    if (strongSelf) {
      if (strongSelf.delegate && [strongSelf.delegate respondsToSelector:@selector
                                                      (connectListView:onAcceptWithSeatItem:)]) {
        [strongSelf.delegate connectListView:strongSelf onAcceptWithSeatItem:seatItem];
      }
    }
  };
  cell.rejectBlock = ^(NEListenTogetherSeatItem *_Nonnull seatItem) {
    __strong typeof(self) strongSelf = weakSelf;
    if (strongSelf) {
      if (strongSelf.delegate && [strongSelf.delegate respondsToSelector:@selector
                                                      (connectListView:onRejectWithSeatItem:)]) {
        [strongSelf.delegate connectListView:strongSelf onRejectWithSeatItem:seatItem];
      }
    }
  };
  return cell;
}

- (void)foldConnectList:(UIButton *)sender {
  [self dismissListView];
  self.connectAlertView.showConnectListBtn.hidden = NO;
}

#pragma mark------------------------ Getter ------------------------
- (UIView *)bar {
  if (!_bar) {
    UIView *bar = [[UIView alloc] initWithFrame:CGRectZero];
    _bar = bar;
    [self addSubview:_bar];
  }
  return _bar;
}

- (UILabel *)titleLable {
  if (!_titleLable) {
    UILabel *titleLabel = [[UILabel alloc] init];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    titleLabel.font = [UIFont systemFontOfSize:15];
    [titleLabel setText:@"test1"];
    titleLabel.backgroundColor = [UIColor ne_colorWithHex:0x1D1D24 alpha:0.9];
    _titleLable = titleLabel;
    [self.bar addSubview:_titleLable];
  }
  return _titleLable;
}

- (UIView *)coverView {
  if (!_coverView) {
    UIView *coverView = [[UIView alloc] initWithFrame:CGRectZero];
    coverView.backgroundColor = [UIColor ne_colorWithHex:0x1D1D24 alpha:0.9];
    _coverView = coverView;
    [self.bar addSubview:coverView];
  }
  return _coverView;
}

- (UITableView *)listView {
  if (!_listView) {
    UITableView *tableview = [[UITableView alloc] initWithFrame:CGRectZero];
    tableview.delegate = self;
    tableview.dataSource = self;
    [tableview registerClass:[NEListenTogetherUIConnectListCell class]
        forCellReuseIdentifier:[NEListenTogetherUIConnectListCell description]];
    tableview.backgroundColor = [UIColor ne_colorWithHex:0x1D1D24 alpha:0.9];
    [tableview setSeparatorColor:[UIColor ne_colorWithHex:0xE2E2E2]];
    [tableview setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    _listView = tableview;
    [self.bar addSubview:_listView];
  }
  return _listView;
}

- (NEListenTogetherUIConnectAlertView *)connectAlertView {
  if (!_connectAlertView) {
    _connectAlertView = [[NEListenTogetherUIConnectAlertView alloc] init];
    __weak typeof(self) weakSelf = self;
    _connectAlertView.actionBlock = ^{
      __strong typeof(self) strongSelf = weakSelf;
      strongSelf.listViewPushed ? [strongSelf dismissListView] : [strongSelf showListView];
    };
    [self.bar addSubview:_connectAlertView];
  }
  return _connectAlertView;
}

- (UIButton *)foldBtn {
  if (!_foldBtn) {
    _foldBtn = [[UIButton alloc] init];
    _foldBtn.backgroundColor = [UIColor ne_colorWithHex:0x1D1D24 alpha:0.9];

    NSMutableAttributedString *res = [[NSMutableAttributedString alloc]
        initWithString:NELocalizedString(@"收起")
            attributes:@{
              NSForegroundColorAttributeName : [UIColor whiteColor],
              NSFontAttributeName : [UIFont systemFontOfSize:14.0]
            }];
    NSTextAttachment *attchment = [[NSTextAttachment alloc] init];
    attchment.bounds = CGRectMake(0, -2, 14, 14);
    attchment.image = [NEListenTogetherUI ne_listen_imageName:@"up_ico_14"];
    NSAttributedString *icoStr = [NSAttributedString attributedStringWithAttachment:attchment];
    [res appendAttributedString:icoStr];

    [_foldBtn setAttributedTitle:[res copy] forState:UIControlStateNormal];
    [_foldBtn addTarget:self
                  action:@selector(foldConnectList:)
        forControlEvents:UIControlEventTouchUpInside];
    [self.bar addSubview:_foldBtn];
  }
  return _foldBtn;
}
@end
