//
//  NTESLiveRoomViewController.m
//  NEChatroom-iOS-ObjC
//
//  Created by vvj on 2021/2/4.
//  Copyright © 2021 netease. All rights reserved.
//

#import "NTESLiveRoomViewController.h"
#import "NTESMusicPanelViewController.h"
#import "NTESMuteListViewController.h"
#import "NTESSelectViewController.h"
#import "NTESMicInviteeListViewController.h"
#import "NTESActionSheetNavigationController.h"
#import "NTESMoreViewController.h"

#import "NTESLiveRoomHeaderView.h"
#import "NTESLiveChatView.h"
#import "NTESLiveRoomFooterView.h"
#import "NTESKtvMicQueueView.h"
#import "NTESChatroomAlertView.h"
#import "NTESSettingPanelView.h"
#import "NTESConnectListView.h"
#import "NTESPickSongVC.h"
#import "NTESMicQueueView.h"
#import "NTESKeyboardToolbarView.h"

#import "NTESChatroomNotificationHandler.h"
#import "NTESCustomAttachment.h"
#import <NERtcSDK/NERtcSDK.h>
#import "AppKey.h"
#import "NTESChatroomDataSource.h"
#import "NTESAudioPlayerManager.h"
#import "NTESCdnStreamService.h"
#import <NELivePlayerFramework/NELivePlayerFramework.h>
#import "NTESJsonUtil.h"
#import "NSDictionary+NTESJson.h"
#import "UIView+NTESToast.h"
#import "UIView+Toast.h"
#import "NTESAuthorityHelper.h"
#import "NTESDemoSystemManager.h"
#import "NTESChatroomQueueHelper.h"
#import "NTESCustomNotificationHelper.h"
#import "NTESRtcConfig.h"
#import "NTESMicQueueViewProtocol.h"
#import "NTESDemoService.h"

@interface NTESLiveRoomViewController ()<NTESChatroomNotificationHandlerDelegate,
                                        NTESMicInviteeListViewControllerDelegate,
                                        NETSFunctionAreaDelegate,
                                        NTESConnectListViewDelegate,
                                        NTESMuteListVCDelegate,
                                        NERtcEngineDelegateEx,
                                        NTESSettingPanelDelegate,
                                        NTESMicQueueViewDelegate,
                                        NTESLiveRoomHeaderDelegate,
                                        NTESKeyboardToolbarDelegate,
                                        NTESMoreSettingDelegate
                                        >



@property (nonatomic, strong) UIImageView *roomBgImageView;
@property (nonatomic, strong) NTESLiveRoomHeaderView *roomHeaderView;
@property (nonatomic, strong) NTESLiveRoomFooterView *roomfooterView;
@property (nonatomic,assign) BOOL       enableEarback;  // 耳返状态
@property (nonatomic,assign) CGFloat    gatherVolume;   // 采集音量
@property (nonatomic, assign) NTESPushType pushType;//cdn rtc
@property (nonatomic, assign) NTESCreateRoomType roomType;//语聊房  ktv
@property (nonatomic,strong) NTESAudioPlayerManager *playerManager; //背景音乐播放器
@property(nonatomic, strong) NERtcLiveStreamTaskInfo *liveStreamTask;
@property (nonatomic,strong) NTESChatroomAlertView *alerView; //alert
@property (nonatomic,strong) NTESConnectListView *connectListView; //连麦列表

//信息区域
@property (nonatomic, strong) NTESLiveChatView *messageContentView;
@property (nonatomic,strong) NTESChatroomNotificationHandler *handler; //协议处理
@property (nonatomic,strong) NTESChatroomDataSource *dataSource; //数据源
@property (nonatomic, strong) NTESMusicPanelViewController *musicPanelCtrl;
@property (nonatomic,assign) NSInteger selectMicOrder;
@property (nonatomic,readonly) BOOL networkNotReachable;
//拉流播放器
@property(nonatomic, strong) NELivePlayerController *audioPlayer;
//用来标记是否需要拉流的变量
@property(nonatomic, assign) BOOL isCloseRoom;
//记录是否断过网络
@property(nonatomic, assign) BOOL isBrokenNetwork;
/// 麦位视图
@property (nonatomic, strong) UIView<NTESMicQueueViewProtocol> *micQueueView;
//消息承载数组
@property(nonatomic, strong) NSMutableArray *notificationIdArray;

@property (nonatomic, strong) NTESKeyboardToolbarView *keyboardView;

@end

@implementation NTESLiveRoomViewController


- (instancetype)initWithChatroomInfo:(NTESChatroomInfo *)chatroomInfo
                         accountInfo:(NTESAccountInfo *)accountInfo
                            userMode:(NTESUserMode)userMode
                            pushType:(NTESPushType)pushType
                            roomType:(NTESCreateRoomType)roomType
{
    if (self = [super init]) {
        _dataSource = [[NTESChatroomDataSource alloc] init];
        _dataSource.chatroomInfo = chatroomInfo;
        _dataSource.myAccountInfo = accountInfo;
        _dataSource.userMode = userMode;
        _pushType = pushType;
        _roomType = roomType;
        _playerManager = [[NTESAudioPlayerManager alloc] init];
        _enableEarback = NO;
        _gatherVolume = 100;
    }
    return self;
}

- (void)ntes_initializeConfig {
    [self setupRTCEngine];//初始化rtc引擎
    [[NIMSDK sharedSDK].chatManager addDelegate:self.handler];
    [[NIMSDK sharedSDK].chatroomManager addDelegate:self.handler];
    [[NIMSDK sharedSDK].systemNotificationManager addDelegate:self.handler];
    
    [[NIMSDK sharedSDK].chatroomManager addDelegate:self.connectListView];

}

- (void)ntes_bindViewModel {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)
        name:UIKeyboardWillHideNotification object:nil];
    [self setupNotication];
}
// 根据键盘状态，调整_mainView的位置
- (void)keyboardWillShow:(NSNotification *)notification{

    NSDictionary *userInfo = [notification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    float keyBoardHeight = keyboardRect.size.height;
    [UIView animateWithDuration:0.3 animations:^{
        self.keyboardView.frame = CGRectMake(0, UIScreenHeight-keyBoardHeight-50, UIScreenWidth, 50);
    }];

}

- (void)keyboardWillHide:(NSNotification *)aNotification {
     //键盘消失时 隐藏工具栏
     [UIView animateWithDuration:0.1 animations:^{
         self.keyboardView.frame = CGRectMake(0, UIScreenHeight+50, UIScreenWidth, 50);
     }];
}


- (void)ntes_addSubViews {
    [self.view addSubview:self.roomBgImageView];
    [self.view addSubview:self.keyboardView];
    [self.roomBgImageView addSubview:self.roomHeaderView];
    [self.roomBgImageView addSubview:self.micQueueView];
    [self.roomBgImageView addSubview:self.messageContentView];
    [self.roomBgImageView addSubview:self.roomfooterView];
    [self.roomBgImageView addSubview:self.musicPanelCtrl.view];
    [self addChildViewController:self.musicPanelCtrl];
    
    [self.roomHeaderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(54);
        make.left.equalTo(self.view).offset(8);
        make.right.equalTo(self.view).offset(-8);
        make.top.mas_equalTo(statusBarHeight +8);
    }];
    
    [self.roomfooterView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(36);
        make.left.equalTo(self.view).offset(8);
        make.right.equalTo(self.view).offset(-8);
        make.bottom.mas_equalTo(-[NTESDeviceSizeInfo get_iPhoneBottomSafeDistance] -8);
    }];
    

    if (self.roomType == NTESCreateRoomTypeChatRoom) {//语聊房
        CGFloat width = self.view.width - 2*30.0;
        CGFloat height = [self.micQueueView calculateHeightWithWidth:width];

        [self.micQueueView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.roomHeaderView.mas_bottom).offset(12);
            make.left.equalTo(self.roomBgImageView).offset(30);
            make.right.equalTo(self.roomBgImageView).offset(-30);
            make.height.mas_equalTo(height);
        }];
        [self.messageContentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.micQueueView.mas_bottom).offset(20);
            make.bottom.equalTo(self.roomfooterView.mas_top).offset(-12);
            make.left.equalTo(self.roomBgImageView).offset(8);
            make.right.equalTo(self.roomBgImageView).offset(-88);
        }];
    }else if (self.roomType == NTESCreateRoomTypeKTV){//ktv
        self.musicPanelCtrl.view.hidden = NO;
        [self.musicPanelCtrl.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.roomHeaderView.mas_bottom).offset(12);
            make.left.equalTo(self.roomBgImageView).offset(8);
            make.right.equalTo(self.roomBgImageView).offset(-8);
            make.height.mas_equalTo(220);
        }];

        [self.micQueueView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.musicPanelCtrl.view.mas_bottom).offset(12);
            make.left.equalTo(self.roomBgImageView).offset(2);
            make.right.equalTo(self.roomBgImageView).offset(-8);
            make.height.mas_equalTo(68);
        }];
        
        [self.messageContentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.micQueueView.mas_bottom).offset(3);
            make.bottom.equalTo(self.roomfooterView.mas_top).offset(-12);
            make.left.equalTo(self.roomBgImageView).offset(8);
            make.right.equalTo(self.roomBgImageView).offset(-88);
        }];
    }
    

    

}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    
    if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    };
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self enterChatroomWithUserMode:_dataSource.userMode];
    [self bindEvent];
}

- (void)bindEvent {
    @weakify(self);
    // 刷新主播信息
    [RACObserve(self.dataSource, anchorInfo) subscribeNext:^(NTESAccountInfo *x) {
        @strongify(self);
        if (x) {
            NTESMicInfo *micInfo = [[NTESMicInfo alloc] init];
            micInfo.userInfo = [[NTESUserInfo alloc] initWithAccountInfo:x];
            self.micQueueView.anchorMicInfo = micInfo;
        }
    }];
    // 刷新主播状态信息
    [RACObserve(self.dataSource.chatroomInfo, micMute) subscribeNext:^(id x) {
        @strongify(self);
        NTESMicStatus status = NTESMicStatusConnectFinished;
        if ([x boolValue]) {
            status = NTESMicStatusConnectFinishedWithMuted;
        }
        
        NTESMicInfo *micInfo = self.micQueueView.anchorMicInfo;
        micInfo.micStatus = status;
        self.micQueueView.anchorMicInfo = micInfo;
    }];
    
    // 刷新正在唱歌的麦位状态
    RACSignal *pickSongSub = RACObserve(self.dataSource.pickService, pickSongs);
    RACSignal *anchorInfoSub = RACObserve(self.micQueueView, anchorMicInfo);
    [[pickSongSub combineLatestWith:anchorInfoSub] subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        if (self.roomType == NTESCreateRoomTypeChatRoom || self.micQueueView.anchorMicInfo == nil) {
            return;
        }
        NSString *singerAccountId = nil;
        NTESQueueMusic *mus = [self.dataSource.pickService.pickSongs firstObject];
        singerAccountId = mus.userId;
        ntes_main_async_safe(^{
            self.micQueueView.singerAccountId = singerAccountId;
        });
    }];
}

- (void)setupRTCEngine {
    NERtcEngineContext *context = [[NERtcEngineContext alloc] init];
    context.appKey = kNertcAppkey;
    context.engineDelegate = self;
    NERtcEngine *coreEngine = [NERtcEngine sharedEngine];
    NERtcLogSetting *setting = [[NERtcLogSetting alloc] init];
    #if DEBUG
         setting.logLevel = kNERtcLogLevelInfo;
    #else
         setting.logLevel = kNERtcLogLevelWarning;
    #endif
    context.logSetting = setting;
    
    [coreEngine setAudioProfile:self.roomType == NTESCreateRoomTypeChatRoom ? kNERtcAudioProfileHighQuality:kNERtcAudioProfileHighQualityStereo scenario:self.roomType == NTESCreateRoomTypeChatRoom ? kNERtcAudioScenarioChatRoom : kNERtcAudioScenarioMusic];
    [coreEngine setupEngineWithContext:context];
    [coreEngine enableAudioVolumeIndication:YES interval:1000];
    [coreEngine setChannelProfile:kNERtcChannelProfileLiveBroadcasting];
    [NIMCustomObject registerCustomDecoder:[[NTESCustomAttachmentDecoder alloc] init]];

    if (_dataSource.userMode == NTESUserModeAnchor) {
        [coreEngine enableLocalAudio:YES];
    } else {
        [coreEngine enableLocalAudio:NO];
    }

    if (self.pushType == NTESPushTypeCdn) {
        [coreEngine setParameters:@{kNERtcKeyPublishSelfStreamEnabled: @YES}]; // 打开推流
    }
}

- (void)setupNotication {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appReachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillTerminate:) name:UIApplicationWillTerminateNotification object:nil];
}

- (void)updateInputView {
    if (_dataSource.userMode == NTESUserModeAnchor) {
        return;
    }
    if (_dataSource.isMuteAll) {
        [self.view endEditing:YES];
        [self.roomfooterView setMuteWithType:NTESMuteTypeAll];
    } else {
        if (_dataSource.meIsMute) {
            [self.view endEditing:YES];
            [self.roomfooterView setMuteWithType:NTESMuteTypeSelf];
        } else {
            [self.roomfooterView cancelMute];
        }
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

#pragma mark - Router
- (void)goMuteListVC {
    NTESMuteListViewController *muteVC = [[NTESMuteListViewController alloc] initWithChatroom:_dataSource.chatroom
                                                                                 chatroomMute:_dataSource.isMuteAll];
    muteVC.delegate = self;
    NTESActionSheetNavigationController *nav = [[NTESActionSheetNavigationController alloc] initWithRootViewController:muteVC];
    nav.dismissOnTouchOutside = YES;
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)goInviteMicVC:(NTESMicInfo *)info {
    NTESMicInviteeListViewController *vc = [[NTESMicInviteeListViewController alloc] initWithChatroom:_dataSource.chatroom
                                                                                           micMembers:_dataSource.micInfoArray
                                                                                           dstMicInfo:info];
    vc.delegate = self;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)showNetworkStatus {
    NetworkStatus networkStatus = [NTESDemoSystemManager shareInstance].netStatus;
    if (networkStatus == NotReachable) {
        self.isBrokenNetwork = YES;
        [self.view showToastWithMessage:@"网络断开" state:NTESToastStateFail autoDismiss:NO];

    } else {
        [self.view dismissToast];
//        [self fetchChatroomQueue];备注： 重复调用了，在还没进入到聊天室就调用了，时机不对
        if (self.dataSource.userMode == NTESUserModeAnchor
            && self.isBrokenNetwork == YES
            && self.pushType == NTESPushTypeCdn) {//主播断网后的重连
            //发送消息通知观众，重新拉流
            NIMSession *session = [NIMSession session:_dataSource.chatroomInfo.roomId type:NIMSessionTypeChatroom];
            NIMMessage *message = [[NIMMessage alloc] init];
            NTESCustomAttachment *attachment = [[NTESCustomAttachment alloc] init];
            attachment.type = NTESVoiceChatAttachmentTypePullStream;
            NIMCustomObject *object = [[NIMCustomObject alloc] init];
            object.attachment = attachment;
            message.messageObject = object;
            [[NIMSDK sharedSDK].chatManager sendMessage:message toSession:session error:nil];
        }
        
        if (self.dataSource.userMode == NTESUserModeAudience
            && self.isBrokenNetwork == YES
            && self.pushType == NTESPushTypeCdn) {//观众断网后的重连
           [self pullStreamTask];
        }
        self.isBrokenNetwork = NO;
    }
}
#pragma mark - Alert Actions
- (NSMutableArray <NTESChatroomAlertAction *> *)setUpAlertActions {
    NSMutableArray *ret = [NSMutableArray array];
    __weak typeof(self) weakSelf = self;
    NTESChatroomAlertAction *inviteMicAction = [NTESChatroomAlertAction actionWithTitle:@"将成员抱上麦"
                                                                                   type:NTESAlertActionTypeInviteMic
                                                                                handler:^(id  _Nonnull info) {
        if (NELP_AUTHORITY_CHECK) {
            NTESMicInfo *micInfo = (NTESMicInfo *)info;
            [weakSelf goInviteMicVC:micInfo];
        }
        weakSelf.selectMicOrder = -1;
    }];
    [ret addObject:inviteMicAction];
    
    NTESChatroomAlertAction *maskMicAction = [NTESChatroomAlertAction actionWithTitle:@"屏蔽麦位"
                                                                                 type:NTESAlertActionTypeMaskMic
                                                                              handler:^(id  _Nonnull info) {
          if (weakSelf.networkNotReachable) {
              [weakSelf.view makeToast:@"语音屏蔽失败" duration:1 position:CSToastPositionCenter];
          } else {

              NTESMicInfo *micInfo = (NTESMicInfo *)info;
              micInfo.micStatus = NTESMicStatusMasked;
              micInfo.micReason = NTESMicReasonMicMasked;
              
              [weakSelf didUpdateChatroomQueueWithMicInfo:micInfo];
              [weakSelf.view makeToast:@"该麦位语音已被屏蔽，无法发言" duration:1 position:CSToastPositionCenter];
          }
          weakSelf.selectMicOrder = -1;

    }];
    [ret addObject:maskMicAction];
    
    NTESChatroomAlertAction *finishMaskMicAction = [NTESChatroomAlertAction actionWithTitle:@"屏蔽该麦位语音"
                                                                                 type:NTESAlertActionTypeFinishedMaskMic
                                                                              handler:^(id  _Nonnull info) {
          if (weakSelf.networkNotReachable) {
              [weakSelf.view makeToast:@"语音屏蔽失败" duration:1 position:CSToastPositionCenter];
          } else {
              NTESMicInfo *micInfo = (NTESMicInfo *)info;
              if (micInfo.micStatus == NTESMicStatusConnectFinished) {
                  micInfo.micStatus = NTESMicStatusConnectFinishedWithMasked;
              } else if (micInfo.micStatus == NTESMicStatusConnectFinishedWithMuted) {
                  micInfo.micStatus = NTESMicStatusConnectFinishedWithMutedAndMasked;
              }
              [weakSelf didUpdateChatroomQueueWithMicInfo:micInfo];
              [weakSelf.view makeToast:@"该麦位语音已被屏蔽，无法发言" duration:1 position:CSToastPositionCenter];
          }
          weakSelf.selectMicOrder = -1;

    }];
    [ret addObject:finishMaskMicAction];
    
    
    NTESChatroomAlertAction *closeMicAction = [NTESChatroomAlertAction actionWithTitle:@"关闭麦位"
                                                                                  type:NTESAlertActionTypeCloseMic
                                                                               handler:^(id  _Nonnull info) {
           if (weakSelf.networkNotReachable) {
               [weakSelf.view makeToast:@"关闭麦位失败" duration:1 position:CSToastPositionCenter];
           } else {
               NTESMicInfo *micInfo = (NTESMicInfo *)info;
               micInfo.micStatus = NTESMicStatusClosed;
               [weakSelf didUpdateChatroomQueueWithMicInfo:micInfo];
               NSString *msg = [NSString stringWithFormat:@"\"麦位%d\"已关闭", (int)micInfo.micOrder];
               [weakSelf.view makeToast:msg duration:1 position:CSToastPositionCenter];
           }
           weakSelf.selectMicOrder = -1;
    }];
    [ret addObject:closeMicAction];
    
    NTESChatroomAlertAction *kickMicAction = [NTESChatroomAlertAction actionWithTitle:@"将TA踢下麦位"
                                                                                 type:NTESAlertActionTypeKickMic
                                                                              handler:^(id  _Nonnull info) {
          if (weakSelf.networkNotReachable) {
              [weakSelf.view makeToast:@"踢人失败" duration:1 position:CSToastPositionCenter];
          } else {
              NTESMicInfo *micInfo = (NTESMicInfo *)info;
              if ([info isOnMicStatus]) {
                  if (micInfo.micStatus == NTESMicStatusConnectFinishedWithMasked) {
                      micInfo.micStatus = NTESMicStatusMasked;
                  } else {
                      micInfo.micStatus = NTESMicStatusNone;
                  }
                  micInfo.micReason = NTESMicReasonMicKicked;
                  [weakSelf didUpdateChatroomQueueWithMicInfo:micInfo];
                  
                  //弹幕
                  NSString *msg = [NSString stringWithFormat:@"\"%@\"离开了麦位%d",
                                   micInfo.userInfo.nickName, (int)micInfo.micOrder];
                  [NTESChatroomMessageHelper sendSystemMessage:weakSelf.dataSource.chatroom.roomId
                                                          text:msg];
              }
          }
          weakSelf.selectMicOrder = -1;
    }];
    [ret addObject:kickMicAction];
    
    NTESChatroomAlertAction *openMicAction = [NTESChatroomAlertAction actionWithTitle:@"打开麦位"
                                                                                 type:NTESAlertActionTypeOpenMic
                                                                              handler:^(id  _Nonnull info) {
          if (weakSelf.networkNotReachable) {
              [weakSelf.view makeToast:@"打开麦位失败" duration:1 position:CSToastPositionCenter];
          } else {
              NTESMicInfo *micInfo = (NTESMicInfo *)info;
              micInfo.micStatus = NTESMicStatusNone;
              micInfo.micReason = NTESMicReasonOpenMic;
              [weakSelf didUpdateChatroomQueueWithMicInfo:micInfo];
              NSString *msg = [NSString stringWithFormat:@"\"麦位%d\"已打开", (int)micInfo.micOrder];
              [weakSelf.view makeToast:msg duration:1 position:CSToastPositionCenter];
          }
          weakSelf.selectMicOrder = -1;
    }];
    [ret addObject:openMicAction];
    
    NTESChatroomAlertAction *cancelMaskMicAction = [NTESChatroomAlertAction actionWithTitle:@"解除语音屏蔽"
                                                                                       type:NTESAlertActionTypeCancelMaskMic
                                                                                    handler:^(id  _Nonnull info) {
            if (weakSelf.networkNotReachable) {
                [weakSelf.view makeToast:@"解除语音屏蔽失败" duration:1 position:CSToastPositionCenter];
            } else {
                NTESMicInfo *micInfo = (NTESMicInfo *)info;
                if (micInfo.micStatus == NTESMicStatusConnectFinishedWithMasked) {
                    micInfo.micStatus = NTESMicStatusConnectFinished;
                    micInfo.micReason = NTESMicReasonResumeMasked;
                } else if (micInfo.micStatus == NTESMicStatusConnectFinishedWithMutedAndMasked) {
                    micInfo.micStatus = NTESMicStatusConnectFinishedWithMuted;
                    micInfo.micReason = NTESMicReasonResumeMasked;
                } else {
                    micInfo.micStatus = NTESMicStatusNone;
                    micInfo.micReason = NTESMicReasonNone;
                }
                
                [weakSelf.view makeToast:@"该麦位已\"解除语音屏蔽\"" duration:1 position:CSToastPositionCenter];
                [weakSelf didUpdateChatroomQueueWithMicInfo:micInfo];
            }
            weakSelf.selectMicOrder = -1;
    }];
    [ret addObject:cancelMaskMicAction];
    
    NTESChatroomAlertAction *cancelOnMicRequestAction = [NTESChatroomAlertAction actionWithTitle:@"确认取消申请上麦"
                                                                                       type:NTESAlertActionTypeCancelOnMicRequest
                                                                                    handler:^(id  _Nonnull info) {
            if (weakSelf.networkNotReachable) {
                [weakSelf.view makeToast:@"取消申请上麦失败" duration:1 position:CSToastPositionCenter];
            } else {
                NTESMicInfo *micInfo = (NTESMicInfo *)info;
                [NTESCustomNotificationHelper sendCancelMicNotication:weakSelf.dataSource.chatroom.creator
                                                                 micInfo:micInfo];
            }
 
    }];
    [ret addObject:cancelOnMicRequestAction];
    
    NTESChatroomAlertAction *dropMicAction = [NTESChatroomAlertAction actionWithTitle:@"下麦"
                                                                                 type:NTESAlertActionTypeDropMic
                                                                              handler:^(id  _Nonnull info) {
          if (weakSelf.networkNotReachable) {
              [weakSelf.view makeToast:@"下麦失败" duration:1 position:CSToastPositionCenter];
          } else {
              NTESMicInfo *micInfo = (NTESMicInfo *)info;
              [NTESCustomNotificationHelper sendDropMicNotication:weakSelf.dataSource.chatroom.creator micInfo:micInfo completion:nil];
              [weakSelf.view makeToast:@"您已下麦" duration:1 position:CSToastPositionCenter];
          }
    }];
    [ret addObject:dropMicAction];
    
    NTESChatroomAlertAction *exitAction = [NTESChatroomAlertAction actionWithTitle:@"退出并解散房间"
                                                                              type:NTESAlertActionTypeExistRoom
                                                                           handler:^(id  _Nonnull info) {
        [weakSelf _exitChatroomWithUserMode:weakSelf.dataSource.userMode
                                    creator:weakSelf.dataSource.chatroom.creator
                                    micInfo:weakSelf.dataSource.myMicInfo];
    }];
    [ret addObject:exitAction];

    return ret;
}

#pragma mark - Private
//关闭播放器
- (void)destoryPlayer {
    if (self.audioPlayer && self.pushType == NTESPushTypeCdn) {
        [self.audioPlayer shutdown];
        self.audioPlayer = nil;
    }
}

- (void)enterChatroomWithUserMode:(NTESUserMode)userMode {
    NIMChatroomEnterRequest *request = [[NIMChatroomEnterRequest alloc] init];
    request.roomId = _dataSource.chatroomInfo.roomId;
    request.roomNickname = _dataSource.myAccountInfo.nickName;
    request.roomAvatar = _dataSource.myAccountInfo.icon;

    __weak typeof(self) wself = self;
    [[NIMSDK sharedSDK].chatroomManager enterChatroom:request
                                           completion:^(NSError * _Nullable error, NIMChatroom * _Nullable chatroom, NIMChatroomMember * _Nullable me) {
        if (!error) {
            wself.dataSource.chatroom = chatroom;
        } else {
            [NTESChatroomAlertView showAlertWithMessage:@"进入聊天室失败" completion:^{
                [wself.navigationController popViewControllerAnimated:YES];
            }];
            NELPLogInfo(@"[demo] 进入房间失败.[%@]", error);
        }
    }];
}

- (void)_exitChatroomWithUserMode:(NTESUserMode)userMode creator:(NSString *)creator micInfo:(NTESMicInfo *)micInfo
{
    // 销毁播放器,SDK退出
    @weakify(self);
    void(^releaseSource)(void) = ^() {
        @strongify(self);
        [self.playerManager stop];
        [self destoryPlayer];
        [[NERtcEngine sharedEngine] leaveChannel];
        
        NSString *roomId = self.dataSource.chatroom.roomId;
        [[NIMSDK sharedSDK].chatroomManager exitChatroom:roomId completion:^(NSError * _Nullable error) {
            if (error) {
                NELPLogError(@"[demo] exit chatroom error![%@]", error);
            }
            ntes_main_async_safe(^{
                [self.navigationController popViewControllerAnimated:YES];
            });
        }];
        self.isCloseRoom = YES;
    };
    
    switch (userMode) {
        case NTESUserModeAnchor:
        {
            // 主播退出: 下麦-移除推流-销毁引擎
            [NTESCustomNotificationHelper sendDropMicNotication:_dataSource.chatroom.creator micInfo:_dataSource.myMicInfo completion:^(NSError * _Nullable error) {
                if (error) {
                    NELPLogError(@"下麦失败, error: %@", error);
                    return;
                }
                
                // 移除推流任务
                [self removeLiveStreamTask];
                releaseSource();
            }];
        }
            break;
        case NTESUserModeConnector:
        {
            NTESMicInfo *micInfo = _dataSource.myMicInfo;
            if ([micInfo isOnMicStatus]) {
                // 连麦者退出: 下麦-销毁引擎
                [NTESCustomNotificationHelper sendDropMicNotication:_dataSource.chatroom.creator micInfo:_dataSource.myMicInfo completion:^(NSError * _Nullable error) {
                    if (error) {
                        NELPLogError(@"下麦失败, error: %@", error);
                        return;
                    }
                    releaseSource();
                }];
            } else {
                releaseSource();
            }
        }
            break;
            
        default:
            // 观众退出: 销毁引擎
            releaseSource();
            break;
    }
    
    YXAlogInfo(@"关闭直播间, micInfo: %@, userMode: %lu", _dataSource.myMicInfo, (unsigned long)userMode);
}

- (void)updateChatroomExtWithChatroom:(NIMChatroom *)chatroom
                                 info:(NTESChatroomInfo *)info {
    NIMChatroomUpdateRequest *request = [[NIMChatroomUpdateRequest alloc] init];
    NSString *update = nil;
    update = [@{
                NTESChatroomAudioQuality : @(info.audioQuality),
                } jsonBody];
    NSString *ext = [NTESJsonUtil jsonString:chatroom.ext addJsonString:update];
    request.roomId = chatroom.roomId;
    request.updateInfo = @{@(NIMChatroomUpdateTagExt) : ext};
    [[NIMSDK sharedSDK].chatroomManager updateChatroomInfo:request completion:^(NSError * _Nullable error) {
        if (error) {
            NELPLogError(@"[demo] update chatroomInfo error![%@]", error);
        }
    }];
}

- (void)updateChatroomInfoWithChatroom:(NIMChatroom *)chatroom {
    NSString *ext = chatroom.ext;
    NSDictionary *dic = [NTESJsonUtil dictByJsonString:ext];
    _dataSource.chatroomInfo.audioQuality = [dic[NTESChatroomAudioQuality] integerValue];
}

- (void)fetchCreaterInfo {
    
    NSString *creator = _dataSource.chatroom.creator;
    NSString *myId = _dataSource.myAccountInfo.account;
    NSMutableArray *userIds = [NSMutableArray array];
    if (creator.length == 0) {
        return;
    }
    if (_dataSource.userMode == NTESUserModeAnchor) {
        [userIds addObject:creator];
    } else {
        [userIds addObject:creator];
        if (myId.length != 0) {
            [userIds addObject:myId];
        }
    }
    
    NIMChatroomMembersByIdsRequest *request = [[NIMChatroomMembersByIdsRequest alloc] init];
    request.roomId = _dataSource.chatroom.roomId;
    request.userIds = userIds;
    __weak typeof(self) weakSelf = self;
    [[NIMSDK sharedSDK].chatroomManager fetchChatroomMembersByIds:request
                                                       completion:^(NSError * _Nullable error, NSArray<NIMChatroomMember *> * _Nullable members) {
        if (!error) {
            //旧逻辑
            for (NIMChatroomMember *member in members) {
                if ([member.userId isEqualToString:creator]) {
                    NTESAccountInfo *info = [[NTESAccountInfo alloc] init];
                    info.account = member.userId;
                    info.nickName = member.roomNickname;
                    info.icon = member.roomAvatar;
//                    weakSelf.headerView.accountInfo = info;

                    weakSelf.dataSource.anchorInfo = info;
                } else if ([member.userId isEqualToString:myId]) {
                    weakSelf.dataSource.meIsMute = member.isTempMuted;
                    if (member.isTempMuted) {
                        [weakSelf.view makeToast:@"您已被禁言" duration:1 position:CSToastPositionCenter];
                    }
                    [weakSelf updateInputView];
                }
            }
        }
    }];
}

- (void)fetchChatroomQueue {
    __weak typeof(self) wself = self;
    [[NIMSDK sharedSDK].chatroomManager fetchChatroomQueue:_dataSource.chatroomInfo.roomId
                                                completion:^(NSError * _Nullable error, NSArray<NSDictionary<NSString *,NSString *> *> * _Nullable info) {
        if (!error) {
            if (info) {
                [wself.dataSource buildMicInfoDataWithChatroomQueue:info];
                [wself.dataSource.pickService buildPickedSongDataWithChatroomQueue:info];
                wself.micQueueView.datas = wself.dataSource.micInfoArray;
            }
        } else {
            NELPLogError(@"[demo] chatroomqueue更新失败.[%@]", error);
        }
    }];
}

- (void)joinMeeting {
    //观众进入频道后开启CDN,则开启拉流
    __weak typeof(self) wself = self;
    if (wself.pushType == NTESPushTypeCdn && wself.dataSource.userMode == NTESUserModeAudience) {
//        [wself.audioPlayer play];
        [self pullStreamTask];
        return;
    }
    [self rtcEngineJoinChannel];
}

//rtc加入频道
- (void)rtcEngineJoinChannel {
    
    __weak typeof(self) wself = self;
    [[NERtcEngine sharedEngine] joinChannelWithToken:@""
                                         channelName:_dataSource.chatroomInfo.roomId
                                               myUid:_dataSource.myAccountInfo.uid
                                          completion:^(NSError * _Nullable error, uint64_t channelId, uint64_t elapesd) {
        if (error) {
            NELPLogError(@"[demo] 加入meeting失败.%@", error);
            [NTESChatroomAlertView showAlertWithMessage:@"进入音视频房间失败" completion:^{
                [wself _exitChatroomWithUserMode:wself.dataSource.userMode
                                         creator:wself.dataSource.chatroom.creator
                                         micInfo:wself.dataSource.myMicInfo];
            }];
        } else {
            [[NERtcEngine sharedEngine] setLoudspeakerMode:YES];
            [[NERtcEngine sharedEngine] uploadSdkInfo];
            //开启CDN，只有加入频道成功后才添加推流任务
            if (wself.pushType == NTESPushTypeCdn && wself.dataSource.userMode == NTESUserModeAnchor) {
                [self addLiveStream:self.dataSource.chatroomInfo.configModel.pushUrl];
            }
        }
    }];
}

//添加推流任务
- (void)addLiveStream:(NSString *)streamURL {
    NSAssert(![streamURL isEqualToString:@""], @"请设置推流地址");
    self.liveStreamTask = [[NERtcLiveStreamTaskInfo alloc] init];
    self.liveStreamTask.taskID = [NSString stringWithFormat:@"%d",arc4random()/100];;
    self.liveStreamTask.streamURL = streamURL;
    self.liveStreamTask.lsMode = kNERtcLsModeAudio;
    self.liveStreamTask.serverRecordEnabled = NO;
    NSInteger layoutWidth = 720;
    NSInteger layoutHeight = 1280;
//    设置整体布局
    NERtcLiveStreamLayout *layout = [[NERtcLiveStreamLayout alloc] init];
    
    NERtcLiveStreamUserTranscoding *userTranscoding = [self addLiveStreamUserTrans:self.dataSource.myAccountInfo.uid];
    layout.users = @[userTranscoding];
    layout.width = layoutWidth; //整体布局宽度
    layout.height = layoutHeight; //整体布局高度
    self.liveStreamTask.layout = layout;

    
    int ret = [NERtcEngine.sharedEngine addLiveStreamTask:self.liveStreamTask
                                               compeltion:^(NSString * _Nonnull taskId, kNERtcLiveStreamError errorCode) {
        if (errorCode == 0) {
          //推流任务添加成功
            NELPLogInfo(@"推流任务添加成功,推流地址：%@",streamURL);
        }else {
          //推流任务添加失败
            NELPLogError(@"推流任务添加失败");

        }
    }];
    if (ret != 0) {
        //推流任务添加失败
        NELPLogError(@"推流任务添加失败");

    }
}

- (void)pullStreamTask {
    
    if ([self.audioPlayer isPlaying]) {//正在播放就返回
        return;
    }
    
    NSURL *pullUrl = [NSURL URLWithString:self.dataSource.chatroomInfo.configModel.rtmpPullUrl];
    NSError *error = nil;
    self.audioPlayer = [[NELivePlayerController alloc] initWithContentURL:pullUrl config:nil error:&error];
    if (error) {
        NELPLogError(@"观众端拉流失败 %@",error);
    }else {
//        NELPLogInfo(@"观众端拉流成功,拉流地址:%@",pullUrl);
    }
    [self.audioPlayer setBufferStrategy:NELPLowDelay];
    [self.audioPlayer setScalingMode:NELPMovieScalingModeNone];
    [self.audioPlayer setShouldAutoplay:YES];
    [self.audioPlayer setHardwareDecoder:YES];
    [self.audioPlayer setPauseInBackground:NO];
    [self.audioPlayer setPlaybackTimeout:15 *1000];
    [self.audioPlayer prepareToPlay];

}

- (NERtcLiveStreamUserTranscoding *)addLiveStreamUserTrans:(uint64_t)uid {
    NERtcLiveStreamUserTranscoding *userTranscoding = [[NERtcLiveStreamUserTranscoding alloc] init];
    userTranscoding.uid = uid;
    userTranscoding.audioPush = YES;
    userTranscoding.videoPush = YES;
    userTranscoding.x = 0;
    userTranscoding.y = 0;
    userTranscoding.width = 720;
    userTranscoding.height = 1280;
    userTranscoding.adaption = kNERtcLsModeVideoScaleCropFill;
    return userTranscoding;
}

//添加观众的uid
- (void)addAudienceUid:(uint64_t)userUid {
    NSMutableArray *users = [[NSMutableArray alloc]initWithArray:self.liveStreamTask.layout.users];
    BOOL isContain = [NTESCdnStreamService isContainUid:userUid dataSource:users];
    if (!isContain) {
        NERtcLiveStreamUserTranscoding *userTranscoding = [self addLiveStreamUserTrans:userUid];
        [users addObject:userTranscoding];
    }
    self.liveStreamTask.layout.users = users;
}

//退出频道清除uid
- (void)deleteAudienceUid:(uint64_t)userUid {
    NSMutableArray *users = [[NSMutableArray alloc]initWithArray:self.liveStreamTask.layout.users];
    NERtcLiveStreamUserTranscoding *userTranscoding =  [NTESCdnStreamService getTargetDataWithUid:userUid dataSource:users];
    if (userTranscoding) {
        [users removeObject:userTranscoding];
    }
    self.liveStreamTask.layout.users = users;
}

//更新推流任务
- (void)updateLiveStreamTask {
    int ret = [NERtcEngine.sharedEngine updateLiveStreamTask:self.liveStreamTask
                                               compeltion:^(NSString * _Nonnull taskId, kNERtcLiveStreamError errorCode) {
    if (errorCode == 0) {
          //推流任务添加成功
        }else {
          //推流任务添加失败
            NELPLogError(@"推流任务添加失败");
        }
    }];
    if (ret != 0) {
      //更新失败
        NELPLogError(@"更新失败");

    }
}

//移除推流的操作
- (void)removeLiveStreamTask {
    
    if (self.pushType != NTESPushTypeCdn) {
        return;
    }
    
    if (self.liveStreamTask) {
        __weak typeof(self)weakSelf = self;
        int ret = [NERtcEngine.sharedEngine removeLiveStreamTask:self.liveStreamTask.taskID compeltion:^(NSString * _Nonnull taskId, kNERtcLiveStreamError errorCode) {
            if (errorCode == 0) {
              //移除成功
                weakSelf.liveStreamTask = nil;
            }
        }];
     if (ret != 0) {
            NELPLogInfo(@"移除任务失败");
     }

    }
}

//更新自己的信息
- (void)didUpdateMyMicInfo:(NTESMicInfo *)micInfo {
    switch (micInfo.micStatus) {
        case NTESMicStatusNone:
        {
            //主动下麦
            if (micInfo.micReason == NTESMicReasonDropMic) {
                NELPLogInfo(@"[demo] YAT drop mic");
                [[NERtcEngine sharedEngine] enableLocalAudio:NO];
                if (self.pushType == NTESPushTypeCdn) {
                    [[NERtcEngine sharedEngine] leaveChannel];
//                    if (!self.isCloseRoom) {
//                        [self pullStreamTask];
//                    }
                }
            }
            //被踢了
            else if (micInfo.micReason == NTESMicReasonMicKicked){
                NELPLogInfo(@"[demo] YAT be kicked");
                [NTESChatroomAlertView showAlertWithMessage:@"您已被主播踢下麦"];
                [[NERtcEngine sharedEngine] enableLocalAudio:NO];
                if (self.pushType == NTESPushTypeCdn) {
                    [[NERtcEngine sharedEngine] leaveChannel];
//                    [self pullStreamTask];
                }
            }
            //被拒绝了
            else if (micInfo.micReason == NTESMicReasonConnectRejected){
                NELPLogInfo(@"[demo] YAT be rejected");
                [self.view dismissToast];
                [NTESChatroomAlertView showAlertWithMessage:@"你的申请已被拒绝"];
            }
            //取消申请了
            else if (micInfo.micReason == NTESMicReasonCancelConnect){
                NELPLogInfo(@"[demo] YAT cancel connect");
                [self.view dismissToast];
                [self.view showToastWithMessage:@"已取消申请上麦" state:NTESToastStateSuccess];
            }
            //麦位打开
            else if (micInfo.micReason == NTESMicReasonOpenMic) {}
            _roomfooterView.userMode = NTESUserModeAudience;
            _dataSource.userMode = NTESUserModeAudience;
            _dataSource.isMasked = NO;
        }
            break;
        case NTESMicStatusConnecting: //正在申请 不需要操作
            {}
            break;
        case NTESMicStatusConnectFinished:{
            //同意上麦了
            if (micInfo.micReason == NTESMicReasonConnectAccepted) {
                NELPLogInfo(@"[demo] YAT allow connect");
                [self.view showToastWithMessage:@"申请通过" state:NTESToastStateSuccess];
                [[NERtcEngine sharedEngine] enableLocalAudio:YES];
                [self destoryPlayer];//关闭播放器
                [self rtcEngineJoinChannel];//进入rtc房间
            }
            
            //被抱麦了
            else if (micInfo.micReason == NTESMicReasonConnectInvited){
                NELPLogInfo(@"[demo] YAT be on mic");
                NELP_AUTHORITY_CHECK;
                NSString *msg = [NSString stringWithFormat:@"您已被主播抱上\"麦位%d\"\n现在可以进行语音互动啦\n如需下麦，可点击自己的头像或者下麦按钮",
                                 (int)micInfo.micOrder];
                [NTESProgressHUD ntes_showInfo:msg];
                [[NERtcEngine sharedEngine] enableLocalAudio:YES];
                [self destoryPlayer];//关闭播放器
                [self rtcEngineJoinChannel];//进入rtc房间
            }
            
            //恢复语音
            else if (micInfo.micReason == NTESMicReasonResumeMasked) {
                NELPLogInfo(@"[demo] YAT be resume masked");
                [[NERtcEngine sharedEngine] muteLocalAudio:NO];
                [NTESChatroomAlertView showAlertWithMessage:@"该麦位被主播\"解除语音屏蔽\"\n现在您可以在此进行语音互动了"];
                _dataSource.isMasked = NO;
            }
            //刷新布局
            _roomfooterView.userMode = NTESUserModeConnector;
            _dataSource.userMode = NTESUserModeConnector;
        }
            break;
        case NTESMicStatusClosed:
            _roomfooterView.userMode = NTESUserModeAudience;
            _dataSource.userMode = NTESUserModeAudience;
            if (micInfo.micReason == NTESMicReasonConnectRejected){
                NELPLogInfo(@"[demo] YAT be rejected");
                [self.view dismissToast];
                [NTESChatroomAlertView showAlertWithMessage:@"你的申请已被拒绝"];
            }
            break;
        case NTESMicStatusMasked:
            _roomfooterView.userMode = NTESUserModeAudience;
            _dataSource.userMode = NTESUserModeAudience;
            
            //主动下麦
            if (micInfo.micReason == NTESMicReasonDropMic) {
                NELPLogInfo(@"[demo] YAT drop mic");
                [[NERtcEngine sharedEngine] enableLocalAudio:NO];
            }
            //被踢了
            if (micInfo.micReason == NTESMicReasonMicKicked){
                NELPLogInfo(@"[demo] YAT be kicked from maked");
                [NTESChatroomAlertView showAlertWithMessage:@"您已被主播踢下麦"];
            }
            //被拒绝了
            else if (micInfo.micReason == NTESMicReasonConnectRejected){
                NELPLogInfo(@"[demo] YAT be rejected");
                [self.view dismissToast];
                [NTESChatroomAlertView showAlertWithMessage:@"你的申请已被拒绝"];
            }
            //取消申请了
            else if (micInfo.micReason == NTESMicReasonCancelConnect){
                NELPLogInfo(@"[demo] YAT cancel connect");
                [self.view dismissToast];
                [self.view showToastWithMessage:@"已取消申请上麦" state:NTESToastStateSuccess];
            }
            break;
        case NTESMicStatusConnectFinishedWithMuted:
            if (micInfo.micReason == NTESMicReasonResumeMasked) {
                NELPLogInfo(@"[demo] YAT be resume masked to NTESMicStatusConnectFinishedWithMuted");
                [[NERtcEngine sharedEngine] enableLocalAudio:YES];
                [[NERtcEngine sharedEngine] muteLocalAudio:NO];
                [NTESChatroomAlertView showAlertWithMessage:@"该麦位被主播\"解除语音屏蔽\"\n现在您可以在此进行语音互动了"];
                _dataSource.isMasked = NO;
            }
            _roomfooterView.userMode = NTESUserModeConnector;
            _dataSource.userMode = NTESUserModeConnector;
            break;
        case NTESMicStatusConnectFinishedWithMutedAndMasked:
        case NTESMicStatusConnectFinishedWithMasked: {
            [self.view dismissToast];
            if (!_dataSource.isMasked) {
                NELPLogInfo(@"[demo] YAT be masked to %d", (int)micInfo.micStatus);
                [[NERtcEngine sharedEngine] enableLocalAudio:YES];
                [[NERtcEngine sharedEngine] muteLocalAudio:YES];
                [NTESChatroomAlertView showAlertWithMessage:@"该麦位被主播\"屏蔽语音\"\n现在您已无法进行语音互动"];
                _roomfooterView.userMode = NTESUserModeConnector;
                _dataSource.userMode = NTESUserModeConnector;
                _dataSource.isMasked = YES;
            }
        }
            break;
        default:
            break;
    }
    YXAlogInfo(@"更新个人麦位信息, micInfo: %@, thread: %@", [micInfo copy], [NSThread currentThread]);
    _dataSource.myMicInfo = [micInfo copy];
}

//批准上麦
- (void)didAllowOnMicWithInfo:(NTESMicInfo *)micInfo {
    NTESMicInfo *curMicInfo = nil;
    if (micInfo.micOrder > 0 && micInfo.micOrder <= _dataSource.micInfoArray.count) {
        curMicInfo = _dataSource.micInfoArray[micInfo.micOrder - 1];
    }
    
    //异常：该麦位已经有人上了，不能再批准了
    if ([curMicInfo isOnMicStatus]) {
        NSString *msg = [NSString stringWithFormat:@"批准失败，麦位%d已经有人在上麦",
                         (int)micInfo.micOrder];
        [self.view makeToast:msg duration:1 position:CSToastPositionCenter];
        return;
    }
    
    //正常批准
    if (micInfo.micStatus == NTESMicStatusConnecting) {
        if (curMicInfo.micReason == NTESMicReasonMicMasked
            || micInfo.micStatus == NTESMicReasonMicMasked) { //异常情况，在申请到过程中，micInfo被其他事情更新了
            micInfo.micStatus = NTESMicStatusConnectFinishedWithMasked;
        } else {
            micInfo.micStatus = NTESMicStatusConnectFinished;
        }
        micInfo.micReason = NTESMicReasonConnectAccepted;
    }
    
    [_dataSource.connectorArray removeObject:micInfo];
    
    //移除其他的同麦位申请者
    NSMutableIndexSet *delIndexs = [NSMutableIndexSet indexSet];
    [_dataSource.connectorArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NTESMicInfo *info = (NTESMicInfo *)obj;
        if (info.micOrder == micInfo.micOrder
            || [info.userInfo.account isEqualToString:micInfo.userInfo.account]) { //相同麦位的都移除
            [delIndexs addIndex:idx];
        }
    }];
    if (delIndexs.count != 0) {
        [_dataSource.connectorArray removeObjectsAtIndexes:delIndexs];
    }
    
    [self.connectListView refreshWithDataArray:_dataSource.connectorArray];
    [self didUpdateChatroomQueueWithMicInfo:micInfo];//更新聊天室队列
    
    //弹幕
    NSString *msg = [NSString stringWithFormat:@"\"%@\"加入了麦位%d",
                     micInfo.userInfo.nickName, (int)micInfo.micOrder];
    [NTESChatroomMessageHelper sendSystemMessage:_dataSource.chatroom.roomId
                                            text:msg];
}

//拒绝申请
- (void)didRejectOnMicWithInfo:(NTESMicInfo *)micInfo {
    NTESMicInfo *curMicInfo = _dataSource.micInfoArray[micInfo.micOrder - 1];
    if (curMicInfo.micStatus == NTESMicStatusClosed) {
        micInfo.micStatus = NTESMicStatusClosed;
    } else {
        if (micInfo.micReason == NTESMicReasonMicMasked) {
            micInfo.micStatus = NTESMicStatusMasked;
        } else {
            micInfo.micStatus = NTESMicStatusNone;
        }
    }
    micInfo.micReason = NTESMicReasonConnectRejected;
    [_dataSource.connectorArray removeObject:micInfo];
    [self.connectListView refreshWithDataArray:_dataSource.connectorArray];
    
    //更新聊天室队列
    [self didUpdateChatroomQueueWithMicInfo:micInfo];
}

//抱麦
- (void)didInviteeUserToMicInfo:(NTESMicInfo *)dstMicInfo
{
    NIMChatroomMembersByIdsRequest *request = [[NIMChatroomMembersByIdsRequest alloc] init];
    request.roomId = _dataSource.chatroom.roomId;
    request.userIds = @[dstMicInfo.userInfo.account];
    [[NIMSDK sharedSDK].chatroomManager fetchChatroomMembersByIds:request completion:^(NSError * _Nullable error, NSArray<NIMChatroomMember *> * _Nullable members) {
        if (error) {
            YXAlogInfo(@"获取聊天室成员失败, error: %@", error);
            [NTESProgressHUD ntes_showError:@"操作失败: 获取聊天室成员失败!"];
            return;
        }
        
        BOOL exist = [members count] > 0;
        if (!exist) {
            YXAlogInfo(@"抱麦失败, 用户已离开直播间, userId: %@", dstMicInfo.userInfo.account);
            [NTESProgressHUD ntes_showError:@"操作失败: 用户已离开直播间!"];
            return;
        }
        
        ntes_main_async_safe(^{
            [self _inviteeUserToMicInfo:dstMicInfo];
        });
    }];
}

- (void)_inviteeUserToMicInfo:(NTESMicInfo *)dstMicInfo
{
    YXAlogInfo(@"申请的麦位信息: micInfo: %@", dstMicInfo);
    //member 是否在申请列表中
    NTESMicInfo *srcMicInfo = [_dataSource userInfoOnConnectorArray:dstMicInfo.userInfo.account];
    if (!srcMicInfo) //不在申请列表里，正常抱麦
    {
        if (dstMicInfo.micStatus == NTESMicStatusMasked) {
            dstMicInfo.micStatus = NTESMicStatusConnectFinishedWithMasked;
        } else {
            dstMicInfo.micStatus = NTESMicStatusConnectFinished;
        }
        dstMicInfo.micReason = NTESMicReasonConnectInvited;
        [self didUpdateChatroomQueueWithMicInfo:dstMicInfo];
        
        //UI
        NSString *msg = [NSString stringWithFormat:@"已将\"%@\"抱上麦位", dstMicInfo.userInfo.nickName];
        [self.view makeToast:msg duration:1 position:CSToastPositionCenter];
        msg = [NSString stringWithFormat:@"\"%@\"进入了麦位%d",
               dstMicInfo.userInfo.nickName, (int)dstMicInfo.micOrder];
        [NTESChatroomMessageHelper sendSystemMessage:_dataSource.chatroom.roomId text:msg];
        
        //清理其他申请该麦位的人
        [_dataSource cleanConnectorOnMicOrder:dstMicInfo.micOrder];
        [_connectListView refreshWithDataArray:_dataSource.connectorArray];
    }
    else //在申请列表里，批准到dstMicInfo麦位
    {
        //异常情况兼容：多人同时申请一个麦位的情况，这时将原来麦位的状态更新到下一个申请这个麦位的人的状态
        __block NTESMicInfo *nextConnectMicInfo = nil;
        [_dataSource.connectorArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NTESMicInfo *temp = (NTESMicInfo *)obj;
            if (temp.micOrder == srcMicInfo.micOrder
                && ![temp.userInfo.account isEqualToString:srcMicInfo.userInfo.account]) {
                srcMicInfo.micOrder = temp.micOrder;
                srcMicInfo.micStatus = temp.micStatus;
                srcMicInfo.micReason = temp.micReason;
                srcMicInfo.userInfo = [temp.userInfo copy];
            }
        }];
        if (nextConnectMicInfo) { //存在这样的异常情况
            srcMicInfo = nextConnectMicInfo;
        } else {  //不存在这样的情况，正常的麦位更新
            if (srcMicInfo.micReason == NTESMicReasonMicMasked) {
                srcMicInfo.micStatus = NTESMicStatusMasked;
            } else {
                srcMicInfo.micStatus = NTESMicStatusNone;
            }
            srcMicInfo.micReason = NTESMicStatusNone;
        }
        
        //更新用户申请的麦位状态
        [self didUpdateChatroomQueueWithMicInfo:srcMicInfo];
        
        //批准新麦位
        dstMicInfo.micStatus = NTESMicStatusConnecting;
        [self didAllowOnMicWithInfo:dstMicInfo];
    }
}

#pragma mark - NTESMoreSettingDelegate

- (void)didSetMicOn:(BOOL)micOn
{
    [self didMicMute:!micOn];
}

//麦克静音
- (void)didMicMute:(BOOL)mute {
    self.dataSource.rtcConfig.micOn = !mute;
    if (_dataSource.userMode == NTESUserModeAnchor) {
        [NTESChatroomInfoHelper updateChatroom:_dataSource.chatroom //修改房间的信息
                           anchorMicMuteStatus:mute];
    } else {
        NTESMicInfo *micInfo = _dataSource.myMicInfo;
        if (mute) {
            if (_dataSource.isMasked) {
                micInfo.micStatus = NTESMicStatusConnectFinishedWithMutedAndMasked;
            } else {
                micInfo.micStatus = NTESMicStatusConnectFinishedWithMuted;
                micInfo.micReason = NTESMicReasonNone;
            }
        } else {
            if (_dataSource.isMasked) {
                micInfo.micStatus = NTESMicStatusConnectFinishedWithMasked;
                micInfo.micReason = NTESMicReasonNone;
            } else {
                micInfo.micStatus = NTESMicStatusConnectFinished;
                micInfo.micReason = NTESMicReasonNone;
            }
        }
        micInfo.isMicMute = mute;
        [self didUpdateChatroomQueueWithMicInfo:micInfo];
    }
    NSString *msg = (mute ? @"话筒已关闭" : @"话筒已打开");
    [self.view makeToast:msg duration:1 position:CSToastPositionCenter];
}

//声音静音
- (void)didSoundMute:(BOOL)mute {
    if (_dataSource.userMode == NTESUserModeAnchor) {
        _dataSource.isAllSoundMute = mute;
    }
    
    if (self.pushType == NTESPushTypeCdn && self.dataSource.userMode == NTESUserModeAudience) {
        [self.audioPlayer setMute:mute];
    }
    NSString *msg = (mute ? @"声音已关闭" : @"声音已打开");
    [self.view makeToast:msg duration:1 position:CSToastPositionCenter];
}


- (void)didToolBarSendText:(NSString *)text {
    if (isEmptyString(text)) {
        [NTESProgressHUD ntes_showInfo:@"发送内容为空"];
        return;
    }
    if (_dataSource.userMode == NTESUserModeAnchor) {
        NIMMessage *textMessage = [[NIMMessage alloc] init];
        textMessage.text = text;
        NIMSession *session = [NIMSession session:_dataSource.chatroomInfo.roomId type:NIMSessionTypeChatroom];
        [[NIMSDK sharedSDK].chatManager sendMessage:textMessage toSession:session error:nil];
    } else {
        if (_dataSource.isMuteAll || _dataSource.meIsMute) {
            [self.view makeToast:@"您已被禁言" duration:1 position:CSToastPositionCenter];
        } else {
            NIMMessage *textMessage = [[NIMMessage alloc] init];
            textMessage.text = text;
            NIMSession *session = [NIMSession session:_dataSource.chatroomInfo.roomId type:NIMSessionTypeChatroom];
            [[NIMSDK sharedSDK].chatManager sendMessage:textMessage toSession:session error:nil];
        }
    }
}


#pragma mark - NTESLiveRoomHeaderDelegate

- (void)liveRoomHeaderDidReceiveExitAction {
    
    if (_dataSource.userMode == NTESUserModeAnchor) {
        [self.alerView showWithTypes:@[@(NTESAlertActionTypeExistRoom)] info:_dataSource.myMicInfo];
        return;
    }
    [self _exitChatroomWithUserMode:self.dataSource.userMode
                            creator:self.dataSource.chatroom.creator
                            micInfo:self.dataSource.myMicInfo];
    
}



#pragma mark - NETSFunctionAreaDelegate

- (void)footerInputViewDidClickAction {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.keyboardView becomeFirstResponse];
    });
}

//点歌事件
- (void)footerDidReceiveRequestSongAciton {
    NTESPickSongVC *pickSongVc = [[NTESPickSongVC alloc] initWithService:_dataSource.pickService];
    NTESActionSheetNavigationController *nav = [[NTESActionSheetNavigationController alloc] initWithRootViewController:pickSongVc];
    nav.dismissOnTouchOutside = YES;
    [self presentViewController:nav animated:YES completion:nil];
}

//麦克静音事件
- (void)footerDidReceiveMicMuteAction:(BOOL)mute {
    [self didMicMute:mute];
}

//禁言事件
- (void)footerDidReceiveNoSpeekingAciton {
    [self goMuteListVC];
}

//menu点击事件
- (void)footerDidReceiveMenuClickAciton {
    NTESMoreViewController *moreVc = [[NTESMoreViewController alloc] initWithContext:self.dataSource];
    moreVc.delegate = self;
    NTESActionSheetNavigationController *nav = [[NTESActionSheetNavigationController alloc] initWithRootViewController:moreVc];
    nav.dismissOnTouchOutside = YES;
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark - NTESMicInviteeListViewControllerDelegate
- (void)onSelectInviteeUserWithMicInfo:(NTESMicInfo *)micInfo {
    [self didInviteeUserToMicInfo:micInfo];
}

#pragma mark - NTESConnectListViewDelegate
- (void)onAcceptBtnPressedWithMicInfo:(NTESMicInfo *)micInfo {
    [self didAllowOnMicWithInfo:micInfo];
}

- (void)onRejectBtnPressedWithMicInfo:(NTESMicInfo *)micInfo {
    [self didRejectOnMicWithInfo:micInfo];
}

#pragma mark - <NTESSettingPanelDelegate>

- (void)setEarbackEnable:(BOOL)enable
{
    _enableEarback = enable;
    [[NERtcEngine sharedEngine] enableEarback:enable volume:100];
}

- (void)setGatherVolume:(CGFloat)volume
{
    _gatherVolume = volume;
    [[NERtcEngine sharedEngine] adjustRecordingSignalVolume:_gatherVolume];
}

#pragma mark - <NTESMuteListVCDelegate>
- (void)didMuteMember:(NIMChatroomMember *)member mute:(BOOL)mute {
    NIMChatroomMemberUpdateRequest *request = [[NIMChatroomMemberUpdateRequest alloc] init];
    request.roomId = _dataSource.chatroom.roomId;
    request.userId = member.userId;
    request.enable = mute;
    [[NIMSDK sharedSDK].chatroomManager updateMemberTempMute:request
                                                    duration:60*60*24*30
                                                  completion:^(NSError * _Nullable error) {
        if (error) {
            NELPLogInfo(@"禁言失败,[%@]!", error);
        }
    }];
}

- (void)didMuteAll:(BOOL)mute vc:(NTESMuteListViewController *)vc {
    NSString *sid = _dataSource.myAccountInfo.account;
    NSString *roomId = _dataSource.chatroom.roomId;
    __weak typeof(self) weakSelf = self;
    [[NTESDemoService sharedService] muteChatroomWithSid:sid
                                                  roomId:[roomId integerValue]
                                                    mute:mute
                                              completion:^(NSError *error) {
          if (!error) {
              NSString *msg = (mute ? @"已全部禁言" : @"已取消全部禁言");
              [NTESProgressHUD ntes_showInfo:msg];
              weakSelf.dataSource.isMuteAll = mute;
              [weakSelf updateInputView];
              [vc reloadWithChatroomMute:weakSelf.dataSource.isMuteAll];
          } else {
              NELPLogInfo(@"聊天室禁言失败!%@", error);
          }
    }];
}

#pragma mark - NERtcEngineDelegate

- (void)onNERTCEngineLiveStreamState:(NERtcLiveStreamStateCode)state taskID:(NSString *)taskID url:(NSString *)url
{
    switch (state) {
        case kNERtcLsStatePushing:
            NELPLogDebug(@"Pushing stream for task [%@]", taskID);
            break;
        case kNERtcLsStatePushStopped:
            NELPLogDebug(@"Stream for task [%@] stopped", taskID);
            break;
        case kNERtcLsStatePushFail:{
            NELPLogDebug(@"Stream for task [%@] failed", taskID);
            if (self.pushType == NTESPushTypeCdn && self.liveStreamTask) {
                int ret = [NERtcEngine.sharedEngine removeLiveStreamTask:self.liveStreamTask.taskID compeltion:^(NSString * _Nonnull taskId, kNERtcLiveStreamError errorCode) {
                    if (errorCode == 0) {
                      //移除成功
                        self.liveStreamTask = nil;
                        [self addLiveStream:self.dataSource.chatroomInfo.configModel.pushUrl];//重新推流
                    }
                }];
                 if (ret != 0) {
                     NELPLogInfo(@"移除任务失败");
                 }
            }
   
        }
            break;
        default:
            NELPLogDebug(@"Unknown state for task [%@]", taskID);
            break;
    }
    
    
    
    
}

- (void)onNERtcEngineUserAudioDidStart:(uint64_t)userID
{
    [[NERtcEngine sharedEngine] subscribeRemoteVideo:YES forUserID:userID streamType:kNERtcRemoteVideoStreamTypeLow]; // SEI功能需要订阅视频流
    [[NERtcEngine sharedEngine] subscribeRemoteAudio:YES forUserID:userID];
}

- (void)onNERtcEngineUserDidJoinWithUserID:(uint64_t)userID userName:(NSString *)userName
{
    NELPLogDebug(@"userID: %lld, userName: %@", userID, userName);
    if (self.pushType == NTESPushTypeCdn) {
        [self addAudienceUid:userID];
        [self updateLiveStreamTask];//更新推流任务
    }
}

- (void)onNERtcEngineUserDidLeaveWithUserID:(uint64_t)userID reason:(NERtcSessionLeaveReason)reason
{
    NELPLogDebug(@"userID: %lld, reason: %ld", userID, (long)reason);
    if (self.pushType == NTESPushTypeCdn) {
        [self deleteAudienceUid:userID];
        [self updateLiveStreamTask];//更新推流任务
    }
}


- (void)onNERtcEngineDidDisconnectWithReason:(NERtcError)reason {
    //主要用于断网时，退出频道和pop掉当前页面
    [NERtcEngine.sharedEngine leaveChannel];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)onAudioMixingTimestampUpdate:(uint64_t)timeStampMS {
    if (self.roomType == NTESCreateRoomTypeKTV && [self.dataSource.pickService.pickSongs.firstObject.userId isEqualToString:NIMSDK.sharedSDK.loginManager.currentAccount]) { // 只有演唱者才发送SEI
        NSDictionary *dict = @{@"audio_mixing_pos": @(timeStampMS)};
        NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
        [NERtcEngine.sharedEngine sendSEIMsg:data];
        self.dataSource.pickService.musicPosition = timeStampMS;
    }
}

- (void)onAudioMixingStateChanged:(NERtcAudioMixingState)state errorCode:(NERtcAudioMixingErrorCode)errorCode {
    if (self.roomType == NTESCreateRoomTypeKTV && state == kNERtcAudioMixingStateFinished && errorCode == kNERtcAudioMixingErrorOK) {
        self.dataSource.pickService.musicPosition = 0;
        [self.dataSource.pickService removeTopMusicWithSuccessBlock:nil failedBlock:nil];
    }
}

- (void)onNERtcEngineRecvSEIMsg:(uint64_t)userID message:(NSData *)message {
    NSError *error;
    NSDictionary *JSONObject = [NSJSONSerialization JSONObjectWithData:message options:0 error:&error];
    if (error) {
        return NELPLogError(@"Error decode SEI message: %@", error);
    }
    uint32_t musicPosition = (uint32_t)[JSONObject[@"audio_mixing_pos"] integerValue];
    // Bug: 播放者首次暂停，接收方首次进入房间会收到一次被覆盖掉的SEI
    self.dataSource.pickService.musicPosition = MAX(musicPosition, self.dataSource.pickService.pickSongs.firstObject.timestamp);
}

- (void)onNERtcEngineDidLeaveChannelWithResult:(NERtcError)result {
    if (self.pushType == NTESPushTypeCdn && _dataSource.userMode == NTESUserModeAudience && result == kNERtcNoError) {
        [self pullStreamTask];//下麦后在拉流
    }
}
#pragma mark - NTESChatroomNotificationHandlerDelegate
- (void)didShowMessages:(NSArray<NIMMessage *> *)messages {
    [self.messageContentView addMessages:messages];
}

- (void)didReceiveCustomMessage:(NIMMessage *)customMessage {
    
    NTESCustomAttachment* attachment = [NTESCustomAttachment getAttachmentWithMessage:customMessage];
    if (!attachment) return;
    if (attachment.type == NTESVoiceChatAttachmentTypePullStream) {
        [self pullStreamTask];//重新拉流
    } else if (attachment.type == NTESVoiceChatAttachmentTypePauseMusic) {
        self.dataSource.pickService.pickSongs.firstObject.status = 1;
        [NSNotificationCenter.defaultCenter postNotificationName:kNTESChatroomPauseMusicNotification object:nil userInfo:@{kNTESChatroomPauseMusicOperatorUserInfoKey: attachment.operator?:@""}];
    } else if (attachment.type == NTESVoiceChatAttachmentTypeResumeMusic) {
        self.dataSource.pickService.pickSongs.firstObject.status = 0;
        [NSNotificationCenter.defaultCenter postNotificationName:kNTESChatroomResumeMusicNotification object:nil userInfo:@{kNTESChatroomResumeMusicOperatorUserInfoKey: attachment.operator?:@""}];
    }
}

- (void)didReceiveRequestConnect:(NTESMicInfo *)micInfo;
{
    NSInteger micOrder = micInfo.micOrder;
    NTESMicInfo *curMicInfo = _dataSource.micInfoArray[micOrder - 1];
    if (curMicInfo.micStatus == NTESMicStatusClosed) { //麦位已经关闭，又来同麦位申请，直接拒绝吧
        [self didRejectOnMicWithInfo:micInfo];
        return;
    } else if (curMicInfo.micStatus == NTESMicStatusMasked) { //麦位被屏蔽了
        micInfo.micReason = NTESMicReasonMicMasked;
    } else {
        micInfo.micReason = NTESMicReasonNone;//正常上麦
    }
    micInfo.micStatus = NTESMicStatusConnecting;

    //消息去重处理
    if (![self.notificationIdArray containsObject:micInfo.notificationId]) {
        [self.notificationIdArray addObject:micInfo.notificationId];
        [_dataSource.connectorArray addObject:micInfo];
    }
    //加入请求连麦队列
//    [_dataSource.connectorArray addObject:micInfo];
    [self.connectListView refreshWithDataArray:_dataSource.connectorArray];
    
    //更新队列
    [self didUpdateChatroomQueueWithMicInfo:micInfo];
    
    //弹出提示框
    [self.connectListView showAsAlertOnView:self.view];
}

- (void)didReceiveMicBeDropped:(NTESMicInfo *)micInfo
{
    NSInteger micOrder = micInfo.micOrder;
    if (!(micOrder > 0 && micOrder < [_dataSource.micInfoArray count])) {
        return;
    }
    NTESMicInfo *curMicInfo = _dataSource.micInfoArray[micOrder - 1];

    if (![curMicInfo isOnMicStatus]) {
        return;
    }

    if (curMicInfo.micStatus == NTESMicStatusConnectFinishedWithMasked) {
        micInfo.micStatus = NTESMicStatusMasked;
    } else {
        micInfo.micStatus = NTESMicStatusNone;
    }
    micInfo.micReason = NTESMicReasonDropMic;
    //更新聊天室队列
    [self didUpdateChatroomQueueWithMicInfo:micInfo];

    //弹幕
    NSString *msg = [NSString stringWithFormat:@"\"%@\"离开了麦位%d",
                     curMicInfo.userInfo.nickName, (int)curMicInfo.micOrder];
    [NTESChatroomMessageHelper sendSystemMessage:_dataSource.chatroom.roomId
                                            text:msg];
}

- (void)didReceiveConnectBeCanceled:(NTESMicInfo *)micInfo
{
    NSInteger micOrder = micInfo.micOrder;
    NTESMicInfo *curMicInfo = _dataSource.micInfoArray[micOrder - 1];

    if (curMicInfo.micStatus != NTESMicStatusConnecting) {
        return;
    }

    if (curMicInfo.micReason == NTESMicReasonMicMasked) {
        micInfo.micStatus = NTESMicStatusMasked;
    } else {
        micInfo.micStatus = NTESMicStatusNone;
    }
    micInfo.micReason = NTESMicReasonCancelConnect;

    //先从请求连麦的队列里扔掉
    BOOL isExist = NO;
    NSMutableArray *temConnectorArray = [_dataSource.connectorArray mutableCopy];
    for (int i = 0; i < _dataSource.connectorArray.count; i++) {
        NTESMicInfo *temMicInfo = [_dataSource.connectorArray objectAtIndex:i];
        if (temMicInfo.micOrder == micInfo.micOrder) {
            [temConnectorArray removeObjectAtIndex:i];
            isExist = YES;
            break;
        }
    }

    if (isExist) {
        _dataSource.connectorArray = temConnectorArray;
        [self.connectListView refreshWithDataArray:_dataSource.connectorArray];
        //更新聊天室队列
        [self didUpdateChatroomQueueWithMicInfo:micInfo];
    }
}

 //更新连麦队列
- (void)didUpdateChatroomQueueWithMicInfokey:(NSString *)key
                                micInfoValue:(NSString *)value
                                  changeType:(NIMChatroomQueueChangeType)changeType
 {
     NELPLogInfo(@"[demo] didUpdateChatroomQueueWithMicInfo");
     
     if ([key hasPrefix:@"music_"]) {
         [self.dataSource.pickService didChangedMusicWithKey:key value:value type:changeType complation:^(NSError * _Nullable error) {
             YXAlogInfo(@"处理队列音乐变更结果, error: %@", error);
         }];
         return;
     }
     ntes_main_async_safe(^{
         //获取更新的信息
         NTESMicInfo *micInfo = [NTESChatroomQueueHelper micInfoByChatroomQueueValue:value];
         if (self->_dataSource.userMode == NTESUserModeAnchor
             && micInfo.micOrder == self->_selectMicOrder) {
             [self->_alerView dismiss];
         }
         
         //更新自己的信息
         if ([micInfo.userInfo.account isEqualToString:self->_dataSource.myAccountInfo.account]) {
             [self didUpdateMyMicInfo:micInfo];
         } else { //异常：其他上了自己申请麦位
             if ((micInfo.micReason == NTESMicReasonConnectAccepted || micInfo.micReason == NTESMicReasonConnectInvited)
                 && self->_dataSource.myMicInfo.micStatus == NTESMicStatusConnecting
                 && micInfo.micOrder == self->_dataSource.myMicInfo.micOrder) {
                 [self.view dismissToast];
                 [self.view makeToast:@"该麦位已被其他人上麦" duration:1 position:CSToastPositionCenter];
                 self->_dataSource.myMicInfo.micStatus = NTESMicStatusNone;
                 self->_dataSource.myMicInfo.micReason = NTESMicReasonNone;
             }
         }
         
         self.dataSource.micInfoArray[micInfo.micOrder - 1] = micInfo;
         
         //更新mic队列
         if (micInfo.micOrder > 0 && micInfo.micOrder <= self->_dataSource.micInfoArray.count) {
             self.dataSource.micInfoArray[micInfo.micOrder - 1] = micInfo;
         } else {
             NELPLogError(@"[demo] update queue micinfo error, micorder [%d] error!", (int)micInfo.micOrder);
         }
         YXAlogInfo(@"刷新麦位视图: micInfo: %@, thread: %@", micInfo, [NSThread currentThread]);
         [self.micQueueView updateCellWithMicInfo:micInfo];
         // 连麦者下麦,移除其所点歌曲
         if (micInfo.micStatus == NTESMicStatusNone) {
             [self.dataSource.pickService removeMusicWithAccountId:micInfo.userInfo.account serverSensitive:NO];
         }
     });
 }

 - (void)didUpdateChatroomQueueWithMicInfo:(NTESMicInfo *)micInfo {
     if (!micInfo) {
         return;
     }
     
     NSString *roomId = _dataSource.chatroom.roomId;
     [NTESChatroomQueueHelper updateChatroomQueueWithRoomId:roomId
                                                    micInfo:micInfo
                                                 complation:^(NSError * _Nullable error) {
         if (error) {
             YXAlogInfo(@"更新麦位操作失败");
         }
     }];
 }

 - (void)didChatroomMember:(NIMChatroomNotificationMember *)member enter:(BOOL)enter { //进入或离开房间
     BOOL isMyAccount = [member.userId isEqualToString:_dataSource.myAccountInfo.account];
     if (!isMyAccount) {
         if (enter) {
             _dataSource.chatroomInfo.onlineUserCount++;
             NELPLogInfo(@"[demo] user %@ enter room.", member.userId);
         } else {
             _dataSource.chatroomInfo.onlineUserCount--;
             NELPLogInfo(@"[demo] user %@ leaved room.", member.userId);
         }
     }
     self.roomHeaderView.chatroomInfo = _dataSource.chatroomInfo;//老逻辑
     
     NSString *text = [NSString stringWithFormat:@"\"%@\" %@房间", member.nick, (enter ? @"加入":@"离开")];
     NIMMessage *message = [NTESChatroomMessageHelper systemMessageWithText:text];
     [_messageContentView addMessages:@[message]];

     if (_dataSource.userMode == NTESUserModeAnchor) {
         //清理请求连麦列表
         __block NTESMicInfo *micInfo = [_dataSource userInfoOnConnectorArray:member.userId];
         if (micInfo) {
             [_dataSource.connectorArray removeObject:micInfo];
             [_connectListView refreshWithDataArray:_dataSource.connectorArray];
         }
         ntes_main_async_safe(^{
             //清理已经上麦的人
             [_dataSource.micInfoArray enumerateObjectsUsingBlock:^(NTESMicInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                 if ([obj.userInfo.account isEqualToString:member.userId]) {
                     micInfo = obj;
                     *stop = YES;
                 }
             }];
             if (!enter) {
                 micInfo.micStatus = NTESMicStatusNone;
                 micInfo.micReason = NTESMicReasonDropMic;
             }
             YXAlogInfo(@"%@ idx: %d", text, (micInfo.micOrder - 1));
             [self didUpdateChatroomQueueWithMicInfo:micInfo];
         });
     }
 }

 - (void)didChatroomMember:(NIMChatroomNotificationMember *)member mute:(BOOL)mute { //禁言某个人
     NSString *text = [NSString stringWithFormat:@"\"%@\" %@", member.nick, (mute?@"被禁言":@"恢复发言")];
     NIMMessage *message = [NTESChatroomMessageHelper systemMessageWithText:text];
     [_messageContentView addMessages:@[message]];
     if ([member.userId isEqualToString:_dataSource.myAccountInfo.account]) {
         _dataSource.meIsMute = mute;
         [self updateInputView];
     }
 }

 - (void)didChatroomMute:(BOOL)mute { //聊天室禁言
     NSString *text = (mute ? @"聊天室 被禁言" : @"聊天室 解除禁言");
     NIMMessage *message = [NTESChatroomMessageHelper systemMessageWithText:text];
     [_messageContentView addMessages:@[message]];
     _dataSource.isMuteAll = mute;
     
     //提示
     text = [NSString stringWithFormat:@"主播已%@\"全部禁言\"", mute ? @"开启" : @"关闭"];
     [self.view makeToast:text duration:1 position:CSToastPositionCenter];
     
     //输入框
     [self updateInputView];
 }

 - (void)didChatroomClosed { //房间关闭
     [_playerManager stop];
     [[NERtcEngine sharedEngine] leaveChannel];
//     if (_delegate && [_delegate respondsToSelector:@selector(didRoomClosed:)]) {
//         [_delegate didRoomClosed:_dataSource.chatroomInfo];
//     }
     
     [self dismissViewControllerAnimated:YES completion:nil];
     [self.navigationController popViewControllerAnimated:YES];
 }

- (void)didChatroomEnter {
    NIMChatroom *chatroom = self.dataSource.chatroom;
    NTESChatroomInfo *roomInfo = self.dataSource.chatroomInfo;
    [roomInfo updateByChatroom:chatroom];
    self.dataSource.chatroomInfo = roomInfo;
    
    self.dataSource.isMuteAll = [chatroom inAllMuteMode];
    //            wself.headerView.chatroomInfo = wself.dataSource.chatroomInfo;//旧逻辑
    if (self.dataSource.userMode == NTESUserModeAnchor) {
        [self updateChatroomExtWithChatroom:chatroom
                                        info:roomInfo];
        [self joinMeeting];
    } else {
        [self updateChatroomInfoWithChatroom:chatroom];
        [self joinMeeting];
    }
    [self fetchChatroomQueue];
    [self fetchCreaterInfo];
}

 - (void)didChatroomAnchorMicMute:(BOOL)micMute { //主播关闭话筒
     self.dataSource.chatroomInfo.micMute = micMute;
//     _headerView.chatroomInfo = _dataSource.chatroomInfo;//老逻辑
 }

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NIMSDK sharedSDK].chatManager removeDelegate:self.handler];
    [[NIMSDK sharedSDK].chatroomManager removeDelegate:self.handler];
    [[NIMSDK sharedSDK].systemNotificationManager removeDelegate:self.handler];
    [[NERtcEngine sharedEngine] leaveChannel];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
       [NERtcEngine destroyEngine];
    });
}

#pragma mark - NTESMicQueueViewDelegate

- (void)micQueueConnectBtnPressedWithMicInfo:(NTESMicInfo *)micInfo
{
    if (!micInfo) {
        return;
    }
    if (_dataSource.userMode == NTESUserModeAnchor) {
        NSArray *actionTypes = nil;
        switch (micInfo.micStatus) {
            case NTESMicStatusNone:{
                actionTypes = @[@(NTESAlertActionTypeInviteMic),
                                @(NTESAlertActionTypeMaskMic),
                                @(NTESAlertActionTypeCloseMic)];
                break;
            }
            case NTESMicStatusConnectFinished:
            case NTESMicStatusConnectFinishedWithMuted: {
                actionTypes = @[@(NTESAlertActionTypeKickMic),
                                @(NTESAlertActionTypeFinishedMaskMic)];
                break;
            }
            case NTESMicStatusClosed: {
                actionTypes = @[@(NTESAlertActionTypeOpenMic)];
                break;
            }
            case NTESMicStatusMasked:{
                actionTypes = @[@(NTESAlertActionTypeInviteMic),
                                @(NTESAlertActionTypeCancelMaskMic)];
                break;
            }
            case NTESMicStatusConnectFinishedWithMasked:
            case NTESMicStatusConnectFinishedWithMutedAndMasked:
            {
                actionTypes = @[@(NTESAlertActionTypeKickMic),
                                @(NTESAlertActionTypeCancelMaskMic)];
                break;
            }
            case NTESMicStatusConnecting://打开连麦列表
            default:
                break;
        }
        _selectMicOrder = micInfo.micOrder;
        [self.alerView showWithTypes:actionTypes info:micInfo];
    }
    else
    {
        if (_dataSource.myMicInfo.micStatus == NTESMicStatusConnecting) { //等待连接中
            return;
        }
        
        if (micInfo.micStatus == NTESMicStatusNone
            || micInfo.micStatus == NTESMicStatusMasked) {
            if ([_dataSource.myMicInfo isOffMicStatus]) { //当前没有上麦
                if (!NELP_AUTHORITY_CHECK) {
                    return;
                }
                //先更新一下本地显示
                micInfo.micStatus = NTESMicStatusConnecting;
                _dataSource.myMicInfo.micStatus = micInfo.micStatus;
                _dataSource.myMicInfo.micOrder = micInfo.micOrder;
                _dataSource.myMicInfo.micReason = micInfo.micReason;
                
                self.micQueueView.datas = _dataSource.micInfoArray;
                
                //发送请求
                [NTESCustomNotificationHelper sendRequestMicNotication:_dataSource.chatroom.creator
                                                               micInfo:micInfo
                                                           accountInfo:_dataSource.myAccountInfo];
                
                //请求等待显示
                __weak typeof(self) weakSelf= self;
                [self.view showToastWithMessage:@"已申请上麦，等待通过..." state:NTESToastCancel cancel:^{
                    [weakSelf.alerView showWithTypes:@[@(NTESAlertActionTypeCancelOnMicRequest)]
                                                info:micInfo];
                }];
            } else {
                [self.view makeToast:@"您正在连麦中，无法申请上麦" duration:1 position:CSToastPositionCenter];
            }
        }
        else if (micInfo.micStatus == NTESMicStatusConnecting) {
            NSString *msg = [NSString stringWithFormat:@"%@ 正在申请该麦位", micInfo.userInfo.nickName];
            [self.view makeToast:msg duration:1 position:CSToastPositionCenter];
        }
        else if (micInfo.micStatus == NTESMicStatusClosed) {
            [self.view makeToast:@"该麦位已关闭" duration:1 position:CSToastPositionCenter];
        }
        else if ([micInfo isOnMicStatus]) {
            if ([micInfo.userInfo.account isEqualToString:_dataSource.myAccountInfo.account]) {//下麦
                [self.alerView showWithTypes:@[@(NTESAlertActionTypeDropMic)]
                                        info:_dataSource.myMicInfo];
            }
        }
    }
}

#pragma mark - Notication
- (void)appReachabilityChanged:(NSNotification *)note {
    [self showNetworkStatus];
}

- (void)appWillEnterForeground:(NSNotification *)note {
    NELP_AUTHORITY_CHECK;
}

- (void)appWillTerminate:(NSNotification *)note {
    if (_dataSource.userMode == NTESUserModeConnector){
        [NTESCustomNotificationHelper sendDropMicNotication:_dataSource.chatroom.creator
                                                    micInfo:_dataSource.myMicInfo completion:nil];
    }
}


#pragma mark - lazyMethod
- (NTESConnectListView *)connectListView {
     if (!_connectListView) {
         _connectListView = [[NTESConnectListView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 0)];
         _connectListView.delegate = self;
         _connectListView.roomId = self.dataSource.chatroomInfo.roomId;
     }
     return _connectListView;
}
     
- (NTESLiveRoomHeaderView *)roomHeaderView {
    if (!_roomHeaderView) {
        _roomHeaderView = [[NTESLiveRoomHeaderView alloc]init];
        _roomHeaderView.chatroomInfo = self.dataSource.chatroomInfo;
        _roomHeaderView.backgroundColor = UIColor.clearColor;
        _roomHeaderView.delegate = self;
    }
    return _roomHeaderView;
}

- (NTESLiveRoomFooterView *)roomfooterView {
    if (!_roomfooterView) {
        _roomfooterView = [[NTESLiveRoomFooterView alloc] initWithContext:self.dataSource];
        _roomfooterView.roomType = self.roomType;
        _roomfooterView.userMode = self.dataSource.userMode;
        _roomfooterView.delegate = self;
    }
    return _roomfooterView;
}

- (UIImageView *)roomBgImageView {
    if (!_roomBgImageView) {
        NSString *bgName = @"";
        if (self.roomType == NTESCreateRoomTypeChatRoom) {
            bgName = @"chatRoom_bgImage_icon";
        }else if (self.roomType == NTESCreateRoomTypeKTV){
            bgName = @"ktv_bgImage_icon";
        }
        _roomBgImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:bgName]];
        _roomBgImageView.frame = self.view.bounds;
        _roomBgImageView.userInteractionEnabled = YES;
    }
    return _roomBgImageView;
}

- (NTESLiveChatView *)messageContentView {
    if (!_messageContentView) {
        _messageContentView = [[NTESLiveChatView alloc] initWithFrame:CGRectMake(0, 0, 100, 200)];
    }
    return _messageContentView;
}

- (NTESChatroomNotificationHandler *)handler {
    if (!_handler) {
        _handler = [[NTESChatroomNotificationHandler alloc]initWithDelegate:self];
        _handler.roomId = self.dataSource.chatroomInfo.roomId;
    }
    return _handler;
}

- (NTESChatroomDataSource *)dataSource {
    if (!_dataSource) {
        _dataSource = [[NTESChatroomDataSource alloc]init];
    }
    return _dataSource;
}

- (NTESMusicPanelViewController *)musicPanelCtrl {
    if (!_musicPanelCtrl) {
        _musicPanelCtrl = [[NTESMusicPanelViewController alloc]initWithContext:self.dataSource];
        _musicPanelCtrl.view.hidden = YES;
    }
    return _musicPanelCtrl;
}

- (UIView<NTESMicQueueViewProtocol> *)micQueueView
{
    if (!_micQueueView) {
        Class cla = (self.roomType == NTESCreateRoomTypeChatRoom) ? [NTESMicQueueView class] : [NTESKtvMicQueueView class];
        _micQueueView = [[cla alloc] init];
        _micQueueView.datas = _dataSource.micInfoArray;
        _micQueueView.delegate = self;
    }
    return _micQueueView;
}

- (NTESChatroomAlertView *)alerView {
    if(!_alerView) {
        NSMutableArray *actions = [self setUpAlertActions];
        _alerView = [[NTESChatroomAlertView alloc] initWithActions:actions];
        __weak typeof(self) weakSelf = self;
        _alerView.cancel = ^{
            weakSelf.selectMicOrder = -1;
        };
    }
    return _alerView;
}

-(NSMutableArray *)notificationIdArray {
    if (!_notificationIdArray) {
        _notificationIdArray = [NSMutableArray array];
    }
    return _notificationIdArray;
}

- (NTESKeyboardToolbarView *)keyboardView {
    if (!_keyboardView) {
        _keyboardView = [[NTESKeyboardToolbarView alloc]initWithFrame:CGRectMake(0, UIScreenHeight, UIScreenWidth, 50)];
        _keyboardView.backgroundColor = UIColor.whiteColor;
        _keyboardView.cusDelegate = self;
    }
    return _keyboardView;
}
@end

