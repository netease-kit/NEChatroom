// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEOpenRoomViewController.h"
#import <Masonry/Masonry.h>
#import <NEUIKit/NEUIBaseNavigationController.h>
#import <NEVoiceRoomKit/NEVoiceRoomKit-Swift.h>
#import "NEUICreateRoomNameView.h"
#import "NEUIDeviceSizeInfo.h"
#import "NEUIPlanChooseAlertView.h"
#import "NEUIViewFactory.h"
#import "NEVoiceRoomFloatWindowSingleton.h"
#import "NEVoiceRoomLocalized.h"
#import "NEVoiceRoomToast.h"
#import "NEVoiceRoomUI.h"
#import "NEVoiceRoomUIManager.h"
#import "NEVoiceRoomViewController.h"
#import "NSObject+additions.h"
#import "NTESGlobalMacro.h"
#import "UIImage+NEUIExtension.h"
#import "UIImage+VoiceRoom.h"
#import "UIView+Gradient.h"
#import "UIView+Toast.h"
#import "UIView+VoiceRoom.h"
@import NESocialUIKit;

@interface NEOpenRoomViewController () <NEUICreateRoomDelegate,
                                        NTESPlanChooseDelegate,
                                        UIAlertViewDelegate>
@property(nonatomic, strong) UIImageView *bgImageView;
@property(nonatomic, strong) UIButton *backButton;
@property(nonatomic, strong) NEUICreateRoomNameView *createRoomNameView;
@property(nonatomic, strong) UIButton *openLiveButton;
@property(nonatomic, assign) BOOL clickOpenButton;

@end

@implementation NEOpenRoomViewController

- (instancetype)init {
  self = [super init];
  if (self) {
    [self createRoomResult];
    self.clickOpenButton = NO;
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  self.ne_UINavigationItem.navigationBarHidden = YES;
  [self setupSubviews];
}

- (void)setupSubviews {
  [self.view addSubview:self.bgImageView];
  [self.bgImageView addSubview:self.backButton];
  [self.bgImageView addSubview:self.openLiveButton];
  [self.bgImageView addSubview:self.createRoomNameView];

  [self.bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.left.right.bottom.equalTo(self.view);
  }];

  [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
    make.size.mas_equalTo(CGSizeMake(24, 24));
    make.left.mas_equalTo(20);
    make.top.equalTo(self.view).offset([NEUICommon ne_statusBarHeight] + 10);
  }];
  [self.openLiveButton mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.mas_equalTo(20);
    make.right.mas_equalTo(-20);
    make.bottom.equalTo(self.view).offset(-[NEUIDeviceSizeInfo get_iPhoneBottomSafeDistance] - 20);
    make.height.mas_equalTo(44);
  }];

  [self.createRoomNameView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.mas_equalTo(20);
    make.right.mas_equalTo(-20);
    make.top.equalTo(self.backButton.mas_bottom).offset(15);
    make.height.mas_equalTo(116);
  }];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
  [super touchesEnded:touches withEvent:event];
  [self.view endEditing:YES];
}

// 开启直播间
- (void)openRoomAction {
  if (self.clickOpenButton) {
    return;
  }

  [NSNotificationCenter.defaultCenter
      postNotification:[NSNotification notificationWithName:@"chatroomStartLive" object:nil]];
  self.clickOpenButton = YES;
  NSString *roomName = [self.createRoomNameView getRoomName];
  if ([NSObject isNullOrNilWithObject:roomName]) {
    self.clickOpenButton = NO;
    [NEVoiceRoomToast showToast:NELocalizedString(@"房间名称为空")];
    return;
  }
  if (![self isValidRoomName:roomName]) {
    self.clickOpenButton = NO;
    [NEVoiceRoomToast showToast:NELocalizedString(@"房间名含有非法字符")];
    return;
  }

  [NEVoiceRoomToast showLoading];
  NECreateVoiceRoomParams *params = [[NECreateVoiceRoomParams alloc] init];
  params.liveTopic = self.createRoomNameView.getRoomName;
  params.seatCount = 9;
  params.cover = self.createRoomNameView.getRoomBgImageUrl;
#ifdef DEBUG
  params.configId = 76;
#else
  params.configId = 569;
#endif
  if ([[[NEVoiceRoomUIManager sharedInstance].config.extras objectForKey:@"serverUrl"]
          isEqualToString:@"https://roomkit-sg.netease.im"]) {
    params.configId = 75;
  }

  [[NEVoiceRoomKit getInstance]
      createRoom:params
         options:[[NECreateVoiceRoomOptions alloc] init]
        callback:^(NSInteger code, NSString *_Nullable msg, NEVoiceRoomInfo *_Nullable obj) {
          [NEVoiceRoomToast hideLoading];
          self.clickOpenButton = NO;
          if (code == 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
              NEVoiceRoomViewController *vc =
                  [[NEVoiceRoomViewController alloc] initWithRole:NEVoiceRoomRoleHost detail:obj];
              [self.navigationController pushViewController:vc animated:true];
            });
          } else {
            [NEVoiceRoomToast
                showToast:[NSString stringWithFormat:@"%@ %zd %@",
                                                     NELocalizedString(@"加入直播间失败"), code,
                                                     msg]];
            if (code == 2001) {
              dispatch_async(dispatch_get_main_queue(), ^{
                NESocialAuthenticationViewController *view =
                    [[NESocialAuthenticationViewController alloc] init];
                __weak typeof(view) weakView = view;
                view.authenticateAction = ^(NSString *_Nonnull name, NSString *_Nonnull cardNo) {
                  [[NEVoiceRoomKit getInstance]
                      authenticateWithName:name
                                    cardNo:cardNo
                                  callback:^(NSInteger code, NSString *_Nullable msg,
                                             NSNumber *_Nullable ret) {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                      if (code == 0) {
                                        if (ret.boolValue) {
                                          [weakView showSuccWithSucc:nil];
                                        } else {
                                          [weakView showErrorWithError:nil];
                                        }
                                      } else {
                                        [weakView showErrorWithError:msg];
                                      }
                                    });
                                  }];
                };
                [self.navigationController pushViewController:view animated:true];
              });
            }
          }
        }];
}

/// 是否是合法字符
- (BOOL)isValidRoomName:(NSString *)roomName {
  NSString *regex = @"^[a-zA-Z0-9\u4e00-\u9fa5,\\s+]{1,20}$";
  NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
  if ([pred evaluateWithObject:roomName]) {
    return YES;
  }
  NSString *language = [NSLocale preferredLanguages].firstObject;
  if ([language hasPrefix:@"en"]) {
    return YES;
  }
  return NO;
}

- (void)viewWillLayoutSubviews {
  [super viewWillLayoutSubviews];
  [self.openLiveButton cutViewRounded:UIRectCornerAllCorners cornerRadii:CGSizeMake(30, 30)];
  [self.createRoomNameView cutViewRounded:UIRectCornerAllCorners cornerRadii:CGSizeMake(8, 8)];
}

#pragma mark - NEUICreateRoomDelegate
- (void)createRoomResult {
  self.bgImageView.image = [UIImage nevoiceRoom_imageNamed:@"homePage_chatRoomBgIcon"];
  [self.openLiveButton setGradientBackgroundWithColors:@[ HEXCOLOR(0x6699FF), HEXCOLOR(0x30F2F2) ]
                                             locations:nil
                                            startPoint:CGPointMake(0, 0)
                                              endPoint:CGPointMake(1, 0)];
}

#pragma mark - NTESPlanChooseDelegate
// 创建房间类型 rtc cdn
- (void)planChooseResult {
  //    if (NELP_AUTHORITY_CHECK) {
  //        selectIndex == NTESPushTypeCdn?NELPLogInfo(@"create CDN room"):NELPLogInfo(@"create RTC
  //        room"); NECreateRoomParams *params = [[NECreateRoomParams alloc] init]; params.title =
  //        self.createRoomNameView.getRoomName; params.pushType = selectIndex; params.seatLimit =
  //        8; params.userLimit = 8; NELiveRoomPushType pushType = (selectIndex == NTESPushTypeCdn)
  //        ? NELiveRoomPushTypeCDN : NELiveRoomPushTypeRTC; NTESLanguageChatRoomViewController
  //        *chatRoomCtrl = [[NTESLanguageChatRoomViewController
  //        alloc]initWithLiveRoomWithPushType:pushType role:NTESUserModeAnchor
  //        createRoomParams:params enterRoomParams:nil]; [self.navigationController
  //        pushViewController:chatRoomCtrl animated:YES];
  //    }
}
- (void)popToLastController {
  [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - lazyMethod
- (UIImageView *)bgImageView {
  if (!_bgImageView) {
    _bgImageView = [NEUIViewFactory createImageViewFrame:CGRectZero
                                               imageName:@"homePage_chatRoomBgIcon"];
    _bgImageView.userInteractionEnabled = YES;
  }
  return _bgImageView;
}
- (UIButton *)backButton {
  if (!_backButton) {
    _backButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [_backButton addTarget:self
                    action:@selector(popToLastController)
          forControlEvents:UIControlEventTouchUpInside];
    [_backButton setBackgroundImage:[NEVoiceRoomUI ne_voice_imageName:@"homePage_backIcon"]
                           forState:UIControlStateNormal];
  }
  return _backButton;
}
- (NEUICreateRoomNameView *)createRoomNameView {
  if (!_createRoomNameView) {
    _createRoomNameView = [[NEUICreateRoomNameView alloc] init];
    _createRoomNameView.delegate = self;
  }
  return _createRoomNameView;
}

- (UIButton *)openLiveButton {
  if (!_openLiveButton) {
    _openLiveButton = [NEUIViewFactory createSystemBtnFrame:CGRectZero
                                                      title:NELocalizedString(@"开启房间")
                                                 titleColor:UIColor.whiteColor
                                            backgroundColor:nil
                                                     target:nil
                                                     action:nil];
    [_openLiveButton setGradientBackgroundWithColors:@[ HEXCOLOR(0x6699FF), HEXCOLOR(0x30F2F2) ]
                                           locations:nil
                                          startPoint:CGPointMake(0, 0)
                                            endPoint:CGPointMake(1, 0)];
    [_openLiveButton addTarget:self
                        action:@selector(openLiveButtonClicked)
              forControlEvents:UIControlEventTouchUpInside];
  }
  return _openLiveButton;
}

- (void)openLiveButtonClicked {
  if ([NEVoiceRoomFloatWindowSingleton Ins].hasFloatingView) {
    UIAlertView *alertView =
        [[UIAlertView alloc] initWithTitle:NELocalizedString(@"提示")
                                   message:NELocalizedString(@"是否退出当前房间，并创建新房间")
                                  delegate:self
                         cancelButtonTitle:NELocalizedString(@"取消")
                         otherButtonTitles:NELocalizedString(@"确认"), nil];  // 一般在if判断中加入
    [alertView show];
  } else {
    [self openRoomAction];
  }
}

// 监听点击事件 代理方法
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
  NSString *btnTitle = [alertView buttonTitleAtIndex:buttonIndex];
  if ([btnTitle isEqualToString:NELocalizedString(@"取消")]) {
  } else if ([btnTitle isEqualToString:NELocalizedString(@"确认")]) {
    [[NEVoiceRoomFloatWindowSingleton Ins]
        clickCloseButton:[NEVoiceRoomFloatWindowSingleton Ins].hasFloatingView ? NO : YES
                callback:^{
                  dispatch_async(dispatch_get_main_queue(), ^{
                    [self openRoomAction];
                  });
                }];
  }
}

@end
