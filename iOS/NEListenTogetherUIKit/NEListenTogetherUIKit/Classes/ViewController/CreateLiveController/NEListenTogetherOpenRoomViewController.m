// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEListenTogetherOpenRoomViewController.h"
#import <Masonry/Masonry.h>
#import <NEListenTogetherKit/NEListenTogetherKit-Swift.h>
#import <NEUIKit/NEUIBaseNavigationController.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import "NEListenTogetherGlobalMacro.h"
#import "NEListenTogetherLocalized.h"
#import "NEListenTogetherToast.h"
#import "NEListenTogetherUI.h"
#import "NEListenTogetherUICreateRoomNameView.h"
#import "NEListenTogetherUIDeviceSizeInfo.h"
#import "NEListenTogetherUIManager.h"
#import "NEListenTogetherUIPlanChooseAlertView.h"
#import "NEListenTogetherUIViewFactory.h"
#import "NEListenTogetherViewController.h"
#import "NSObject+NEListenTogetherAdditions.h"
#import "UIImage+ListenTogether.h"
#import "UIImage+NEUIExtension.h"
#import "UIView+NEListenTogether.h"
#import "UIView+NEListenTogetherGradient.h"
#import "UIView+Toast.h"

@interface NEListenTogetherOpenRoomViewController () <NEUICreateRoomDelegate,
                                                      NTESPlanChooseDelegate>
@property(nonatomic, strong) UIImageView *bgImageView;
@property(nonatomic, strong) UIButton *backButton;
@property(nonatomic, strong) NEListenTogetherUICreateRoomNameView *createRoomNameView;
@property(nonatomic, strong) UIButton *openLiveButton;
@property(nonatomic, assign) BOOL clickOpenButton;

@end

@implementation NEListenTogetherOpenRoomViewController

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
  [self bindViewModel];
  [self setupSubviews];
}

- (void)bindViewModel {
  @weakify(self);
  [[self.openLiveButton rac_signalForControlEvents:UIControlEventTouchUpInside]
      subscribeNext:^(__kindof UIControl *_Nullable x) {
        @strongify(self);

        if ([NEListenTogetherUIManager.sharedInstance.delegate
                respondsToSelector:@selector(inOtherRoom)] &&
            [NEListenTogetherUIManager.sharedInstance.delegate inOtherRoom]) {
          // 已经在其他房间中，比如语聊房
          UIAlertController *alert = [UIAlertController
              alertControllerWithTitle:NELocalizedString(@"提示")
                               message:NELocalizedString(@"是否退出当前房间，并创建新房间")
                        preferredStyle:UIAlertControllerStyleAlert];
          [alert addAction:[UIAlertAction actionWithTitle:NELocalizedString(@"取消")
                                                    style:UIAlertActionStyleCancel
                                                  handler:nil]];
          [alert addAction:[UIAlertAction
                               actionWithTitle:NELocalizedString(@"确认")
                                         style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction *_Nonnull action) {
                                         if ([NEListenTogetherUIManager.sharedInstance.delegate
                                                 respondsToSelector:@selector
                                                 (leaveOtherRoomWithCompletion:)]) {
                                           [NEListenTogetherUIManager.sharedInstance.delegate
                                               leaveOtherRoomWithCompletion:^{
                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                   [self openRoomAction];
                                                 });
                                               }];
                                         }
                                       }]];
          [self presentViewController:alert animated:true completion:nil];
        } else {
          [self openRoomAction];
        }
      }];
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
    make.bottom.equalTo(self.view).offset(
        -[NEListenTogetherUIDeviceSizeInfo get_iPhoneBottomSafeDistance] - 20);
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
      postNotification:[NSNotification notificationWithName:@"listenTogetherStartLive" object:nil]];
  self.clickOpenButton = YES;
  NSString *roomName = [self.createRoomNameView getRoomName];
  if ([NSObject isNullOrNilWithObject:roomName]) {
    [NEListenTogetherToast showToast:NELocalizedString(@"房间名称为空")];
    self.clickOpenButton = NO;
    return;
  }
  if (![self isValidRoomName:roomName]) {
    self.clickOpenButton = NO;
    [NEListenTogetherToast showToast:NELocalizedString(@"房间名含有非法字符")];
    return;
  }

  [NEListenTogetherToast showLoading];
  NEListenTogetherCreateVoiceRoomParams *params =
      [[NEListenTogetherCreateVoiceRoomParams alloc] init];
  params.title = self.createRoomNameView.getRoomName;
  params.liveType = NEListenTogetherLiveRoomTypeListen_together;
  params.seatCount = 2;
  params.cover = self.createRoomNameView.getRoomBgImageUrl;
#ifdef DEBUG
  params.configId = 79;
#else
  params.configId = 570;
#endif
  if ([[[NEListenTogetherUIManager sharedInstance].config.extras objectForKey:@"serverUrl"]
          isEqualToString:@"https://roomkit-sg.netease.im"]) {
    params.configId = 76;
  }

  [[NEListenTogetherKit getInstance]
      createRoom:params
         options:[[NEListenTogetherCreateVoiceRoomOptions alloc] init]
        callback:^(NSInteger code, NSString *_Nullable msg, NEListenTogetherInfo *_Nullable obj) {
          [NEListenTogetherToast hideLoading];
          if (code == 0) {
            self.clickOpenButton = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
              NEListenTogetherViewController *vc =
                  [[NEListenTogetherViewController alloc] initWithRole:NEListenTogetherRoleHost
                                                                detail:obj];
              [self.navigationController pushViewController:vc animated:true];
            });
          } else {
            [NEListenTogetherToast
                showToast:[NSString stringWithFormat:@"%@ %zd %@",
                                                     NELocalizedString(@"加入直播间失败"), code,
                                                     msg]];
          }
        }];

  //    NTESPlanChooseAlertView *chooseAlertView = [[NTESPlanChooseAlertView alloc]
  //        initWithFrame:CGRectMake(0, 0, UIScreenWidth, UIScreenHeight)];
  //    chooseAlertView.delegate = self;
  //    [[UIApplication sharedApplication].keyWindow addSubview:chooseAlertView];
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
  self.bgImageView.image = [UIImage voiceRoom_imageNamed:@"homePage_chatRoomBgIcon"];
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
    _bgImageView = [NEListenTogetherUIViewFactory createImageViewFrame:CGRectZero
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
    [_backButton setBackgroundImage:[NEListenTogetherUI ne_listen_imageName:@"homePage_backIcon"]
                           forState:UIControlStateNormal];
  }
  return _backButton;
}
- (NEListenTogetherUICreateRoomNameView *)createRoomNameView {
  if (!_createRoomNameView) {
    _createRoomNameView = [[NEListenTogetherUICreateRoomNameView alloc] init];
    _createRoomNameView.delegate = self;
  }
  return _createRoomNameView;
}

- (UIButton *)openLiveButton {
  if (!_openLiveButton) {
    _openLiveButton =
        [NEListenTogetherUIViewFactory createSystemBtnFrame:CGRectZero
                                                      title:NELocalizedString(@"开启房间")
                                                 titleColor:UIColor.whiteColor
                                            backgroundColor:nil
                                                     target:nil
                                                     action:nil];
    [_openLiveButton setGradientBackgroundWithColors:@[ HEXCOLOR(0x6699FF), HEXCOLOR(0x30F2F2) ]
                                           locations:nil
                                          startPoint:CGPointMake(0, 0)
                                            endPoint:CGPointMake(1, 0)];
  }
  return _openLiveButton;
}
@end
