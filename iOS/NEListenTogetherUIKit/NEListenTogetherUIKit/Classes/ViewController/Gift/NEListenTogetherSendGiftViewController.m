// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEListenTogetherSendGiftViewController.h"
#import <Masonry/Masonry.h>
#import "NEListenTogetherGlobalMacro.h"
#import "NEListenTogetherLocalized.h"
#import "NEListenTogetherSendGiftCell.h"
#import "NEListenTogetherUIActionSheetNavigationController.h"

@interface NEListenTogetherSendGiftViewController () <UICollectionViewDelegate,
                                                      UICollectionViewDataSource>

/// 代理
@property(nonatomic, weak) id<NEListenTogetherSendGiftViewtDelegate> delegate;
/// 礼物展示视图
@property(nonatomic, strong) UICollectionView *collectionView;
/// 发送按钮
@property(nonatomic, strong) UIButton *sendBtn;
/// 礼物数组
@property(nonatomic, strong) NSArray<NEListenTogetherUIGiftModel *> *gifts;
/// 选中的礼物
@property(nonatomic, strong) NEListenTogetherUIGiftModel *selectedGift;

@property(nonatomic, strong) CAGradientLayer *buttonBackground;

// 赠送Label
@property(nonatomic, strong) UITableView *giftToLabel;

// 赠送对象列表
@property(nonatomic, strong) UICollectionView *giftToCollectionView;

@end

@implementation NEListenTogetherSendGiftViewController

+ (void)showWithTarget:(id<NEListenTogetherSendGiftViewtDelegate>)target
        viewController:(UIViewController *)viewController {
  NEListenTogetherSendGiftViewController *vc =
      [[NEListenTogetherSendGiftViewController alloc] init];
  vc.delegate = target;
  NEListenTogetherUIActionSheetNavigationController *nav =
      [[NEListenTogetherUIActionSheetNavigationController alloc] initWithRootViewController:vc];
  nav.dismissOnTouchOutside = YES;
  [viewController presentViewController:nav animated:YES completion:nil];
}

- (instancetype)init {
  if ([super init]) {
    self.gifts = [NEListenTogetherUIGiftModel defaultGifts];
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
    textAttribute[NSForegroundColorAttributeName] = UIColor.whiteColor;     // 标题颜色
    textAttribute[NSFontAttributeName] = [UIFont boldSystemFontOfSize:18];  // 标题大小
    [appearance setTitleTextAttributes:textAttribute];

    // 去除底部黑线
    [appearance setShadowImage:[UIImage new]];

    UIColor *color = UIColor.clearColor;
    appearance.backgroundColor = color;

    self.navigationController.navigationBar.standardAppearance = appearance;
    self.navigationController.navigationBar.scrollEdgeAppearance = appearance;
  } else {
    // Fallback on earlier versions
  }

  self.title = NELocalizedString(@"送礼物");
  [self.navigationController.navigationBar
      setTitleTextAttributes:@{NSForegroundColorAttributeName : UIColor.whiteColor}];

  UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
  UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
  effectView.backgroundColor = [UIColor colorWithRed:0.192 green:0.239 blue:0.235 alpha:0.5];
  effectView.layer.cornerRadius = 10;
  effectView.layer.masksToBounds = YES;
  [self.view addSubview:effectView];
  [effectView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.right.top.bottom.equalTo(self.view);
  }];

  // 导航栏下面画个分割线
  CAShapeLayer *lineLayer = [[CAShapeLayer alloc] init];
  lineLayer.strokeColor = [UIColor colorWithRed:0.371 green:0.371 blue:0.371 alpha:0.3].CGColor;
  lineLayer.lineWidth = 1.0;
  CGMutablePathRef path = CGPathCreateMutable();
  CGPathMoveToPoint(path, NULL, 0, 49);
  CGPathAddLineToPoint(path, NULL, self.view.frame.size.width, 49);
  lineLayer.path = path;
  [self.view.layer addSublayer:lineLayer];

  [self setupSubView];
}

- (void)setupSubView {
  [self.view addSubview:self.collectionView];
  [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(self.view).offset(16 + 48);
    make.left.right.equalTo(self.view);
    make.height.mas_equalTo(136);
  }];

  [self.view addSubview:self.sendBtn];
  [self.sendBtn mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(self.collectionView.mas_bottom).offset(8);
    make.left.equalTo(self.view).offset(20);
    make.right.equalTo(self.view).offset(-20);
    make.height.mas_equalTo(44);
    if (@available(iOS 11.0, *)) {
      make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(-8);
    } else {
      make.bottom.equalTo(self.view).offset(-8);
    }
  }];

  [self.view layoutIfNeeded];
  [self.sendBtn.layer insertSublayer:self.buttonBackground atIndex:0];
}

#pragma mark - getter

- (UIButton *)sendBtn {
  if (!_sendBtn) {
    _sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_sendBtn setTitle:@"发送" forState:UIControlStateNormal];
    _sendBtn.layer.cornerRadius = 8;
    _sendBtn.layer.masksToBounds = YES;
    [_sendBtn addTarget:self
                  action:@selector(sendAction:)
        forControlEvents:UIControlEventTouchUpInside];
  }
  return _sendBtn;
}

- (UICollectionView *)collectionView {
  if (!_collectionView) {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = [NEListenTogetherSendGiftCell size];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumInteritemSpacing = 8;
    layout.minimumLineSpacing = 8;
    layout.sectionInset = UIEdgeInsetsMake(0, 10, 0, 10);

    CGRect frame = CGRectMake(0, 107, self.view.frame.size.width, 136);
    _collectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:layout];
    _collectionView.backgroundColor = [UIColor clearColor];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.showsHorizontalScrollIndicator = NO;
    [_collectionView registerClass:[NEListenTogetherSendGiftCell class]
        forCellWithReuseIdentifier:[NEListenTogetherSendGiftCell description]];
    _collectionView.allowsMultipleSelection = NO;
  }
  return _collectionView;
}

- (CAGradientLayer *)buttonBackground {
  if (!_buttonBackground) {
    _buttonBackground = [CAGradientLayer layer];
    NSArray *colors = [NSArray arrayWithObjects:(id)[HEXCOLOR(0xFF60AF) CGColor],
                                                (id)[HEXCOLOR(0xF96C6E) CGColor],
                                                (id)[[UIColor blackColor] CGColor], nil];
    [_buttonBackground setColors:colors];
    _buttonBackground.locations = @[ @0, @1 ];
    _buttonBackground.startPoint = CGPointMake(0.25, 0.5);
    _buttonBackground.endPoint = CGPointMake(0.75, 0.5);
    [_buttonBackground setFrame:CGRectMake(0, 0, CGRectGetWidth(self.sendBtn.frame),
                                           CGRectGetHeight(self.sendBtn.frame))];
    _buttonBackground.cornerRadius = 8;
  }
  return _buttonBackground;
}

#pragma mark - UICollectionView delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
  return [_gifts count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  NEListenTogetherSendGiftCell *cell =
      [NEListenTogetherSendGiftCell cellWithCollectionView:collectionView
                                                 indexPath:indexPath
                                                     datas:_gifts];
  return cell;
}

- (void)collectionView:(UICollectionView *)collectionView
    didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
  if ([_gifts count] > indexPath.row) {
    _selectedGift = _gifts[indexPath.row];
    _sendBtn.enabled = YES;
  }
  [self.collectionView selectItemAtIndexPath:indexPath
                                    animated:YES
                              scrollPosition:UICollectionViewScrollPositionNone];
}

- (void)sendAction:(UIButton *)sender {
  if (!_selectedGift) {
    return;
  }

  if (self.delegate && [self.delegate respondsToSelector:@selector(didSendGift:)]) {
    [self.delegate didSendGift:_selectedGift];
  }
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
@end
