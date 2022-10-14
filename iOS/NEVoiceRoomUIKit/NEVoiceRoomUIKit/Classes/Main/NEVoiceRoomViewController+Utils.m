// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <ReactiveObjC/ReactiveObjC.h>
#import <SDWebImage/SDWebImage.h>
#import "NEInnerSingleton.h"
#import "NEVoiceRoomToast.h"
#import "NEVoiceRoomUI.h"
#import "NEVoiceRoomUIManager.h"
#import "NEVoiceRoomViewController+Seat.h"
#import "NEVoiceRoomViewController+Utils.h"
#import "NSBundle+NELocalized.h"
#import "UIView+NEUIToast.h"
@implementation NEVoiceRoomViewController (Utils)
- (void)joinRoom {
  NEJoinVoiceRoomParams *param = [NEJoinVoiceRoomParams new];
  param.nick = NEVoiceRoomUIManager.sharedInstance.nickname;
  param.roomUuid = self.detail.liveModel.roomUuid;
  param.role = self.role;
  param.liveRecordId = self.detail.liveModel.liveRecordId;
  @weakify(self);
  [NEVoiceRoomKit.getInstance
      joinRoom:param
       options:[NEJoinVoiceRoomOptions new]
      callback:^(NSInteger code, NSString *_Nullable msg, NEVoiceRoomInfo *_Nullable info) {
        @strongify(self);
        self.detail = info;
        if (code != 0) {
          dispatch_async(dispatch_get_main_queue(), ^{
            [NEVoiceRoomToast showToast:NELocalizedString(@"加入房间失败")];
          });
          [self closeRoom];
          return;
        }
        /// 内部使用
        NEInnerSingleton.singleton.roomInfo = info;
        // 默认操作
        [self defaultOperation];
        // 获取麦位信息
        [self getSeatInfo];
        dispatch_async(dispatch_get_main_queue(), ^{
          //          [self.bgImageView
          //              sd_setImageWithURL:[NSURL URLWithString:info.liveModel.cover]
          //                placeholderImage:[NEVoiceRoomUI ne_imageName:@"chatRoom_bgImage_icon"]];
          self.roomHeaderView.title = info.liveModel.liveTopic;
          self.roomHeaderView.onlinePeople = NEVoiceRoomKit.getInstance.allMemberList.count;
        });
      }];
}
- (void)unmuteAudio:(BOOL)showToast {
  [NEVoiceRoomKit.getInstance
      unmuteMyAudio:^(NSInteger code, NSString *_Nullable msg, id _Nullable obj) {
        dispatch_async(dispatch_get_main_queue(), ^{
          if (code != 0) {
            [NEVoiceRoomToast showToast:NELocalizedString(@"麦克风打开失败")];
          } else {
            [self getSeatInfo];
            if (!showToast) return;
            [NEVoiceRoomToast showToast:NELocalizedString(@"麦克风已打开")];
          }
        });
      }];
}

/// 关闭麦克风
- (void)muteAudio:(BOOL)showToast {
  [NEVoiceRoomKit.getInstance
      muteMyAudio:^(NSInteger code, NSString *_Nullable msg, id _Nullable obj) {
        dispatch_async(dispatch_get_main_queue(), ^{
          if (code != 0) {
            if (code != 1021) {
              [NEVoiceRoomToast showToast:NELocalizedString(@"静音失败")];
            }
            return;
          }
          [self getSeatInfo];
          if (!showToast) return;
          [NEVoiceRoomToast showToast:NELocalizedString(@"麦克风已关闭")];
        });
      }];
}
- (void)addNetworkObserver {
  [self.reachability startNotifier];
  [NSNotificationCenter.defaultCenter addObserver:self
                                         selector:@selector(networkStatusChange)
                                             name:kNEVoiceRoomReachabilityChangedNotification
                                           object:nil];
}
- (void)destroyNetworkObserver {
  [self.reachability stopNotifier];
  [NSNotificationCenter.defaultCenter removeObserver:self];
}
- (void)networkStatusChange {
  // 无网络
  if ([self.reachability currentReachabilityStatus] != NotReachable) {
    [self.view dismissToast];
  } else {
    [self.view showToastWithMessage:NSLocalizedString(@"网络断开", nil)
                              state:NEUIToastStateFail
                        autoDismiss:NO];
  }
}
- (void)checkMicAuthority {
  [NEVoiceRoomAuthorityHelper checkMicAuthority];
}
- (void)defaultOperation {
  if (self.role == NEVoiceRoomRoleHost) {  // 直播
    [NEVoiceRoomKit.getInstance
        submitSeatRequest:1
                exclusive:YES
                 callback:^(NSInteger code, NSString *_Nullable msg, id _Nullable obj) {
                   if (code == 0) {
                     [self unmuteAudio:NO];
                   } else {
                     [self closeRoom];
                   }
                 }];
  }
}
- (NSArray<NEVoiceRoomSeatItem *> *)simulatedSeatData {
  NSMutableArray *datas = @[].mutableCopy;
  for (NSInteger i = 0; i < 8; i++) {
    NEVoiceRoomSeatItem *item = [[NEVoiceRoomSeatItem alloc] init];
    item.index = i + 2;
    [datas addObject:item];
  }
  return datas.copy;
}

- (BOOL)isAnchor {
  return self.role == NEVoiceRoomRoleHost;
}

- (void)handleMuteOperation:(BOOL)isMute {
  if (isMute) {
    if ([self isAnchor]) {
      [self muteAudio:YES];
    } else {
      if (NEVoiceRoomKit.getInstance.localMember.isAudioBanned) {
        [NEVoiceRoomToast showToast:NELocalizedString(@"您已被主播屏蔽语音，暂不能操作麦克风")];
      } else {
        [self muteAudio:YES];
      }
    }
  } else {
    if ([self isAnchor]) {
      [self unmuteAudio:YES];
    } else {
      if (NEVoiceRoomKit.getInstance.localMember.isAudioBanned) {
        [NEVoiceRoomToast showToast:NELocalizedString(@"您已被主播屏蔽语音，暂不能操作麦克风")];
      } else {
        [self unmuteAudio:YES];
      }
    }
  }
}
@end
