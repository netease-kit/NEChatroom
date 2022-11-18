// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEVoiceRoomViewController.h"
#import <NEUIKit/NEUIBaseNavigationController.h>
#import <NEUIKit/UIView+NEUIExtension.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import "NEUIActionSheetNavigationController.h"
#import "NEUIDeviceSizeInfo.h"
#import "NEUIMoreFunctionVC.h"
#import "NEVoiceRoomChatView.h"
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
                                         NEUIConnectListViewDelegate>

@end

@implementation NEVoiceRoomViewController
- (instancetype)initWithRole:(NEVoiceRoomRole)role detail:(NEVoiceRoomInfo *)detail {
  if (self = [super init]) {
    self.detail = detail;
    self.role = role;
    self.context.role = role;
  }
  return self;
}
- (void)dealloc {
  [NEVoiceRoomKit.getInstance removeVoiceRoomListener:self];
  [self destroyNetworkObserver];
}
- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  self.ne_UINavigationItem.navigationBarHidden = YES;
  [NEVoiceRoomKit.getInstance addVoiceRoomListener:self];
  [self addSubviews];
  [self joinRoom];
  [self observeKeyboard];
  [self addNetworkObserver];
  [self checkMicAuthority];

  // 禁止返回
  id traget = self.navigationController.interactivePopGestureRecognizer.delegate;
  UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:traget action:nil];
  [self.view addGestureRecognizer:pan];
}

- (void)closeRoom {
  if (self.role == NEVoiceRoomRoleHost) {  // 主播
    [NEVoiceRoomKit.getInstance
        endRoom:^(NSInteger code, NSString *_Nullable msg, id _Nullable obj) {
          dispatch_async(dispatch_get_main_queue(), ^{
            if (self.presentedViewController) {
              [self.presentedViewController dismissViewControllerAnimated:false completion:nil];
            }
            [self.navigationController popViewControllerAnimated:YES];
          });
        }];
  } else {  // 观众
    [NEVoiceRoomKit.getInstance
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

// 禁言事件
- (void)footerDidReceiveNoSpeekingAciton {
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
    [self muteAudio:YES];
  }
}
- (void)endLive {
  [self closeRoom];
}
#pragma mark------------------------ NEUIKeyboardToolbarDelegate ------------------------
- (void)didToolBarSendText:(NSString *)text {
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
}
- (void)onRtcChannelError:(NSInteger)code {
  if (code == 30015) {
    [self closeRoom];
  }
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
    _bgImageView.image = [NEVoiceRoomUI ne_imageName:@"chatRoom_bgImage_icon"];
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
@end
