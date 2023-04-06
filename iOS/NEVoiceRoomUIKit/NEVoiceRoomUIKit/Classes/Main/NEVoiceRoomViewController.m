// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEVoiceRoomViewController.h"
#import <NECopyrightedMedia/NECopyrightedMedia.h>
#import <NEOrderSong/NEOrderSong-Swift.h>
#import <NEUIKit/NEUIBaseNavigationController.h>
#import <NEUIKit/UIView+NEUIExtension.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import <YYModel/YYModel.h>
#import "NEChatRoomListViewController.h"
#import "NEUIActionSheetNavigationController.h"
#import "NEUIDeviceSizeInfo.h"
#import "NEUIMoreFunctionVC.h"
#import "NEVoiceRoomChatView.h"
#import "NEVoiceRoomFloatWindowSingleton.h"
#import "NEVoiceRoomGiftEngine.h"
#import "NEVoiceRoomPickSongEngine.h"
#import "NEVoiceRoomPickSongView.h"
#import "NEVoiceRoomStringMacro.h"
#import "NEVoiceRoomToast.h"
#import "NEVoiceRoomUI.h"
#import "NEVoiceRoomUIManager.h"
#import "NEVoiceRoomViewController+Seat.h"
#import "NEVoiceRoomViewController+UI.h"
#import "NEVoiceRoomViewController+Utils.h"
#import "NSBundle+NELocalized.h"
#import "NTESGlobalMacro.h"
#import "UIImage+VoiceRoom.h"

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
  if ([[NEVoiceRoomUIManager sharedInstance].delegate
          respondsToSelector:@selector(onVoiceRoomLeaveRoom)]) {
    [[NEVoiceRoomUIManager sharedInstance].delegate onVoiceRoomLeaveRoom];
  }
  [NEVoiceRoomKit.getInstance removeVoiceRoomListener:self];
  [self destroyNetworkObserver];
  [[NEVoiceRoomPickSongEngine sharedInstance] removeObserve:self];
  [NEVoiceRoomPickSongEngine sharedInstance].currrentSongModel = nil;
  [[NEOrderSong getInstance] removeOrderSongListener:self];
  self.lastSelfItem = nil;
  [[NEVoiceRoomGiftEngine getInstance] reInitData];
}
- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  self.ne_UINavigationItem.navigationBarHidden = YES;
  [NEVoiceRoomKit.getInstance addVoiceRoomListener:self];
  [NEOrderSong.getInstance addOrderSongListener:self];
  [self addSubviews];
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
}

- (void)closeRoom {
  [self closeRoomWithViewPop:YES callback:nil];
}
- (void)closeRoomWithViewPop:(BOOL)changeView callback:(void (^)(void))callabck {
  if (self.role == NEVoiceRoomRoleHost) {  // 主播
    [NEVoiceRoomKit.getInstance
        endRoom:^(NSInteger code, NSString *_Nullable msg, id _Nullable obj) {
          [NEVoiceRoomToast showToast:NELocalizedString(@"房间解散成功")];
          if (changeView) {
            dispatch_async(dispatch_get_main_queue(), ^{
              if (self.presentedViewController) {
                [self.presentedViewController dismissViewControllerAnimated:false completion:nil];
              }
              [self backToListViewController];
              if (callabck) {
                callabck();
              }
              [[NEVoiceRoomFloatWindowSingleton Ins] setHideWindow:YES];
              [[NEVoiceRoomFloatWindowSingleton Ins] addViewControllerTarget:nil];
            });
          } else {
            if (callabck) {
              callabck();
            }
            [[NEVoiceRoomFloatWindowSingleton Ins] addViewControllerTarget:nil];
          }
        }];
  } else {  // 观众
    [NEVoiceRoomKit.getInstance
        leaveRoom:^(NSInteger code, NSString *_Nullable msg, id _Nullable obj) {
          if (changeView) {
            dispatch_async(dispatch_get_main_queue(), ^{
              if (self.presentedViewController) {
                [self.presentedViewController dismissViewControllerAnimated:false completion:nil];
              }
              [self.navigationController popViewControllerAnimated:YES];
              if (callabck) {
                callabck();
              }
              [[NEVoiceRoomFloatWindowSingleton Ins] setHideWindow:YES];
              [[NEVoiceRoomFloatWindowSingleton Ins] addViewControllerTarget:nil];
            });
          } else {
            if (callabck) {
              callabck();
            }
            [[NEVoiceRoomFloatWindowSingleton Ins] addViewControllerTarget:nil];
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

  @weakify(self) @weakify(nav) self.pickSongView.applyOnseat = ^{
    @strongify(nav) @strongify(self) UIAlertController *alert =
        [UIAlertController alertControllerWithTitle:@"仅麦上成员可点歌，先申请上麦"
                                            message:nil
                                     preferredStyle:UIAlertControllerStyleAlert];
    @weakify(self)
        [alert addAction:[UIAlertAction actionWithTitle:@"取消"
                                                  style:UIAlertActionStyleCancel
                                                handler:^(UIAlertAction *_Nonnull action) {
                                                  @strongify(self)[self.pickSongView cancelApply];
                                                }]];
    [alert
        addAction:[UIAlertAction
                      actionWithTitle:@"申请上麦"
                                style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction *_Nonnull action) {
                                if (!
                                    [NEVoiceRoomAuthorityHelper checkMicAuthority]) {  // 麦克风权限
                                  [NEVoiceRoomToast showToast:@"请先开启麦克风权限"];
                                  return;
                                }
                                // 申请上麦
                                [NEVoiceRoomKit.getInstance
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

- (void)readySongModel:(long)orderId {
  dispatch_async(dispatch_get_main_queue(), ^{
    [[NEOrderSong getInstance]
        readyPlaySongWithOrderId:orderId
                        chorusId:nil
                             ext:nil
                        callback:^(NSInteger code, NSString *_Nullable msg, id _Nullable obj) {
                          if (code != 0) {
                            [NEVoiceRoomToast
                                showToast:[NSString stringWithFormat:@"歌曲开始播放失败：%@", msg]];
                          }
                        }];
  });
}

- (void)singSong:(NEOrderSongSongModel *)songModel {
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
    NEVoiceRoomCreateAudioEffectOption *option = [NEVoiceRoomCreateAudioEffectOption new];
    option.startTimeStamp = 3000;
    option.path = originPath;
    option.playbackVolume = volume;
    option.sendVolume = volume;
    option.sendEnabled = true;
    option.sendWithAudioType = NEVoiceRoomAudioStreamTypeMain;
    [[NEVoiceRoomKit getInstance] playEffect:NEVoiceRoomKit.OriginalEffectId option:option];
  } else if (accompanyPath.length > 0) {
  } else {
    /// 无有效数据
  }
}
#pragma mark - NTESLiveRoomHeaderDelegate
- (void)headerExitAction {
  [self closeRoom];
}

- (void)smallWindowAction {
  [[NEVoiceRoomFloatWindowSingleton Ins] addViewControllerTarget:self];
  [[NEVoiceRoomFloatWindowSingleton Ins] setHideWindow:NO];
  [[NEVoiceRoomFloatWindowSingleton Ins] setNetImage:self.detail.anchor.icon title:@""];
  {
    if (self.role == NEVoiceRoomRoleHost) {  // 主播
      [self backToListViewController];
    } else {  // 观众
      [self.navigationController popViewControllerAnimated:YES];
    }
  }
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
    [NEVoiceRoomToast showToast:NELocalizedString(@"网络连接断开，请稍后重试")];
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
  [NEVoiceRoomKit.getInstance
      sendTextMessage:text
             callback:^(NSInteger code, NSString *_Nullable msg, id _Nullable obj) {
               dispatch_async(dispatch_get_main_queue(), ^{
                 NEVoiceRoomChatViewMessage *model = [NEVoiceRoomChatViewMessage new];
                 model.type = NEVoiceRoomChatViewMessageTypeNormal;
                 model.text = text;
                 model.sender = NEVoiceRoomUIManager.sharedInstance.nickname;
                 model.isAnchor = self.role == NEVoiceRoomRoleHost;
                 [self.chatView addMessages:@[ model ]];
               });
             }];
}
#pragma mark------------------------ NEVoiceRoomListener ------------------------

- (void)onAudioOutputDeviceChanged:(enum NEVoiceRoomAudioOutputDevice)device {
  if (device == NEVoiceRoomAudioOutputDeviceWiredHeadset ||
      device == NEVoiceRoomAudioOutputDeviceBluetoothHeadset) {
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

- (void)onMemberJoinRoom:(NSArray<NEVoiceRoomMember *> *)members {
  NSMutableArray *messages = @[].mutableCopy;
  for (NEVoiceRoomMember *member in members) {
    NEVoiceRoomChatViewMessage *message = [NEVoiceRoomChatViewMessage new];
    message.type = NEVoiceRoomChatViewMessageTypeNotication;
    message.notication =
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
    NEVoiceRoomChatViewMessage *message = [NEVoiceRoomChatViewMessage new];
    message.type = NEVoiceRoomChatViewMessageTypeNotication;
    message.notication =
        [NSString stringWithFormat:@"%@ %@", member.name, NELocalizedString(@"离开房间")];
    [messages addObject:message];
#warning 请求麦位信息
  }
  dispatch_async(dispatch_get_main_queue(), ^{
    self.roomHeaderView.onlinePeople = NEVoiceRoomKit.getInstance.allMemberList.count;
    [self.chatView addMessages:messages];
  });
}
- (void)onMemberJoinChatroom:(NSArray<NEVoiceRoomMember *> *)members {
  bool isSelf = false;
  for (NEVoiceRoomMember *member in members) {
    if ([member.account isEqualToString:NEVoiceRoomKit.getInstance.localMember.account]) {
      isSelf = true;
      self.isInChatRoom = YES;
      break;
    }
  }
  if (isSelf) {
    [self getSeatInfoWhenRejoinChatRoom];
  }
}
- (void)onReceiveTextMessage:(NEVoiceRoomChatTextMessage *)message {
  dispatch_async(dispatch_get_main_queue(), ^{
    NEVoiceRoomChatViewMessage *model = [[NEVoiceRoomChatViewMessage alloc] init];
    model.type = NEVoiceRoomChatViewMessageTypeNormal;
    model.text = message.text;
    model.sender = message.fromNick;
    model.isAnchor = [message.fromUserUuid isEqualToString:self.detail.liveModel.userUuid];
    [self.chatView addMessages:@[ model ]];
  });
}

- (void)onReceiveGiftWithGiftModel:(NEVoiceRoomGiftModel *)giftModel {
  dispatch_async(dispatch_get_main_queue(), ^{
    // 展示礼物动画
    NEVoiceRoomChatViewMessage *message = [[NEVoiceRoomChatViewMessage alloc] init];
    message.type = NEVoiceRoomChatViewMessageTypeReward;
    message.giftId = (int)giftModel.giftId;
    message.giftFrom = giftModel.sendNick;
    [self.chatView addMessages:@[ message ]];

    if (self.role != NEVoiceRoomRoleHost) {
      // 房主不展示礼物
      NSString *giftName = [NSString stringWithFormat:@"anim_gift_0%zd", giftModel.giftId];
      [self playGiftWithName:giftName];
    }
  });
}

- (void)onReceiveBatchGiftWithGiftModel:(NEVoiceRoomBatchGiftModel *)giftModel {
  // 收到批量礼物回调
  //  展示礼物动画
  NEVoiceRoomChatViewMessage *message = [[NEVoiceRoomChatViewMessage alloc] init];
  message.type = NEVoiceRoomChatViewMessageTypeReward;
  message.giftId = (int)giftModel.giftId;
  message.giftFrom = giftModel.rewarderUserName;
  message.giftCount = (int)giftModel.giftCount;
  message.giftTo = giftModel.rewardeeUserName;
  for (NEVoiceRoomUIGiftModel *model in self.defaultGifts) {
    if (model.giftId == giftModel.giftId) {
      message.giftName = model.display;
      break;
    }
  }
  [self.chatView addMessages:@[ message ]];
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
  [[NEVoiceRoomFloatWindowSingleton Ins] setHideWindow:YES];
  [[NEVoiceRoomFloatWindowSingleton Ins] addViewControllerTarget:nil];
}
- (void)onRtcChannelError:(NSInteger)code {
  if (code == 30015) {
    [self closeRoom];
  }
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
  [NEVoiceRoomKit.getInstance
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
- (void)connectListView:(NEUIConnectListView *)connectListView
    onRejectWithSeatItem:(NEVoiceRoomSeatItem *)seatItem {
  if (!self.isInChatRoom) {
    return;
  }
  [NEVoiceRoomKit.getInstance
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
        initWithFrame:CGRectMake(0, [NEUICommon ne_screenHeight], [NEUICommon ne_screenWidth], 50)];
    _keyboardView.backgroundColor = UIColor.whiteColor;
    _keyboardView.cusDelegate = self;
  }
  return _keyboardView;
}
- (NEVoiceRoomChatView *)chatView {
  if (!_chatView) {
    _chatView = [[NEVoiceRoomChatView alloc] initWithFrame:CGRectMake(0, 0, 100, 200)];
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
/// 列表变更
- (void)onSongListChanged {
}

/// 点歌
- (void)onSongOrdered:(NEOrderSongOrderSongModel *)song {
  [self sendChatroomNotifyMessage:[NSString
                                      stringWithFormat:@"%@ %@《%@》", song.actionOperator.userName,
                                                       NELocalizedString(@"点了"), song.songName]];
}
- (void)onSongDeleted:(NEOrderSongOrderSongModel *)song {
  [self sendChatroomNotifyMessage:[NSString stringWithFormat:@"%@ %@《%@》",
                                                             song.actionOperator.userName,
                                                             NELocalizedString(@"删除了歌曲"),
                                                             song.songName]];
  if ([song.songId isEqualToString:[NEVoiceRoomPickSongEngine sharedInstance]
                                       .currrentSongModel.playMusicInfo.songId]) {
    if (song.nextOrderSong) {
      /// 删除的是播放中的歌曲
      if ([[NEOrderSong getInstance] isSongPreloaded:song.nextOrderSong.songId
                                             channel:(int)song.nextOrderSong.oc_channel]) {
        [self readySongModel:song.nextOrderSong.orderId];
      } else {
        [[NEOrderSong getInstance] preloadSong:song.nextOrderSong.songId
                                       channel:(int)song.nextOrderSong.oc_channel
                                       observe:self];
      }
    } else {
      if ([song.songId isEqualToString:[NEVoiceRoomPickSongEngine sharedInstance]
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

- (void)onSongTopped:(NEOrderSongOrderSongModel *)song {
  [self sendChatroomNotifyMessage:[NSString
                                      stringWithFormat:@"%@ %@《%@》", song.actionOperator.userName,
                                                       NELocalizedString(@"置顶"), song.songName]];
}

- (void)onNextSong:(NEOrderSongOrderSongModel *)song {
  if (song.attachment.length > 0) {
    if ([song.attachment isEqualToString:PlayComplete]) {
      // 自然播放完成
      NEOrderSongOrderSongModel *nextSong = song.nextOrderSong;
      if (nextSong) {
        if ([[NEOrderSong getInstance] isSongPreloaded:nextSong.songId
                                               channel:(int)nextSong.oc_channel]) {
          [self readySongModel:nextSong.orderId];
        } else {
          //        self.playingAction = PlayingAction_switchSong;
          [[NEOrderSong getInstance] preloadSong:nextSong.songId
                                         channel:(int)nextSong.oc_channel
                                         observe:self];
        }
      }
    } else {
      [self sendChatroomNotifyMessage:[NSString stringWithFormat:@"%@ %@",
                                                                 song.actionOperator.userName,
                                                                 NELocalizedString(@"已切歌")]];
      // 选定歌曲切
      NEOrderSongOrderSongModel *nextSong =
          [NEOrderSongOrderSongModel yy_modelWithJSON:song.attachment];
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
    [self
        sendChatroomNotifyMessage:[NSString stringWithFormat:@"%@ %@", song.actionOperator.userName,
                                                             NELocalizedString(@"已切歌")]];
    NEOrderSongOrderSongModel *nextSong = song.nextOrderSong;
    if (nextSong) {
      if ([[NEOrderSong getInstance] isSongPreloaded:nextSong.songId
                                             channel:(int)nextSong.oc_channel]) {
        [self readySongModel:nextSong.orderId];
      } else {
        //        self.playingAction = PlayingAction_switchSong;
        [[NEOrderSong getInstance] preloadSong:nextSong.songId
                                       channel:(int)nextSong.oc_channel
                                       observe:self];
      }
    }
  }
}

#pragma mark---------- NESongPointProtocol -----------
- (void)onOrderSong:(NEOrderSongOrderSongModel *)songModel error:(NSString *)errorMessage {
  if (songModel) {
    // 点歌成功
    /// 获取房间播放信息，如果存在则不处理
    [[NEVoiceRoomKit getInstance]
        queryPlayingSongInfo:self.detail.liveModel.roomUuid
                    callback:^(NSInteger code, NSString *_Nullable msg,
                               NEVoiceRoomPlayMusicInfo *_Nullable model) {
                      if (code == NEVoiceRoomErrorCode.success) {
                        if (model) {
                          // 有播放中歌曲
                        } else {
                          // 无播放中歌曲
                          [self readySongModel:songModel.orderId];
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
    [self refreshUI];
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
    [self.pickSongView setPlayingStatus:(self.playingStatus == PlayingStatus_playing)];
  } else if (actionType == NEOrderSongChorusActionTypeResumeSong) {
    /// 本地有缓存数据，并且orderId 相同，说明是恢复
    [[NEVoiceRoomKit getInstance] resumeEffectWithEffectId:NEVoiceRoomKit.OriginalEffectId];
    self.playingStatus = PlayingStatus_playing;
    [self refreshUI];
    [self.pickSongView setPlayingStatus:(self.playingStatus == PlayingStatus_playing)];
  }
}

- (void)refreshUI {
  if (self.pickSongView) {
    [self.pickSongView setPlayingStatus:(self.playingStatus == PlayingStatus_playing)];
  }
}

- (void)voiceroom_onPreloadComplete:(NSString *)songId
                            channel:(SongChannel)channel
                              error:(NSError *)error {
  if ([songId isEqualToString:[NEVoiceRoomPickSongEngine sharedInstance]
                                  .currrentSongModel.playMusicInfo.songId] &&
      (channel ==
       [NEVoiceRoomPickSongEngine sharedInstance].currrentSongModel.playMusicInfo.oc_channel)) {
    if ([NEVoiceRoomPickSongEngine sharedInstance].currrentSongModel) {
      [self readySongModel:[NEVoiceRoomPickSongEngine sharedInstance]
                               .currrentSongModel.playMusicInfo.orderId];
    }
  }
}

#pragma mark------ NEListenTogetherPickSongViewProtocol

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

- (void)nextSong:(NEOrderSongOrderSongModel *_Nullable)orderSongModel {
  if (orderSongModel) {
    /// 选的某首歌曲
    [[NEOrderSong getInstance]
        nextSongWithOrderId:[NEVoiceRoomPickSongEngine sharedInstance]
                                .currrentSongModel.playMusicInfo.orderId
                 attachment:orderSongModel.yy_modelToJSONString
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
