// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEListenTogetherViewController.h"
#import <NECopyrightedMedia/NECopyrightedMedia.h>
#import <NEUIKit/NEUIBaseNavigationController.h>
#import <NEUIKit/UIView+NEUIExtension.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import <YYModel/YYModel.h>
#import "NEListenTogetherChatView.h"
#import "NEListenTogetherGlobalMacro.h"
#import "NEListenTogetherLocalized.h"
#import "NEListenTogetherPickSongEngine.h"
#import "NEListenTogetherPickSongView.h"
#import "NEListenTogetherRoomListViewController.h"
#import "NEListenTogetherSendGiftViewController.h"
#import "NEListenTogetherStringMacro.h"
#import "NEListenTogetherToast.h"
#import "NEListenTogetherUI.h"
#import "NEListenTogetherUIActionSheetNavigationController.h"
#import "NEListenTogetherUIDeviceSizeInfo.h"
#import "NEListenTogetherUILog.h"
#import "NEListenTogetherUIManager.h"
#import "NEListenTogetherUIMoreFunctionVC.h"
#import "NEListenTogetherViewController+Seat.h"
#import "NEListenTogetherViewController+UI.h"
#import "NEListenTogetherViewController+Utils.h"
#import "UIImage+ListenTogether.h"

@interface NEListenTogetherViewController () <NEListenTogetherHeaderDelegate,
                                              NEListenTogetherFooterFunctionAreaDelegate,
                                              NEUIMoreSettingDelegate,
                                              NEUIKeyboardToolbarDelegate,
                                              NEListenTogetherMicQueueViewDelegate,
                                              NEUIConnectListViewDelegate,
                                              NEListenTogetherSendGiftViewtDelegate,
                                              NEListenTogetherLyricActionViewDelegate,
                                              NESongPointProtocol,
                                              NEListenTogetherCopyrightedMediaListener,
                                              NEListenTogetherPickSongViewProtocol,
                                              NEListenTogetherLyricControlViewDelegate>

@property(nonatomic, strong) NEListenTogetherPickSongView *pickSongView;

@end

@implementation NEListenTogetherViewController
- (instancetype)initWithRole:(NEListenTogetherRole)role detail:(NEListenTogetherInfo *)detail {
  if (self = [super init]) {
    self.detail = detail;
    self.role = role;
    self.context.role = role;
    self.audioManager = [[NEAudioEffectManager alloc] init];
  }
  return self;
}
- (void)dealloc {
  [NEListenTogetherKit.getInstance removeVoiceRoomListener:self];
  [self destroyNetworkObserver];
  [[NEListenTogetherPickSongEngine sharedInstance] removeObserve:self];
  [NEListenTogetherPickSongEngine sharedInstance].currrentSongModel = nil;

  if ([[NEListenTogetherUIManager sharedInstance].delegate
          respondsToSelector:@selector(onListenTogetherLeaveRoom)]) {
    [[NEListenTogetherUIManager sharedInstance].delegate onListenTogetherLeaveRoom];
  }
}
- (void)viewDidLoad {
  [super viewDidLoad];

  if ([[NEListenTogetherUIManager sharedInstance].delegate
          respondsToSelector:@selector(onListenTogetherJoinRoom)]) {
    [[NEListenTogetherUIManager sharedInstance].delegate onListenTogetherJoinRoom];
  }

  self.playingStatus = PlayingStatus_default;
  self.playingAction = PlayingAction_default;
  // Do any additional setup after loading the view.
  self.ne_UINavigationItem.navigationBarHidden = YES;
  [NEListenTogetherKit.getInstance addVoiceRoomListener:self];
  [self addSubviews];
  [self joinRoom];
  [self observeKeyboard];
  [self addNetworkObserver];
  [self checkMicAuthority];
  [[NEListenTogetherPickSongEngine sharedInstance] addObserve:self];

  // 禁止返回
  id traget = self.navigationController.interactivePopGestureRecognizer.delegate;
  UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:traget action:nil];
  [self.view addGestureRecognizer:pan];
}

- (void)closeRoom {
  if (self.role == NEListenTogetherRoleHost) {  // 主播
    [NEListenTogetherKit.getInstance
        endRoom:^(NSInteger code, NSString *_Nullable msg, id _Nullable obj) {
          dispatch_async(dispatch_get_main_queue(), ^{
            [NEListenTogetherToast showToast:NELocalizedString(@"房间解散成功")];
            if (self.presentedViewController) {
              [self.presentedViewController dismissViewControllerAnimated:false completion:nil];
            }
            [self backToListViewController];
          });
        }];
  } else {  // 观众
    [NEListenTogetherKit.getInstance
        leaveRoom:^(NSInteger code, NSString *_Nullable msg, id _Nullable obj) {
          dispatch_async(dispatch_get_main_queue(), ^{
            if (self.presentedViewController) {
              [self.presentedViewController dismissViewControllerAnimated:false completion:nil];
            }
            [self.navigationController popViewControllerAnimated:YES];
          });
        }];
  }
}

- (void)backToListViewController {
  UIViewController *target = nil;
  for (UIViewController *controller in self.navigationController.viewControllers) {
    if ([controller isKindOfClass:[NEListenTogetherRoomListViewController class]]) {
      target = controller;
      break;
    }
  }
  if (target) {
    [self.navigationController popToViewController:target animated:YES];
  }
}
#pragma mark - NTESLiveRoomHeaderDelegate
- (void)headerExitAction {
  [self closeRoom];
}

#pragma mark - NETSFunctionAreaDelegate
// 点歌事件
- (void)footerDidReceiveRequestSongAciton {
}

// 麦克静音事件
- (void)footerDidReceiveMicMuteAction:(BOOL)mute {
  [self handleMuteOperation:mute];
}

- (void)footerDidReceiveGiftClickAciton {
  // 发送礼物
  [NEListenTogetherSendGiftViewController showWithTarget:self viewController:self];
}
// 禁言事件
- (void)footerDidReceiveNoSpeekingAciton {
}

/// 点击点歌台
- (void)footerDidReceiveMusicClickAciton {
  [self showChooseSingViewController];
}
// menu点击事件
- (void)footerDidReceiveMenuClickAciton {
  NEListenTogetherUIMoreFunctionVC *moreVC =
      [[NEListenTogetherUIMoreFunctionVC alloc] initWithContext:self.context];
  moreVC.delegate = self;
  NEListenTogetherUIActionSheetNavigationController *nav =
      [[NEListenTogetherUIActionSheetNavigationController alloc] initWithRootViewController:moreVC];
  nav.dismissOnTouchOutside = YES;
  [self presentViewController:nav animated:YES completion:nil];
}

// 输入框点击事件
- (void)footerInputViewDidClickAction {
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)),
                 dispatch_get_main_queue(), ^{
                   [self.keyboardView becomeFirstResponse];
                 });
}
#pragma mark------------------------ NEUIMoreSettingDelegate ------------------------
- (void)didEarbackOn:(BOOL)earBackOn {
}
- (void)didSetMicOn:(BOOL)micOn {
  if (micOn) {
    [self unmuteAudio:YES];
  } else {
    self.mute = true;
    [self muteAudio:YES];
  }
}
- (void)endLive {
  [self closeRoom];
}

#pragma mark------------------------ NEListenTogetherSendGiftViewtDelegate ------------------------

- (void)didSendGift:(NEListenTogetherUIGiftModel *)gift {
  if (![self checkNetwork]) {
    return;
  }

  [self
      dismissViewControllerAnimated:true
                         completion:^{
                           [[NEListenTogetherKit getInstance]
                               sendGift:gift.giftId
                               callback:^(NSInteger code, NSString *_Nullable msg,
                                          id _Nullable obj) {
                                 if (code != 0) {
                                   [NEListenTogetherToast
                                       showToast:[NSString stringWithFormat:@"发送礼物失败 %zd %@",
                                                                            code, msg]];
                                 }
                               }];
                         }];
}

- (BOOL)checkNetwork {
  NEListenTogetherNetworkStatus status = [self.reachability currentReachabilityStatus];
  if (status == NotReachable) {
    [NEListenTogetherToast showToast:@"网络连接断开，请稍后重试"];
    return false;
  }
  return true;
}

#pragma mark------------------------ NEUIKeyboardToolbarDelegate ------------------------
- (void)didToolBarSendText:(NSString *)text {
  NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
  text = [text stringByTrimmingCharactersInSet:set];
  if (text.length <= 0) {
    [NEListenTogetherToast showToast:NELocalizedString(@"发送内容为空")];
    return;
  }
  [NEListenTogetherKit.getInstance
      sendTextMessage:text
             callback:^(NSInteger code, NSString *_Nullable msg, id _Nullable obj) {
               dispatch_async(dispatch_get_main_queue(), ^{
                 NEListenTogetherChatViewMessage *model = [NEListenTogetherChatViewMessage new];
                 model.type = NEListenTogetherChatViewMessageTypeNormal;
                 model.text = text;
                 model.sender = NEListenTogetherUIManager.sharedInstance.nickname;
                 model.isAnchor = self.role == NEListenTogetherRoleHost;
                 [self.chatView addMessages:@[ model ]];
               });
             }];
}
#pragma mark------------------------ NEListenTogetherListener ------------------------

- (void)onRtcLocalAudioVolumeIndicationWithVolume:(NSInteger)volume enableVad:(BOOL)enableVad {
  [self.micQueueView updateWithLocalVolume:volume];
}

- (void)onRtcRemoteAudioVolumeIndicationWithVolumes:
            (NSArray<NEListenTogetherMemberVolumeInfo *> *)volumes
                                        totalVolume:(NSInteger)totalVolume {
  [self.micQueueView updateWithRemoteVolumeInfos:volumes];
}

- (void)onAudioOutputDeviceChanged:(enum NEListenTogetherAudioOutputDevice)device {
  if (device == NEListenTogetherAudioOutputDeviceWiredHeadset ||
      device == NEListenTogetherAudioOutputDeviceBluetoothHeadset) {
    self.context.rtcConfig.earbackOn = true;
    [NSNotificationCenter.defaultCenter
        postNotification:[[NSNotification alloc] initWithName:@"CanUseEarback"
                                                       object:nil
                                                     userInfo:nil]];
  } else {
    self.context.rtcConfig.earbackOn = false;
    [NSNotificationCenter.defaultCenter
        postNotification:[[NSNotification alloc] initWithName:@"CanNotUseEarback"
                                                       object:nil
                                                     userInfo:nil]];
  }
}

- (void)onMemberJoinRoom:(NSArray<NEListenTogetherMember *> *)members {
  [self.micQueueView togetherListen];
  NSMutableArray *messages = @[].mutableCopy;
  for (NEListenTogetherMember *member in members) {
    NEListenTogetherChatViewMessage *message = [NEListenTogetherChatViewMessage new];
    message.type = NEListenTogetherChatViewMessageTypeNotication;
    message.notication =
        [NSString stringWithFormat:@"%@ %@", member.name, NELocalizedString(@"加入房间")];
    [messages addObject:message];
  }
  dispatch_async(dispatch_get_main_queue(), ^{
    self.roomHeaderView.onlinePeople = NEListenTogetherKit.getInstance.allMemberList.count;
    [self.chatView addMessages:messages];
  });
}
- (void)onMemberLeaveRoom:(NSArray<NEListenTogetherMember *> *)members {
  [self.micQueueView singleListen];
  NSMutableArray *messages = @[].mutableCopy;
  for (NEListenTogetherMember *member in members) {
    NEListenTogetherChatViewMessage *message = [NEListenTogetherChatViewMessage new];
    message.type = NEListenTogetherChatViewMessageTypeNotication;
    message.notication =
        [NSString stringWithFormat:@"%@ %@", member.name, NELocalizedString(@"离开房间")];
    [messages addObject:message];
#warning 请求麦位信息
  }
  dispatch_async(dispatch_get_main_queue(), ^{
    self.roomHeaderView.onlinePeople = NEListenTogetherKit.getInstance.allMemberList.count;
    [self.chatView addMessages:messages];
  });
}
- (void)onMemberJoinChatroom:(NSArray<NEListenTogetherMember *> *)members {
  bool isSelf = false;
  for (NEListenTogetherMember *member in members) {
    if ([member.account isEqualToString:NEListenTogetherKit.getInstance.localMember.account]) {
      isSelf = true;
      break;
    }
  }
  if (isSelf) {
    [self getSeatInfoWhenRejoinChatRoom];
  } else {
    [NEListenTogetherKit.getInstance
        sendSeatInvitationWithSeatIndex:2
                                account:members.firstObject.account
                               callback:^(NSInteger code, NSString *_Nullable msg,
                                          id _Nullable obj) {
                                 if (code != 0) {
                                   //                                   [NEListenTogetherToast
                                   //                                   showToast:NELocalizedString(@"操作失败")];
                                 }
                               }];
  }
}
- (void)onReceiveTextMessage:(NEListenTogetherChatTextMessage *)message {
  dispatch_async(dispatch_get_main_queue(), ^{
    NEListenTogetherChatViewMessage *model = [[NEListenTogetherChatViewMessage alloc] init];
    model.type = NEListenTogetherChatViewMessageTypeNormal;
    model.text = message.text;
    model.sender = message.fromNick;
    model.isAnchor = [message.fromUserUuid isEqualToString:self.detail.liveModel.userUuid];
    [self.chatView addMessages:@[ model ]];
  });
}

- (void)onReceiveGiftWithGiftModel:(NEListenTogetherGiftModel *)giftModel {
  dispatch_async(dispatch_get_main_queue(), ^{
    // 展示礼物动画
    NEListenTogetherChatViewMessage *message = [[NEListenTogetherChatViewMessage alloc] init];
    message.type = NEListenTogetherChatViewMessageTypeReward;
    message.giftId = (int)giftModel.giftId;
    message.giftFrom = giftModel.sendNick;
    [self.chatView addMessages:@[ message ]];

    if (self.role != NEListenTogetherRoleHost) {
      // 房主不展示礼物
      NSString *giftName = [NSString stringWithFormat:@"anim_gift_0%zd", giftModel.giftId];
      [self playGiftWithName:giftName];
    }
  });
}

- (void)onRoomEnded:(enum NEListenTogetherEndReason)reason {
  dispatch_async(dispatch_get_main_queue(), ^{
    if (reason != NEListenTogetherEndReasonLeaveBySelf) {
      [NEListenTogetherToast showToast:NELocalizedString(@"房间关闭")];
      if (self.presentedViewController) {
        [self.presentedViewController dismissViewControllerAnimated:false completion:nil];
      }
      [self.navigationController popViewControllerAnimated:YES];
    }
  });
}
- (void)onRtcChannelError:(NSInteger)code {
  if (code == 30015) {
    [self closeRoom];
  }
}

- (void)onAudioEffectFinished {
  // 播放完成，清理本地的model
  if ([self isAnchor]) {
    [[NEListenTogetherKit getInstance]
        nextSongWithOrderId:[NEListenTogetherPickSongEngine sharedInstance]
                                .currrentSongModel.playMusicInfo.orderId
                 attachment:PlayComplete
                   callback:^(NSInteger code, NSString *_Nullable msg, id _Nullable obj){

                   }];
  }
}

- (void)onAudioEffectTimestampUpdate:(uint32_t)effectId timeStampMS:(uint64_t)timeStampMS {
  if (effectId == NEListenTogetherKit.OriginalEffectId) {
    if (timeStampMS > self.time) {
      [self.micQueueView play];
    } else {
      [self.micQueueView pause];
    }
    self.time = (long)timeStampMS;
    [self.lyricActionView updateLyric:self.time];
  }
}

- (void)onReceiveSongPosition:(enum NEListenTogetherCustomAction)actionType
                         data:(NSDictionary<NSString *, id> *)data {
  if (actionType == NEListenTogetherCustomActionGetPosition) {
    NSString *songId =
        [NEListenTogetherPickSongEngine sharedInstance].currrentSongModel.playMusicInfo.songId;
    if (!songId.length) {
      return;
    }
    // 获取进度
    NSDictionary *songDic = @{
      @"songId" : [NEListenTogetherPickSongEngine sharedInstance]
          .currrentSongModel.playMusicInfo.songId,
      @"channel" : [NSNumber numberWithLong:[NEListenTogetherPickSongEngine sharedInstance]
                                                .currrentSongModel.playMusicInfo.oc_channel],
      @"progress" : [NSNumber numberWithLong:self.time]
    };
    [[NEListenTogetherKit getInstance] sendCustomMessage:data[@"userUuid"]
                                               commandId:NEListenTogetherCustomActionSendPosition
                                                    data:songDic.yy_modelToJSONString
                                                callback:nil];
  } else if (actionType == NEListenTogetherCustomActionSendPosition) {
    NSInteger progress = [data[@"progress"] intValue];
    [[NEListenTogetherKit getInstance] setPlayingPositionWithPosition:progress];
    self.time = progress;
    [self.lyricActionView updateLyric:progress];
    if ([NEListenTogetherPickSongEngine sharedInstance]
            .currrentSongModel.playMusicInfo.oc_songStatus == 2) {
      // 暂停
      [[NEListenTogetherKit getInstance]
          pauseEffectWithEffectId:NEListenTogetherKit.OriginalEffectId];
    }
    //        [self.lyricActionView seekLyricView:];
  } else if (actionType == NEListenTogetherCustomActionDownloadProcess) {
    NSString *songId = data[@"songId"];
    if ([songId isEqualToString:[NEListenTogetherPickSongEngine sharedInstance]
                                    .currrentSongModel.playMusicInfo.songId]) {
      NSNumber *downloadProcess = data[@"downloadProcess"];
      if (downloadProcess.intValue == 1) {
        /// 开始下载
        if (self.role == NEListenTogetherRoleHost) {
          [self.micQueueView showDownloadingProcess:YES show:YES];
        } else {
          [self.micQueueView showDownloadingProcess:NO show:YES];
        }
      } else {
        /// 下载完成
        if (self.role == NEListenTogetherRoleHost) {
          [self.micQueueView showDownloadingProcess:YES show:NO];
        } else {
          [self.micQueueView showDownloadingProcess:NO show:NO];
        }
      }
    }
  }
}

#pragma mark - gift animation

/// 播放礼物动画
- (void)playGiftWithName:(NSString *)name {
  [self.view addSubview:self.giftAnimation];
  [self.view bringSubviewToFront:self.giftAnimation];
  [self.giftAnimation addGift:name];
}

- (NEListenTogetherAnimationView *)giftAnimation {
  if (!_giftAnimation) {
    _giftAnimation = [[NEListenTogetherAnimationView alloc] init];
  }
  return _giftAnimation;
}

#pragma mark------------------------ NEListenTogetherMicQueueViewDelegate ------------------------
- (void)micQueueConnectBtnPressedWithMicInfo:(NEListenTogetherSeatItem *)micInfo {
  switch (self.role) {
    case NEListenTogetherRoleHost: {  // 主播操作麦位
      [self anchorOperationSeatItem:micInfo];
    } break;
    default: {  // 观众操作麦位
      [self audienceOperationSeatItem:micInfo];
    } break;
  }
}

- (void)clickPointSongButton {
  [self showChooseSingViewController];
}
#pragma mark------------------------ NEUIConnectListViewDelegate ------------------------
- (void)connectListView:(NEListenTogetherUIConnectListView *)connectListView
    onAcceptWithSeatItem:(NEListenTogetherSeatItem *)seatItem {
  [NEListenTogetherKit.getInstance
      approveSeatRequestWithAccount:seatItem.user
                           callback:^(NSInteger code, NSString *_Nullable msg, id _Nullable obj) {
                             if (code == 0) {
                               dispatch_async(dispatch_get_main_queue(), ^{
                                 [self.connectorArray removeObject:seatItem];
                                 [self.connectListView refreshWithDataArray:self.connectorArray];
                               });
                             }
                           }];
}
- (void)connectListView:(NEListenTogetherUIConnectListView *)connectListView
    onRejectWithSeatItem:(NEListenTogetherSeatItem *)seatItem {
  [NEListenTogetherKit.getInstance
      rejectSeatRequestWithAccount:seatItem.user
                          callback:^(NSInteger code, NSString *_Nullable msg, id _Nullable obj) {
                            if (code == 0) {
                              dispatch_async(dispatch_get_main_queue(), ^{
                                [self.connectorArray removeObject:seatItem];
                                [self.connectListView refreshWithDataArray:self.connectorArray];
                              });
                            }
                          }];
}
#pragma mark------------------------ Getter  ------------------------
- (NEListenTogetherContext *)context {
  if (!_context) {
    _context = [NEListenTogetherContext new];
  }
  return _context;
}
- (UIImageView *)bgImageView {
  if (!_bgImageView) {
    _bgImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    _bgImageView.contentMode = UIViewContentModeScaleAspectFill;
    _bgImageView.image = [NEListenTogetherUI ne_listen_imageName:@"chatRoom_bgImage_icon"];
  }
  return _bgImageView;
}
- (NEListenTogetherHeaderView *)roomHeaderView {
  if (!_roomHeaderView) {
    _roomHeaderView = [[NEListenTogetherHeaderView alloc] init];
    _roomHeaderView.delegate = self;
  }
  return _roomHeaderView;
}

- (NEListenTogetherFooterView *)roomFooterView {
  if (!_roomFooterView) {
    _roomFooterView = [[NEListenTogetherFooterView alloc] initWithContext:self.context];
    _roomFooterView.role = self.role;
    _roomFooterView.delegate = self;
  }
  return _roomFooterView;
}
- (NEListenTogetherKeyboardToolbarView *)keyboardView {
  if (!_keyboardView) {
    _keyboardView = [[NEListenTogetherKeyboardToolbarView alloc]
        initWithFrame:CGRectMake(0, [NEUICommon ne_screenHeight], [NEUICommon ne_screenWidth], 50)];
    _keyboardView.backgroundColor = UIColor.whiteColor;
    _keyboardView.cusDelegate = self;
  }
  return _keyboardView;
}
- (NEListenTogetherChatView *)chatView {
  if (!_chatView) {
    _chatView = [[NEListenTogetherChatView alloc] initWithFrame:CGRectMake(0, 0, 100, 200)];
  }
  return _chatView;
}
- (NEListenTogetherMicQueueView *)micQueueView {
  if (!_micQueueView) {
    _micQueueView = [[NEListenTogetherMicQueueView alloc] initWithFrame:CGRectZero];
    _micQueueView.delegate = self;
    _micQueueView.datas = [self simulatedSeatData];
  }
  return _micQueueView;
}
- (NEListenTogetherReachability *)reachability {
  if (!_reachability) {
    _reachability = [NEListenTogetherReachability reachabilityForInternetConnection];
  }
  return _reachability;
}
- (NEListenTogetherUIAlertView *)alertView {
  if (!_alertView) {
    _alertView = [[NEListenTogetherUIAlertView alloc] initWithActions:[self setupAlertActions]];
  }
  return _alertView;
}
- (NEListenTogetherUIConnectListView *)connectListView {
  if (!_connectListView) {
    _connectListView = [[NEListenTogetherUIConnectListView alloc]
        initWithFrame:CGRectMake(0, 0, self.view.width, 0)];
    _connectListView.delegate = self;
  }
  return _connectListView;
}
- (NSMutableArray *)connectorArray {
  if (!_connectorArray) {
    _connectorArray = @[].mutableCopy;
  }
  return _connectorArray;
}

- (NEListenTogetherLyricActionView *)lyricActionView {
  if (!_lyricActionView) {
    _lyricActionView = [[NEListenTogetherLyricActionView alloc] initWithFrame:self.view.frame];
    _lyricActionView.delegate = self;
  }
  return _lyricActionView;
}

- (NEListenTogetherLyricControlView *)lyricControlView {
  if (!_lyricControlView) {
    _lyricControlView = [[NEListenTogetherLyricControlView alloc] initWithFrame:self.view.frame];
    _lyricControlView.delegate = self;
  }
  return _lyricControlView;
}

#pragma mark------------------------ Private ------------------------

- (void)showChooseSingViewController {
  if (![self checkNetwork]) {
    return;
  }
  self.pickSongView = nil;
  CGSize size = CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds),
                           CGRectGetHeight([UIScreen mainScreen].bounds) / 3 * 2);
  UIViewController *controller = [[UIViewController alloc] init];
  controller.preferredContentSize = size;
  self.pickSongView =
      [[NEListenTogetherPickSongView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)
                                                   detail:self.detail];
  [self.pickSongView setPlayingStatus:(self.playingStatus == PlayingStatus_playing)];
  [self.pickSongView setVolume:[NEListenTogetherKit getInstance].getEffectVolume * 1.0 / 100.00];
  self.pickSongView.delegate = self;
  @weakify(self) self.pickSongView.isUserOnSeat = ^bool {
    @strongify(self) return [self isOnSeat];
  };
  controller.view = self.pickSongView;
  NEListenTogetherUIActionSheetNavigationController *nav =
      [[NEListenTogetherUIActionSheetNavigationController alloc]
          initWithRootViewController:controller];
  controller.navigationController.navigationBar.hidden = true;
  nav.dismissOnTouchOutside = YES;
  [self presentViewController:nav animated:YES completion:nil];

  @weakify(nav) self.pickSongView.applyOnseat = ^{
    @strongify(nav) @strongify(self) UIAlertController *alert = [UIAlertController
        alertControllerWithTitle:NELocalizedString(@"仅麦上成员可点歌，先申请上麦")
                         message:nil
                  preferredStyle:UIAlertControllerStyleAlert];
    @weakify(self)
        [alert addAction:[UIAlertAction actionWithTitle:NELocalizedString(@"取消")
                                                  style:UIAlertActionStyleCancel
                                                handler:^(UIAlertAction *_Nonnull action) {
                                                  @strongify(self)[self.pickSongView cancelApply];
                                                }]];
    [alert addAction:[UIAlertAction
                         actionWithTitle:NELocalizedString(@"申请上麦")
                                   style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction *_Nonnull action) {
                                   if (![NEListenTogetherAuthorityHelper
                                           checkMicAuthority]) {  // 麦克风权限
                                     [NEListenTogetherToast
                                         showToast:NELocalizedString(@"请先开启麦克风权限")];
                                     return;
                                   }
                                   // 申请上麦
                                   [NEListenTogetherKit.getInstance
                                       requestSeat:^(NSInteger code, NSString *_Nullable msg,
                                                     id _Nullable obj) {
                                         if (code == 0) {
                                           [self.pickSongView applyFaile];
                                         } else {
                                           [self.pickSongView applySuccess];
                                         }
                                       }];
                                 }]];
    UIViewController *controller = nav;
    if (controller.presentedViewController) {
      controller = controller.presentedViewController;
    }
    [controller presentViewController:alert
                             animated:true
                           completion:^{
                           }];
  };
}

#pragma mark------------------------ CMD处理 ------------------------
- (void)onReceiveChorusMessage:(enum NEListenTogetherChorusActionType)actionType
                     songModel:(NEListenTogetherSongModel *)songModel {
  if (actionType == NEListenTogetherChorusActionTypeStartSong) {
    [self sendChatroomNotifyMessage:[NSString stringWithFormat:@"%@《%@》",
                                                               NELocalizedString(@"正在播放歌曲"),
                                                               songModel.playMusicInfo.songName]];
    /// 开始唱歌
    self.playingStatus = PlayingStatus_playing;
    [self singSong:songModel];
    [NEListenTogetherPickSongEngine sharedInstance].currrentSongModel = songModel;
    [NEListenTogetherUILog infoLog:ListenTogetherUILog
                              desc:[NSString stringWithFormat:@"播放中的歌曲赋值 --- %@",
                                                              songModel.playMusicInfo.songId]];
    [self refreshUI];
    if (self.pickSongView) {
      // 刷新数据
      [self.pickSongView refreshPickedSongView];
    }

  } else if (actionType == NEListenTogetherChorusActionTypePauseSong) {
    // 暂停
    self.playingStatus = PlayingStatus_pause;
    [[NEListenTogetherKit getInstance]
        pauseEffectWithEffectId:NEListenTogetherKit.OriginalEffectId];
    [self.micQueueView pause];
    [self.pickSongView setPlayingStatus:(self.playingStatus == PlayingStatus_playing)];
    [self.lyricControlView setIsPlaying:(self.playingStatus == PlayingStatus_playing)];
  } else if (actionType == NEListenTogetherChorusActionTypeResumeSong) {
    /// 本地有缓存数据，并且orderId 相同，说明是恢复
    [[NEListenTogetherKit getInstance]
        resumeEffectWithEffectId:NEListenTogetherKit.OriginalEffectId];
    self.playingStatus = PlayingStatus_playing;
    [self refreshUI];
    //    [self.micQueueView play];
    [self.pickSongView setPlayingStatus:(self.playingStatus == PlayingStatus_playing)];
    [self.lyricControlView setIsPlaying:(self.playingStatus == PlayingStatus_playing)];
  }
}

- (void)refreshUI {
  if (self.pickSongView) {
    [self.pickSongView setPlayingStatus:(self.playingStatus == PlayingStatus_playing)];
    [self.lyricControlView setIsPlaying:(self.playingStatus == PlayingStatus_playing)];
  }
  //    [self.micQueueView showListenButton:NO];
}

- (void)voiceroom_onPreloadComplete:(NSString *)songId
                            channel:(SongChannel)channel
                              error:(NSError *)error {
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
  if (![NEListenTogetherPickSongEngine sharedInstance].currrentSongModel.playMusicInfo) {
    return;
  }
  NSDictionary *songDic = @{
    @"songId" : songId,
    @"channel" : [NSNumber numberWithLong:channel],
    @"downloadProcess" : [NSNumber numberWithInt:0]
  };
  [[NEListenTogetherKit getInstance] sendCustomMessage:userUuid
                                             commandId:NEListenTogetherCustomActionDownloadProcess
                                                  data:songDic.yy_modelToJSONString
                                              callback:nil];

  [NEListenTogetherKit.getInstance
      queryPlayingSongInfo:^(NSInteger code, NSString *_Nullable msg,
                             NEListenTogetherPlayMusicInfo *_Nullable model) {
        if (code == NEListenTogetherErrorCode.success) {
          if (model) {
            // 有播放中歌曲
            if ([songId isEqualToString:model.songId] && (channel == model.oc_channel)) {
              if ([NEListenTogetherPickSongEngine sharedInstance].currrentSongModel) {
                if (self.playingAction == PlayingAction_join_half_way) {
                  /// 中途加入，房间内存在播放中的歌曲
                  [self singSong:[NEListenTogetherPickSongEngine sharedInstance].currrentSongModel];
                  if ([NEListenTogetherPickSongEngine sharedInstance]
                          .currrentSongModel.playMusicInfo.oc_songStatus == 2) {
                    // 暂停
                    [[NEListenTogetherKit getInstance]
                        pauseEffectWithEffectId:NEListenTogetherKit.OriginalEffectId];
                  }

                  NSString *dataString =
                      @{@"userUuid" : NEListenTogetherKit.getInstance.localMember.account}
                          .yy_modelToJSONString;
                  [[NEListenTogetherKit getInstance]
                      sendCustomMessage:userUuid
                              commandId:NEListenTogetherCustomActionGetPosition
                                   data:dataString
                               callback:nil];
                } else if (self.playingAction == PlayingAction_switchSong) {
                  /// 切歌
                  [self readySongModel:model.orderId];
                } else {
                  /// 正常ready
                  [self readySongModel:model.orderId];
                }
              } else {
                /// 一开始就在
                [self readySongModel:model.orderId];
              }
            }

          } else {
            // 无播放中歌曲
          }
        } else {
          // 发生错误
        }
      }];
}

- (void)voiceroom_onPreloadStart:(NSString *)songId channel:(SongChannel)channel {
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
  NSDictionary *songDic = @{
    @"songId" : songId,
    @"channel" : [NSNumber numberWithLong:channel],
    @"downloadProcess" : [NSNumber numberWithInt:1]
  };
  [[NEListenTogetherKit getInstance] sendCustomMessage:userUuid
                                             commandId:NEListenTogetherCustomActionDownloadProcess
                                                  data:songDic.yy_modelToJSONString
                                              callback:nil];
}

- (void)readySongModel:(long)orderId {
  dispatch_async(dispatch_get_main_queue(), ^{
    [[NEListenTogetherKit getInstance]
        readyPlaySongWithOrderId:orderId
                        chorusId:nil
                             ext:nil
                        callback:^(NSInteger code, NSString *_Nullable msg, id _Nullable obj) {
                          if (code != 0) {
                            [NEListenTogetherToast
                                showToast:[NSString stringWithFormat:@"%@：%@",
                                                                     NELocalizedString(
                                                                         @"歌曲开始播放失败"),
                                                                     msg]];
                          }
                        }];
  });
}
#pragma mark-----------------------------  NEListenTogetherSongProtocol  -----------------------------
/// 列表变更
- (void)onSongListChanged {
  [self fetchPickedSongList];
}

/// 点歌
- (void)onSongOrdered:(NEListenTogetherOrderSongModel *)song {
  [self sendChatroomNotifyMessage:[NSString
                                      stringWithFormat:@"%@ %@《%@》", song.actionOperator.userName,
                                                       NELocalizedString(@"点了"), song.songName]];

  [[NEListenTogetherKit getInstance]
      queryPlayingSongInfo:^(NSInteger code, NSString *_Nullable msg,
                             NEListenTogetherPlayMusicInfo *_Nullable songModel) {
        if (code == 0) {
          NEListenTogetherSongModel *currentModel = [[NEListenTogetherSongModel alloc] init];
          currentModel.playMusicInfo = songModel;
          [NEListenTogetherPickSongEngine sharedInstance].currrentSongModel = currentModel;
          if (![[NEListenTogetherKit getInstance].localMember.account
                  isEqualToString:song.actionOperator.account]) {
            /// 不是自己点的
            if (currentModel.playMusicInfo) {
              /// 当前存在播放中的歌曲数据

              return;
            } else {
              // 如果当前无播放中歌曲
              // 需要赋值,用户点了一首歌，但是没有开始播放，那么房间内不存在播放中歌曲
              [NEListenTogetherPickSongEngine sharedInstance].currrentSongModel =
                  [[NEListenTogetherSongModel alloc] init:song];
              if ([[NEListenTogetherKit getInstance] isSongPreloaded:song.songId
                                                             channel:(int)song.oc_channel]) {
                [self readySongModel:song.orderId];
              } else {
                self.playingAction = PlayingAction_default;
                [[NEListenTogetherKit getInstance] preloadSong:song.songId
                                                       channel:(int)song.oc_channel
                                                       observe:self];
              }
            }
          }
        }
      }];
}
- (void)onSongDeleted:(NEListenTogetherOrderSongModel *)song {
  [self sendChatroomNotifyMessage:[NSString stringWithFormat:@"%@ %@《%@》",
                                                             song.actionOperator.userName,
                                                             NELocalizedString(@"删除了歌曲"),
                                                             song.songName]];
  [NEListenTogetherUILog
      infoLog:ListenTogetherUILog
         desc:[NSString stringWithFormat:@"播放中的歌曲 --- %@ 要删除的歌曲 --- %@",
                                         [NEListenTogetherPickSongEngine sharedInstance]
                                             .currrentSongModel.playMusicInfo.songId,
                                         song.songId]];
  if ([song.songId isEqualToString:[NEListenTogetherPickSongEngine sharedInstance]
                                       .currrentSongModel.playMusicInfo.songId]) {
    [NEListenTogetherUILog
        infoLog:ListenTogetherUILog
           desc:[NSString stringWithFormat:@"删除的是播放中的歌曲 --- %@", song.songId]];
    /// 删除播放中的歌
    [[NEListenTogetherKit getInstance]
        pauseEffectWithEffectId:NEListenTogetherKit.OriginalEffectId];
    [[NEListenTogetherKit getInstance] stopEffectWithEffectId:NEListenTogetherKit.OriginalEffectId];
    [NEListenTogetherPickSongEngine sharedInstance].currrentSongModel.playMusicInfo = nil;
    self.lyricActionView.hidden = YES;
    self.lyricControlView.hidden = YES;
    self.lyricControlView.isPlaying = NO;
    [self.micQueueView stop];
    if (song.nextOrderSong) {
      /// 删除的是播放中的歌曲
      if ([[NEListenTogetherKit getInstance] isSongPreloaded:song.nextOrderSong.songId
                                                     channel:(int)song.nextOrderSong.oc_channel]) {
        [self readySongModel:song.nextOrderSong.orderId];
      } else {
        [[NEListenTogetherKit getInstance] preloadSong:song.nextOrderSong.songId
                                               channel:(int)song.nextOrderSong.oc_channel
                                               observe:self];
      }
    } else {
    }
  }
}

- (void)onSongTopped:(NEListenTogetherOrderSongModel *)song {
  [self sendChatroomNotifyMessage:[NSString
                                      stringWithFormat:@"%@ %@《%@》", song.actionOperator.userName,
                                                       NELocalizedString(@"置顶"), song.songName]];
}

- (void)onNextSong:(NEListenTogetherOrderSongModel *)song {
  [NEListenTogetherUILog infoLog:ListenTogetherUILog
                            desc:[NSString stringWithFormat:@"收到切歌消息 --- %@", song.songId]];
  if (song.attachment.length > 0) {
    if ([song.attachment isEqualToString:PlayComplete]) {
      {
        NEListenTogetherOrderSongModel *nextSong = song.nextOrderSong;
        [NEListenTogetherUILog
            infoLog:ListenTogetherUILog
               desc:[NSString stringWithFormat:@"自然播放结束歌曲切歌 --- %@", nextSong.songId]];
        if (nextSong) {
          if ([[NEListenTogetherKit getInstance] isSongPreloaded:nextSong.songId
                                                         channel:(int)nextSong.oc_channel]) {
            [self readySongModel:nextSong.orderId];
          } else {
            self.playingAction = PlayingAction_switchSong;
            [[NEListenTogetherKit getInstance] preloadSong:nextSong.songId
                                                   channel:(int)nextSong.oc_channel
                                                   observe:self];
          }
        } else {
          [NEListenTogetherUILog
              infoLog:ListenTogetherUILog
                 desc:[NSString
                          stringWithFormat:@"自然播放结束切歌数据为空 --- %@", nextSong.songId]];
        }
      }
    } else {
      [self sendChatroomNotifyMessage:[NSString stringWithFormat:@"%@ %@",
                                                                 song.actionOperator.userName,
                                                                 NELocalizedString(@"已切歌")]];
      // 选定歌曲切
      NEListenTogetherOrderSongModel *nextSong =
          [NEListenTogetherOrderSongModel yy_modelWithJSON:song.attachment];
      [NEListenTogetherUILog
          infoLog:ListenTogetherUILog
             desc:[NSString stringWithFormat:@"选定歌曲切歌 --- %@", nextSong.songId]];
      if (nextSong) {
        if ([[NEListenTogetherKit getInstance] isSongPreloaded:nextSong.songId
                                                       channel:(int)nextSong.oc_channel]) {
          [self readySongModel:nextSong.orderId];
        } else {
          self.playingAction = PlayingAction_switchSong;
          [[NEListenTogetherKit getInstance] preloadSong:nextSong.songId
                                                 channel:(int)nextSong.oc_channel
                                                 observe:self];
        }
      } else {
        [NEListenTogetherUILog
            infoLog:ListenTogetherUILog
               desc:[NSString stringWithFormat:@"选定歌曲切歌数据为空 --- %@", nextSong.songId]];
      }
    }

  } else {
    [self
        sendChatroomNotifyMessage:[NSString stringWithFormat:@"%@ %@", song.actionOperator.userName,
                                                             NELocalizedString(@"已切歌")]];
    NEListenTogetherOrderSongModel *nextSong = song.nextOrderSong;
    [NEListenTogetherUILog
        infoLog:ListenTogetherUILog
           desc:[NSString stringWithFormat:@"未选定歌曲切歌 --- %@", nextSong.songId]];
    if (nextSong) {
      if ([[NEListenTogetherKit getInstance] isSongPreloaded:nextSong.songId
                                                     channel:(int)nextSong.oc_channel]) {
        [self readySongModel:nextSong.orderId];
      } else {
        self.playingAction = PlayingAction_switchSong;
        [[NEListenTogetherKit getInstance] preloadSong:nextSong.songId
                                               channel:(int)nextSong.oc_channel
                                               observe:self];
      }
    } else {
      [NEListenTogetherUILog
          infoLog:ListenTogetherUILog
             desc:[NSString stringWithFormat:@"未选定歌曲切歌数据为空 --- %@", nextSong.songId]];
    }
  }
}

- (BOOL)shouldAutorotate {
  return NO;
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
  return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
  return UIInterfaceOrientationPortrait;
}

#pragma mark---------- NESongPointProtocol -----------
- (void)onOrderSong:(NEListenTogetherOrderSongModel *)songModel error:(NSString *)errorMessage {
  if (songModel) {
    // 点歌成功
    /// 获取房间播放信息，如果存在则不处理
    [NEListenTogetherKit.getInstance
        queryPlayingSongInfo:^(NSInteger code, NSString *_Nullable msg,
                               NEListenTogetherPlayMusicInfo *_Nullable model) {
          if (code == NEListenTogetherErrorCode.success) {
            if (model) {
              // 有播放中歌曲
            } else {
              [self readySongModel:songModel.orderId];
            }
          }
        }];

  } else {
    // 点歌失败 , View 层error已处理
  }
}

- (NSInteger)onLyricTime {
  return self.time;
}

- (void)onLyricSeek:(NSInteger)seek {
  self.time = seek;
  [[NEListenTogetherKit getInstance] setPlayingPositionWithPosition:seek];
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
  NSDictionary *songDic = @{
    @"songId" : [NEListenTogetherPickSongEngine sharedInstance]
        .currrentSongModel.playMusicInfo.songId,
    @"channel" : [NSNumber numberWithLong:[NEListenTogetherPickSongEngine sharedInstance]
                                              .currrentSongModel.playMusicInfo.oc_channel],
    @"progress" : [NSNumber numberWithLong:seek]
  };
  [[NEListenTogetherKit getInstance] sendCustomMessage:userUuid
                                             commandId:NEListenTogetherCustomActionSendPosition
                                                  data:songDic.yy_modelToJSONString
                                              callback:nil];
}

- (void)singSong:(NEListenTogetherSongModel *)songModel {
  self.time = 0;
  dispatch_async(dispatch_get_main_queue(), ^{
    NSInteger duration = songModel.playMusicInfo.oc_songTime;
    if (duration <= 0) {
      duration = (int)[[NEListenTogetherKit getInstance] getEffectDuration];
    }
    self.lyricActionView.lyricDuration = duration;
    self.lyricActionView.songName = songModel.playMusicInfo.songName;
    self.lyricActionView.songSingers = songModel.playMusicInfo.singer;
  });

  NSString *lyric = [self fetchLyricContentWithSongId:songModel.playMusicInfo.songId
                                              channel:(int)songModel.playMusicInfo.oc_channel];

  // 开始合唱，展示歌词页，独唱展示打分，合唱展示歌词
  dispatch_async(dispatch_get_main_queue(), ^{
    if (lyric.length) {
      [self.lyricActionView
          setLyricContent:lyric
                lyricType:songModel.playMusicInfo.oc_channel == MIGU ? NELyricTypeKas
                                                                     : NELyricTypeYrc];
      self.lyricActionView.hidden = NO;
      self.lyricActionView.lyricSeekBtnHidden = true;
      self.lyricControlView.hidden = NO;
    } else {
      self.lyricControlView.hidden = YES;
      self.lyricActionView.hidden = YES;
    }
  });

  NSString *originPath =
      [self fetchOriginalFilePathWithSongId:songModel.playMusicInfo.songId
                                    channel:(int)songModel.playMusicInfo.oc_channel];
  NSString *accompanyPath =
      [self fetchAccompanyFilePathWithSongId:songModel.playMusicInfo.songId
                                     channel:(int)songModel.playMusicInfo.oc_channel];
  // 默认设置一把采集音量
  [self.audioManager adjustRecordingSignalVolume:[self.audioManager getRecordingSignalVolume]];

  int volume = 100;
  if (self.pickSongView) {
    volume = self.pickSongView.getVolume * 100;
  }

  if (originPath.length > 0) {
    NEListenTogetherCreateAudioEffectOption *option = [NEListenTogetherCreateAudioEffectOption new];
    option.startTimeStamp = 3000;
    option.path = originPath;
    option.playbackVolume = volume;
    option.sendVolume = 0;
    option.sendEnabled = false;
    option.progressInterval = 100;
    option.sendWithAudioType = NEListenTogetherAudioStreamTypeMain;
    NSInteger code =
        [[NEListenTogetherKit getInstance] playEffect:NEListenTogetherKit.OriginalEffectId
                                               option:option];
    if (code != 0) {
      dispatch_async(dispatch_get_main_queue(), ^{
        self.lyricControlView.hidden = YES;
        self.lyricControlView.isPlaying = NO;
        self.lyricActionView.hidden = YES;
        [self.micQueueView stop];
      });

    } else {
      dispatch_async(dispatch_get_main_queue(), ^{
        //        [self.micQueueView play];
        self.lyricControlView.hidden = NO;
        self.lyricControlView.isPlaying = YES;
        self.lyricActionView.hidden = NO;
      });
    }

  } else if (accompanyPath.length > 0) {
  } else {
    dispatch_async(dispatch_get_main_queue(), ^{
      [self.micQueueView stop];
      self.lyricControlView.hidden = YES;
      self.lyricControlView.isPlaying = NO;
      self.lyricActionView.hidden = YES;
    });
  }
}

#pragma mark------ NEListenTogetherPickSongViewProtocol

- (void)pauseSong {
  [[NEListenTogetherKit getInstance]
      requestPausePlayingSong:[NEListenTogetherPickSongEngine sharedInstance]
                                  .currrentSongModel.playMusicInfo.orderId
                     callback:^(NSInteger code, NSString *_Nullable msg, id _Nullable obj){
                         // 歌曲暂停
                         //                       [self.micQueueView stop];
                     }];
}

- (void)resumeSong {
  [[NEListenTogetherKit getInstance]
      requestResumePlayingSong:[NEListenTogetherPickSongEngine sharedInstance]
                                   .currrentSongModel.playMusicInfo.orderId
                      callback:^(NSInteger code, NSString *_Nullable msg, id _Nullable obj){
                          /// 继续播放
                          //                        [self.micQueueView play];
                      }];
}

- (void)nextSong:(NEListenTogetherOrderSongModel *_Nullable)orderSongModel {
  if (orderSongModel) {
    /// 选的某首歌曲
    [[NEListenTogetherKit getInstance]
        nextSongWithOrderId:[NEListenTogetherPickSongEngine sharedInstance]
                                .currrentSongModel.playMusicInfo.orderId
                 attachment:orderSongModel.yy_modelToJSONString
                   callback:^(NSInteger code, NSString *_Nullable msg, id _Nullable obj){

                   }];
  } else {
    /// 点击切歌按钮
    [[NEListenTogetherKit getInstance]
        nextSongWithOrderId:[NEListenTogetherPickSongEngine sharedInstance]
                                .currrentSongModel.playMusicInfo.orderId
                 attachment:@""
                   callback:^(NSInteger code, NSString *_Nullable msg, id _Nullable obj){

                   }];
  }
}

- (void)volumeChanged:(float)volume {
  [[NEListenTogetherKit getInstance] setEffectVolume:NEListenTogetherKit.OriginalEffectId
                                              volume:volume * 100];
}

#pragma mark-------- NEListenTogetherLyricControlViewDelegate
- (void)pauseSongWithView:(NEListenTogetherLyricControlView *)view {
  [self pauseSong];
}

- (void)resumeSongWithView:(NEListenTogetherLyricControlView *)view {
  [self resumeSong];
}

- (void)nextSongWithView:(NEListenTogetherLyricControlView *)view {
  [self nextSong:nil];
}
- (void)onVoiceRoomSongTokenExpired {
  [[NEListenTogetherKit getInstance]
      getSongTokenWithCallback:^(NSInteger code, NSString *_Nullable msg,
                                 NEListenTogetherDynamicToken *_Nullable token) {
        if (code == 0) {
          [[NEListenTogetherKit getInstance] renewToken:token.accessToken];
        }
      }];
}
@end
