// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEChatRoomListViewController.h"
#import <MJRefresh/MJRefresh.h>
#import <Masonry/Masonry.h>
#import <NEUIKit/UIImage+NEUIExtension.h>
#import <NEVoiceRoomKit/NEVoiceRoomKit-Swift.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import "NEChatroomListViewModel.h"
#import "NEOpenRoomViewController.h"
#import "NEUIDeviceSizeInfo.h"
#import "NEUIEmptyListView.h"
#import "NEUILiveListCell.h"
#import "NEUIViewFactory.h"
#import "NEVoiceRoomFloatWindowSingleton.h"
#import "NEVoiceRoomToast.h"
#import "NEVoiceRoomUI.h"
#import "NEVoiceRoomViewController.h"
#import "NSBundle+NELocalized.h"
#import "NSString+NTES.h"
#import "NTESGlobalMacro.h"
#import "UIView+NEUIExtension.h"

@interface NEChatRoomListViewController () <UICollectionViewDelegate,
                                            UICollectionViewDataSource,
                                            UIAlertViewDelegate>
@property(nonatomic, strong) UICollectionView *collectionView;
@property(nonatomic, strong) UIButton *createLiveRoomButton;
@property(nonatomic, strong) NEUIEmptyListView *emptyView;
@property(nonatomic, strong) NEChatroomListViewModel *roomListViewModel;
@property(nonatomic, assign) BOOL hasEntered;
/// 是否已进入房间，亦可做防重点击
@property(nonatomic, assign) BOOL isEnterRoom;
/// 在线人数
@property(nonatomic, assign) NSInteger onlineCount;

/// 选中Info 信息
@property(nonatomic, strong) NEVoiceRoomInfo *roomInfoModel;
@end

@implementation NEChatRoomListViewController

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  //  if (!self.hasEntered) {
  //    [self getNewData];
  //  }
  //  self.hasEntered = YES;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  if (@available(iOS 13.0, *)) {
    UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];

    [appearance configureWithOpaqueBackground];

    NSMutableDictionary *textAttribute = [NSMutableDictionary dictionary];
    textAttribute[NSForegroundColorAttributeName] = [UIColor blackColor];  // 标题颜色
    textAttribute[NSFontAttributeName] = [UIFont systemFontOfSize:16];     // 标题大小
    [appearance setTitleTextAttributes:textAttribute];

    // 去除底部黑线
    [appearance setShadowImage:[UIImage ne_imageWithColor:UIColor.clearColor]];

    UIColor *color = [UIColor whiteColor];
    appearance.backgroundColor = color;

    self.navigationController.navigationBar.standardAppearance = appearance;
    self.navigationController.navigationBar.scrollEdgeAppearance = appearance;
  }

  // Do any additional setup after loading the view.
  self.title = NELocalizedString(@"语聊房");

  [self getNewData];
  [self bindViewModel];
  [self setupSubviews];
}

- (void)getNewData {
  [self.roomListViewModel requestNewDataWithLiveType:NEVoiceRoomLiveRoomTypeMultiAudio];
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
      [NEVoiceRoomToast showToast:NELocalizedString(@"直播列表为空")];
    } else {
      NSString *msg =
          err.userInfo[NSLocalizedDescriptionKey] ?: NELocalizedString(@"请求直播列表错误");
      [NEVoiceRoomToast showToast:msg];
    }
  }];
}
- (void)setupSubviews {
  [self.view addSubview:self.collectionView];
  self.emptyView.centerX = self.collectionView.centerX;
  self.emptyView.centerY = self.collectionView.centerY - 100;
  [self.collectionView addSubview:self.emptyView];

  [self.view addSubview:self.createLiveRoomButton];

  [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.right.bottom.equalTo(self.view);
    make.height.mas_equalTo(UIScreenHeight - [NEUIDeviceSizeInfo get_iPhoneNavBarHeight]);
  }];

  [self.createLiveRoomButton mas_makeConstraints:^(MASConstraintMaker *make) {
    make.height.equalTo(@44);
    make.right.equalTo(self.view).offset(-17);
    make.left.equalTo(self.view).offset(17);
    make.bottom.equalTo(self.view).offset(-25);
  }];

  @weakify(self);
  MJRefreshGifHeader *mjHeader = [MJRefreshGifHeader headerWithRefreshingBlock:^{
    @strongify(self);
    [self.roomListViewModel requestNewDataWithLiveType:NEVoiceRoomLiveRoomTypeMultiAudio];
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
      [NEVoiceRoomToast showToast:NELocalizedString(@"无更多内容")];
      [self.collectionView.mj_footer endRefreshing];
    } else {
      [self.roomListViewModel requestMoreDataWithLiveType:NEVoiceRoomLiveRoomTypeMultiAudio];
    }
  }];
}

/// 开始直播
- (void)createChatRoomAction {
  NEOpenRoomViewController *chatRoomCtrl = [[NEOpenRoomViewController alloc] init];
  [self.navigationController pushViewController:chatRoomCtrl animated:YES];
}

#pragma mark - UICollectionView delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
  return [self.roomListViewModel.datas count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  return [NEUILiveListCell cellWithCollectionView:collectionView
                                        indexPath:indexPath
                                            datas:self.roomListViewModel.datas];
}

- (void)collectionView:(UICollectionView *)collectionView
    didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
  if ([self.roomListViewModel.datas count] > indexPath.row) {
    NEVoiceRoomInfo *roomInfoModel = self.roomListViewModel.datas[indexPath.row];
    self.roomInfoModel = roomInfoModel;
    [self audienceEnterLiveRoomWithListInfo:roomInfoModel];
  }
}

// 监听点击事件 代理方法
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
  NSString *btnTitle = [alertView buttonTitleAtIndex:buttonIndex];
  if ([btnTitle isEqualToString:NELocalizedString(@"取消")]) {
  } else if ([btnTitle isEqualToString:NELocalizedString(@"确认")]) {
    [[NEVoiceRoomFloatWindowSingleton Ins]
        clickCloseButton:[NEVoiceRoomFloatWindowSingleton Ins].hasFloatingView ? NO : YES
                callback:^{
                  dispatch_async(dispatch_get_main_queue(), ^{
                    NEVoiceRoomViewController *vc =
                        [[NEVoiceRoomViewController alloc] initWithRole:NEVoiceRoomRoleAudience
                                                                 detail:self.roomInfoModel];
                    [self.navigationController pushViewController:vc animated:YES];
                  });
                }];
  }
}

- (void)audienceEnterLiveRoomWithListInfo:(NEVoiceRoomInfo *)info {
  if ([NEVoiceRoomFloatWindowSingleton Ins].hasFloatingView) {
    if ([NEVoiceRoomFloatWindowSingleton Ins].getRoomUuid &&
        [[NEVoiceRoomFloatWindowSingleton Ins].getRoomUuid
            isEqualToString:info.liveModel.roomUuid]) {
      [[NEVoiceRoomFloatWindowSingleton Ins] dragButtonClicked:nil];
      return;
    }
    UIAlertView *alertView =
        [[UIAlertView alloc] initWithTitle:NELocalizedString(@"提示")
                                   message:NELocalizedString(@"是否退出当前房间进入其他房间")
                                  delegate:self
                         cancelButtonTitle:NELocalizedString(@"取消")
                         otherButtonTitles:NELocalizedString(@"确认"), nil];  // 一般在if判断中加入
    [alertView show];

  } else {
    NSLog(@"列表点击");
    [NSNotificationCenter.defaultCenter
        postNotification:[NSNotification notificationWithName:@"chatroomEnter" object:nil]];
    NEVoiceRoomViewController *vc =
        [[NEVoiceRoomViewController alloc] initWithRole:NEVoiceRoomRoleAudience detail:info];
    [self.navigationController pushViewController:vc animated:YES];
  }
}

#pragma mark - lazy load
- (UICollectionView *)collectionView {
  if (!_collectionView) {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = [NEUILiveListCell size];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.minimumInteritemSpacing = 8;
    layout.minimumLineSpacing = 8;
    layout.sectionInset = UIEdgeInsetsMake(8, 8, 8, 8);

    _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds
                                         collectionViewLayout:layout];
    _collectionView.backgroundColor = UIColor.whiteColor;
    [_collectionView registerClass:[NEUILiveListCell class]
        forCellWithReuseIdentifier:[NEUILiveListCell description]];
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
    _createLiveRoomButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_createLiveRoomButton setTitle:NELocalizedString(@"开始直播") forState:UIControlStateNormal];
    _createLiveRoomButton.imageEdgeInsets = UIEdgeInsetsMake(0, -5, 0, 5);
    _createLiveRoomButton.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, -5);
    [_createLiveRoomButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_createLiveRoomButton setImage:[NEVoiceRoomUI ne_voice_imageName:@"create_ico"]
                           forState:UIControlStateNormal];
    _createLiveRoomButton.backgroundColor = [UIColor colorWithRed:0.2 green:0.494 blue:1 alpha:1];
    [_createLiveRoomButton addTarget:self
                              action:@selector(createChatRoomAction)
                    forControlEvents:UIControlEventTouchUpInside];
    _createLiveRoomButton.layer.cornerRadius = 22;
  }
  return _createLiveRoomButton;
}

- (NEUIEmptyListView *)emptyView {
  if (!_emptyView) {
    _emptyView = [[NEUIEmptyListView alloc] initWithFrame:CGRectZero];
  }
  return _emptyView;
}

- (NEChatroomListViewModel *)roomListViewModel {
  if (!_roomListViewModel) {
    _roomListViewModel = [[NEChatroomListViewModel alloc] init];
  }
  return _roomListViewModel;
}
@end
