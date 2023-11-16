// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEInnerSingleton.h"
#import "NEVoiceRoomLocalized.h"
#import "NEVoiceRoomToast.h"
#import "NEVoiceRoomUILog.h"
#import "NEVoiceRoomViewController+Seat.h"
#import "NEVoiceRoomViewController+Utils.h"
#import "NSArray+NEUIExtension.h"
#import "UIView+NEUIToast.h"

@implementation NEVoiceRoomViewController (Seat)
- (void)getSeatInfo {
  [NEVoiceRoomUILog infoLog:@"GetSeatInfo" desc:[NSString stringWithFormat:@"%s", __FUNCTION__]];
  __weak typeof(self) weakSelf = self;
  [NEVoiceRoomKit.getInstance getSeatInfo:^(NSInteger code, NSString *_Nullable msg,
                                            NEVoiceRoomSeatInfo *_Nullable seatInfo) {
    if (code == 0 && seatInfo) {
      dispatch_async(dispatch_get_main_queue(), ^{
        NEVoiceRoomSeatItem *anchorSeatInfo =
            [NEInnerSingleton.singleton fetchAnchorItem:seatInfo.seatItems];
        NSArray *otherDatas =
            [NEInnerSingleton.singleton fetchAudienceSeatItems:seatInfo.seatItems];
        [weakSelf.micQueueView setAnchorMicInfo:anchorSeatInfo];
        weakSelf.micQueueView.datas = otherDatas;
        [weakSelf updateGiftAnchorSeat:anchorSeatInfo];
        [weakSelf updateGiftOtherDatas:otherDatas];
      });
    }
  }];
}

- (void)getSeatInfoWhenRejoinChatRoom {
  [[NEOrderSong getInstance] getSongTokenWithCallback:^(NSInteger code, NSString *_Nullable msg,
                                                        NEOrderSongDynamicToken *_Nullable token) {
    if (code == 0) {
      [[NEOrderSong getInstance] renewToken:token.accessToken];
    }
  }];
  [self updateRoomInfo];
  [self getSongInfo];
}
- (void)updateAudienceToast:(NSArray *)seatItems {
  if (![self isAnchor]) {
    bool audienceOnSeat = false;
    for (NEVoiceRoomSeatItem *item in seatItems) {
      if ([item.user isEqualToString:NEVoiceRoomKit.getInstance.localMember.account]) {
        /// 当前用户
        audienceOnSeat = true;
        if (item.status == NEVoiceRoomSeatItemStatusTaken) {
          /// 已上麦，上麦行为
          [self.view dismissToast];
        } else if (item.status == NEVoiceRoomSeatItemStatusWaiting) {
          __weak typeof(self) weakSelf = self;
          [self.view showToastWithMessage:NELocalizedString(@"已申请上麦，等待通过...")
                                    state:NEUIToastCancel
                                   cancel:^{
                                     [weakSelf.alertView
                                         showWithTypes:@[ @(NEUIAlertActionTypeCancelOnMicRequest) ]
                                                  info:item];
                                   }
                             dismissToast:NO];
        }
        break;
      }
    }
    if (!audienceOnSeat) {
      /// 如果不在麦上，则处理 toast
      [self.view dismissToast];
    }
  }
}
- (void)anchorOperationSeatItem:(NEVoiceRoomSeatItem *)seatItem {
  // 主播点击自己
  if ([seatItem.user isEqualToString:NEInnerSingleton.singleton.roomInfo.anchor.userUuid]) return;
  NSMutableArray *actionTypes = @[].mutableCopy;
  switch (seatItem.status) {
    case NEVoiceRoomSeatItemStatusInitial: {  // 麦上无人
      // 抱麦、关闭
      [actionTypes
          addObjectsFromArray:@[ @(NEUIAlertActionTypeInviteMic), @(NEUIAlertActionTypeCloseMic) ]];
    } break;
    case NEVoiceRoomSeatItemStatusTaken: {  // 麦位被占
      NEVoiceRoomMember *member = [self getMemberOnTheSeat:seatItem];
      if (member.isAudioBanned) {
        // 踢人、解除音频、关闭
        [actionTypes addObjectsFromArray:@[
          @(NEUIAlertActionTypeKickMic), @(NEUIAlertActionTypeCancelMaskMic),
          @(NEUIAlertActionTypeCloseMic)
        ]];
      } else {
        // 踢人、屏蔽音频、关闭
        [actionTypes addObjectsFromArray:@[
          @(NEUIAlertActionTypeKickMic), @(NEUIAlertActionTypeFinishedMaskMic),
          @(NEUIAlertActionTypeCloseMic)
        ]];
      }
    } break;
    case NEVoiceRoomSeatItemStatusClosed: {  // 麦位关闭
      [actionTypes addObject:@(NEUIAlertActionTypeOpenMic)];
    } break;
    default:
      break;
  }
  [self.alertView showWithTypes:actionTypes info:seatItem];
}
- (void)audienceOperationSeatItem:(NEVoiceRoomSeatItem *)seatItem {
  switch (seatItem.status) {
    case NEVoiceRoomSeatItemStatusWaiting: {  // 等待中
      if (![seatItem.user isEqualToString:NEVoiceRoomKit.getInstance.localMember.account]) {
        [NEVoiceRoomToast
            showToast:[NSString stringWithFormat:@"%@ %@", seatItem.userName,
                                                 NELocalizedString(@"正在申请该麦位")]];
      }
      return;
    }
    case NEVoiceRoomSeatItemStatusTaken: {  // 被占
      if ([seatItem.user isEqualToString:NEVoiceRoomKit.getInstance.localMember.account]) {
        [self.alertView showWithTypes:@[ @(NEUIAlertActionTypeDropMic) ] info:seatItem];
      }
    } break;
    case NEVoiceRoomSeatItemStatusClosed: {  // 关闭
      [NEVoiceRoomToast showToast:NELocalizedString(@"该麦位已关闭")];
      return;
    } break;
    case NEVoiceRoomSeatItemStatusInitial: {  // 无人
      switch (self.selfStatus) {
        case NEVoiceRoomSeatItemStatusInitial: {
          // 当前正在申请中，直接返回
          for (UIView *subView in self.view.subviews) {
            if (subView.tag == KNEVoiceRoomToastBarTag &&
                ((NEUIToastBar *)subView).infoLab.text ==
                    NELocalizedString(@"已申请上麦，等待通过...")) {
              return;
            }
          }
          // 申请上麦
          __weak typeof(self) weakSelf = self;
          [self.view showToastWithMessage:NELocalizedString(@"已申请上麦，等待通过...")
                                    state:NEUIToastCancel
                                   cancel:^{
                                     [weakSelf.alertView
                                         showWithTypes:@[ @(NEUIAlertActionTypeCancelOnMicRequest) ]
                                                  info:seatItem];
                                   }];
          [NEVoiceRoomKit.getInstance
              submitSeatRequest:seatItem.index
                      exclusive:YES
                       callback:^(NSInteger code, NSString *_Nullable msg, id _Nullable obj) {
                         dispatch_async(dispatch_get_main_queue(), ^{
                           if (code != 0) {
                             [weakSelf.view dismissToast];
                             [NEVoiceRoomToast showToast:NELocalizedString(@"该麦位正在被操作")];
                           }
                         });
                       }];
        } break;
        case NEVoiceRoomSeatItemStatusWaiting: {
          [NEVoiceRoomToast showToast:NELocalizedString(@"该麦位正在被申请,请尝试申请其他麦位")];
        } break;
        default:
          break;
      }
    } break;
    default:
      break;
  }
}

#pragma mark------------------------ NEVoiceRoomListener ------------------------

- (void)onSeatListChanged:(NSArray<NEVoiceRoomSeatItem *> *)seatItems {
  __weak typeof(self) weakSelf = self;
  dispatch_async(dispatch_get_main_queue(), ^{
    __strong typeof(weakSelf) self = weakSelf;
    if (self.role == NEVoiceRoomRoleHost) {
      self.connectorArray = [seatItems ne_filter:^BOOL(NEVoiceRoomSeatItem *obj) {
                              return obj.status == NEVoiceRoomSeatItemStatusWaiting;
                            }].mutableCopy;
      // 刷新请求连麦队列
      [self.connectListView refreshWithDataArray:self.connectorArray];
      // 有人在申请，弹出提示框
      if (self.connectorArray.count) {
        // 自己申请不算
        if (self.connectorArray.count == 1 &&
            [((NEVoiceRoomSeatItem *)self.connectorArray.firstObject).user
                isEqualToString:[NEVoiceRoomKit getInstance].localMember.account]) {
        } else {
          [self.connectListView showAsAlertOnView:self.view];
        }
      }
    } else {
      NEVoiceRoomSeatItem *selfSeat = [seatItems ne_find:^BOOL(NEVoiceRoomSeatItem *obj) {
        return [obj.user isEqualToString:[NEVoiceRoomKit getInstance].localMember.account];
      }];
      if (selfSeat && selfSeat.status == NEVoiceRoomSeatItemStatusTaken) {
        // 自己已经在麦上，更新底部工具栏
        [self.roomFooterView updateAudienceOperatingButton:YES];
        self.context.rtcConfig.micOn = [NEVoiceRoomKit getInstance].localMember.isAudioOn;
      } else {
        [self.roomFooterView updateAudienceOperatingButton:NO];
      }
      [self updateAudienceToast:seatItems];
    }
    NEVoiceRoomSeatItem *anchorSeatInfo = [NEInnerSingleton.singleton fetchAnchorItem:seatItems];
    NSArray *otherDatas = [NEInnerSingleton.singleton fetchAudienceSeatItems:seatItems];
    [self.micQueueView setAnchorMicInfo:anchorSeatInfo];
    self.micQueueView.datas = otherDatas;
    [self updateGiftAnchorSeat:anchorSeatInfo];
    [self updateGiftOtherDatas:otherDatas];
    [self configSelfSeatStatusWithSeatItems:seatItems];
  });
}

- (void)onSeatLeave:(NSInteger)seatIndex account:(NSString *)account {
  [self NotifityMessage:NELocalizedString(@"已下麦") account:account];
  if (![self isAnchor] && [self isSelfWithSeatAccount:account]) {
    [NEVoiceRoomToast showToast:NELocalizedString(@"您已下麦")];
    [self.roomFooterView updateAudienceOperatingButton:NO];
  }
}
- (void)onSeatKicked:(NSInteger)seatIndex
             account:(NSString *)account
           operateBy:(NSString *)operateBy {
  [self NotifityMessage:NELocalizedString(@"已被主播请下麦位") account:account];
  if ([self isAnchor]) {
    NEVoiceRoomMember *member =
        [NEVoiceRoomKit.getInstance.allMemberList ne_find:^BOOL(NEVoiceRoomMember *obj) {
          return [account isEqualToString:obj.account];
        }];
    if (!member) return;
    [NEVoiceRoomToast showToast:[NSString stringWithFormat:NELocalizedString(@"已将\"%@\"踢下麦位"),
                                                           member.name]];
    return;
  }
  if ([self isSelfWithSeatAccount:account]) {
    [NEVoiceRoomToast showToast:NELocalizedString(@"您已被主播踢下麦")];
    [self.view dismissToast];
    [self.roomFooterView updateAudienceOperatingButton:NO];
  }
  NSLog(@"从麦位上被踢");
}

- (void)onSeatRequestCancelled:(NSInteger)seatIndex account:(NSString *)account {
  NSLog(@"取消申请麦位");
  [self NotifityMessage:NELocalizedString(@"已取消申请上麦") account:account];
  if ([account isEqualToString:NEVoiceRoomKit.getInstance.localMember.account]) {
    [self.view dismissToast];
  }
}
- (void)onSeatRequestSubmitted:(NSInteger)seatIndex account:(NSString *)account {
  [self NotifityMessage:[NSString stringWithFormat:@"%@(%zd)", NELocalizedString(@"申请上麦"),
                                                   seatIndex - 1]
                account:account];
  // 房主
  if ([self isAnchor]) {
    if ([account isEqualToString:NEVoiceRoomKit.getInstance.localMember.account]) return;
  }
  /// 3.7.0 礼物值不清空
  //  else{
  //      [self.micQueueView updateGiftData:account];
  //  }
}
- (void)onSeatRequestApproved:(NSInteger)seatIndex
                      account:(NSString *)account
                    operateBy:(NSString *)operateBy
                  isAutoAgree:(BOOL)isAutoAgree {
  [self updateRoomInfo];
  [self NotifityMessage:NELocalizedString(@"已上麦") account:account];
  if (![account isEqualToString:NEVoiceRoomKit.getInstance.localMember.account]) return;
  [self.view dismissToast];
  [self.roomFooterView updateAudienceOperatingButton:YES];
  NSLog(@"房主同意请求");
}
- (void)onSeatRequestRejected:(NSInteger)seatIndex
                      account:(NSString *)account
                    operateBy:(NSString *)operateBy {
  [self NotifityMessage:NELocalizedString(@"申请麦位已被拒绝") account:account];
  [NEVoiceRoomUILog infoLog:@"GetSeatInfo" desc:[NSString stringWithFormat:@"%s", __FUNCTION__]];
  [self getSeatInfo];
  if ([self isAnchor]) return;
  if (![account isEqualToString:NEVoiceRoomKit.getInstance.localMember.account]) return;
  [NEVoiceRoomToast showToast:NELocalizedString(@"你的申请已被拒绝")];
  [self.view dismissToast];
  NSLog(@"房主拒绝请求");
}
- (void)onSeatInvitationAccepted:(NSInteger)seatIndex
                         account:(NSString *)account
                     isAutoAgree:(BOOL)isAutoAgree {
  [self NotifityMessage:NELocalizedString(@"已上麦") account:account];
  /// 3.7.0 礼物值不清空
  //    [self.micQueueView updateGiftData:account];
  if ([self isAnchor]) {
    NEVoiceRoomMember *member =
        [NEVoiceRoomKit.getInstance.allMemberList ne_find:^BOOL(NEVoiceRoomMember *obj) {
          return [account isEqualToString:obj.account];
        }];
    if (!member) return;
    [NEVoiceRoomToast
        showToast:[NSString stringWithFormat:@"%@ %@ %@%ld", NELocalizedString(@"已将"),
                                             member.name, NELocalizedString(@"抱上麦位"),
                                             seatIndex - 1]];
    return;
  }
  [self updateRoomInfo];
  if ([self isSelfWithSeatAccount:account]) {
    [NEVoiceRoomToast
        showToast:[NSString stringWithFormat:@"%@%ld", NELocalizedString(@"您已被主播抱上麦位"),
                                             seatIndex - 1]];
    [self.roomFooterView updateAudienceOperatingButton:YES];
    [self.view dismissToast];
  }
}
- (void)onMemberAudioMuteChanged:(NEVoiceRoomMember *)member
                            mute:(BOOL)mute
                       operateBy:(NEVoiceRoomMember *)operateBy {
  [NEVoiceRoomUILog infoLog:@"GetSeatInfo" desc:[NSString stringWithFormat:@"%s", __FUNCTION__]];
  [self getSeatInfo];
}
- (void)onMemberAudioBanned:(NEVoiceRoomMember *)member banned:(BOOL)banned {
  [self.micQueueView reloadData];
  NSString *anchorTitle = banned ? NELocalizedString(@"该麦位语音已被屏蔽，无法发言")
                                 : NELocalizedString(@"该麦位已\"解除语音屏蔽\"");
  if ([self isAnchor]) {
    [NEVoiceRoomToast showToast:anchorTitle];
    return;
  }
  if (![NEVoiceRoomKit.getInstance.localMember.account isEqualToString:member.account]) {
    return;
  }
  NSString *audienceTitle =
      banned ? NELocalizedString(@"该麦位被主播\"屏蔽语音\"\n现在您已无法进行语音互动")
             : NELocalizedString(@"该麦位被主播\"解除语音屏蔽\"\n现在您可以在此进行语音互动了");
  if ([self isSelfWithSeatAccount:member.account]) {
    [NEVoiceRoomToast showToast:audienceTitle];
  }
}
- (NEVoiceRoomMember *_Nullable)getMemberOnTheSeat:(NEVoiceRoomSeatItem *)seatItem {
  for (NEVoiceRoomMember *member in NEVoiceRoomKit.getInstance.allMemberList) {
    if ([member.account isEqualToString:seatItem.user]) {
      return member;
    }
  }
  return nil;
}
// 设置自己的麦位状态
- (void)configSelfSeatStatusWithSeatItems:(NSArray<NEVoiceRoomSeatItem *> *)seatItems {
  for (NEVoiceRoomSeatItem *item in seatItems) {
    if ([item.user isEqualToString:NEVoiceRoomKit.getInstance.localMember.account]) {
      self.selfStatus = item.status;
      return;
    }
  }
  self.selfStatus = NEVoiceRoomSeatItemStatusInitial;
}

// 麦位上是否是自己
- (BOOL)isSelfWithSeatAccount:(NSString *)account {
  if ([NEVoiceRoomKit.getInstance.localMember.account isEqualToString:account]) {
    return YES;
  }
  return NO;
}

- (void)NotifityMessage:(NSString *)msg account:(NSString *)account {
  NEVoiceRoomMember *member =
      [NEVoiceRoomKit.getInstance.allMemberList ne_find:^BOOL(NEVoiceRoomMember *obj) {
        return [account isEqualToString:obj.account];
      }];
  if (!member) return;

  NSMutableArray *messages = @[].mutableCopy;
  NESocialChatroomNotiMessage *message = [NESocialChatroomNotiMessage new];
  message.notification = [NSString stringWithFormat:@"%@ %@", member.name, msg];
  [messages addObject:message];
  dispatch_async(dispatch_get_main_queue(), ^{
    [self.chatView addMessages:messages];
  });
}
@end
