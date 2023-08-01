// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEVoiceRoomSendGiftViewController.h"
#import <Masonry/Masonry.h>
#import <NEUIKit/UIImage+NEUIExtension.h>
#import "NEInnerSingleton.h"
#import "NEUIActionSheetNavigationController.h"
#import "NEVoiceRoomGiftEngine.h"
#import "NEVoiceRoomGiftNumCell.h"
#import "NEVoiceRoomGiftToCell.h"
#import "NEVoiceRoomLocalized.h"
#import "NEVoiceRoomPopover.h"
#import "NEVoiceRoomSendGiftCell.h"
#import "NEVoiceRoomToast.h"
#import "NEVoiceRoomUI.h"
#import "NEVoiceRoomUILog.h"
#import "NTESGlobalMacro.h"

@interface NEVoiceRoomSendGiftViewController () <UICollectionViewDelegate,
                                                 UICollectionViewDataSource,
                                                 UITableViewDataSource,
                                                 UITableViewDelegate>

/// 代理
@property(nonatomic, weak) id<NEVoiceRoomSendGiftViewtDelegate> giftDelegate;
/// 礼物展示视图
@property(nonatomic, strong) UICollectionView *collectionView;
/// 发送按钮
//@property(nonatomic, strong) UIButton *sendBtn;
// 发送父视图
@property(nonatomic, strong) UIView *bottomSendGiftView;
// 发送礼物箭头
@property(nonatomic, strong) UIButton *bottomSendGiftIcon;
// 发送礼物个数
@property(nonatomic, strong) UILabel *bottomSendGiftNumberLabel;
// 发送礼物按钮
@property(nonatomic, strong) UIButton *bottomSendGiftButton;
/// 礼物数组
@property(nonatomic, strong) NSArray<NEVoiceRoomUIGiftModel *> *gifts;
/// 礼物个数数组
@property(nonatomic, strong) NSArray *giftNumbers;
/// 礼物个数视图
@property(nonatomic, strong) UIView *giftNumSuperView;
/// 礼物个数列表的底部指向箭头
@property(nonatomic, strong) UIImageView *giftNumImageView;
/// 礼物个数列表
@property(nonatomic, strong) UITableView *giftNumTableView;
/// 选中的礼物
@property(nonatomic, strong) NEVoiceRoomUIGiftModel *selectedGift;

@property(nonatomic, strong) CAGradientLayer *buttonBackground;

// 赠送Label
@property(nonatomic, strong) UILabel *giftToLabel;

// 赠送对象列表
@property(nonatomic, strong) UICollectionView *giftToCollectionView;

@property(nonatomic, strong) NEVoiceRoomPopover *btnPopover;

@end

@implementation NEVoiceRoomSendGiftViewController

@synthesize anchorMicInfo = _anchorMicInfo, datas = _datas;

+ (NEVoiceRoomSendGiftViewController *)showWithTarget:(id<NEVoiceRoomSendGiftViewtDelegate>)target
                                       viewController:(UIViewController *)viewController {
  NEVoiceRoomSendGiftViewController *vc = [[NEVoiceRoomSendGiftViewController alloc] init];
  vc.giftDelegate = target;
  NEUIActionSheetNavigationController *nav =
      [[NEUIActionSheetNavigationController alloc] initWithRootViewController:vc];
  nav.dismissOnTouchOutside = YES;
  [viewController presentViewController:nav animated:YES completion:nil];
  return vc;
}

- (instancetype)init {
  if ([super init]) {
    self.gifts = [NEVoiceRoomUIGiftModel defaultGifts];
    self.giftNumbers = @[ @1314, @520, @66, @20, @6, @1 ];
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  /// 设置背景色
  if (@available(iOS 13.0, *)) {
    UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
    [appearance configureWithOpaqueBackground];
    NSMutableDictionary *textAttribute = [NSMutableDictionary dictionary];
    textAttribute[NSForegroundColorAttributeName] = HEXCOLOR(0x222222);     // 标题颜色
    textAttribute[NSFontAttributeName] = [UIFont boldSystemFontOfSize:18];  // 标题大小
    [appearance setTitleTextAttributes:textAttribute];

    // 去除底部黑线
    [appearance setShadowImage:[UIImage ne_imageWithColor:UIColor.clearColor]];

    UIColor *color = [UIColor whiteColor];
    appearance.backgroundColor = color;

    self.navigationController.navigationBar.standardAppearance = appearance;
    self.navigationController.navigationBar.scrollEdgeAppearance = appearance;
  } else {
    // Fallback on earlier versions
  }

  self.title = NELocalizedString(@"送礼物");
  self.view.backgroundColor = [UIColor whiteColor];

  //   导航栏下面画个分割线
  CAShapeLayer *lineLayer = [[CAShapeLayer alloc] init];
  lineLayer.strokeColor = HEXCOLOR(0xE6E7EB).CGColor;
  lineLayer.lineWidth = 1.0;
  CGMutablePathRef path = CGPathCreateMutable();
  CGPathMoveToPoint(path, NULL, 0, 5);
  CGPathAddLineToPoint(path, NULL, self.view.frame.size.width, 5);
  lineLayer.path = path;
  [self.view.layer addSublayer:lineLayer];

  [self setupSubView];

  __weak typeof(self) weakSelf = self;
  self.btnPopover.willDismissHandler = ^{
    weakSelf.bottomSendGiftIcon.selected = !weakSelf.bottomSendGiftIcon.selected;
  };

  [NEVoiceRoomUILog infoLog:@"GetSeatInfo" desc:[NSString stringWithFormat:@"%s", __FUNCTION__]];
  [self getSeatInfo];

  [self collectionView:self.collectionView
      didSelectItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
}

- (void)setDatas:(NSArray<NEVoiceRoomSeatItem *> *)datas {
  _datas = datas;
  ntes_main_async_safe(^{
    [self.giftToCollectionView reloadData];
  });
}

- (void)setAnchorMicInfo:(NEVoiceRoomSeatItem *)anchorMicInfo {
  _anchorMicInfo = anchorMicInfo;
  ntes_main_async_safe(^{
    [self.giftToCollectionView reloadData];
  });
}

- (void)setupSubView {
  [self.view addSubview:self.collectionView];
  [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(self.view).offset(79 + 4);
    make.left.right.equalTo(self.view);
    make.height.mas_equalTo(100);
  }];

  [self.view addSubview:self.giftToLabel];
  [self.giftToLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self.view);
    make.top.equalTo(self.view).offset(28);
    make.width.equalTo(@32);
  }];

  [self.view addSubview:self.giftToCollectionView];
  [self.giftToCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self.giftToLabel.mas_right);
    make.top.equalTo(self.view).offset(16 + 4);
    make.right.equalTo(self.view).offset(-6);
    make.height.equalTo(@47);
  }];

  //   导航栏下面画个分割线
  CAShapeLayer *lineLayer = [[CAShapeLayer alloc] init];
  lineLayer.strokeColor = HEXCOLOR(0xE6E7EB).CGColor;
  lineLayer.lineWidth = 1.0;
  CGMutablePathRef path = CGPathCreateMutable();
  CGPathMoveToPoint(path, NULL, 0, 197);
  CGPathAddLineToPoint(path, NULL, self.view.frame.size.width, 197);
  lineLayer.path = path;
  [self.view.layer addSublayer:lineLayer];

  [self.view addSubview:self.bottomSendGiftView];
  [self.bottomSendGiftView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(self.collectionView.mas_bottom).offset(26);
    make.width.equalTo(@144);
    make.height.equalTo(@32);
    make.right.equalTo(self.view).offset(-12);
  }];

  [self.bottomSendGiftView addSubview:self.bottomSendGiftIcon];
  [self.bottomSendGiftIcon mas_makeConstraints:^(MASConstraintMaker *make) {
    make.centerY.equalTo(self.bottomSendGiftView);
    make.left.equalTo(self.bottomSendGiftView).offset(11);
    make.width.height.equalTo(@20);
  }];
  [self.bottomSendGiftView addSubview:self.bottomSendGiftNumberLabel];
  [self.bottomSendGiftNumberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.centerY.equalTo(self.bottomSendGiftIcon);
    make.left.equalTo(self.bottomSendGiftIcon).offset(20);
    make.width.equalTo(@35);
    make.top.bottom.equalTo(self.bottomSendGiftView);
  }];

  [self.bottomSendGiftView addSubview:self.bottomSendGiftButton];
  [self.bottomSendGiftButton mas_makeConstraints:^(MASConstraintMaker *make) {
    make.right.equalTo(self.bottomSendGiftView).offset(-2);
    make.centerY.equalTo(self.bottomSendGiftView);
    make.width.equalTo(@60);
    make.height.equalTo(@28);
  }];

  /// 礼物数量列表视图
  //  [self.view addSubview:self.giftNumSuperView];
  //  [self.giftNumSuperView mas_makeConstraints:^(MASConstraintMaker *make) {
  //    make.width.equalTo(@120);
  //    make.height.equalTo(@193);
  //    make.bottom.equalTo(self.bottomSendGiftView.mas_top).offset(-4);
  //    make.right.equalTo(self.view).offset(-40);
  //  }];
  //
  [self.giftNumSuperView addSubview:self.giftNumImageView];
  [self.giftNumImageView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.width.height.equalTo(@10);
    make.centerX.equalTo(self.giftNumSuperView);
    make.bottom.equalTo(self.giftNumSuperView);
  }];

  [self.giftNumSuperView addSubview:self.giftNumTableView];
  [self.giftNumTableView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.left.right.equalTo(self.giftNumSuperView);
    make.bottom.equalTo(self.giftNumSuperView).offset(-10);
  }];

  [self.view layoutIfNeeded];
  //  [self.view bringSubviewToFront:self.giftNumSuperView];
  [self.bottomSendGiftButton.layer insertSublayer:self.buttonBackground atIndex:0];
}

#pragma mark - 获取麦位信息
- (void)getSeatInfo {
  [NEVoiceRoomUILog infoLog:@"GetSeatInfo" desc:[NSString stringWithFormat:@"%s", __FUNCTION__]];
  [NEVoiceRoomKit.getInstance getSeatInfo:^(NSInteger code, NSString *_Nullable msg,
                                            NEVoiceRoomSeatInfo *_Nullable seatInfo) {
    if (code == 0 && seatInfo) {
      dispatch_async(dispatch_get_main_queue(), ^{
        self.anchorMicInfo = [NEInnerSingleton.singleton fetchAnchorItem:seatInfo.seatItems];
        if (!self.datas) {
          self.datas = [NEInnerSingleton.singleton fetchAudienceSeatItems:seatInfo.seatItems];
        }
        [self.giftToCollectionView reloadData];
      });
    }
  }];
}
#pragma mark - getter

- (UIButton *)bottomSendGiftButton {
  if (!_bottomSendGiftButton) {
    _bottomSendGiftButton = [[UIButton alloc] init];
    [_bottomSendGiftButton setTitle:NELocalizedString(@"赠送") forState:UIControlStateNormal];
    _bottomSendGiftButton.layer.masksToBounds = YES;
    _bottomSendGiftButton.layer.cornerRadius = 14;
    [_bottomSendGiftButton addTarget:self
                              action:@selector(sendAction:)
                    forControlEvents:UIControlEventTouchUpInside];
  }
  return _bottomSendGiftButton;
}
- (UIButton *)bottomSendGiftIcon {
  if (!_bottomSendGiftIcon) {
    _bottomSendGiftIcon = [[UIButton alloc] init];
    _bottomSendGiftIcon.selected = NO;
    _bottomSendGiftIcon.backgroundColor = [UIColor clearColor];
    [_bottomSendGiftIcon setImage:[NEVoiceRoomUI ne_voice_imageName:@"send_top_icon"]
                         forState:UIControlStateNormal];
    [_bottomSendGiftIcon setImage:[NEVoiceRoomUI ne_voice_imageName:@"send_bottom_icon"]
                         forState:UIControlStateSelected];
    [_bottomSendGiftIcon addTarget:self
                            action:@selector(showGiftNumListView)
                  forControlEvents:UIControlEventTouchUpInside];
  }
  return _bottomSendGiftIcon;
}
- (UILabel *)giftToLabel {
  if (!_giftToLabel) {
    _giftToLabel = [[UILabel alloc] init];
    _giftToLabel.backgroundColor = [UIColor clearColor];
    _giftToLabel.font = [UIFont systemFontOfSize:10];
    _giftToLabel.textColor = HEXCOLOR(0x666666);
    _giftToLabel.textAlignment = NSTextAlignmentCenter;
    _giftToLabel.text = NELocalizedString(@"送给");
  }
  return _giftToLabel;
}
- (UICollectionView *)giftToCollectionView {
  if (!_giftToCollectionView) {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = [NEVoiceRoomGiftToCell size];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);

    CGRect frame = CGRectZero;
    _giftToCollectionView = [[UICollectionView alloc] initWithFrame:frame
                                               collectionViewLayout:layout];
    _giftToCollectionView.backgroundColor = [UIColor clearColor];
    _giftToCollectionView.delegate = self;
    _giftToCollectionView.dataSource = self;
    _giftToCollectionView.showsHorizontalScrollIndicator = NO;
    [_giftToCollectionView registerClass:[NEVoiceRoomGiftToCell class]
              forCellWithReuseIdentifier:[NEVoiceRoomGiftToCell description]];
    _giftToCollectionView.allowsMultipleSelection = NO;
  }
  return _giftToCollectionView;
}
- (UIView *)bottomSendGiftView {
  if (!_bottomSendGiftView) {
    _bottomSendGiftView = [[UIView alloc] init];
    _bottomSendGiftView.backgroundColor = HEXCOLOR(0xEDEFF2);
    _bottomSendGiftView.layer.masksToBounds = YES;
    _bottomSendGiftView.layer.cornerRadius = 16;
  }
  return _bottomSendGiftView;
}

- (UILabel *)bottomSendGiftNumberLabel {
  if (!_bottomSendGiftNumberLabel) {
    _bottomSendGiftNumberLabel = [[UILabel alloc] init];
    _bottomSendGiftNumberLabel.textColor = HEXCOLOR(0x333333);
    _bottomSendGiftNumberLabel.text = @"1";
    _bottomSendGiftNumberLabel.font = [UIFont systemFontOfSize:14];
    _bottomSendGiftNumberLabel.textAlignment = NSTextAlignmentCenter;
  }
  return _bottomSendGiftNumberLabel;
}

- (UIView *)giftNumSuperView {
  if (!_giftNumSuperView) {
    _giftNumSuperView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 120, 232)];
    _giftNumSuperView.backgroundColor = [UIColor clearColor];
    _giftNumSuperView.layer.masksToBounds = YES;
    _giftNumSuperView.layer.cornerRadius = 4;
    _giftNumSuperView.layer.shadowColor = [UIColor blackColor].CGColor;
    _giftNumSuperView.layer.shadowOpacity = 0.2f;
    _giftNumSuperView.layer.shadowRadius = 4.f;
    _giftNumSuperView.layer.shadowOffset = CGSizeMake(0, 0);
  }
  return _giftNumSuperView;
}

- (UIImageView *)giftNumImageView {
  if (!_giftNumImageView) {
    _giftNumImageView =
        [[UIImageView alloc] initWithImage:[NEVoiceRoomUI ne_voice_imageName:@"gift_bottom_icon"]];
  }
  return _giftNumImageView;
}
- (UICollectionView *)collectionView {
  if (!_collectionView) {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = [NEVoiceRoomSendGiftCell size];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumInteritemSpacing = 5;
    layout.minimumLineSpacing = 5;

    CGRect frame = CGRectZero;
    _collectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:layout];
    _collectionView.backgroundColor = [UIColor clearColor];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.scrollEnabled = NO;
    [_collectionView registerClass:[NEVoiceRoomSendGiftCell class]
        forCellWithReuseIdentifier:[NEVoiceRoomSendGiftCell description]];
    _collectionView.allowsMultipleSelection = NO;
  }
  return _collectionView;
}

- (CAGradientLayer *)buttonBackground {
  if (!_buttonBackground) {
    _buttonBackground = [CAGradientLayer layer];
    NSArray *colors = [NSArray arrayWithObjects:(id)[HEXCOLOR(0x2D78F9) CGColor],
                                                (id)[HEXCOLOR(0x6699FF) CGColor],
                                                (id)[[UIColor blackColor] CGColor], nil];
    [_buttonBackground setColors:colors];
    _buttonBackground.locations = @[ @0, @1 ];
    _buttonBackground.startPoint = CGPointMake(0.25, 0.5);
    _buttonBackground.endPoint = CGPointMake(0.75, 0.5);
    [_buttonBackground setFrame:CGRectMake(0, 0, CGRectGetWidth(self.bottomSendGiftButton.frame),
                                           CGRectGetHeight(self.bottomSendGiftButton.frame))];
    _buttonBackground.cornerRadius = 14;
  }
  return _buttonBackground;
}
- (UITableView *)giftNumTableView {
  if (!_giftNumTableView) {
    _giftNumTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 120, 232)];
    _giftNumTableView.backgroundColor = [UIColor whiteColor];
    [_giftNumTableView registerClass:[NEVoiceRoomGiftNumCell class]
              forCellReuseIdentifier:NEVoiceRoomGiftNumCell.description];
    _giftNumTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _giftNumTableView.delegate = self;
    _giftNumTableView.dataSource = self;
  }
  return _giftNumTableView;
}

- (NEVoiceRoomPopover *)btnPopover {
  if (!_btnPopover) {
    NEVoiceRoomPopoverOption *option = [[NEVoiceRoomPopoverOption alloc] init];
    option.autoAjustDirection = YES;
    option.preferedType = NEVoiceRoomPopoverTypeUp;
    option.arrowSize = CGSizeMake(0, 0);
    option.blackOverlayColor = [UIColor clearColor];
    option.popoverColor = [UIColor clearColor];
    option.cornerRadius = 4;
    option.dismissOnBlackOverlayTap = YES;
    option.animationIn = 0.5;
    _btnPopover = [[NEVoiceRoomPopover alloc] initWithOption:option];
  }
  return _btnPopover;
}

#pragma mark - UICollectionView giftDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
  if (collectionView == self.collectionView) {
    return [_gifts count];
  } else {
    return _datas.count + 1;
  }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  if (collectionView == self.collectionView) {
    NEVoiceRoomSendGiftCell *cell = [NEVoiceRoomSendGiftCell cellWithCollectionView:collectionView
                                                                          indexPath:indexPath
                                                                              datas:_gifts];
    return cell;
  } else {
    NEVoiceRoomGiftToCell *cell = [NEVoiceRoomGiftToCell cellWithCollectionView:collectionView
                                                                      indexPath:indexPath
                                                                     anchorData:_anchorMicInfo
                                                                          datas:_datas];
    return cell;
  }
}

- (void)collectionView:(UICollectionView *)collectionView
    didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
  if (collectionView == self.collectionView) {
    if ([_gifts count] > indexPath.row) {
      _selectedGift = _gifts[indexPath.row];
      _bottomSendGiftButton.enabled = YES;
    }
    [self.collectionView selectItemAtIndexPath:indexPath
                                      animated:YES
                                scrollPosition:UICollectionViewScrollPositionNone];
  } else {
    if (indexPath.row == 0) {
      if (self.anchorMicInfo == nil) {
        return;
      }
    } else {
      if ([self.datas count] + 1 > indexPath.row) {
        NEVoiceRoomSeatItem *seat = self.datas[indexPath.row - 1];
        if (seat.user.length <= 0 && ![[NEVoiceRoomGiftEngine getInstance].selectedSeatDatas
                                         containsObject:[NSNumber numberWithLong:indexPath.row]]) {
          /// 针对case 麦上无人 并且未选中该麦位，直接返回
          return;
        } else if (seat.user.length > 0 &&
                   ![[NEVoiceRoomGiftEngine getInstance].selectedSeatDatas
                       containsObject:[NSNumber numberWithLong:indexPath.row]] &&
                   (seat.status != NEVoiceRoomSeatItemStatusTaken)) {
          /// 针对case 麦上有人 并且未选中该麦位，状态 非 taken 无法选中
          return;
        }
      } else {
        return;
      }
    }

    [[NEVoiceRoomGiftEngine getInstance] updateSelectedSeatDatas:indexPath.row];
    NSLog(@"选中数据 --- %@", [NEVoiceRoomGiftEngine getInstance].selectedSeatDatas);
    [self.giftToCollectionView reloadItemsAtIndexPaths:@[ indexPath ]];
  }
}

#pragma mark - UITableView giftDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.giftNumbers.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  NEVoiceRoomGiftNumCell *cell =
      [NEVoiceRoomGiftNumCell cellWithTableView:tableView
                                      indexPath:indexPath
                                  currentNumber:self.bottomSendGiftNumberLabel.text
                                          datas:self.giftNumbers];
  return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 32;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  if (self.giftNumbers.count > indexPath.row) {
    NSNumber *value = self.giftNumbers[indexPath.row];
    self.bottomSendGiftNumberLabel.text = [NSString stringWithFormat:@"%@", value];
    [self.giftNumTableView reloadData];
    [self.btnPopover dismiss];
  }
}

- (void)sendAction:(UIButton *)sender {
  if (!_selectedGift || [NEVoiceRoomGiftEngine getInstance].selectedSeatDatas.count <= 0) {
    [NEVoiceRoomToast showToast:NELocalizedString(@"未选择送礼对象，无法送礼")];
    return;
  }

  NSMutableArray *userUuids = [NSMutableArray array];
  for (NSNumber *index in [NEVoiceRoomGiftEngine getInstance].selectedSeatDatas) {
    if (index.intValue == 0) {
      NSString *userUuid = self.anchorMicInfo.user;
      if (userUuid && userUuid.length > 0) {
        [userUuids addObject:userUuid];
      }
    } else {
      NEVoiceRoomSeatItem *seat = self.datas[[index intValue] - 1];
      if (seat.user.length > 0) {
        [userUuids addObject:seat.user];
        NSLog(@"user -- %@", seat.user);
      }
    }
  }
  if (userUuids.count <= 0) {
    [NEVoiceRoomToast showToast:NELocalizedString(@"未选择送礼对象，无法送礼")];
    return;
  }
  if (self.giftDelegate &&
      [self.giftDelegate respondsToSelector:@selector(didSendGift:giftCount:userUuids:)]) {
    [self.giftDelegate didSendGift:_selectedGift
                         giftCount:[self.bottomSendGiftNumberLabel.text intValue]
                         userUuids:userUuids];
  }
}

- (void)showGiftNumListView {
  NSLog(@"页面点击");
  self.bottomSendGiftIcon.selected = !self.bottomSendGiftIcon.selected;
  [self.btnPopover show:self.giftNumSuperView
               fromView:self.bottomSendGiftNumberLabel];  // in delegate window
}
#pragma mark - Present Size

- (CGFloat)contentViewHeight {
  //_contentHeight
  CGFloat total = 250;
  if (@available(iOS 11.0, *)) {
    total +=
        [UIApplication sharedApplication].keyWindow.rootViewController.view.safeAreaInsets.bottom;
  }
  return total;
}

- (CGSize)preferredContentSize {
  return CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds), [self contentViewHeight]);
}
- (BOOL)shouldAutorotate {
  return NO;
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
  return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
  return UIInterfaceOrientationPortrait;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
  self.bottomSendGiftIcon.selected = NO;
}
- (void)dealloc {
  [self.btnPopover removeFromSuperview];
}
@end
