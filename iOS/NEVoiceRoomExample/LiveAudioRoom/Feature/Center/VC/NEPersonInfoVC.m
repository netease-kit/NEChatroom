// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEPersonInfoVC.h"
#import <Masonry/Masonry.h>
#import <NEUIKit/UIColor+NEUIExtension.h>
#import <NEVoiceRoomUIKit/NEVoiceRoomUIManager.h>
#import <SDWebImage/SDWebImage.h>
#import <YXLogin/YXLogin.h>
#import "NENicknameVC.h"
#import "NEPersonTableViewCell.h"
#import "NEPersonTextCell.h"
@interface NEPersonInfoVC ()
@property(strong, nonatomic) NSArray *dataArray;
@property(strong, nonatomic) NSString *nickname;

@end

@implementation NEPersonInfoVC

- (void)viewDidLoad {
  [super viewDidLoad];
  [self setupUI];
  if ([AuthorManager shareInstance].isLogin) {
    self.dataArray = @[
      @[ NSLocalizedString(@"头像", nil), NSLocalizedString(@"昵称", nil) ],
      @[ NSLocalizedString(@"退出登录", nil) ]
    ];
  } else {
    self.dataArray = @[ @[ NSLocalizedString(@"头像", nil), NSLocalizedString(@"昵称", nil) ] ];
  }
}
- (void)setupUI {
  self.title = NSLocalizedString(@"个人信息", nil);
  self.tableView.backgroundColor = [UIColor ne_r:18 g:18 b:26];
  [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.edges.mas_equalTo(UIEdgeInsetsZero);
  }];
  [self.tableView registerClass:[NEPersonTextCell class]
         forCellReuseIdentifier:@"NEPersonTextCell"];
  [self.tableView registerClass:[NEPersonTableViewCell class]
         forCellReuseIdentifier:@"NEPersonTableViewCell"];
}
#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return self.dataArray.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  NSArray *sectionArray = [self.dataArray objectAtIndex:section];
  if ([sectionArray isKindOfClass:[NSArray class]]) {
    return sectionArray.count;
  } else {
    return 0;
  }
  return 3;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 56;
}
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section == 0) {
    NEPersonTableViewCell *cell =
        [tableView dequeueReusableCellWithIdentifier:@"NEPersonTableViewCell"
                                        forIndexPath:indexPath];
    NSArray *sectionArray = self.dataArray[indexPath.section];
    NSString *content = sectionArray[indexPath.row];
    YXUserInfo *info = [[AuthorManager shareInstance] getUserInfo];
    if (indexPath.row == 0) {
      [cell.personView.indicatorImageView sd_setImageWithURL:[NSURL URLWithString:info.avatar]
                                            placeholderImage:[UIImage imageNamed:@"avator"]];
    } else {
      NSString *nickname = info.nickname ? info.nickname : @"";
      cell.personView.detailLabel.text = nickname;
      cell.personView.indicatorImageView.image = [UIImage imageNamed:@"menu_arrow"];
    }
    cell.personView.titleLabel.text = content;
    return cell;
  } else {
    NEPersonTextCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NEPersonTextCell"
                                                             forIndexPath:indexPath];
    cell.titleLabel.text = NSLocalizedString(@"退出登录", nil);
    return cell;
  }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section == 0) {
    if (indexPath.row == 1) {
      // 修改昵称
      NENicknameVC *nickNameVC = [[NENicknameVC alloc] init];

      nickNameVC.didModifyNickname = ^(NSString *_Nonnull nickName) {
        self.nickname = nickName;
        [self.tableView reloadData];
      };
      [self.navigationController pushViewController:nickNameVC animated:YES];
    }
  } else {
    if (indexPath.row == 0) {
      // 退出登录
      [self logoutDetail];
    }
  }
}

- (void)logoutDetail {
  [[AuthorManager shareInstance]
      logoutWithConfirm:nil
         withCompletion:^(YXUserInfo *_Nullable userinfo, NSError *_Nullable error) {
           if (error == nil) {
             [[NEVoiceRoomUIManager sharedInstance]
                 logoutWithCallback:^(NSInteger code, NSString *_Nullable msg, id _Nullable obj) {
                   if (code == 0) {
                     dispatch_async(dispatch_get_main_queue(), ^{
                       [self.navigationController popToRootViewControllerAnimated:false];
                       [[AuthorManager shareInstance]
                           startLoginWithCompletion:^(YXUserInfo *_Nullable userinfo,
                                                      NSError *_Nullable error) {
                             if (!error) {
                               [NSNotificationCenter.defaultCenter
                                   postNotification:[NSNotification notificationWithName:@"Login"
                                                                                  object:nil]];
                               [NEVoiceRoomUIManager.sharedInstance
                                   loginWithAccount:userinfo.accountId
                                              token:userinfo.accessToken
                                           nickname:userinfo.nickname
                                           callback:^(NSInteger code, NSString *_Nullable msg,
                                                      id _Nullable objc) {
                                             if (code == 0) {
                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                 [self.tableView reloadData];
                                               });
                                             }
                                           }];
                             }
                           }];
                     });
                   }
                 }];
           } else {
           }
         }];
}

@end
