// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEUIMicInviteeListVC.h"
#import <NEVoiceRoomKit/NEVoiceRoomKit-Swift.h>
#import "NEVoiceRoomLocalized.h"
#import "NEVoiceRoomToast.h"

@interface NEUIMicInviteeListVC ()

@end

@implementation NEUIMicInviteeListVC

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  self.navBar.title = NELocalizedString(@"选择成员");
  self.emptyView.info = NELocalizedString(@"暂无群成员～");
  [self fetchMembers];
}
// 房间内 未上麦的成员
- (void)fetchMembers {
  [NEVoiceRoomKit.getInstance getSeatInfo:^(NSInteger code, NSString *_Nullable msg,
                                            NEVoiceRoomSeatInfo *_Nullable seatInfo) {
    if (code == 0 && seatInfo) {
      dispatch_async(dispatch_get_main_queue(), ^{
        [self filterMembers:seatInfo.seatItems];
      });
    }
  }];
}
- (void)filterMembers:(NSArray<NEVoiceRoomSeatItem *> *)seatItems {
  NSMutableArray *tempArr = @[].mutableCopy;
  for (NEVoiceRoomMember *m in NEVoiceRoomKit.getInstance.allMemberList) {
    BOOL isExist = NO;
    for (NEVoiceRoomSeatItem *item in seatItems) {
      if ([item.user isEqualToString:m.account] &&
          (item.status == NEVoiceRoomSeatItemStatusTaken)) {
        isExist = YES;
      }
    }
    if (!isExist) {
      [tempArr addObject:m];
    }
  }
  self.showMembers = tempArr;
  [self.tableview reloadData];
  self.emptyView.hidden = (self.showMembers.count);
}

#pragma mark------------------------ UITableView datasource and delegate ------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  NEVoiceRoomMember *member = [self.showMembers objectAtIndex:indexPath.row];
  [self pickSeatWithAccount:member.account];  // 抱麦
  [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
- (void)pickSeatWithAccount:(NSString *)account {
  [NEVoiceRoomKit.getInstance
      sendSeatInvitationWithSeatIndex:self.seatIndex
                              account:account
                             callback:^(NSInteger code, NSString *_Nullable msg, id _Nullable obj) {
                               if (code != 0) {
                                 [NEVoiceRoomToast showToast:NELocalizedString(@"操作失败")];
                               }
                             }];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
  return UIStatusBarStyleLightContent;
}

@end
