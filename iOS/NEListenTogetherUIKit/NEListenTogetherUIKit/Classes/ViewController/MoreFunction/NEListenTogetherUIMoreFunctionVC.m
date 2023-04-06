// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEListenTogetherUIMoreFunctionVC.h"
#import "NEListenTogetherLocalized.h"
#import "NEListenTogetherToast.h"
#import "NEListenTogetherUI.h"
#import "NEListenTogetherUIActionSheetNavigationController.h"
#import "NEListenTogetherUIBackgroundMusicVC.h"
#import "NEListenTogetherUIMoreCell.h"
#import "NEListenTogetherUIMoreItem.h"
#import "NEListenTogetherUIMusicConsoleVC.h"

@interface NEListenTogetherUIMoreFunctionVC () <UICollectionViewDataSource,
                                                UICollectionViewDelegate,
                                                UICollectionViewDelegateFlowLayout>
// 设置项视图
@property(nonatomic, strong) UICollectionView *collectionView;
// 布局
@property(nonatomic, strong) UICollectionViewFlowLayout *flowLayout;
// 全部数据源
@property(nonatomic, copy) NSArray<NEListenTogetherUIMoreItem *> *allItems;
// 当前角色的数据源
@property(nonatomic, copy) NSArray<NEListenTogetherUIMoreItem *> *items;
// 麦克风状态
//@property(nonatomic, assign) BOOL micOn;
// 耳返状态
//@property(nonatomic, assign) BOOL earbackOn;
// 角色
//@property(nonatomic, assign) NEListenTogetherRole role;
@property(nonatomic, strong) NEListenTogetherContext *context;
@end

@implementation NEListenTogetherUIMoreFunctionVC
- (instancetype)initWithContext:(NEListenTogetherContext *)context {
  self = [super init];
  if (self) {
    self.context = context;
  }
  return self;
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  for (NEListenTogetherUIMoreItem *item in self.items) {
    if (item.tag == 1) {
      if (![[NEListenTogetherKit getInstance] isHeadSetPlugging]) {
        item.on = false;
      }
    }
  }
}

- (void)loadView {
  UIView *view = [[UIView alloc] initWithFrame:self.navigationController.view.bounds];
  view.backgroundColor = UIColor.whiteColor;
  self.view = view;

  UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
  layout.scrollDirection = UICollectionViewScrollDirectionVertical;
  layout.minimumLineSpacing = 16;
  layout.itemSize = CGSizeMake(60, 84);
  layout.sectionInset = UIEdgeInsetsMake(16, 30, 16, 30);
  self.flowLayout = layout;

  self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds
                                           collectionViewLayout:layout];
  self.collectionView.backgroundColor = UIColor.clearColor;
  self.collectionView.scrollEnabled = NO;
  self.collectionView.dataSource = self;
  self.collectionView.delegate = self;
  [self.collectionView registerClass:NEListenTogetherUIMoreCell.class
          forCellWithReuseIdentifier:@"cell"];
  [self.view addSubview:self.collectionView];

  [self.navigationItem.backBarButtonItem
      setTitleTextAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14]}
                    forState:UIControlStateNormal];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  self.title = NELocalizedString(@"更多");
  switch (self.context.role) {
    case NEListenTogetherRoleHost: {
      self.items = self.allItems;
    } break;
    case NEListenTogetherRoleAudience: {
      self.items = [self.allItems subarrayWithRange:NSMakeRange(0, 3)];
    } break;
    default:
      break;
  }
  [self.collectionView reloadData];

  [NSNotificationCenter.defaultCenter addObserver:self
                                         selector:@selector(canUseEarback)
                                             name:@"CanUseEarback"
                                           object:nil];
  [NSNotificationCenter.defaultCenter addObserver:self
                                         selector:@selector(canNotUseEarback)
                                             name:@"CanNotUseEarback"
                                           object:nil];
}

- (void)dealloc {
  [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)canUseEarback {
  for (NEListenTogetherUIMoreItem *item in self.items) {
    if (item.tag == 1) {
      if ([[NEListenTogetherKit getInstance] isHeadSetPlugging]) {
        item.on = true;
      }
    }
  }
  [self.collectionView reloadData];
}

- (void)canNotUseEarback {
  for (NEListenTogetherUIMoreItem *item in self.items) {
    if (item.tag == 1) {
      if (![[NEListenTogetherKit getInstance] isHeadSetPlugging]) {
        item.on = false;
      }
    }
  }
  [self.collectionView reloadData];
}

- (CGSize)preferredContentSize {
  CGFloat preferedHeight = 0;
  if (@available(iOS 11.0, *)) {
    if ([[UIApplication sharedApplication].delegate respondsToSelector:@selector(window)]) {
      CGFloat safeAreaBottom =
          UIApplication.sharedApplication.delegate.window.safeAreaInsets.bottom;
      preferedHeight += 2 * safeAreaBottom;
    }
  }
  CGFloat preferredWidth = self.navigationController.view.frame.size.width;
  NSInteger itemsPerLine =
      (preferredWidth - self.flowLayout.sectionInset.left - self.flowLayout.sectionInset.right +
       self.flowLayout.minimumInteritemSpacing) /
      (self.flowLayout.itemSize.width + self.flowLayout.minimumInteritemSpacing);
  CGFloat lineCount =
      self.items.count / itemsPerLine + (self.items.count % itemsPerLine > 0 ? 1 : 0);
  preferedHeight += lineCount * self.flowLayout.itemSize.height;
  preferedHeight += self.flowLayout.sectionInset.top;
  preferedHeight += self.flowLayout.sectionInset.bottom;
  preferedHeight += (lineCount - 1) * self.flowLayout.minimumLineSpacing;
  return CGSizeMake(preferredWidth, preferedHeight);
}
#pragma mark------------------------ UICollectionView datasource and delegate ------------------------
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
  return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
  return self.items.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                           cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  NEListenTogetherUIMoreCell *cell =
      [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
  cell.imageView.image = self.items[indexPath.item].currentImage;
  cell.textLabel.text = self.items[indexPath.item].title;
  return cell;
}

- (void)collectionView:(UICollectionView *)collectionView
    didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
  NEListenTogetherUIMoreItem *item = self.items[indexPath.row];
  switch (item.tag) {
    case 0: {  // 麦克风
      item.on = !item.on;
      [UIView performWithoutAnimation:^{
        [collectionView reloadItemsAtIndexPaths:@[ indexPath ]];
      }];
      if (_delegate && [_delegate respondsToSelector:@selector(didSetMicOn:)]) {
        [_delegate didSetMicOn:item.on];
      }
      break;
    }
    case 1: {  // 耳返
      if (![[NEListenTogetherKit getInstance] isHeadSetPlugging]) {
        [NEListenTogetherToast showToast:NELocalizedString(@"插入耳机后可使用耳返功能")];
        return;
      }
      item.on = !item.on;
      self.context.rtcConfig.earbackOn = item.on;
      [UIView performWithoutAnimation:^{
        [collectionView reloadItemsAtIndexPaths:@[ indexPath ]];
      }];
      if (_delegate && [_delegate respondsToSelector:@selector(didEarbackOn:)]) {
        [_delegate didEarbackOn:item.on];
      }
      break;
    }
    case 2: {  // 调音台

      NEListenTogetherUIMusicConsoleVC *musicConsoleVC =
          [[NEListenTogetherUIMusicConsoleVC alloc] initWithContext:self.context];
      NEListenTogetherUIActionSheetNavigationController *nav =
          [[NEListenTogetherUIActionSheetNavigationController alloc]
              initWithRootViewController:musicConsoleVC];
      nav.dismissOnTouchOutside = YES;
      UIViewController *lastVC = self.presentingViewController;
      [lastVC dismissViewControllerAnimated:YES
                                 completion:^{
                                   [lastVC presentViewController:nav animated:YES completion:nil];
                                 }];
      break;
    }
    case 3: {  // 伴音
      NEListenTogetherUIBackgroundMusicVC *vc =
          [[NEListenTogetherUIBackgroundMusicVC alloc] initWithContext:self.context];
      NEListenTogetherUIActionSheetNavigationController *nav =
          [[NEListenTogetherUIActionSheetNavigationController alloc] initWithRootViewController:vc];
      nav.dismissOnTouchOutside = YES;
      UIViewController *lastVC = self.presentingViewController;
      [lastVC dismissViewControllerAnimated:YES
                                 completion:^{
                                   [lastVC presentViewController:nav animated:YES completion:nil];
                                 }];

      break;
    }
    case 4: {  // 结束直播
      [self dismissViewControllerAnimated:YES
                               completion:^{
                                 if (self.delegate &&
                                     [self.delegate respondsToSelector:@selector(endLive)]) {
                                   [self.delegate endLive];
                                 }
                               }];
      break;
    }
    default:
      break;
  }
}
#pragma mark------------------------ Getter  ------------------------
- (NSArray<NEListenTogetherUIMoreItem *> *)allItems {
  if (!_allItems) {
    _allItems = @[
      [NEListenTogetherUIMoreItem
          itemWithTitle:NELocalizedString(@"麦克风")
                onImage:[NEListenTogetherUI ne_listen_imageName:@"icon_more_mic_on"]
               offImage:[NEListenTogetherUI ne_listen_imageName:@"icon_more_mic_off"]
                    tag:0]
          .open(self.context.rtcConfig.micOn),
      [NEListenTogetherUIMoreItem
          itemWithTitle:NELocalizedString(@"耳返")
                onImage:[NEListenTogetherUI ne_listen_imageName:@"icon_more_earback_on"]
               offImage:[NEListenTogetherUI ne_listen_imageName:@"icon_more_earback_off"]
                    tag:1]
          .open(self.context.rtcConfig.earbackOn),
      [NEListenTogetherUIMoreItem
          itemWithTitle:NELocalizedString(@"调音台")
                onImage:[NEListenTogetherUI ne_listen_imageName:@"icon_more_music_console"]
               offImage:nil
                    tag:2],
      [NEListenTogetherUIMoreItem
          itemWithTitle:NELocalizedString(@"音效")
                onImage:[NEListenTogetherUI ne_listen_imageName:@"icon_more_accompaniment_sound"]
               offImage:nil
                    tag:3],
      [NEListenTogetherUIMoreItem
          itemWithTitle:NELocalizedString(@"结束直播")
                onImage:[NEListenTogetherUI ne_listen_imageName:@"icon_more_close_live"]
               offImage:nil
                    tag:4]
    ];
  }
  return _allItems;
}
@end
