// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEChatRoomListViewController.h"
#import <MJRefresh/MJRefresh.h>
#import <Masonry/Masonry.h>
#import <NEUIKit/NEUIKit.h>
#import <NEUIKit/UIImage+NEUIExtension.h>
#import <NEVoiceRoomKit/NEVoiceRoomKit-Swift.h>
#import "NEUIDeviceSizeInfo.h"
#import "NEUILiveListCell.h"
#import "NEUIViewFactory.h"
#import "NEVoiceRoomLocalized.h"
#import "NEVoiceRoomToast.h"
#import "NEVoiceRoomUI.h"
#import "NEVoiceRoomUIManager.h"
#import "NEVoiceRoomViewController.h"
#import "NSString+NTES.h"
#import "NTESGlobalMacro.h"
#import "UIView+NEUIExtension.h"
@import NEVoiceRoomBaseUIKit;
@import NESocialUIKit;

@interface NEChatRoomListViewController () <UICollectionViewDelegate,
                                            UICollectionViewDataSource,
                                            UIAlertViewDelegate>
@property(nonatomic, strong) UICollectionView *collectionView;
@property(nonatomic, strong) UIButton *createLiveRoomButton;
@property(nonatomic, strong) NESocialRoomListEmptyView *emptyView;
@property(nonatomic, strong) NEVRBaseRoomListViewModel *roomListViewModel;
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
  [self.navigationController setNavigationBarHidden:NO animated:YES];
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
  [self.roomListViewModel requestNewData];
}
- (void)bindViewModel {
  __weak typeof(self) weakSelf = self;
  self.roomListViewModel.datasChanged = ^(NSArray<NEVoiceRoomInfo *> *_Nonnull datas) {
    ntes_main_sync_safe(^{
      [weakSelf.collectionView reloadData];
      weakSelf.emptyView.hidden = [datas count] > 0;
    });
  };

  self.roomListViewModel.isLoadingChanged = ^(BOOL isLoading) {
    if (!isLoading) {
      [weakSelf.collectionView.mj_header endRefreshing];
      [weakSelf.collectionView.mj_footer endRefreshing];
    }
  };

  self.roomListViewModel.errorChanged = ^(NSError *_Nonnull error) {
    if (!error || ![error isKindOfClass:[NSError class]]) return;
    if (error.code == NEVRBaseRoomListViewModel.EMPTY_LIST_ERROR) {
      [NEVoiceRoomToast showToast:NELocalizedString(@"直播列表为空")];
    } else if (error.code == NEVRBaseRoomListViewModel.NO_NETWORK_ERROR) {
      [NEVoiceRoomToast showToast:NELocalizedString(@"网络异常，请稍后重试")];
    } else {
      NSString *msg =
          error.userInfo[NSLocalizedDescriptionKey] ?: NELocalizedString(@"请求直播列表错误");
      [NEVoiceRoomToast showToast:msg];
    }
  };
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

  __weak typeof(self) weakSelf = self;
  MJRefreshGifHeader *mjHeader = [MJRefreshGifHeader headerWithRefreshingBlock:^{
    [weakSelf.roomListViewModel requestNewData];
  }];
  [mjHeader setTitle:NELocalizedString(@"下拉更新") forState:MJRefreshStateIdle];
  [mjHeader setTitle:NELocalizedString(@"下拉更新") forState:MJRefreshStatePulling];
  [mjHeader setTitle:NELocalizedString(@"更新中...") forState:MJRefreshStateRefreshing];
  mjHeader.lastUpdatedTimeLabel.hidden = YES;
  [mjHeader setTintColor:[UIColor whiteColor]];
  self.collectionView.mj_header = mjHeader;

  self.collectionView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
    if (weakSelf.roomListViewModel.isEnd) {
      [NEVoiceRoomToast showToast:NELocalizedString(@"无更多内容")];
      [weakSelf.collectionView.mj_footer endRefreshing];
    } else {
      [weakSelf.roomListViewModel requestMoreData];
    }
  }];
}

/// 开始直播
- (void)createChatRoomAction {
  NEVRBaseCreateViewController *view = [[NEVRBaseCreateViewController alloc] init];
  //  view.ne_UINavigationItem.navigationBarHidden = YES;
  __weak typeof(self) weakSelf = self;
  view.createAction = ^(NSString *_Nonnull name, NSString *_Nonnull image, UIButton *button) {
    if (NESocialFloatWindow.instance.hasFloatWindow) {
      // 当前存在小窗，要给用户弹窗提示
      [weakSelf checkBeforeCreateWithName:name image:image button:button];
    } else {
      [weakSelf createActionWithName:name image:image button:button];
    }
  };
  [self.navigationController pushViewController:view animated:YES];
}

- (void)createActionWithName:(NSString *)name image:(NSString *)image button:(UIButton *)button {
  [NSNotificationCenter.defaultCenter
      postNotification:[NSNotification notificationWithName:@"chatroomStartLive" object:nil]];
  NECreateVoiceRoomParams *params = [[NECreateVoiceRoomParams alloc] init];
  params.liveTopic = name;
  params.seatCount = 9;
  params.cover = image;
  params.liveType = NEVoiceRoomLiveRoomTypeMultiAudio;
  params.configId = NEVoiceRoomUIManager.sharedInstance.configId;
  [NEVoiceRoomToast showLoading];
  [[NEVoiceRoomKit getInstance]
      createRoom:params
         options:[[NECreateVoiceRoomOptions alloc] init]
        callback:^(NSInteger code, NSString *_Nullable msg, NEVoiceRoomInfo *_Nullable obj) {
          [NEVoiceRoomToast hideLoading];
          dispatch_async(dispatch_get_main_queue(), ^{
            button.enabled = true;
            if (code == 0) {
              NEVoiceRoomViewController *vc =
                  [[NEVoiceRoomViewController alloc] initWithRole:NEVoiceRoomRoleHost detail:obj];
              [self.navigationController pushViewController:vc animated:true];
            } else if (code == 2001) {
              NESocialAuthenticationViewController *view =
                  [[NESocialAuthenticationViewController alloc] init];
              __weak typeof(view) weakView = view;
              view.authenticateAction = ^(NSString *_Nonnull name, NSString *_Nonnull cardNo) {
                [[NEVoiceRoomKit getInstance]
                    authenticateWithName:name
                                  cardNo:cardNo
                                callback:^(NSInteger code, NSString *_Nullable msg,
                                           id _Nullable obj) {
                                  dispatch_async(dispatch_get_main_queue(), ^{
                                    if (code == 0) {
                                      [weakView showSuccWithSucc:nil];
                                    } else if (code == NSURLErrorNotConnectedToInternet) {
                                      [NEVoiceRoomToast
                                          showToast:NELocalizedString(@"网络异常，请稍后重试")];
                                    } else {
                                      [weakView showErrorWithError:nil];
                                    }
                                  });
                                }];
              };
              [self.navigationController pushViewController:view animated:true];
            } else {
              [NEVoiceRoomToast showToast:NELocalizedString(@"加入房间失败，请重试！")];
            }
          });
        }];
}

- (void)checkBeforeCreateWithName:(NSString *)name
                            image:(NSString *)image
                           button:(UIButton *)button {
  UIAlertController *alert = [UIAlertController
      alertControllerWithTitle:NELocalizedString(@"提示")
                       message:NELocalizedString(@"是否退出当前房间，并创建新房间")
                preferredStyle:UIAlertControllerStyleAlert];
  [alert addAction:[UIAlertAction actionWithTitle:NELocalizedString(@"取消")
                                            style:UIAlertActionStyleCancel
                                          handler:^(UIAlertAction *_Nonnull action) {
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                              button.enabled = true;
                                            });
                                          }]];
  __weak typeof(self) weakSelf = self;
  [alert addAction:[UIAlertAction actionWithTitle:NELocalizedString(@"确认")
                                            style:UIAlertActionStyleDefault
                                          handler:^(UIAlertAction *_Nonnull action) {
                                            NESocialFloatWindow.instance.closeAction(^{
                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                [weakSelf createActionWithName:name
                                                                         image:image
                                                                        button:button];
                                              });
                                            });
                                          }]];
  [self presentViewController:alert animated:YES completion:nil];
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
    __weak typeof(self) weakSelf = self;
    NESocialFloatWindow.instance.closeAction(^{
      dispatch_async(dispatch_get_main_queue(), ^{
        NEVoiceRoomViewController *vc =
            [[NEVoiceRoomViewController alloc] initWithRole:NEVoiceRoomRoleAudience
                                                     detail:weakSelf.roomInfoModel];
        [weakSelf.navigationController pushViewController:vc animated:YES];
      });
    });
  }
}

- (void)audienceEnterLiveRoomWithListInfo:(NEVoiceRoomInfo *)info {
  if (NESocialFloatWindow.instance.hasFloatWindow) {
    if ([NESocialFloatWindow.instance.roomUuid isEqualToString:info.liveModel.roomUuid]) {
      NESocialFloatWindow.instance.button.clickAction();
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
    [self.navigationController pushViewController:vc animated:true];
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

- (NESocialRoomListEmptyView *)emptyView {
  if (!_emptyView) {
    _emptyView = [[NESocialRoomListEmptyView alloc] initWithFrame:CGRectZero];
  }
  return _emptyView;
}

- (NEVRBaseRoomListViewModel *)roomListViewModel {
  if (!_roomListViewModel) {
    _roomListViewModel =
        [[NEVRBaseRoomListViewModel alloc] initWithLiveType:NEVoiceRoomLiveRoomTypeMultiAudio];
  }
  return _roomListViewModel;
}
@end
