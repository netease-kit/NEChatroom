// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEListenTogetherRoomListViewController.h"
#import <MJRefresh/MJRefresh.h>
#import <Masonry/Masonry.h>
#import <NEListenTogetherKit/NEListenTogetherKit-Swift.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import "NEListenTogetherGlobalMacro.h"
#import "NEListenTogetherOpenRoomViewController.h"
#import "NEListenTogetherRoomListViewModel.h"
#import "NEListenTogetherToast.h"
#import "NEListenTogetherUI.h"
#import "NEListenTogetherUIDeviceSizeInfo.h"
#import "NEListenTogetherUIEmptyListView.h"
#import "NEListenTogetherUILiveListCell.h"
#import "NEListenTogetherUIViewFactory.h"
#import "NEListenTogetherViewController.h"
#import "NSBundle+NEListenTogetherLocalized.h"
#import "NSString+NEListenTogetherString.h"
#import "UIView+NEUIExtension.h"

@interface NEListenTogetherRoomListViewController () <UICollectionViewDelegate,
                                                      UICollectionViewDataSource>
@property(nonatomic, strong) UICollectionView *collectionView;
@property(nonatomic, strong) UIButton *createLiveRoomButton;
@property(nonatomic, strong) NEListenTogetherUIEmptyListView *emptyView;
@property(nonatomic, strong) NEListenTogetherRoomListViewModel *roomListViewModel;
@property(nonatomic, assign) BOOL hasEntered;
/// 是否已进入房间，亦可做防重点击
@property(nonatomic, assign) BOOL isEnterRoom;
/// 在线人数
@property(nonatomic, assign) NSInteger onlineCount;
@end

@implementation NEListenTogetherRoomListViewController

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  //  if (!self.hasEntered) {
  //    [self getNewData];
  //  }
  //  self.hasEntered = YES;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  self.title = [NSBundle ne_localizedStringForKey:@"一起听"];

  [self getNewData];
  [self bindViewModel];
  [self setupSubviews];
}

- (void)getNewData {
  [self.roomListViewModel requestNewDataWithLiveType:NEListenTogetherLiveRoomTypeListen_together];
}
- (void)bindViewModel {
  @weakify(self);
  [RACObserve(self.roomListViewModel, datas) subscribeNext:^(NSArray *array) {
    @strongify(self);
    ntes_main_sync_safe(^{
      [self.collectionView reloadData];
      self.emptyView.hidden = [array count] > 0;
    });
  }];

  [RACObserve(self.roomListViewModel, isLoading) subscribeNext:^(id _Nullable x) {
    @strongify(self);
    if (self.roomListViewModel.isLoading == NO) {
      [self.collectionView.mj_header endRefreshing];
      [self.collectionView.mj_footer endRefreshing];
    }
  }];

  [RACObserve(self.roomListViewModel, error) subscribeNext:^(NSError *_Nullable err) {
    if (!err || ![err isKindOfClass:[NSError class]]) return;
    if (err.code == 1003) {
      [NEListenTogetherToast showToast:NELocalizedString(@"直播列表为空")];
    } else {
      NSString *msg =
          err.userInfo[NSLocalizedDescriptionKey] ?: NELocalizedString(@"请求直播列表错误");
      [NEListenTogetherToast showToast:msg];
    }
  }];
}
- (void)setupSubviews {
  [self.view addSubview:self.collectionView];

  self.emptyView.centerX = self.collectionView.centerX;
  self.emptyView.centerY = self.collectionView.centerY - 40;
  [self.collectionView addSubview:self.emptyView];

  [self.view addSubview:self.createLiveRoomButton];

  [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.right.bottom.equalTo(self.view);
    make.height.mas_equalTo(UIScreenHeight -
                            [NEListenTogetherUIDeviceSizeInfo get_iPhoneNavBarHeight]);
  }];

  [self.createLiveRoomButton mas_makeConstraints:^(MASConstraintMaker *make) {
    make.size.mas_equalTo(CGSizeMake(90, 90));
    make.right.equalTo(self.view).offset(-20);
    make.bottom.equalTo(self.view).offset(
        -[NEListenTogetherUIDeviceSizeInfo get_iPhoneTabBarHeight]);
  }];

  @weakify(self);
  MJRefreshGifHeader *mjHeader = [MJRefreshGifHeader headerWithRefreshingBlock:^{
    @strongify(self);
    [self.roomListViewModel requestNewDataWithLiveType:NEListenTogetherLiveRoomTypeListen_together];
  }];
  [mjHeader setTitle:NELocalizedString(@"下拉更新") forState:MJRefreshStateIdle];
  [mjHeader setTitle:NELocalizedString(@"下拉更新") forState:MJRefreshStatePulling];
  [mjHeader setTitle:NELocalizedString(@"更新中...") forState:MJRefreshStateRefreshing];
  mjHeader.lastUpdatedTimeLabel.hidden = YES;
  [mjHeader setTintColor:[UIColor whiteColor]];
  self.collectionView.mj_header = mjHeader;

  self.collectionView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
    @strongify(self);
    if (self.roomListViewModel.isEnd) {
      [NEListenTogetherToast showToast:NELocalizedString(@"无更多内容")];
      [self.collectionView.mj_footer endRefreshing];
    } else {
      [self.roomListViewModel
          requestMoreDataWithLiveType:NEListenTogetherLiveRoomTypeListen_together];
    }
  }];
}

/// 开始直播
- (void)createChatRoomAction {
  NEListenTogetherOpenRoomViewController *chatRoomCtrl =
      [[NEListenTogetherOpenRoomViewController alloc] init];
  [self.navigationController pushViewController:chatRoomCtrl animated:YES];
}

#pragma mark - UICollectionView delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
  return [self.roomListViewModel.datas count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  return [NEListenTogetherUILiveListCell cellWithCollectionView:collectionView
                                                      indexPath:indexPath
                                                          datas:self.roomListViewModel.datas];
}

- (void)collectionView:(UICollectionView *)collectionView
    didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
  if ([self.roomListViewModel.datas count] > indexPath.row) {
    NEListenTogetherInfo *roomInfoModel = self.roomListViewModel.datas[indexPath.row];
    [[NEListenTogetherKit getInstance]
        getRoomInfo:roomInfoModel.liveModel.liveRecordId
           callback:^(NSInteger code, NSString *_Nullable msg,
                      NEListenTogetherInfo *_Nullable info) {
             if (code == NEListenTogetherErrorCode.success) {
               if (info.liveModel.audienceCount > 0) {
                 [NEListenTogetherToast showToast:NELocalizedString(@"私密房内人数已满")];
               } else {
                 dispatch_async(dispatch_get_main_queue(), ^{
                   [self audienceEnterLiveRoomWithListInfo:roomInfoModel];
                 });
               }
             } else {
               [NEListenTogetherToast showToast:NELocalizedString(@"请稍后再试")];
             }
           }];
  }
}

- (void)audienceEnterLiveRoomWithListInfo:(NEListenTogetherInfo *)info {
  NEListenTogetherViewController *vc =
      [[NEListenTogetherViewController alloc] initWithRole:NEListenTogetherRoleAudience
                                                    detail:info];
  [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - lazy load
- (UICollectionView *)collectionView {
  if (!_collectionView) {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = [NEListenTogetherUILiveListCell size];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.minimumInteritemSpacing = 8;
    layout.minimumLineSpacing = 8;
    layout.sectionInset = UIEdgeInsetsMake(8, 8, 8, 8);

    _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds
                                         collectionViewLayout:layout];
    _collectionView.backgroundColor = UIColor.whiteColor;
    [_collectionView registerClass:[NEListenTogetherUILiveListCell class]
        forCellWithReuseIdentifier:[NEListenTogetherUILiveListCell description]];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.showsVerticalScrollIndicator = NO;
    if (@available(iOS 11.0, *)) {
      _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
  }
  return _collectionView;
}

- (UIButton *)createLiveRoomButton {
  if (!_createLiveRoomButton) {
    _createLiveRoomButton =
        [NEListenTogetherUIViewFactory createBtnFrame:CGRectZero
                                                title:@""
                                              bgImage:NELocalizedString(@"start_live_icon")
                                        selectBgImage:@""
                                                image:@""
                                               target:self
                                               action:@selector(createChatRoomAction)];
  }
  return _createLiveRoomButton;
}

- (NEListenTogetherUIEmptyListView *)emptyView {
  if (!_emptyView) {
    _emptyView = [[NEListenTogetherUIEmptyListView alloc] initWithFrame:CGRectZero];
    _emptyView.tintColor = HEXCOLOR(0xE6E7EB);
  }
  return _emptyView;
}

- (NEListenTogetherRoomListViewModel *)roomListViewModel {
  if (!_roomListViewModel) {
    _roomListViewModel = [[NEListenTogetherRoomListViewModel alloc] init];
  }
  return _roomListViewModel;
}
@end
