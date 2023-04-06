// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <ReactiveObjC/ReactiveObjC.h>
#import <SDWebImage/SDWebImage.h>
#import <YYModel/YYModel.h>
#import "NEListenTogetherInnerSingleton.h"
#import "NEListenTogetherKit/NEListenTogetherKit-Swift.h"
#import "NEListenTogetherLocalized.h"
#import "NEListenTogetherPickSongEngine.h"
#import "NEListenTogetherToast.h"
#import "NEListenTogetherUI.h"
#import "NEListenTogetherUILog.h"
#import "NEListenTogetherUIManager.h"
#import "NEListenTogetherViewController+Seat.h"
#import "NEListenTogetherViewController+Utils.h"
#import "NSArray+NEListenTogetherUIExtension.h"
#import "UIView+NEListenTogetherUIToast.h"
@implementation NEListenTogetherViewController (Utils)
- (void)joinRoom {
  NEListenTogetherKitJoinVoiceRoomParams *param = [NEListenTogetherKitJoinVoiceRoomParams new];
  param.nick = NEListenTogetherUIManager.sharedInstance.nickname;
  param.roomUuid = self.detail.liveModel.roomUuid;
  param.role = self.role;
  if (self.role == NEListenTogetherRoleHost) {
    [self.micQueueView singleListen];
  } else {
    [self.micQueueView togetherListen];
  }
  param.liveRecordId = self.detail.liveModel.liveRecordId;
  NEListenTogetherInnerSingleton.singleton.roomInfo = self.detail;
  @weakify(self);
  [NEListenTogetherKit.getInstance
      joinRoom:param
       options:[NEJoinVoiceRoomOptions new]
      callback:^(NSInteger code, NSString *_Nullable msg, NEListenTogetherInfo *_Nullable info) {
        @strongify(self);
        self.detail = info;
        if (code != 0) {
          dispatch_async(dispatch_get_main_queue(), ^{
            [NEListenTogetherToast showToast:msg];
          });
          [self closeRoom];
          return;
        }
        // 开启音量上报
        [NEListenTogetherKit.getInstance enableAudioVolumeIndicationWithEnable:true interval:1000];
        /// 内部使用
        NEListenTogetherInnerSingleton.singleton.roomInfo = info;
        // 默认操作
        [self defaultOperation];
        // 获取麦位信息
        [self getSeatInfo];
        dispatch_async(dispatch_get_main_queue(), ^{
          //          [self.bgImageView
          //              sd_setImageWithURL:[NSURL URLWithString:info.liveModel.cover]
          //                placeholderImage:[NEListenTogetherUI
          //                ne_listen_imageName:@"chatRoom_bgImage_icon"]];
          self.roomHeaderView.title = info.liveModel.liveTopic;
          self.roomHeaderView.onlinePeople = NEListenTogetherKit.getInstance.allMemberList.count;
        });
      }];
}
- (void)unmuteAudio:(BOOL)showToast {
  [NEListenTogetherKit.getInstance
      unmuteMyAudio:^(NSInteger code, NSString *_Nullable msg, id _Nullable obj) {
        dispatch_async(dispatch_get_main_queue(), ^{
          if (code != 0) {
            [NEListenTogetherToast showToast:NELocalizedString(@"麦克风打开失败")];
          } else {
            self.mute = false;
            [self getSeatInfo];
            if (!showToast) return;
            [NEListenTogetherToast showToast:NELocalizedString(@"麦克风已打开")];
          }
        });
      }];
}

/// 关闭麦克风
- (void)muteAudio:(BOOL)showToast {
  [NEListenTogetherKit.getInstance
      muteMyAudio:^(NSInteger code, NSString *_Nullable msg, id _Nullable obj) {
        dispatch_async(dispatch_get_main_queue(), ^{
          if (code != 0) {
            if (code != 1021) {
              [NEListenTogetherToast showToast:NELocalizedString(@"静音失败")];
            }
            return;
          }
          [self getSeatInfo];
          if (!showToast) return;
          [NEListenTogetherToast showToast:NELocalizedString(@"麦克风已关闭")];
        });
      }];
}
- (void)addNetworkObserver {
  [self.reachability startNotifier];
  [NSNotificationCenter.defaultCenter addObserver:self
                                         selector:@selector(networkStatusChange)
                                             name:kNEListenTogetherReachabilityChangedNotification
                                           object:nil];
}
- (void)destroyNetworkObserver {
  [self.reachability stopNotifier];
  [NSNotificationCenter.defaultCenter removeObserver:self];
}
- (void)networkStatusChange {
  // 无网络
  if ([self.reachability currentReachabilityStatus] != NotReachable) {
    [NEListenTogetherUILog infoLog:ListenTogetherUILog desc:@"网络变化  有网"];

  } else {
    [NEListenTogetherUILog infoLog:ListenTogetherUILog desc:@"网络变化  有网"];
    [NEListenTogetherToast showToast:NELocalizedString(@"网络断开")];
  }
}
- (void)checkMicAuthority {
  [NEListenTogetherAuthorityHelper checkMicAuthority];
}
- (void)defaultOperation {
  if (self.role == NEListenTogetherRoleHost) {  // 直播
    [NEListenTogetherKit.getInstance
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
- (NSArray<NEListenTogetherSeatItem *> *)simulatedSeatData {
  NSMutableArray *datas = @[].mutableCopy;
  for (NSInteger i = 0; i < 8; i++) {
    NEListenTogetherSeatItem *item = [[NEListenTogetherSeatItem alloc] init];
    item.index = i + 2;
    [datas addObject:item];
  }
  return datas.copy;
}

- (BOOL)isAnchor {
  return self.role == NEListenTogetherRoleHost;
}

- (void)handleMuteOperation:(BOOL)isMute {
  if (isMute) {
    if ([self isAnchor]) {
      [self muteAudio:YES];
    } else {
      if (NEListenTogetherKit.getInstance.localMember.isAudioBanned) {
        [NEListenTogetherToast
            showToast:NELocalizedString(@"您已被主播屏蔽语音，暂不能操作麦克风")];
      } else {
        self.mute = true;
        [self muteAudio:YES];
      }
    }
  } else {
    if ([self isAnchor]) {
      [self unmuteAudio:YES];
    } else {
      if (NEListenTogetherKit.getInstance.localMember.isAudioBanned) {
        [NEListenTogetherToast
            showToast:NELocalizedString(@"您已被主播屏蔽语音，暂不能操作麦克风")];
      } else {
        [self unmuteAudio:YES];
      }
    }
  }
}

- (NSString *)fetchLyricContentWithSongId:(NSString *)songId channel:(SongChannel)channel {
  return [[NEListenTogetherKit getInstance] getLyric:songId channel:channel];
}
- (NSString *)fetchPitchContentWithSongId:(NSString *)songId channel:(SongChannel)channel {
  return [[NEListenTogetherKit getInstance] getPitch:songId channel:channel];
}
- (NSString *)fetchOriginalFilePathWithSongId:(NSString *)songId channel:(SongChannel)channel {
  return [[NEListenTogetherKit getInstance] getSongURI:songId
                                               channel:channel
                                           songResType:TYPE_ORIGIN];
}
- (NSString *)fetchAccompanyFilePathWithSongId:(NSString *)songId channel:(SongChannel)channel {
  return [[NEListenTogetherKit getInstance] getSongURI:songId
                                               channel:channel
                                           songResType:TYPE_ACCOMP];
}

/// 获取观众userUuid
- (NSString *)getAnotherAccount {
  NSString *anotherUuid;
  for (NEListenTogetherMember *member in [NEListenTogetherKit getInstance].allMemberList) {
    if (![member.account isEqualToString:self.detail.anchor.userUuid]) {
      anotherUuid = member.account;
      break;
    }
  }
  return anotherUuid;
}
@end
