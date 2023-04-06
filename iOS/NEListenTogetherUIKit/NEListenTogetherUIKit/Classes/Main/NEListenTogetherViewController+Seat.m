// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <YYModel/YYModel.h>
#import "NEListenTogetherInnerSingleton.h"
#import "NEListenTogetherLocalized.h"
#import "NEListenTogetherPickSongEngine.h"
#import "NEListenTogetherToast.h"
#import "NEListenTogetherViewController+Seat.h"
#import "NEListenTogetherViewController+Utils.h"
#import "NSArray+NEListenTogetherUIExtension.h"
#import "UIView+NEListenTogetherUIToast.h"

@implementation NEListenTogetherViewController (Seat)
- (void)getSeatInfo {
  [NEListenTogetherKit.getInstance getSeatInfo:^(NSInteger code, NSString *_Nullable msg,
                                                 NEListenTogetherSeatInfo *_Nullable seatInfo) {
    if (code == 0 && seatInfo) {
      dispatch_async(dispatch_get_main_queue(), ^{
        [self.micQueueView setAnchorMicInfo:[NEListenTogetherInnerSingleton.singleton
                                                fetchAnchorItem:seatInfo.seatItems]];
        self.micQueueView.datas =
            [NEListenTogetherInnerSingleton.singleton fetchAudienceSeatItems:seatInfo.seatItems];
      });
    }
  }];
}

- (void)getSeatInfoWhenRejoinChatRoom {
  [[NEListenTogetherKit getInstance]
      getSongTokenWithCallback:^(NSInteger code, NSString *_Nullable msg,
                                 NEListenTogetherDynamicToken *_Nullable token) {
        if (code == 0) {
          [[NEListenTogetherKit getInstance] renewToken:token.accessToken];
        }
      }];
  [NEListenTogetherKit.getInstance getSeatInfo:^(NSInteger code, NSString *_Nullable msg,
                                                 NEListenTogetherSeatInfo *_Nullable seatInfo) {
    if (code == 0 && seatInfo) {
      dispatch_async(dispatch_get_main_queue(), ^{
        [self.micQueueView setAnchorMicInfo:[NEListenTogetherInnerSingleton.singleton
                                                fetchAnchorItem:seatInfo.seatItems]];
        self.micQueueView.datas =
            [NEListenTogetherInnerSingleton.singleton fetchAudienceSeatItems:seatInfo.seatItems];
        [self updateAudienceToast:seatInfo.seatItems];
      });
    }
  }];
  // 获取房间内播放歌曲
  [[NEListenTogetherKit getInstance] queryPlayingSongInfo:^(
                                         NSInteger code, NSString *_Nullable msg,
                                         NEListenTogetherPlayMusicInfo *_Nullable songModel) {
    if (code == NEListenTogetherErrorCode.success) {
      NEListenTogetherSongModel *model = [[NEListenTogetherSongModel alloc] init];
      model.playMusicInfo = songModel;
      BOOL sameSong = NO;
      if ([NEListenTogetherPickSongEngine sharedInstance].currrentSongModel.playMusicInfo.songId &&
          [[NEListenTogetherPickSongEngine sharedInstance].currrentSongModel.playMusicInfo.songId
              isEqualToString:songModel.songId]) {
        sameSong = YES;
      }
      [NEListenTogetherPickSongEngine sharedInstance].currrentSongModel = model;
      /// 做同步处理，等同中途加入，不需要ready
      if (songModel.oc_songStatus == 3) {
        // 一方已经ready，需要发送ready
        self.playingAction = PlayingAction_default;
      } else {
        self.playingAction = PlayingAction_join_half_way;
      }
      /// 获取已点列表数据
      [[NEListenTogetherPickSongEngine sharedInstance]
          getKaraokeSongOrderedList:^(NSError *_Nullable error) {
            /// 判断当前房间是否存在播放中歌曲
            if (songModel.songId.length > 0) {
              // 房间内存在播放中歌曲
              if (sameSong) {
                /// 房间内播放歌曲和本地播放中的是同一首
                /// 同步进度
                NSString *userUuid;
                if (self.isAnchor) {
                  /// 是主播
                  userUuid = [self getAnotherAccount];
                } else {
                  /// 是连麦者
                  userUuid = self.detail.anchor.userUuid;
                }
                if (!userUuid) {
                  return;
                }
                NSString *dataString =
                    @{@"userUuid" : NEListenTogetherKit.getInstance.localMember.account}
                        .yy_modelToJSONString;
                [[NEListenTogetherKit getInstance]
                    sendCustomMessage:userUuid
                            commandId:NEListenTogetherCustomActionGetPosition
                                 data:dataString
                             callback:nil];
              } else {
                BOOL matched = NO;
                for (NEListenTogetherOrderSongModel *model in
                     [NEListenTogetherPickSongEngine sharedInstance]
                         .pickedSongArray) {
                  if (matched) {
                    // 预加载歌曲
                    [[NEListenTogetherKit getInstance] preloadSong:model.songId
                                                           channel:(int)model.oc_channel
                                                           observe:self];
                  }
                  if ([model.songId isEqualToString:songModel.songId] &&
                      (model.oc_channel == songModel.oc_channel)) {
                    matched = YES;
                    // 当前存在播放中歌曲
                    [[NEListenTogetherKit getInstance] preloadSong:songModel.songId
                                                           channel:(int)songModel.oc_channel
                                                           observe:self];
                  }
                }
              }
            }
          }];
    }
  }];
}
- (void)updateAudienceToast:(NSArray *)seatItems {
  if (![self isAnchor]) {
    // 观众
    [self configSelfSeatStatusWithSeatItems:seatItems];
    bool audienceOnSeat = false;
    for (NEListenTogetherSeatItem *item in seatItems) {
      if ([item.user isEqualToString:NEListenTogetherKit.getInstance.localMember.account]) {
        /// 当前用户
        audienceOnSeat = true;
        if (item.status == NEListenTogetherSeatItemStatusTaken) {
          /// 已上麦，上麦行为
          [self.view dismissToast];
        } else if (item.status == NEListenTogetherSeatItemStatusWaiting) {
          /// 不做任何操作
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
- (void)anchorOperationSeatItem:(NEListenTogetherSeatItem *)seatItem {
  // 主播点击自己
  if ([seatItem.user
          isEqualToString:NEListenTogetherInnerSingleton.singleton.roomInfo.anchor.userUuid])
    return;
  NSMutableArray *actionTypes = @[].mutableCopy;
  switch (seatItem.status) {
    case NEListenTogetherSeatItemStatusInitial: {  // 麦上无人
      // 抱麦、关闭
      [actionTypes
          addObjectsFromArray:@[ @(NEUIAlertActionTypeInviteMic), @(NEUIAlertActionTypeCloseMic) ]];
    } break;
    case NEListenTogetherSeatItemStatusTaken: {  // 麦位被占
      NEListenTogetherMember *member = [self getMemberOnTheSeat:seatItem];
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
    case NEListenTogetherSeatItemStatusClosed: {  // 麦位关闭
      [actionTypes addObject:@(NEUIAlertActionTypeOpenMic)];
    } break;
    default:
      break;
  }
  [self.alertView showWithTypes:actionTypes info:seatItem];
}
- (void)audienceOperationSeatItem:(NEListenTogetherSeatItem *)seatItem {
  switch (seatItem.status) {
    case NEListenTogetherSeatItemStatusWaiting: {  // 等待中
      if (![seatItem.user isEqualToString:NEListenTogetherKit.getInstance.localMember.account]) {
        [NEListenTogetherToast
            showToast:[NSString stringWithFormat:@"%@ %@", seatItem.userName,
                                                 NELocalizedString(@"正在申请该麦位")]];
      }
      return;
    }
    case NEListenTogetherSeatItemStatusTaken: {  // 被占
      if ([seatItem.user isEqualToString:NEListenTogetherKit.getInstance.localMember.account]) {
        [self.alertView showWithTypes:@[ @(NEUIAlertActionTypeDropMic) ] info:seatItem];
      }
    } break;
    case NEListenTogetherSeatItemStatusClosed: {  // 关闭
      [NEListenTogetherToast showToast:NELocalizedString(@"该麦位已关闭")];
      return;
    } break;
    case NEListenTogetherSeatItemStatusInitial: {  // 无人
      switch (self.selfStatus) {
        case NEListenTogetherSeatItemStatusInitial: {
          // 申请上麦
          __weak typeof(self) weakSelf = self;
          [NEListenTogetherKit.getInstance
              submitSeatRequest:seatItem.index
                      exclusive:YES
                       callback:^(NSInteger code, NSString *_Nullable msg, id _Nullable obj) {
                         dispatch_async(dispatch_get_main_queue(), ^{
                           if (code == 0) {
                             [weakSelf.view
                                 showToastWithMessage:NELocalizedString(@"已申请上麦，等待通过...")
                                                state:NEUIToastCancel
                                               cancel:^{
                                                 [weakSelf.alertView showWithTypes:@[
                                                   @(NEUIAlertActionTypeCancelOnMicRequest)
                                                 ]
                                                                              info:seatItem];
                                               }];
                           } else {
                             [NEListenTogetherToast
                                 showToast:NELocalizedString(@"该麦位正在被操作")];
                           }
                         });
                       }];
        } break;
        case NEListenTogetherSeatItemStatusWaiting: {
          [NEListenTogetherToast
              showToast:NELocalizedString(@"该麦位正在被申请,请尝试申请其他麦位")];
        } break;
        default:
          break;
      }
    } break;
    default:
      break;
  }
}

#pragma mark------------------------ NEListenTogetherListener ------------------------

- (void)onSeatListChanged:(NSArray<NEListenTogetherSeatItem *> *)seatItems {
  [self configSelfSeatStatusWithSeatItems:seatItems];
  // 刷新UI
  [self.micQueueView
      setAnchorMicInfo:[NEListenTogetherInnerSingleton.singleton fetchAnchorItem:seatItems]];
  self.micQueueView.datas =
      [NEListenTogetherInnerSingleton.singleton fetchAudienceSeatItems:seatItems];

  self.connectorArray = [seatItems ne_filter:^BOOL(NEListenTogetherSeatItem *obj) {
                          return obj.status == NEListenTogetherSeatItemStatusWaiting;
                        }].mutableCopy;
  dispatch_async(dispatch_get_main_queue(), ^{
    if ([self isAnchor]) {
      // 加入请求连麦队列
      [self.connectListView refreshWithDataArray:self.connectorArray];
      // 有人在申请，弹出提示框
      if (self.connectorArray.count) {
        [self.connectListView showAsAlertOnView:self.view];
      }
    } else {
      NEListenTogetherSeatItem *selfSeat = [seatItems ne_find:^BOOL(NEListenTogetherSeatItem *obj) {
        return [obj.user isEqualToString:[NEListenTogetherKit getInstance].localMember.account];
      }];
      if (selfSeat && selfSeat.status == NEListenTogetherSeatItemStatusTaken) {
        // 自己已经在麦上，更新底部工具栏
        [self.roomFooterView updateAudienceOperatingButton:YES];
        self.context.rtcConfig.micOn = [NEListenTogetherKit getInstance].localMember.isAudioOn;
        if (!self.context.rtcConfig.micOn && self.lastSelfItem == nil) {
          /// 麦克风关闭，并且原来不在麦上
          /// 打开麦克风
          [self unmuteAudio:YES];
        }
        self.lastSelfItem = selfSeat;
      } else {
        [self.roomFooterView updateAudienceOperatingButton:NO];
      }
    }
  });
}

- (void)onSeatLeave:(NSInteger)seatIndex account:(NSString *)account {
  [self NotifityMessage:NELocalizedString(@"已下麦") account:account];
  if (![self isAnchor] && [self isSelfWithSeatAccount:account]) {
    self.mute = false;
    [NEListenTogetherToast showToast:NELocalizedString(@"您已下麦")];
    [self muteAudio:NO];
    [self.roomFooterView updateAudienceOperatingButton:NO];
  }
  if ([account isEqualToString:self.detail.liveModel.userUuid]) {
    dispatch_async(dispatch_get_main_queue(), ^{
      if (self.presentedViewController) {
        [self.presentedViewController dismissViewControllerAnimated:false completion:nil];
      }
      [self.navigationController popViewControllerAnimated:YES];
    });
  }

  NSLog(@"下麦");
}
- (void)onSeatKicked:(NSInteger)seatIndex
             account:(NSString *)account
           operateBy:(NSString *)operateBy {
  [self NotifityMessage:NELocalizedString(@"已被主播请下麦位") account:account];
  if ([self isAnchor]) {
    NEListenTogetherMember *member =
        [NEListenTogetherKit.getInstance.allMemberList ne_find:^BOOL(NEListenTogetherMember *obj) {
          return [account isEqualToString:obj.account];
        }];
    if (!member) return;
    [NEListenTogetherToast
        showToast:[NSString
                      stringWithFormat:NELocalizedString(@"已将\"%@\"踢下麦位"), member.name]];
    return;
  }
  if ([self isSelfWithSeatAccount:account]) {
    self.mute = false;
    [NEListenTogetherToast showToast:NELocalizedString(@"您已被主播踢下麦")];
    [self.view dismissToast];
    [self muteAudio:NO];
    [self.roomFooterView updateAudienceOperatingButton:NO];
  }
  NSLog(@"从麦位上被踢");
}

- (void)onSeatRequestCancelled:(NSInteger)seatIndex account:(NSString *)account {
  NSLog(@"取消申请麦位");
  [self NotifityMessage:NELocalizedString(@"已取消申请上麦") account:account];
  if ([account isEqualToString:NEListenTogetherKit.getInstance.localMember.account]) {
    [self.view dismissToast];
  }
}
- (void)onSeatRequestSubmitted:(NSInteger)seatIndex account:(NSString *)account {
  [self NotifityMessage:[NSString stringWithFormat:@"%@(%zd)", NELocalizedString(@"申请上麦"),
                                                   seatIndex - 1]
                account:account];
  // 房主
  if ([self isAnchor]) {
    if ([account isEqualToString:NEListenTogetherKit.getInstance.localMember.account]) return;
  }
}
- (void)onSeatRequestApproved:(NSInteger)seatIndex
                      account:(NSString *)account
                    operateBy:(NSString *)operateBy
                  isAutoAgree:(BOOL)isAutoAgree {
  [self NotifityMessage:NELocalizedString(@"已上麦") account:account];
  if (![account isEqualToString:NEListenTogetherKit.getInstance.localMember.account]) return;
  [self.view dismissToast];
  [self unmuteAudio:YES];
  [self.roomFooterView updateAudienceOperatingButton:YES];
  NSLog(@"房主同意请求");
}
- (void)onSeatRequestRejected:(NSInteger)seatIndex
                      account:(NSString *)account
                    operateBy:(NSString *)operateBy {
  [self NotifityMessage:NELocalizedString(@"申请麦位已被拒绝") account:account];
  [self getSeatInfo];
  if ([self isAnchor]) return;
  if (![account isEqualToString:NEListenTogetherKit.getInstance.localMember.account]) return;
  [NEListenTogetherToast showToast:NELocalizedString(@"你的申请已被拒绝")];
  [self.view dismissToast];
  NSLog(@"房主拒绝请求");
}
- (void)onSeatInvitationAccepted:(NSInteger)seatIndex
                         account:(NSString *)account
                     isAutoAgree:(BOOL)isAutoAgree {
  [self NotifityMessage:NELocalizedString(@"已上麦") account:account];
  if ([self isAnchor]) {
    NEListenTogetherMember *member =
        [NEListenTogetherKit.getInstance.allMemberList ne_find:^BOOL(NEListenTogetherMember *obj) {
          return [account isEqualToString:obj.account];
        }];
    if (!member) return;
    //    [NEListenTogetherToast
    //        showToast:[NSString stringWithFormat:@"%@ %@ %@%ld", NELocalizedString(@"已将"),
    //                                             member.name, NELocalizedString(@"抱上麦位"),
    //                                             seatIndex - 1]];
    return;
  }
  if ([self isSelfWithSeatAccount:account]) {
    //    [NEListenTogetherToast
    //        showToast:[NSString stringWithFormat:@"%@%ld",
    //        NELocalizedString(@"您已被主播抱上麦位"),
    //                                             seatIndex - 1]];
    [self unmuteAudio:NO];
    [self.roomFooterView updateAudienceOperatingButton:YES];
    [self.view dismissToast];
    //    [self audienceOperation];
  }
}

- (void)audienceOperation {
  if (self.role == NEListenTogetherRoleAudience) {
    // 观众
    [[NEListenTogetherKit getInstance]
        queryPlayingSongInfo:^(NSInteger code, NSString *_Nullable msg,
                               NEListenTogetherPlayMusicInfo *_Nullable songModel) {
          if (code == 0) {
            NEListenTogetherSongModel *currentModel = [[NEListenTogetherSongModel alloc] init];
            currentModel.playMusicInfo = songModel;
            [NEListenTogetherPickSongEngine sharedInstance].currrentSongModel = currentModel;
            self.playingAction = PlayingAction_join_half_way;
            [[NEListenTogetherPickSongEngine sharedInstance]
                getKaraokeSongOrderedList:^(NSError *_Nullable error) {
                  if (!error) {
                    BOOL matched = NO;
                    for (NEListenTogetherOrderSongModel *model in
                         [NEListenTogetherPickSongEngine sharedInstance]
                             .pickedSongArray) {
                      if (matched) {
                        // 预加载歌曲
                        [[NEListenTogetherKit getInstance] preloadSong:model.songId
                                                               channel:(int)model.oc_channel
                                                               observe:self];
                      }
                      if ([model.songId isEqualToString:songModel.songId] &&
                          (model.oc_channel == songModel.oc_channel)) {
                        matched = YES;
                        // 当前存在播放中歌曲
                        [[NEListenTogetherKit getInstance] preloadSong:songModel.songId
                                                               channel:(int)songModel.oc_channel
                                                               observe:self];
                      }
                    }
                  }
                }];
          }
        }];
  }
}

- (void)onMemberAudioMuteChanged:(NEListenTogetherMember *)member
                            mute:(BOOL)mute
                       operateBy:(NEListenTogetherMember *)operateBy {
  [self getSeatInfo];
}
- (void)onMemberAudioBanned:(NEListenTogetherMember *)member banned:(BOOL)banned {
  self.micQueueView.datas = self.micQueueView.datas;
  NSString *anchorTitle = banned ? NELocalizedString(@"该麦位语音已被屏蔽，无法发言")
                                 : NELocalizedString(@"该麦位已\"解除语音屏蔽\"");
  if ([self isAnchor]) {
    [NEListenTogetherToast showToast:anchorTitle];
    return;
  }
  if (![NEListenTogetherKit.getInstance.localMember.account isEqualToString:member.account]) {
    return;
  }
  if (!banned) {
    if (!self.mute) {
      [self unmuteAudio:NO];
    }
  } else {
    [self muteAudio:NO];
  }
  NSString *audienceTitle =
      banned ? NELocalizedString(@"该麦位被主播\"屏蔽语音\"\n现在您已无法进行语音互动")
             : NELocalizedString(@"该麦位被主播\"解除语音屏蔽\"\n现在您可以在此进行语音互动了");
  if ([self isSelfWithSeatAccount:member.account]) {
    [NEListenTogetherToast showToast:audienceTitle];
  }
}
- (NEListenTogetherMember *_Nullable)getMemberOnTheSeat:(NEListenTogetherSeatItem *)seatItem {
  for (NEListenTogetherMember *member in NEListenTogetherKit.getInstance.allMemberList) {
    if ([member.account isEqualToString:seatItem.user]) {
      return member;
    }
  }
  return nil;
}
// 设置自己的麦位状态
- (void)configSelfSeatStatusWithSeatItems:(NSArray<NEListenTogetherSeatItem *> *)seatItems {
  for (NEListenTogetherSeatItem *item in seatItems) {
    if ([item.user isEqualToString:NEListenTogetherKit.getInstance.localMember.account]) {
      self.selfStatus = item.status;
      return;
    }
  }
  self.selfStatus = NEListenTogetherSeatItemStatusInitial;
}

// 麦位上是否是自己
- (BOOL)isSelfWithSeatAccount:(NSString *)account {
  if ([NEListenTogetherKit.getInstance.localMember.account isEqualToString:account]) {
    return YES;
  }
  return NO;
}

- (void)NotifityMessage:(NSString *)msg account:(NSString *)account {
  NEListenTogetherMember *member =
      [NEListenTogetherKit.getInstance.allMemberList ne_find:^BOOL(NEListenTogetherMember *obj) {
        return [account isEqualToString:obj.account];
      }];
  if (!member) return;

  NSMutableArray *messages = @[].mutableCopy;
  NEListenTogetherChatViewMessage *message = [NEListenTogetherChatViewMessage new];
  message.type = NEListenTogetherChatViewMessageTypeNotication;
  message.notication = [NSString stringWithFormat:@"%@ %@", member.name, msg];
  [messages addObject:message];
  dispatch_async(dispatch_get_main_queue(), ^{
    [self.chatView addMessages:messages];
  });
}
@end
