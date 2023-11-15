// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEVoiceRoomViewController.h"
#import <NECopyrightedMedia/NECopyrightedMedia.h>
#import <NECoreKit/NSObject+YXModel.h>
#import <NEOrderSong/NEOrderSong-Swift.h>
#import <NEUIKit/NEUIBaseNavigationController.h>
#import <NEUIKit/UIView+NEUIExtension.h>
#import <SDWebImage/SDWebImage.h>
#import "NEChatRoomListViewController.h"
#import "NEUIActionSheetNavigationController.h"
#import "NEUIDeviceSizeInfo.h"
#import "NEUIMoreFunctionVC.h"
#import "NEVoiceRoomGiftEngine.h"
#import "NEVoiceRoomLocalized.h"
#import "NEVoiceRoomPickSongEngine.h"
#import "NEVoiceRoomPickSongView.h"
#import "NEVoiceRoomToast.h"
#import "NEVoiceRoomUI.h"
#import "NEVoiceRoomUILog.h"
#import "NEVoiceRoomUIManager.h"
#import "NEVoiceRoomViewController+Seat.h"
#import "NEVoiceRoomViewController+UI.h"
#import "NEVoiceRoomViewController+Utils.h"
#import "NTESGlobalMacro.h"
#import "UIColor+NEUIExtension.h"
#import "UIImage+VoiceRoom.h"
@import NEVoiceRoomBaseUIKit;

@interface NEVoiceRoomViewController () <NEVoiceRoomHeaderDelegate,
                                         NEVoiceRoomFooterFunctionAreaDelegate,
                                         NEUIMoreSettingDelegate,
                                         NEUIKeyboardToolbarDelegate,
                                         NEUIMicQueueViewDelegate,
                                         NEUIConnectListViewDelegate,
                                         NEVoiceRoomSendGiftViewtDelegate,
                                         NEVoiceRoomPickSongViewProtocol,
                                         NESongPointProtocol,
                                         NEOrderSongCopyrightedMediaListener>

@property(nonatomic, strong) NEVoiceRoomPickSongView *pickSongView;
@property(nonatomic, strong) NSArray *defaultGifts;
@end

@implementation NEVoiceRoomViewController
- (instancetype)initWithRole:(NEVoiceRoomRole)role detail:(NEVoiceRoomInfo *)detail {
  if (self = [super init]) {
    self.detail = detail;
    self.role = role;
    self.context.role = role;
    self.audioManager = [[NEAudioEffectManager alloc] init];
    self.defaultGifts = [NEVoiceRoomUIGiftModel defaultGifts];
  }
  return self;
}
- (void)dealloc {
  [NEVoiceRoomUILog infoLog:@"GetSeatInfo" desc:[NSString stringWithFormat:@"%s", __FUNCTION__]];
  [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
  if ([[NEVoiceRoomUIManager sharedInstance].delegate
          respondsToSelector:@selector(onVoiceRoomLeaveRoom)]) {
    [[NEVoiceRoomUIManager sharedInstance].delegate onVoiceRoomLeaveRoom];
  }
  [NEVoiceRoomKit.getInstance removeVoiceRoomListener:self];
  [self destroyNetworkObserver];
  [[NEVoiceRoomPickSongEngine sharedInstance] removeObserve:self];
  [NEVoiceRoomPickSongEngine sharedInstance].currrentSongModel = nil;
  [[NEOrderSong getInstance] removeOrderSongListener:self];
  [[NEVoiceRoomGiftEngine getInstance] reInitData];
}
- (BOOL)prefersNavigationBarHidden {
  return YES;
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self.navigationController setNavigationBarHidden:YES animated:YES];
}
- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  if (self.role == NEVoiceRoomRoleHost) {
    self.isBackToList = YES;
  }
  [NEVoiceRoomKit.getInstance addVoiceRoomListener:self];
  [NEOrderSong.getInstance addOrderSongListener:self];
  [self addSubviews];
  [NEVoiceRoomUILog infoLog:@"GetSeatInfo" desc:[NSString stringWithFormat:@"%s", __FUNCTION__]];
  [self joinRoom];
  [self observeKeyboard];
  [self addNetworkObserver];
  [self checkMicAuthority];
  [[NEVoiceRoomPickSongEngine sharedInstance] addObserve:self];

  if ([[NEVoiceRoomUIManager sharedInstance].delegate
          respondsToSelector:@selector(onVoiceRoomJoinRoom)]) {
    [[NEVoiceRoomUIManager sharedInstance].delegate onVoiceRoomJoinRoom];
  }

  // 禁止返回
  id traget = self.navigationController.interactivePopGestureRecognizer.delegate;
  UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:traget action:nil];
  [self.view addGestureRecognizer:pan];
  [[UIApplication sharedApplication] setIdleTimerDisabled:YES];

  [self.bgImageView sd_setImageWithURL:[NSURL URLWithString:self.detail.liveModel.cover]
                      placeholderImage:[NEVoiceRoomUI ne_voice_imageName:@"chatRoom_bgImage_icon"]];
}

- (void)closeRoom:(void (^)(void))complete {
  __weak typeof(self) weakSelf = self;
  dispatch_async(dispatch_get_main_queue(), ^{
    if (weakSelf.role == NEVoiceRoomRoleHost) {
      UIAlertController *alert =
          [UIAlertController alertControllerWithTitle:NELocalizedString(@"确认结束直播？")
                                              message:NELocalizedString(@"请确认是否结束直播")
                                       preferredStyle:UIAlertControllerStyleAlert];
      [alert addAction:[UIAlertAction actionWithTitle:NELocalizedString(@"确认")
                                                style:UIAlertActionStyleDefault
                                              handler:^(UIAlertAction *_Nonnull action) {
                                                [weakSelf closeRoomWithViewPop:YES
                                                                      callback:complete];
                                              }]];
      [alert addAction:[UIAlertAction actionWithTitle:NELocalizedString(@"取消")
                                                style:UIAlertActionStyleCancel
                                              handler:^(UIAlertAction *_Nonnull action) {
                                                complete();
                                              }]];
      [weakSelf presentViewController:alert animated:true completion:nil];
    } else {
      [weakSelf closeRoomWithViewPop:YES callback:complete];
    }
  });
}
- (void)closeRoom {
  [self closeRoomWithViewPop:YES
                    callback:^{

                    }];
}
- (void)closeRoomWithViewPop:(BOOL)changeView callback:(void (^)(void))callabck {
  if ([[NEVoiceRoomUIManager sharedInstance].delegate
          respondsToSelector:@selector(onVoiceRoomLeaveRoom)]) {
    [[NEVoiceRoomUIManager sharedInstance].delegate onVoiceRoomLeaveRoom];
  }
  __weak typeof(self) weakSelf = self;
  if (self.role == NEVoiceRoomRoleHost) {  // 主播
    [NEVoiceRoomKit.getInstance endRoom:^(NSInteger code, NSString *_Nullable msg,
                                          id _Nullable obj) {
      [NEVoiceRoomToast showToast:NELocalizedString(@"房间解散成功")];
      if (changeView) {
        dispatch_async(dispatch_get_main_queue(), ^{
          if (weakSelf.presentedViewController) {
            [weakSelf.presentedViewController dismissViewControllerAnimated:false completion:nil];
          }
          [weakSelf backToListViewController];
          if (callabck) {
            callabck();
          }
          NESocialFloatWindow.instance.floatingView.hidden = YES;
          NESocialFloatWindow.instance.target = nil;
        });
      } else {
        if (callabck) {
          callabck();
        }
        NESocialFloatWindow.instance.target = nil;
      }
    }];
  } else {  // 观众
    [NEVoiceRoomKit.getInstance leaveRoom:^(NSInteger code, NSString *_Nullable msg,
                                            id _Nullable obj) {
      if (changeView) {
        dispatch_async(dispatch_get_main_queue(), ^{
          if (weakSelf.presentedViewController) {
            [weakSelf.presentedViewController dismissViewControllerAnimated:false completion:nil];
          }
          [weakSelf.navigationController popViewControllerAnimated:YES];
          if (callabck) {
            callabck();
          }
          NESocialFloatWindow.instance.floatingView.hidden = YES;
          NESocialFloatWindow.instance.target = nil;
        });
      } else {
        if (callabck) {
          callabck();
        }
        NESocialFloatWindow.instance.target = nil;
      }
    }];
  }
}

- (void)backToListViewController {
  UIViewController *target = nil;
  for (UIViewController *controller in self.navigationController.viewControllers) {
    if ([controller isKindOfClass:[NEChatRoomListViewController class]]) {
      target = controller;
      break;
    }
  }
  if (target) {
    [self.navigationController popToViewController:target animated:YES];
  } else {
    [self.navigationController popViewControllerAnimated:YES];
  }
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
      [[NEVoiceRoomPickSongView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)
                                              detail:self.detail];
  [self.pickSongView setPlayingStatus:(self.playingStatus == PlayingStatus_playing)];
  [self.pickSongView setVolume:[NEVoiceRoomKit getInstance].getEffectVolume * 1.0 / 100.00];
  self.pickSongView.delegate = self;
  controller.view = self.pickSongView;
  NEUIActionSheetNavigationController *nav =
      [[NEUIActionSheetNavigationController alloc] initWithRootViewController:controller];
  controller.navigationController.navigationBar.hidden = true;
  nav.dismissOnTouchOutside = YES;
  [self presentViewController:nav animated:YES completion:nil];
}

#warning 优化
- (void)readySongModel:(long)orderId {
  dispatch_async(dispatch_get_main_queue(), ^{
    [[NEOrderSong getInstance]
        readyPlaySongWithOrderId:orderId
                        chorusId:nil
                             ext:nil
                        callback:^(NSInteger code, NSString *_Nullable msg, id _Nullable obj) {
                          // 1007表示歌曲不存在
                          if (code != 0 && code != 1007) {
                            [NEVoiceRoomToast
                                showToast:[NSString stringWithFormat:@"歌曲开始播放失败：%@", msg]];
                          }
                        }];
  });
}

#warning 不需要播放伴奏
- (void)singSong:(NEOrderSongSongModel *)songModel {
  if (self.role != NEVoiceRoomRoleHost) {
    // 观众不需要操作
    return;
  }
  NSString *originPath =
      [self fetchOriginalFilePathWithSongId:songModel.playMusicInfo.songId
                                    channel:(int)songModel.playMusicInfo.oc_channel];
  // 默认设置一把采集音量
  [self.audioManager adjustRecordingSignalVolume:[self.audioManager getRecordingSignalVolume]];

  int volume = 100;
  if (self.pickSongView) {
    volume = self.pickSongView.getVolume * 100;
  }

  if (originPath.length > 0) {
    /// 有待播放数据才进行停止音效
    [[NEVoiceRoomKit getInstance] stopEffectWithEffectId:NEVoiceRoomKit.OriginalEffectId];
    NEVoiceRoomCreateAudioEffectOption *option = [NEVoiceRoomCreateAudioEffectOption new];
    option.startTimeStamp = 0;
    option.path = originPath;
    option.playbackVolume = volume;
    option.sendVolume = volume;
    option.sendEnabled = true;
    option.sendWithAudioType = NEVoiceRoomAudioStreamTypeMain;
    [[NEVoiceRoomKit getInstance] playEffect:NEVoiceRoomKit.OriginalEffectId option:option];
  }
}
#pragma mark - NTESLiveRoomHeaderDelegate
- (void)headerExitAction:(void (^)(void))complete {
  [self closeRoom:complete];
}

- (void)smallWindowAction {
  NESocialFloatWindow.instance.floatingView.hidden = NO;
  [NESocialFloatWindow.instance setupUIWithIcon:self.detail.anchor.icon title:@""];
  __weak typeof(self) weakSelf = self;
  [NESocialFloatWindow.instance
      addViewControllerTarget:self
                     roomUuid:self.detail.liveModel.roomUuid
                  closeAction:^(void (^callback)(void)) {
                    NESocialFloatWindow.instance.floatingView.hidden = YES;
                    [weakSelf closeRoomWithViewPop:!NESocialFloatWindow.instance.hasFloatWindow
                                          callback:callback];
                  }];
  if (self.role == NEVoiceRoomRoleHost) {  // 主播
    if (self.isBackToList) {
      [self backToListViewController];
      self.isBackToList = NO;
    } else {
      [self.navigationController popViewControllerAnimated:YES];
    }

  } else {  // 观众
    [self.navigationController popViewControllerAnimated:YES];
  }
}

#pragma mark - NETSFunctionAreaDelegate
// 麦克静音事件
- (void)footerDidReceiveMicMuteAction:(BOOL)mute {
  [NEVoiceRoomUILog infoLog:@"GetSeatInfo" desc:[NSString stringWithFormat:@"%s", __FUNCTION__]];
  [self handleMuteOperation:mute];
}

- (void)footerDidReceiveGiftClickAciton {
  // 发送礼物
  self.giftViewController = [NEVoiceRoomSendGiftViewController showWithTarget:self
                                                               viewController:self];
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
  NEUIMoreFunctionVC *moreVC = [[NEUIMoreFunctionVC alloc] initWithContext:self.context];
  moreVC.delegate = self;
  NEUIActionSheetNavigationController *nav =
      [[NEUIActionSheetNavigationController alloc] initWithRootViewController:moreVC];
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
#warning 耳返操作
}
- (void)didSetMicOn:(BOOL)micOn {
  [NEVoiceRoomUILog infoLog:@"GetSeatInfo" desc:[NSString stringWithFormat:@"%s", __FUNCTION__]];
  if (micOn) {
    [self unmuteAudio];
  } else {
    [self muteAudio];
  }
}
- (void)endLive {
  [self closeRoom:^{

  }];
}

#pragma mark------------------------ NEVoiceRoomSendGiftViewtDelegate ------------------------

- (void)didSendGift:(NEVoiceRoomUIGiftModel *)gift
          giftCount:(int)giftCount
          userUuids:(NSArray *)userUuids {
  if (![self checkNetwork]) {
    return;
  }

  [self dismissViewControllerAnimated:true
                           completion:^{
                             [[NEVoiceRoomKit getInstance]
                                 sendBatchGift:gift.giftId
                                     giftCount:giftCount
                                     userUuids:userUuids
                                      callback:^(NSInteger code, NSString *_Nullable msg,
                                                 id _Nullable obj) {
                                        if (code != 0) {
                                          [NEVoiceRoomToast
                                              showToast:[NSString
                                                            stringWithFormat:@"%@ %zd %@",
                                                                             NELocalizedString(
                                                                                 @"发送礼物失败"),
                                                                             code, msg]];
                                        }
                                      }];
                           }];
}

- (BOOL)checkNetwork {
  NEVoiceRoomNetworkStatus status = [self.reachability currentReachabilityStatus];
  if (status == NotReachable) {
    [NEVoiceRoomToast showToast:NELocalizedString(@"网络异常，请稍后重试")];
    return false;
  }
  return true;
}

#pragma mark------------------------ NEUIKeyboardToolbarDelegate ------------------------
- (void)didToolBarSendText:(NSString *)text {
  NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
  text = [text stringByTrimmingCharactersInSet:set];
  if (text.length <= 0) {
    [NEVoiceRoomToast showToast:NELocalizedString(@"发送内容为空")];
    return;
  }
  __weak typeof(self) weakSelf = self;
  [NEVoiceRoomKit.getInstance
      sendTextMessage:text
             callback:^(NSInteger code, NSString *_Nullable msg, id _Nullable obj) {
               dispatch_async(dispatch_get_main_queue(), ^{
                 NESocialChatroomTextMessage *model = [[NESocialChatroomTextMessage alloc] init];
                 model.sender = NEVoiceRoomUIManager.sharedInstance.nickname;
                 model.text = text;
                 if (weakSelf.role == NEVoiceRoomRoleHost) {
                   model.iconSize = CGSizeMake(32, 16);
                   model.icon = [NEVRBaseBundle loadImage:[NEVRBaseBundle localized:@"Owner_Icon"
                                                                              value:nil]];
                 } else {
                   model.icon = nil;
                 }
                 [weakSelf.chatView addMessages:@[ model ]];
               });
             }];
}
#pragma mark------------------------ NEVoiceRoomListener ------------------------

- (void)onAudioOutputDeviceChanged:(enum NEVoiceRoomAudioOutputDevice)device {
  if (device == NEVoiceRoomAudioOutputDeviceWiredHeadset ||
      device == NEVoiceRoomAudioOutputDeviceBluetoothHeadset) {
    // 默认不打开耳返
    //    self.context.rtcConfig.earbackOn = true;
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

- (void)onMemberJoinRoom:(NSArray<NEVoiceRoomMember *> *)members {
  NSMutableArray *messages = @[].mutableCopy;
  for (NEVoiceRoomMember *member in members) {
    NESocialChatroomNotiMessage *message = [NESocialChatroomNotiMessage new];
    message.notification =
        [NSString stringWithFormat:@"%@ %@", member.name, NELocalizedString(@"加入房间")];
    [messages addObject:message];
  }
  dispatch_async(dispatch_get_main_queue(), ^{
    self.roomHeaderView.onlinePeople = NEVoiceRoomKit.getInstance.allMemberList.count;
    [self.chatView addMessages:messages];
  });
}
- (void)onMemberLeaveRoom:(NSArray<NEVoiceRoomMember *> *)members {
  NSMutableArray *messages = @[].mutableCopy;
  for (NEVoiceRoomMember *member in members) {
    NESocialChatroomNotiMessage *message = [NESocialChatroomNotiMessage new];
    message.notification =
        [NSString stringWithFormat:@"%@ %@", member.name, NELocalizedString(@"离开房间")];
    [messages addObject:message];
  }
  dispatch_async(dispatch_get_main_queue(), ^{
    self.roomHeaderView.onlinePeople = NEVoiceRoomKit.getInstance.allMemberList.count;
    [self.chatView addMessages:messages];
  });
}

#warning 在业务组件里包装成重连的接口
- (void)onMemberJoinChatroom:(NSArray<NEVoiceRoomMember *> *)members {
  bool isSelf = false;
  for (NEVoiceRoomMember *member in members) {
    if ([member.account isEqualToString:NEVoiceRoomKit.getInstance.localMember.account]) {
      isSelf = true;
#warning 直接用NERoom.localMember.isInChatRoom
      self.isInChatRoom = YES;
      break;
    }
  }
#warning 重连的才需要
  if (isSelf) {
    [NEVoiceRoomUILog infoLog:@"GetSeatInfo" desc:[NSString stringWithFormat:@"%s", __FUNCTION__]];
    [self getSeatInfoWhenRejoinChatRoom];
  }
}
- (void)onReceiveTextMessage:(NEVoiceRoomChatTextMessage *)message {
  dispatch_async(dispatch_get_main_queue(), ^{
    NESocialChatroomTextMessage *model = [[NESocialChatroomTextMessage alloc] init];
    model.sender = message.fromNick;
    model.text = message.text;
    if ([message.fromUserUuid isEqualToString:self.detail.liveModel.userUuid]) {
      model.iconSize = CGSizeMake(32, 16);
      model.icon = [NEVRBaseBundle loadImage:[NEVRBaseBundle localized:@"Owner_Icon" value:nil]];
    } else {
      model.icon = nil;
    }
    [self.chatView addMessages:@[ model ]];
  });
}

- (void)onReceiveBatchGiftWithGiftModel:(NEVoiceRoomBatchGiftModel *)giftModel {
  // 收到批量礼物回调
  //  展示礼物动画
  NSString *giftDisplay;
  for (NEVoiceRoomUIGiftModel *model in self.defaultGifts) {
    if (model.giftId == giftModel.giftId) {
      giftDisplay = model.display;
      break;
    }
  }
  NSMutableArray *messages = [NSMutableArray array];
  for (NEVoiceRoomBatchSeatUserRewardee *userRewardee in giftModel.rewardeeUsers) {
    NESocialChatroomRewardMessage *message = [[NESocialChatroomRewardMessage alloc] init];
    message.giftImage = [NEVoiceRoomUI
        ne_voice_imageName:[NEVoiceRoomUIGiftModel getRewardWithGiftId:giftModel.giftId].icon];
    message.giftImageSize = CGSizeMake(20, 20);
    message.sender = giftModel.rewarderUserName;
    message.receiver = userRewardee.userName;
    message.rewardText = NELocalizedString(@"送给");
    message.rewardColor = [UIColor colorWithWhite:1 alpha:0.6];
    message.giftColor = [UIColor ne_colorWithHex:0xFFD966 alpha:1];
    message.giftCount = giftModel.giftCount;
    message.giftName = giftDisplay;
    [messages addObject:message];
  }

  [self.chatView addMessages:messages];
  //  message.giftTo = giftModel.rewardeeUserName;

  if (self.role != NEVoiceRoomRoleHost) {
    // 房主不展示礼物
    NSString *giftName = [NSString stringWithFormat:@"anim_gift_0%zd", giftModel.giftId];
    [self playGiftWithName:giftName];
  }

  [self.micQueueView updateGiftDatas:[giftModel.seatUserReward mutableCopy]];
}
- (void)onRoomEnded:(enum NEVoiceRoomEndReason)reason {
  dispatch_async(dispatch_get_main_queue(), ^{
    if (reason != NEVoiceRoomEndReasonLeaveBySelf) {
      [NEVoiceRoomToast showToast:NELocalizedString(@"房间关闭")];
      if (self.presentedViewController) {
        [self.presentedViewController dismissViewControllerAnimated:false completion:nil];
      }
      [self.navigationController popViewControllerAnimated:YES];
    }
  });
  NESocialFloatWindow.instance.floatingView.hidden = YES;
  NESocialFloatWindow.instance.target = nil;
}

- (void)onRtcLocalAudioVolumeIndicationWithVolume:(NSInteger)volume enableVad:(BOOL)enableVad {
  [self.micQueueView updateWithLocalVolume:volume];
}

- (void)onRtcRemoteAudioVolumeIndicationWithVolumes:
            (NSArray<NEVoiceRoomMemberVolumeInfo *> *)volumes
                                        totalVolume:(NSInteger)totalVolume {
  [self.micQueueView updateWithRemoteVolumeInfos:volumes];
}
#pragma mark - gift animation

/// 播放礼物动画
- (void)playGiftWithName:(NSString *)name {
  if (UIApplication.sharedApplication.applicationState == UIApplicationStateBackground) {
    // 在后台就不添加礼物动画了
    return;
  }
  [self.view addSubview:self.giftAnimation];
  [self.view bringSubviewToFront:self.giftAnimation];
  [self.giftAnimation addGift:name];
}

- (NEVoiceRoomAnimationView *)giftAnimation {
  if (!_giftAnimation) {
    _giftAnimation = [[NEVoiceRoomAnimationView alloc] init];
  }
  return _giftAnimation;
}

#pragma mark------------------------ NEUIMicQueueViewDelegate ------------------------
- (void)micQueueConnectBtnPressedWithMicInfo:(NEVoiceRoomSeatItem *)micInfo {
  switch (self.role) {
    case NEVoiceRoomRoleHost: {  // 主播操作麦位
      [self anchorOperationSeatItem:micInfo];
    } break;
    default: {  // 观众操作麦位
      [self audienceOperationSeatItem:micInfo];
    } break;
  }
}
#pragma mark------------------------ NEUIConnectListViewDelegate ------------------------
- (void)connectListView:(NEUIConnectListView *)connectListView
    onAcceptWithSeatItem:(NEVoiceRoomSeatItem *)seatItem {
  __weak typeof(self) weakSelf = self;
  [NEVoiceRoomKit.getInstance
      approveSeatRequestWithAccount:seatItem.user
                           callback:^(NSInteger code, NSString *_Nullable msg, id _Nullable obj) {
                             if (code == 0) {
                               dispatch_async(dispatch_get_main_queue(), ^{
                                 [weakSelf.connectorArray removeObject:seatItem];
                                 [weakSelf.connectListView
                                     refreshWithDataArray:weakSelf.connectorArray];
                               });
                             }
                           }];
}
- (void)connectListView:(NEUIConnectListView *)connectListView
    onRejectWithSeatItem:(NEVoiceRoomSeatItem *)seatItem {
  if (!self.isInChatRoom) {
    return;
  }
  __weak typeof(self) weakSelf = self;
  [NEVoiceRoomKit.getInstance
      rejectSeatRequestWithAccount:seatItem.user
                          callback:^(NSInteger code, NSString *_Nullable msg, id _Nullable obj) {
                            if (code == 0) {
                              dispatch_async(dispatch_get_main_queue(), ^{
                                [weakSelf.connectorArray removeObject:seatItem];
                                [weakSelf.connectListView
                                    refreshWithDataArray:weakSelf.connectorArray];
                              });
                            }
                          }];
}
#pragma mark------------------------ Getter  ------------------------
- (NEUIChatroomContext *)context {
  if (!_context) {
    _context = [NEUIChatroomContext new];
  }
  return _context;
}

- (UIImageView *)bgImageView {
  if (!_bgImageView) {
    _bgImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    _bgImageView.contentMode = UIViewContentModeScaleAspectFill;
    _bgImageView.image = [NEVoiceRoomUI ne_voice_imageName:@"chatRoom_bgImage_icon"];
  }
  return _bgImageView;
}
- (NEVoiceRoomHeaderView *)roomHeaderView {
  if (!_roomHeaderView) {
    _roomHeaderView = [[NEVoiceRoomHeaderView alloc] init];
    _roomHeaderView.delegate = self;
  }
  return _roomHeaderView;
}

- (NEVoiceRoomFooterView *)roomFooterView {
  if (!_roomFooterView) {
    _roomFooterView = [[NEVoiceRoomFooterView alloc] initWithContext:self.context];
    _roomFooterView.role = self.role;
    _roomFooterView.delegate = self;
  }
  return _roomFooterView;
}
- (NEUIKeyboardToolbarView *)keyboardView {
  if (!_keyboardView) {
    _keyboardView = [[NEUIKeyboardToolbarView alloc]
        initWithFrame:CGRectMake(0, UIScreen.mainScreen.bounds.size.height,
                                 UIScreen.mainScreen.bounds.size.width, 50)];
    _keyboardView.backgroundColor = UIColor.whiteColor;
    _keyboardView.cusDelegate = self;
  }
  return _keyboardView;
}
- (NESocialChatroomView *)chatView {
  if (!_chatView) {
    _chatView = [[NESocialChatroomView alloc] initWithFrame:CGRectMake(0, 0, 100, 200)];
  }
  return _chatView;
}
- (NEUIMicQueueView *)micQueueView {
  if (!_micQueueView) {
    _micQueueView = [[NEUIMicQueueView alloc] initWithFrame:CGRectZero];
    _micQueueView.delegate = self;
    _micQueueView.datas = [self simulatedSeatData];
  }
  return _micQueueView;
}
- (NEVoiceRoomReachability *)reachability {
  if (!_reachability) {
    _reachability = [NEVoiceRoomReachability reachabilityForInternetConnection];
  }
  return _reachability;
}
- (NEVoiceRoomUIAlertView *)alertView {
  if (!_alertView) {
    _alertView = [[NEVoiceRoomUIAlertView alloc] initWithActions:[self setupAlertActions]];
  }
  return _alertView;
}
- (NEUIConnectListView *)connectListView {
  if (!_connectListView) {
    _connectListView =
        [[NEUIConnectListView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 0)];
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

#pragma mark-----------------------------  NEVoiceRoomSongProtocol  -----------------------------

/// 点歌
- (void)onSongOrdered:(NEOrderSongProtocolResult *)song {
  [self sendChatroomNotifyMessage:[NSString
                                      stringWithFormat:@"%@ %@《%@》", song.operatorUser.userName,
                                                       NELocalizedString(@"点了"),
                                                       song.orderSongResultDto.orderSong.songName]];
}
- (void)onSongDeleted:(NEOrderSongProtocolResult *)song {
  [self sendChatroomNotifyMessage:[NSString
                                      stringWithFormat:@"%@ %@《%@》", song.operatorUser.userName,
                                                       NELocalizedString(@"删除了歌曲"),
                                                       song.orderSongResultDto.orderSong.songName]];

  if (self.role != NEVoiceRoomRoleHost) {
    // 非房主 不需要操作
    return;
  }
  if ([song.orderSongResultDto.orderSong.songId
          isEqualToString:[NEVoiceRoomPickSongEngine sharedInstance]
                              .currrentSongModel.playMusicInfo.songId]) {
    if (song.nextOrderSong) {
      /// 删除的是播放中的歌曲
      if ([[NEOrderSong getInstance]
              isSongPreloaded:song.nextOrderSong.orderSong.songId
                      channel:(int)song.nextOrderSong.orderSong.oc_channel]) {
        if ([song.nextOrderSong.orderSongUser.userUuid
                isEqualToString:[NEVoiceRoomKit getInstance].localMember.account]) {
          [self readySongModel:song.nextOrderSong.orderSong.orderId];
        }
      } else {
        [[NEOrderSong getInstance] preloadSong:song.nextOrderSong.orderSong.songId
                                       channel:(int)song.nextOrderSong.orderSong.oc_channel
                                       observe:self];
      }
    } else {
      if ([song.orderSongResultDto.orderSong.songId
              isEqualToString:[NEVoiceRoomPickSongEngine sharedInstance]
                                  .currrentSongModel.playMusicInfo.songId] &&
          !song.nextOrderSong) {
        /// 删除播放中的歌，并且没有下一首歌。停止播放
        [[NEVoiceRoomKit getInstance] stopEffectWithEffectId:NEVoiceRoomKit.OriginalEffectId];
        [NEVoiceRoomPickSongEngine sharedInstance].currrentSongModel = nil;
        self.roomHeaderView.musicTitle = nil;
      }
    }
  }
}

- (void)onNextSong:(NEOrderSongProtocolResult *)song {
#warning 代码优化
  if (song.attachment.length > 0) {
    if ([song.attachment isEqualToString:PlayComplete]) {
      if (self.role != NEVoiceRoomRoleHost) {
        // 非房主 不需要操作
        return;
      }
      // 自然播放完成
      NEOrderSongResponse *nextSong = song.nextOrderSong;
      if (nextSong) {
        if ([[NEOrderSong getInstance] isSongPreloaded:nextSong.orderSong.songId
                                               channel:(int)nextSong.orderSong.oc_channel]) {
          if ([nextSong.orderSongUser.userUuid
                  isEqualToString:[NEVoiceRoomKit getInstance].localMember.account]) {
            [self readySongModel:nextSong.orderSong.orderId];
          }
        } else {
          //        self.playingAction = PlayingAction_switchSong;
          [[NEOrderSong getInstance] preloadSong:nextSong.orderSong.songId
                                         channel:(int)nextSong.orderSong.oc_channel
                                         observe:self];
        }
      }
    } else {
      [self
          sendChatroomNotifyMessage:[NSString stringWithFormat:@"%@ %@", song.operatorUser.userName,
                                                               NELocalizedString(@"已切歌")]];
      if (self.role != NEVoiceRoomRoleHost) {
        // 非房主 不需要操作
        return;
      }
      // 选定歌曲切
      NEOrderSongResponseOrderSongModel *nextSong =
          [NEOrderSongResponseOrderSongModel yx_modelWithJSON:song.attachment];
      if (nextSong) {
        if ([[NEOrderSong getInstance] isSongPreloaded:nextSong.songId
                                               channel:(int)nextSong.oc_channel]) {
          [self readySongModel:nextSong.orderId];
        } else {
          [[NEOrderSong getInstance] preloadSong:nextSong.songId
                                         channel:(int)nextSong.oc_channel
                                         observe:self];
        }
      }
    }
  } else {
    [self sendChatroomNotifyMessage:[NSString stringWithFormat:@"%@ %@", song.operatorUser.userName,
                                                               NELocalizedString(@"已切歌")]];
    if (self.role != NEVoiceRoomRoleHost) {
      // 非房主 不需要操作
      return;
    }
    NEOrderSongResponse *nextSong = song.nextOrderSong;
    if (nextSong) {
      if ([[NEOrderSong getInstance] isSongPreloaded:nextSong.orderSong.songId
                                             channel:(int)nextSong.orderSong.oc_channel]) {
        [self readySongModel:nextSong.orderSong.orderId];
      } else {
        //        self.playingAction = PlayingAction_switchSong;
        [[NEOrderSong getInstance] preloadSong:nextSong.orderSong.songId
                                       channel:(int)nextSong.orderSong.oc_channel
                                       observe:self];
      }
    }
  }
}

#pragma mark---------- NESongPointProtocol -----------
- (void)onOrderSong:(NEOrderSongResponse *)songModel error:(NSString *)errorMessage {
  if (songModel) {
    // 点歌成功
    /// 获取房间播放信息，如果存在则不处理
    __weak typeof(self) weakSelf = self;
    [[NEOrderSong getInstance] queryPlayingSongInfo:^(NSInteger code, NSString *_Nullable msg,
                                                      NEOrderSongPlayMusicInfo *_Nullable model) {
      if (code == NEVoiceRoomErrorCode.success) {
        if (model) {
          // 有播放中歌曲
        } else {
          // 无播放中歌曲
          if ([songModel.orderSongUser.userUuid
                  isEqualToString:[NEVoiceRoomKit getInstance].localMember.account]) {
            [weakSelf readySongModel:songModel.orderSong.orderId];
          }
        }
      }
    }];

  } else {
    // 点歌失败 , View 层error已处理
  }
}

- (void)onAudioEffectFinished {
  self.roomHeaderView.musicTitle = @"";
  if ([self isAnchor]) {
    [[NEOrderSong getInstance]
        nextSongWithOrderId:[NEVoiceRoomPickSongEngine sharedInstance]
                                .currrentSongModel.playMusicInfo.orderId
                 attachment:PlayComplete
                   callback:^(NSInteger code, NSString *_Nullable msg, id _Nullable obj){

                   }];
  }
}

#pragma mark------------------------ CMD处理 ------------------------
- (void)onReceiveChorusMessage:(enum NEOrderSongChorusActionType)actionType
                     songModel:(NEOrderSongSongModel *)songModel {
  if (actionType == NEOrderSongChorusActionTypeStartSong) {
    [self sendChatroomNotifyMessage:[NSString stringWithFormat:@"%@《%@》",
                                                               NELocalizedString(@"正在播放歌曲"),
                                                               songModel.playMusicInfo.songName]];
    /// 开始唱歌
    self.playingStatus = PlayingStatus_playing;
    [self singSong:songModel];
    [NEVoiceRoomPickSongEngine sharedInstance].currrentSongModel = songModel;
    self.roomHeaderView.musicTitle =
        [NSString stringWithFormat:@"%@-%@", songModel.playMusicInfo.songName,
                                   songModel.playMusicInfo.singer];
    if (self.pickSongView) {
      // 刷新数据
      [self.pickSongView refreshPickedSongView];
    }

  } else if (actionType == NEOrderSongChorusActionTypePauseSong) {
    // 暂停
    self.playingStatus = PlayingStatus_pause;
    [[NEVoiceRoomKit getInstance] pauseEffectWithEffectId:NEVoiceRoomKit.OriginalEffectId];
  } else if (actionType == NEOrderSongChorusActionTypeResumeSong) {
    /// 本地有缓存数据，并且orderId 相同，说明是恢复
    [[NEVoiceRoomKit getInstance] resumeEffectWithEffectId:NEVoiceRoomKit.OriginalEffectId];
    self.playingStatus = PlayingStatus_playing;
  }
  [self refreshUI];
}

- (void)refreshUI {
  if (self.pickSongView) {
    [self.pickSongView setPlayingStatus:(self.playingStatus == PlayingStatus_playing)];
  }
}

- (void)onPreloadComplete:(NSString *)songId channel:(SongChannel)channel error:(NSError *)error {
  NEOrderSongSongModel *currrentSongModel =
      [NEVoiceRoomPickSongEngine sharedInstance].currrentSongModel;
  if ([songId isEqualToString:currrentSongModel.playMusicInfo.songId] &&
      (channel == currrentSongModel.playMusicInfo.oc_channel) &&
      [currrentSongModel.actionOperator.account
          isEqualToString:[NEVoiceRoomKit getInstance].localMember.account]) {
    [self readySongModel:currrentSongModel.playMusicInfo.orderId];
  }
}

#pragma mark------ NEVoiceRoomPickSongViewProtocol

- (void)pauseSong {
  [[NEOrderSong getInstance]
      requestPausePlayingSong:[NEVoiceRoomPickSongEngine sharedInstance]
                                  .currrentSongModel.playMusicInfo.orderId
                     callback:^(NSInteger code, NSString *_Nullable msg, id _Nullable obj){
                         // 歌曲暂停
                     }];
}

- (void)resumeSong {
  [[NEOrderSong getInstance]
      requestResumePlayingSong:[NEVoiceRoomPickSongEngine sharedInstance]
                                   .currrentSongModel.playMusicInfo.orderId
                      callback:^(NSInteger code, NSString *_Nullable msg, id _Nullable obj){
                          /// 继续播放
                      }];
}

- (void)nextSong:(NEOrderSongResponseOrderSongModel *_Nullable)orderSongModel {
  if (orderSongModel) {
    /// 选的某首歌曲
    [[NEOrderSong getInstance]
        nextSongWithOrderId:[NEVoiceRoomPickSongEngine sharedInstance]
                                .currrentSongModel.playMusicInfo.orderId
                 attachment:orderSongModel.yx_modelToJSONString
                   callback:^(NSInteger code, NSString *_Nullable msg, id _Nullable obj){

                   }];
  } else {
    /// 点击切歌按钮
    [[NEOrderSong getInstance]
        nextSongWithOrderId:[NEVoiceRoomPickSongEngine sharedInstance]
                                .currrentSongModel.playMusicInfo.orderId
                 attachment:@""
                   callback:^(NSInteger code, NSString *_Nullable msg, id _Nullable obj){

                   }];
  }
}

- (void)volumeChanged:(float)volume {
  [[NEVoiceRoomKit getInstance] setEffectVolume:NEVoiceRoomKit.OriginalEffectId
                                         volume:volume * 100];
}

- (void)onVoiceRoomSongTokenExpired {
  [[NEOrderSong getInstance] getSongTokenWithCallback:^(NSInteger code, NSString *_Nullable msg,
                                                        NEOrderSongDynamicToken *_Nullable token) {
    if (code == 0) {
      [[NEOrderSong getInstance] renewToken:token.accessToken];
    }
  }];
}
@end
