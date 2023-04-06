// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEMenuViewController.h"
#import <Masonry/Masonry.h>
#import <NEListenTogetherUIKit/NEListenTogetherRoomListViewController.h>
#import <NEUIKit/NEUIBackNavigationController.h>
#import <NEVoiceRoomUIKit/NEChatRoomListViewController.h>
#import "AppKey.h"
#import "NEMenuCell.h"
#import "NEMenuHeader.h"
#import "NENavCustomView.h"
#import "UIView+Toast.h"
#import "ViewController.h"
@interface NEMenuViewController () <UITableViewDelegate,
                                    UITableViewDataSource,
                                    UINavigationControllerDelegate>
@property(strong, nonatomic) UITableView *tableView;
@property(strong, nonatomic) UIImageView *bgImageView;
@property(nonatomic, strong) NSArray *datas;
@end

@implementation NEMenuViewController
- (void)viewDidLoad {
  [super viewDidLoad];

  //  self.navigationController.delegate = self;
  self.ne_UINavigationItem.navigationBarHidden = YES;
  [self setupDatas];
  [self setupUI];
  [self.tableView reloadData];
}

#pragma mark - private
- (void)setupDatas {
  NEMenuCellModel *live = [[NEMenuCellModel alloc]
      initWithTitle:NSLocalizedString(@"语聊", nil)
           subtitle:NSLocalizedString(
                        @"6-8人语聊房，玩家可自由发言，实现线上兴趣/话题式语聊互动场景", nil)
               icon:@"home_chatroom_icon"
              block:^{
                  //        [[NENavigator shared] showLiveListVC];
              }];
  NEMenuCellModel *connectMic = [[NEMenuCellModel alloc]
      initWithTitle:NSLocalizedString(@"一起听", nil)
           subtitle:NSLocalizedString(@"私密房两人听一首歌，操作同步，边听边聊，天涯若比邻", nil)
               icon:@"home_ktv_icon"
              block:^{
                  //        [[NENavigator shared] showLiveListVC];
              }];
  BOOL isOutsea = isOverSea;
  if (isOutsea) {
    _datas = @[ @[ live ] ];
  } else {
    _datas = @[ @[ live, connectMic ] ];
  }
}

- (void)setupUI {
  [self.view addSubview:self.bgImageView];
  [self.bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.edges.mas_equalTo(UIEdgeInsetsZero);
  }];

  NENavCustomView *customView = [[NENavCustomView alloc] init];
  [self.view addSubview:customView];
  CGFloat statusHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
  [customView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.top.right.mas_equalTo(0);
    make.height.mas_equalTo(statusHeight + 80);
  }];

  [self.view addSubview:self.tableView];
  [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.mas_equalTo(customView.mas_bottom);
    make.right.mas_equalTo(-20);
    make.left.mas_equalTo(20);
    make.bottom.mas_equalTo(0);
  }];
}

#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  if ([_datas count] > section) {
    NSArray *arr = _datas[section];
    return [arr count];
  }
  return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return [NEMenuCell height];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  if ([_datas count] > indexPath.section) {
    NSArray *array = _datas[indexPath.section];
    if ([array count] > indexPath.row) {
      NEMenuCellModel *data = array[indexPath.row];
      return [NEMenuCell cellWithTableView:tableView indexPath:indexPath data:data];
    }
  }
  return [NEMenuCell new];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  switch (indexPath.row) {
    case 0: {  // 语聊房
      NEChatRoomListViewController *vc = [[NEChatRoomListViewController alloc] init];
      [self.navigationController pushViewController:vc animated:YES];
    } break;
    default: {  // 一起听
      NEListenTogetherRoomListViewController *vc =
          [[NEListenTogetherRoomListViewController alloc] init];
      [self.navigationController pushViewController:vc animated:YES];
    } break;
  }
}

#pragma mark - property
- (UITableView *)tableView {
  if (!_tableView) {
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [UIView new];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.rowHeight = 104;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_tableView registerClass:[NEMenuCell class]
        forCellReuseIdentifier:NSStringFromClass(NEMenuCell.class)];
  }
  return _tableView;
}

- (UIImageView *)bgImageView {
  if (!_bgImageView) {
    _bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"menu_bg"]];
  }
  return _bgImageView;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
  return UIStatusBarStyleLightContent;
}

@end
