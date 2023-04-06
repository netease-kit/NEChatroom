// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <Masonry/Masonry.h>
#import <NEListenTogetherKit/NEListenTogetherKit-Swift.h>
#import <NEUIKit/NEUIBackNavigationController.h>
#import <NEUIKit/UIView+NEUIExtension.h>
#import <libextobjc/extobjc.h>
#import "NEListenTogetherLocalized.h"
#import "NEListenTogetherToast.h"
#import "NEListenTogetherUI.h"
#import "NEListenTogetherUIDeviceSizeInfo.h"
#import "NEListenTogetherUIMicInviteeListVC.h"
#import "NEListenTogetherViewController+UI.h"
#import "UIImage+ListenTogether.h"
#import "UIView+NEListenTogetherUIToast.h"

@implementation NEListenTogetherViewController (UI)
- (void)addSubviews {
  [self.view addSubview:self.bgImageView];
  [self.view addSubview:self.roomHeaderView];
  [self.view addSubview:self.roomFooterView];
  [self.view addSubview:self.chatView];
  [self.view addSubview:self.micQueueView];
  [self.view addSubview:self.lyricActionView];
  [self.view addSubview:self.lyricControlView];
  [self.bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.edges.mas_equalTo(UIEdgeInsetsZero);
  }];

  [self.roomHeaderView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.height.mas_equalTo(54);
    make.left.equalTo(self.view).offset(8);
    make.right.equalTo(self.view).offset(-8);
    make.top.mas_equalTo([NEUICommon ne_statusBarHeight] + 8);
  }];

  [self.roomFooterView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.height.mas_equalTo(36);
    make.left.equalTo(self.view).offset(8);
    make.right.equalTo(self.view).offset(-8);
    make.bottom.mas_equalTo(-[NEListenTogetherUIDeviceSizeInfo get_iPhoneBottomSafeDistance] - 8);
  }];
  CGFloat width = self.view.width - 2 * 30.0;
  CGFloat height = [self.micQueueView calculateHeightWithWidth:width];

  [self.micQueueView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(self.roomHeaderView.mas_bottom).offset(12);
    make.left.equalTo(self.view).offset(30);
    make.right.equalTo(self.view).offset(-30);
    make.height.mas_equalTo(height);
  }];

  [self.lyricActionView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.mas_equalTo(14);
    make.right.mas_equalTo(-14);
    make.top.equalTo(self.micQueueView.mas_bottom).offset(-50);
    make.height.mas_equalTo(177);
  }];

  [self.lyricControlView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.height.mas_equalTo(40);
    make.left.right.equalTo(self.view);
    make.top.equalTo(self.lyricActionView.mas_bottom).offset(10);
  }];

  [self.chatView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(self.lyricActionView.mas_bottom).offset(50);
    make.bottom.equalTo(self.roomFooterView.mas_top).offset(-5);
    make.left.equalTo(self.view).offset(8);
    make.right.equalTo(self.view).offset(-88);
  }];
  [self.view addSubview:self.keyboardView];
}

#pragma mark-----------------------------  键盘管理  -----------------------------
- (void)observeKeyboard {
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(keyboardWillShow:)
                                               name:UIKeyboardWillShowNotification
                                             object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(keyboardWillHide:)
                                               name:UIKeyboardWillHideNotification
                                             object:nil];
}
#pragma mark - 当键盘事件
- (void)keyboardWillShow:(NSNotification *)aNotification {
  NSDictionary *userInfo = [aNotification userInfo];
  CGRect rect = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
  CGFloat keyboardHeight = rect.size.height;
  [UIView animateWithDuration:[userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]
                   animations:^{
                     self.keyboardView.frame =
                         CGRectMake(0, [NEUICommon ne_screenHeight] - keyboardHeight - 50,
                                    [NEUICommon ne_screenWidth], 50);
                   }];
}
- (void)keyboardWillHide:(NSNotification *)aNotification {
  [UIView animateWithDuration:0.1
                   animations:^{
                     self.keyboardView.frame = CGRectMake(0, [NEUICommon ne_screenHeight] + 50,
                                                          [NEUICommon ne_screenWidth], 50);
                   }];
}
/// 点击屏幕收起键盘
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  [super touchesBegan:touches withEvent:event];
  [self.keyboardView resignFirstResponder];
  [self.view endEditing:true];
}

- (NSMutableArray<NEListenTogetherUIAlertAction *> *)setupAlertActions {
  NSMutableArray<NEListenTogetherUIAlertAction *> *actions = @[].mutableCopy;
  // 抱麦操作
  NEListenTogetherUIAlertAction *inviteAction = [NEListenTogetherUIAlertAction
      actionWithTitle:NELocalizedString(@"将成员抱上麦")
                 type:NEUIAlertActionTypeInviteMic
              handler:^(id _Nonnull info) {
                NEListenTogetherSeatItem *seatItem = (NEListenTogetherSeatItem *)info;
                NEListenTogetherUIMicInviteeListVC *inviteeVC =
                    [[NEListenTogetherUIMicInviteeListVC alloc] init];
                inviteeVC.seatIndex = seatItem.index;
                NEUIBackNavigationController *navigationVC =
                    [[NEUIBackNavigationController alloc] initWithRootViewController:inviteeVC];
                [self presentViewController:navigationVC animated:YES completion:nil];
              }];
  [actions addObject:inviteAction];

  // 屏蔽麦位音频 （关闭麦克风）
  NEListenTogetherUIAlertAction *maskAction = [NEListenTogetherUIAlertAction
      actionWithTitle:NELocalizedString(@"屏蔽麦位")
                 type:NEUIAlertActionTypeFinishedMaskMic
              handler:^(id _Nonnull info) {
                NEListenTogetherSeatItem *seatItem = (NEListenTogetherSeatItem *)info;
                [NEListenTogetherKit.getInstance
                    banRemoteAudio:seatItem.user
                          callback:^(NSInteger code, NSString *_Nullable msg, id _Nullable obj) {
                            if (code != 0) {
                              [NEListenTogetherToast showToast:NELocalizedString(@"语音屏蔽失败")];
                            }
                          }];
              }];
  [actions addObject:maskAction];

  // 关闭麦位
  NEListenTogetherUIAlertAction *closeAction = [NEListenTogetherUIAlertAction
      actionWithTitle:NELocalizedString(@"关闭麦位")
                 type:NEUIAlertActionTypeCloseMic
              handler:^(id _Nonnull info) {
                NEListenTogetherSeatItem *seatItem = (NEListenTogetherSeatItem *)info;
                [NEListenTogetherKit.getInstance
                    closeSeatsWithSeatIndices:@[ @(seatItem.index) ]
                                     callback:^(NSInteger code, NSString *_Nullable msg,
                                                id _Nullable obj) {
                                       if (code != 0) {
                                         [NEListenTogetherToast
                                             showToast:NELocalizedString(@"关闭麦位失败")];
                                       } else {
                                         NSString *msg =
                                             [NSString stringWithFormat:NELocalizedString(
                                                                            @"\"麦位%d\"已关闭"),
                                                                        (int)seatItem.index - 1];
                                         [NEListenTogetherToast showToast:msg];
                                       }
                                     }];
              }];
  [actions addObject:closeAction];

  // 踢麦
  NEListenTogetherUIAlertAction *kickoutAction = [NEListenTogetherUIAlertAction
      actionWithTitle:NELocalizedString(@"将TA踢下麦位")
                 type:NEUIAlertActionTypeKickMic
              handler:^(id _Nonnull info) {
                NEListenTogetherSeatItem *seatItem = (NEListenTogetherSeatItem *)info;
                [NEListenTogetherKit.getInstance
                    kickSeatWithAccount:seatItem.user
                               callback:^(NSInteger code, NSString *_Nullable msg,
                                          id _Nullable obj) {
                                 if (code != 0) {
                                   [NEListenTogetherToast showToast:NELocalizedString(@"操作失败")];
                                 }
                               }];
              }];
  [actions addObject:kickoutAction];

  // 打开麦位
  NEListenTogetherUIAlertAction *openAction = [NEListenTogetherUIAlertAction
      actionWithTitle:NELocalizedString(@"打开麦位")
                 type:NEUIAlertActionTypeOpenMic
              handler:^(id _Nonnull info) {
                NEListenTogetherSeatItem *seatItem = (NEListenTogetherSeatItem *)info;
                [NEListenTogetherKit.getInstance
                    openSeatsWithSeatIndices:@[ @(seatItem.index) ]
                                    callback:^(NSInteger code, NSString *_Nullable msg,
                                               id _Nullable obj) {
                                      if (code != 0) {
                                        [NEListenTogetherToast
                                            showToast:NELocalizedString(@"麦位打开失败")];
                                      } else {
                                        [NEListenTogetherToast
                                            showToast:[NSString stringWithFormat:@"%@%ld%@",
                                                                                 NELocalizedString(
                                                                                     @"麦位"),
                                                                                 seatItem.index - 1,
                                                                                 NELocalizedString(
                                                                                     @"已打开")]];
                                      }
                                    }];
              }];
  [actions addObject:openAction];

  // 解除语音屏蔽
  NEListenTogetherUIAlertAction *cancelMaskAction = [NEListenTogetherUIAlertAction
      actionWithTitle:NELocalizedString(@"解除语音屏蔽")
                 type:NEUIAlertActionTypeCancelMaskMic
              handler:^(id _Nonnull info) {
                NEListenTogetherSeatItem *seatItem = (NEListenTogetherSeatItem *)info;
                [NEListenTogetherKit.getInstance
                    unbanRemoteAudio:seatItem.user
                            callback:^(NSInteger code, NSString *_Nullable msg, id _Nullable obj) {
                              if (code != 0) {
                                [NEListenTogetherToast
                                    showToast:NELocalizedString(@"解除语音屏蔽失败")];
                              }
                            }];
              }];
  [actions addObject:cancelMaskAction];

  // 取消申请上麦
  NEListenTogetherUIAlertAction *cancelRequestAction = [NEListenTogetherUIAlertAction
      actionWithTitle:NELocalizedString(@"确认取消申请上麦")
                 type:NEUIAlertActionTypeCancelOnMicRequest
              handler:^(id _Nonnull info) {
                [NEListenTogetherKit.getInstance
                    cancelSeatRequest:^(NSInteger code, NSString *_Nullable msg, id _Nullable obj) {
                      if (code == 0) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                          [self.view dismissToast];
                        });
                      }
                    }];
              }];
  [actions addObject:cancelRequestAction];

  // 下麦
  NEListenTogetherUIAlertAction *dropAction = [NEListenTogetherUIAlertAction
      actionWithTitle:NELocalizedString(@"下麦")
                 type:NEUIAlertActionTypeDropMic
              handler:^(id _Nonnull info) {
                [NEListenTogetherKit.getInstance
                    leaveSeat:^(NSInteger code, NSString *_Nullable msg, id _Nullable obj) {
                      if (code != 0) {
                        [NEListenTogetherToast showToast:NELocalizedString(@"下麦失败")];
                      }
                    }];
              }];
  [actions addObject:dropAction];

  // 房主退出并解散房间
  NEListenTogetherUIAlertAction *exitAction =
      [NEListenTogetherUIAlertAction actionWithTitle:NELocalizedString(@"退出并解散房间")
                                                type:NEUIAlertActionTypeExistRoom
                                             handler:^(id _Nonnull info) {
                                               [self closeRoom];
                                             }];
  [actions addObject:exitAction];
  return actions;
}
- (void)fetchPickedSongList {
  @weakify(self)[[NEListenTogetherKit getInstance]
      getOrderedSongsWithCallback:^(
          NSInteger code, NSString *_Nullable msg,
          NSArray<NEListenTogetherOrderSongModel *> *_Nullable orderSongs) {
        dispatch_async(dispatch_get_main_queue(), ^{
          @strongify(self)[self.roomFooterView configPickSongUnreadNumber:orderSongs.count];
        });
      }];
}

- (void)sendChatroomNotifyMessage:(NSString *)content {
  NEListenTogetherChatViewMessage *message = [[NEListenTogetherChatViewMessage alloc] init];
  message.type = NEListenTogetherChatViewMessageTypeNotication;
  message.notication = content;
  dispatch_async(dispatch_get_main_queue(), ^{
    [self.chatView addMessages:@[ message ]];
  });
}

@end
