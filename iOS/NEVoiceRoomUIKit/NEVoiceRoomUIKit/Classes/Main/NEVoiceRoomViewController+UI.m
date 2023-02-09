// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <Masonry/Masonry.h>
#import <NEUIKit/NEUIBackNavigationController.h>
#import <NEUIKit/UIView+NEUIExtension.h>
#import <libextobjc/extobjc.h>
#import "NEUIDeviceSizeInfo.h"
#import "NEUIMicInviteeListVC.h"
#import "NEVoiceRoomToast.h"
#import "NEVoiceRoomViewController+UI.h"
#import "NSBundle+NELocalized.h"
#import "UIImage+VoiceRoom.h"
#import "UIView+NEUIToast.h"

@implementation NEVoiceRoomViewController (UI)
- (void)addSubviews {
  [self.view addSubview:self.bgImageView];
  [self.view addSubview:self.roomHeaderView];
  [self.view addSubview:self.roomFooterView];
  [self.view addSubview:self.chatView];
  [self.view addSubview:self.micQueueView];

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
    make.bottom.mas_equalTo(-[NEUIDeviceSizeInfo get_iPhoneBottomSafeDistance] - 8);
  }];
  CGFloat width = self.view.width - 2 * 30.0;
  CGFloat height = [self.micQueueView calculateHeightWithWidth:width];

  [self.micQueueView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(self.roomHeaderView.mas_bottom).offset(12);
    make.left.right.equalTo(self.view);
    make.height.mas_equalTo(height);
  }];

  [self.chatView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(self.micQueueView.mas_bottom).offset(20);
    make.bottom.equalTo(self.roomFooterView.mas_top).offset(-12);
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

- (NSMutableArray<NEVoiceRoomUIAlertAction *> *)setupAlertActions {
  NSMutableArray<NEVoiceRoomUIAlertAction *> *actions = @[].mutableCopy;
  // 抱麦操作
  NEVoiceRoomUIAlertAction *inviteAction = [NEVoiceRoomUIAlertAction
      actionWithTitle:NELocalizedString(@"将成员抱上麦")
                 type:NEUIAlertActionTypeInviteMic
              handler:^(id _Nonnull info) {
                NEVoiceRoomSeatItem *seatItem = (NEVoiceRoomSeatItem *)info;
                NEUIMicInviteeListVC *inviteeVC = [[NEUIMicInviteeListVC alloc] init];
                inviteeVC.seatIndex = seatItem.index;
                NEUIBackNavigationController *navigationVC =
                    [[NEUIBackNavigationController alloc] initWithRootViewController:inviteeVC];
                [self presentViewController:navigationVC animated:YES completion:nil];
              }];
  [actions addObject:inviteAction];

  // 屏蔽麦位音频 （关闭麦克风）
  NEVoiceRoomUIAlertAction *maskAction = [NEVoiceRoomUIAlertAction
      actionWithTitle:NELocalizedString(@"屏蔽麦位")
                 type:NEUIAlertActionTypeFinishedMaskMic
              handler:^(id _Nonnull info) {
                NEVoiceRoomSeatItem *seatItem = (NEVoiceRoomSeatItem *)info;
                [NEVoiceRoomKit.getInstance
                    banRemoteAudio:seatItem.user
                          callback:^(NSInteger code, NSString *_Nullable msg, id _Nullable obj) {
                            if (code != 0) {
                              [NEVoiceRoomToast showToast:NELocalizedString(@"语音屏蔽失败")];
                            }
                          }];
              }];
  [actions addObject:maskAction];

  // 关闭麦位
  NEVoiceRoomUIAlertAction *closeAction = [NEVoiceRoomUIAlertAction
      actionWithTitle:NELocalizedString(@"关闭麦位")
                 type:NEUIAlertActionTypeCloseMic
              handler:^(id _Nonnull info) {
                NEVoiceRoomSeatItem *seatItem = (NEVoiceRoomSeatItem *)info;
                [NEVoiceRoomKit.getInstance
                    closeSeatsWithSeatIndices:@[ @(seatItem.index) ]
                                     callback:^(NSInteger code, NSString *_Nullable msg,
                                                id _Nullable obj) {
                                       if (code != 0) {
                                         [NEVoiceRoomToast
                                             showToast:NELocalizedString(@"关闭麦位失败")];
                                       } else {
                                         NSString *msg =
                                             [NSString stringWithFormat:NELocalizedString(
                                                                            @"\"麦位%d\"已关闭"),
                                                                        (int)seatItem.index - 1];
                                         [NEVoiceRoomToast showToast:msg];
                                       }
                                     }];
              }];
  [actions addObject:closeAction];

  // 踢麦
  NEVoiceRoomUIAlertAction *kickoutAction = [NEVoiceRoomUIAlertAction
      actionWithTitle:NELocalizedString(@"将TA踢下麦位")
                 type:NEUIAlertActionTypeKickMic
              handler:^(id _Nonnull info) {
                NEVoiceRoomSeatItem *seatItem = (NEVoiceRoomSeatItem *)info;
                [NEVoiceRoomKit.getInstance
                    kickSeatWithAccount:seatItem.user
                               callback:^(NSInteger code, NSString *_Nullable msg,
                                          id _Nullable obj) {
                                 if (code != 0) {
                                   [NEVoiceRoomToast showToast:NELocalizedString(@"操作失败")];
                                 }
                               }];
              }];
  [actions addObject:kickoutAction];

  // 打开麦位
  NEVoiceRoomUIAlertAction *openAction = [NEVoiceRoomUIAlertAction
      actionWithTitle:NELocalizedString(@"打开麦位")
                 type:NEUIAlertActionTypeOpenMic
              handler:^(id _Nonnull info) {
                NEVoiceRoomSeatItem *seatItem = (NEVoiceRoomSeatItem *)info;
                [NEVoiceRoomKit.getInstance
                    openSeatsWithSeatIndices:@[ @(seatItem.index) ]
                                    callback:^(NSInteger code, NSString *_Nullable msg,
                                               id _Nullable obj) {
                                      if (code != 0) {
                                        [NEVoiceRoomToast
                                            showToast:NELocalizedString(@"麦位打开失败")];
                                      } else {
                                        [NEVoiceRoomToast
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
  NEVoiceRoomUIAlertAction *cancelMaskAction = [NEVoiceRoomUIAlertAction
      actionWithTitle:NELocalizedString(@"解除语音屏蔽")
                 type:NEUIAlertActionTypeCancelMaskMic
              handler:^(id _Nonnull info) {
                NEVoiceRoomSeatItem *seatItem = (NEVoiceRoomSeatItem *)info;
                [NEVoiceRoomKit.getInstance
                    unbanRemoteAudio:seatItem.user
                            callback:^(NSInteger code, NSString *_Nullable msg, id _Nullable obj) {
                              if (code != 0) {
                                [NEVoiceRoomToast showToast:NELocalizedString(@"解除语音屏蔽失败")];
                              }
                            }];
              }];
  [actions addObject:cancelMaskAction];

  // 取消申请上麦
  NEVoiceRoomUIAlertAction *cancelRequestAction = [NEVoiceRoomUIAlertAction
      actionWithTitle:NELocalizedString(@"确认取消申请上麦")
                 type:NEUIAlertActionTypeCancelOnMicRequest
              handler:^(id _Nonnull info) {
                [NEVoiceRoomKit.getInstance
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
  NEVoiceRoomUIAlertAction *dropAction = [NEVoiceRoomUIAlertAction
      actionWithTitle:NELocalizedString(@"下麦")
                 type:NEUIAlertActionTypeDropMic
              handler:^(id _Nonnull info) {
                [NEVoiceRoomKit.getInstance
                    leaveSeat:^(NSInteger code, NSString *_Nullable msg, id _Nullable obj) {
                      if (code != 0) {
                        [NEVoiceRoomToast showToast:NELocalizedString(@"下麦失败")];
                      }
                    }];
              }];
  [actions addObject:dropAction];

  // 房主退出并解散房间
  NEVoiceRoomUIAlertAction *exitAction =
      [NEVoiceRoomUIAlertAction actionWithTitle:NELocalizedString(@"退出并解散房间")
                                           type:NEUIAlertActionTypeExistRoom
                                        handler:^(id _Nonnull info) {
                                          [self closeRoom];
                                        }];
  [actions addObject:exitAction];
  return actions;
}

- (void)sendChatroomNotifyMessage:(NSString *)content {
  NEVoiceRoomChatViewMessage *message = [[NEVoiceRoomChatViewMessage alloc] init];
  message.type = NEVoiceRoomChatViewMessageTypeNotication;
  message.notication = content;
  dispatch_async(dispatch_get_main_queue(), ^{
    [self.chatView addMessages:@[ message ]];
  });
}
@end
