// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEPersonVC.h"
#import <Masonry/Masonry.h>
#import <NEUIKit/NEUIWebViewController.h>
#import <NEUIKit/UIColor+NEUIExtension.h>
#import <NEVoiceRoomUIKit/NEVoiceRoomUIManager.h>
#import <SDWebImage/SDWebImage.h>
#import <YXLogin/YXLogin.h>
#import "NEAboutViewController.h"
#import "NEPersonInfoVC.h"
#import "NEPersonTableViewCell.h"
#import "NEPersonTableViewDataCenterCell.h"

@interface NEPersonVC ()
@property(strong, nonatomic) NSArray *dataArray;

@end

@implementation NEPersonVC

- (void)viewDidLoad {
  [super viewDidLoad];

  [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.edges.mas_equalTo(UIEdgeInsetsZero);
  }];
  [self initializeConfig];
  self.navigationController.view.backgroundColor = [UIColor blackColor];
}

- (void)initializeConfig {
  self.title = NSLocalizedString(@"个人中心", nil);
  [self.tableView registerClass:[NEPersonTableViewCell class]
         forCellReuseIdentifier:@"personCellID"];
  [self.tableView registerClass:[NEPersonTableViewDataCenterCell class]
         forCellReuseIdentifier:@"dataCenterID"];
  self.tableView.backgroundColor = [UIColor ne_r:18 g:18 b:26];
  self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
  self.navigationController.navigationBar.titleTextAttributes =
      @{NSForegroundColorAttributeName : UIColor.whiteColor};
  self.navigationController.navigationBar.barTintColor = UIColor.blackColor;
  self.view.backgroundColor = [UIColor ne_colorWithHex:0x1A1A24];
}

- (void)viewWillAppear:(BOOL)animated {
  //    [super viewWillAppear:animated];
  [self initData];
  [self.tableView reloadData];
}

- (void)initData {
  YXUserInfo *info = [[AuthorManager shareInstance] getUserInfo];
  NSString *name = info.nickname ?: @"";
  self.dataArray = @[
    @[ name ],
    @[
      NSLocalizedString(@"免费申请试用", nil), NSLocalizedString(@"关于", nil),
      NSLocalizedString(@"数据中心", nil)
    ]
  ];
}
#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  NSArray *sectionArray = self.dataArray[section];
  return sectionArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  switch (indexPath.section) {
    case 0:
      return 88;
      break;
    case 1: {
      if (indexPath.row == 2) {
        return 88;
      } else {
        return 56;
      }
    } break;
    default:
      return 56;
      break;
  }
}
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section == 1 && indexPath.row > 1) {
    /// 环境切换
    __weak typeof(self) weakself = self;
    __weak NEPersonTableViewDataCenterCell *cell =
        [tableView dequeueReusableCellWithIdentifier:@"dataCenterID" forIndexPath:indexPath];
    cell.personDataCenterView.selectDataCenter = ^(long index) {
      __strong typeof(weakself) strongself = weakself;
      __strong typeof(cell) strongCell = cell;
      [strongself showAlertView:^{
        [[AuthorManager shareInstance]
            logoutWithCompletion:^(YXUserInfo *_Nullable userinfo, NSError *_Nullable error) {
              [[NEVoiceRoomUIManager sharedInstance]
                  logoutWithCallback:^(NSInteger code, NSString *_Nullable msg, id _Nullable obj) {
                    if (code == 0) {
                      [[NSUserDefaults standardUserDefaults] synchronize];

                      dispatch_async(dispatch_get_main_queue(), ^{
                        [strongCell.personDataCenterView updateDataCenter:index];
                      });
                    }
                  }];
            }];
      }];
      /// 跳出弹窗
    };
    return cell;
  } else {
    NEPersonTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"personCellID"
                                                                  forIndexPath:indexPath];
    NSArray *sectionArray = self.dataArray[indexPath.section];
    NSString *content = sectionArray[indexPath.row];
    if (indexPath.section == 0) {
      YXUserInfo *info = [[AuthorManager shareInstance] getUserInfo];
      [cell.personView.iconImageView sd_setImageWithURL:[NSURL URLWithString:info.avatar]
                                       placeholderImage:[UIImage imageNamed:@"avator"]];
      cell.personView.iconImageView.layer.cornerRadius = (56 - 20) / 2.0;
      cell.personView.iconImageView.clipsToBounds = YES;
    } else {
      cell.personView.iconImageView.image = nil;
    }
    cell.personView.titleLabel.text = content;
    cell.personView.indicatorImageView.image = [UIImage imageNamed:@"menu_arrow"];
    return cell;
  }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section == 0) {
    if (indexPath.row == 0) {
      // 个人信息
      NEPersonInfoVC *vc = [[NEPersonInfoVC alloc] init];
      vc.hidesBottomBarWhenPushed = YES;
      [self.navigationController pushViewController:vc animated:YES];
    }
  } else {
    switch (indexPath.row) {
      case 0:
        /// 免费申请试用
        [self gotoTry];
        break;
      case 1:
        // 关于
        { [self gotoAboutMe]; }
        break;

      default:
        break;
    }
  }
}
- (void)gotoEvaluate {
  //    NEFeedbackVC *evaluateVC = [[NEFeedbackVC alloc] init];
  //    evaluateVC.title = NSLocalizedString(@"意见反馈", nil);
  //    evaluateVC.hidesBottomBarWhenPushed = YES;
  //    [self.navigationController pushViewController:evaluateVC animated:YES];
}
- (void)gotoTry {
  NEUIWebViewController *web =
      [[NEUIWebViewController alloc] initWithUrlString:NSLocalizedString(@"URL_FREE_TRAIL", nil)];
  web.title = NSLocalizedString(@"网易云信注册", nil);
  [self.navigationController pushViewController:web animated:YES];
}
- (void)gotoAboutMe {
  NEAboutViewController *aboutVC = [[NEAboutViewController alloc] init];
  aboutVC.hidesBottomBarWhenPushed = YES;
  [self.navigationController pushViewController:aboutVC animated:YES];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
  return UIStatusBarStyleLightContent;
}

- (void)showAlertView:(void (^)(void))clickSure {
  UIAlertController *alerVC = [UIAlertController
      alertControllerWithTitle:@""
                       message:NSLocalizedString(@"确定切换数据中心吗? 需要重新登录", nil)
                preferredStyle:UIAlertControllerStyleAlert];
  UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"取消", nil)
                                                         style:UIAlertActionStyleCancel
                                                       handler:^(UIAlertAction *_Nonnull action){
                                                       }];
  UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"确认", nil)
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction *_Nonnull action) {
                                                     clickSure();
                                                   }];
  [alerVC addAction:cancelAction];
  [alerVC addAction:okAction];
  [self presentViewController:alerVC animated:YES completion:nil];
}
@end
