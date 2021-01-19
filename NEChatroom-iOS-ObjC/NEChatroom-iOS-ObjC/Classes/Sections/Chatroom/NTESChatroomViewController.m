//
//  NTESChatroomViewController.m
//  NERtcAudioChatroom
//
//  Created by Simon Blue on 2019/1/18.
//  Copyright © 2019年 netease. All rights reserved.
//

#import "NTESChatroomViewController.h"
#import "NTESMicInviteeListViewController.h"
#import "NTESMuteListViewController.h"
#import "UIView+NTES.h"
#import "UIView+Toast.h"
#import "UIView+NTESToast.h"
#import "NTESChatroomHeaderView.h"
#import "NTESChatroomMicQueueView.h"
#import "NTESConnectListView.h"
#import "NTESLiveChatView.h"
#import "NTESTextInputView.h"
#import "NTESChatroomAlertView.h"
#import "NTESAudioPlayerManager.h"
#import "NTESDemoSystemManager.h"
#import "NTESDemoService.h"
#import "NTESCustomNotificationHelper.h"
#import "NTESChatroomQueueHelper.h"
#import "NTESChatroomDataSource.h"
#import "NTESChatroomNotificationHandler.h"
#import "NTESAuthorityHelper.h"
#import "NSDictionary+NTESJson.h"
#import "NTESJsonUtil.h"
#import <NERtcSDK/NERtcSDK.h>
#import "NTESDemoConfig.h"
#import "NTESSettingPanelView.h"

@interface NTESChatroomViewController ()<NTESChatroomNotificationHandlerDelegate,
                                         NTESMicInviteeListViewControllerDelegate,
                                         NTESChatroomHeaderDelegate,
                                         NTESChatroomMicQueueViewDelegate,
                                         NTESTextInputViewDelegate,
                                         NTESConnectListViewDelegate,
                                         NTESMuteListVCDelegate,
                                         NERtcEngineDelegateEx,
                                         NTESSettingPanelDelegate>
@property (nonatomic,assign) CGRect preRect;
@property (nonatomic,assign) NSTimeInterval lastVolumeMy;
@property (nonatomic,assign) NSTimeInterval lastVolumeRemote;
@property (nonatomic,strong) NTESChatroomDataSource *dataSource; //数据源
@property (nonatomic,strong) NTESChatroomNotificationHandler *handler; //协议处理
@property (nonatomic,strong) NTESChatroomHeaderView *headerView; //头视图
@property (nonatomic,strong) NTESChatroomMicQueueView *micQueueView; //麦位
@property (nonatomic,strong) NTESLiveChatView *chatView; //聊天窗
@property (nonatomic,strong) NTESTextInputView *textInputView; //输入框
@property (nonatomic,strong) NTESConnectListView *connectListView; //连麦列表
@property (nonatomic,strong) NTESAudioPlayerManager *playerManager; //背景音乐播放器
@property (nonatomic,strong) NTESChatroomAlertView *alerView; //alert
@property (nonatomic,readonly) BOOL networkNotReachable;
@property (nonatomic,assign) NSInteger selectMicOrder;
@property (nonatomic,weak) UIAlertController *audioStatusAlert;
@property (nonatomic,assign) BOOL       enableEarback;  // 耳返状态
@property (nonatomic,assign) CGFloat    gatherVolume;   // 采集音量
@end

@implementation NTESChatroomViewController

- (void)dealloc {
    NELPLogInfo(@"NTESChatroomViewController 释放");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [NERtcEngine.sharedEngine leaveChannel];
}

- (instancetype)initWithChatroomInfo:(NTESChatroomInfo *)chatroomInfo
                         accountInfo:(NTESAccountInfo *)accountInfo
                            userMode:(NTESUserMode)userMode;
{
    if (self = [super init]) {
        _dataSource = [[NTESChatroomDataSource alloc] init];
        _dataSource.chatroomInfo = chatroomInfo;
        _dataSource.myAccountInfo = accountInfo;
        _dataSource.userMode = userMode;
        _handler = [[NTESChatroomNotificationHandler alloc] initWithDelegate:self];
        _handler.roomId = chatroomInfo.roomId;
        _playerManager = [[NTESAudioPlayerManager alloc] init];
        [[NIMSDK sharedSDK].chatManager addDelegate:_handler];
        [[NIMSDK sharedSDK].chatroomManager addDelegate:_handler];
        [[NIMSDK sharedSDK].systemNotificationManager addDelegate:_handler];
        
        _enableEarback = NO;
        _gatherVolume = 100;
    }
    return self;
}

- (void)setupRTCEngine
{
    NERtcEngineContext *context = [[NERtcEngineContext alloc] init];
    context.appKey = [NTESDemoConfig sharedConfig].rtcAppKey;
    context.engineDelegate = self;
    NERtcEngine *coreEngine = [NERtcEngine sharedEngine];
    [coreEngine setAudioProfile:kNERtcAudioProfileHighQualityStereo scenario:kNERtcAudioScenarioMusic];
    [coreEngine setupEngineWithContext:context];
    [coreEngine enableAudioVolumeIndication:YES interval:1000];
    if (_dataSource.userMode == NTESUserModeAnchor) {
        [coreEngine enableLocalAudio:YES];
    } else {
        [coreEngine enableLocalAudio:NO];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupRTCEngine];
    [self setupUI];
    [self setupNotication];
    [self enterChatroomWithUserMode:_dataSource.userMode];
    NELP_AUTHORITY_CHECK;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_audioStatusAlert dismissViewControllerAnimated:NO completion:nil];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (!CGRectEqualToRect(_preRect, self.view.bounds)) {
        CGFloat width = self.view.width;
        CGFloat height = [_headerView calculateHeightWithWidth:width];
        CGFloat top = (IPHONE_X ? (20.0 + IPHONE_X_HairHeight) : (20.0 + 20.0));
        _headerView.frame = CGRectMake(0, top, width, height);
        
        width = self.view.width - 2*30.0;
        height = [_micQueueView calculateHeightWithWidth:width];
        _micQueueView.frame = CGRectMake(30.0, _headerView.bottom + 15.0, width, height);
        
        top = _micQueueView.bottom + 40.0;
        if (IPHONE_X) {
            height = self.view.height-34.0-36.0-13.0-top;
        }else {
            height = self.view.height-7.0-36.0-13.0-top;
        }
        _chatView.frame = CGRectMake(20.0, top, self.view.width - 2*20.0, height);
        
        width = self.view.width;
        _textInputView.frame = CGRectMake(0.0, _chatView.bottom + 13.0, width, 36.0);
        
        _playerManager.view.size = CGSizeMake(120.0, 56.0);
        _playerManager.view.right = self.view.width;
        _playerManager.view.bottom = _textInputView.top - 13.0;
        
        _playerManager.audioPanelView.size = CGSizeMake(self.view.width, self.view.width * 0.732);
        _playerManager.audioPanelView.bottom = self.view.height;
        
        _playerManager.maskView.frame = self.view.bounds;

        _preRect = self.view.bounds;
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    _playerManager.audioPanelView.hidden = YES;
    [super touchesBegan:touches withEvent:event];
}

- (void)setupUI {
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"img_bg"]];
    [self.view addSubview:self.headerView];
    [self.view addSubview:self.micQueueView];
    [self.view addSubview:self.chatView];
    [self.view addSubview:self.textInputView];
    if (_dataSource.userMode == NTESUserModeAnchor) {
        [self.view addSubview:self.playerManager.view];
        [self.view addSubview:self.playerManager.maskView];
        [self.view addSubview:self.playerManager.audioPanelView];
    }
    [self showNetworkStatus];
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
        [_textInputView setEnableMuteWithType:NTESDisableTypeMuteAll];
    } else {
        if (_dataSource.meIsMute) {
            [_textInputView setEnableMuteWithType:NTESDisableTypeMute];
        } else {
            [_textInputView setDisableMute];
        }
    }
}

#pragma mark - Router
- (void)goMuteListVC {
    NTESMuteListViewController *muteVC = [[NTESMuteListViewController alloc] initWithChatroom:_dataSource.chatroom
                                                                                 chatroomMute:_dataSource.isMuteAll];
    muteVC.delegate = self;
    [self presentViewController:muteVC animated:YES completion:nil];
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
        [self.view showToastWithMessage:@"网络断开" state:NTESToastStateFail autoDismiss:NO];
    } else {
        [self.view dismissToast];
        [self fetchChatroomQueue];
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
              [NTESCustomNotificationHelper sendDropMicNotication:weakSelf.dataSource.chatroom.creator micInfo:micInfo];
              [weakSelf.view makeToast:@"您已下麦" duration:1 position:CSToastPositionCenter];
          }
    }];
    [ret addObject:dropMicAction];
    
    NTESChatroomAlertAction *exitAction = [NTESChatroomAlertAction actionWithTitle:@"退出并解散房间"
                                                                              type:NTESAlertActionTypeExistRoom
                                                                           handler:^(id  _Nonnull info) {
        [weakSelf exitChatroomWithUserMode:weakSelf.dataSource.userMode];
    }];
    [ret addObject:exitAction];

    return ret;
}

#pragma mark - Private
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
            [wself.dataSource.chatroomInfo updateByChatroom:chatroom];
            wself.dataSource.isMuteAll = [chatroom inAllMuteMode];
            wself.headerView.chatroomInfo = wself.dataSource.chatroomInfo;
            if (userMode == NTESUserModeAnchor) {
                [wself updateChatroomExtWithChatroom:chatroom
                                                info:wself.dataSource.chatroomInfo];
                [wself joinMeeting];
            } else {
                [wself updateChatroomInfoWithChatroom:chatroom];
                [wself joinMeeting];
            }
            [wself fetchChatroomQueue];
            [wself fetchCreaterInfo];
        } else {
            [NTESChatroomAlertView showAlertWithMessage:@"进入聊天室失败" completion:^{
                [wself.navigationController popViewControllerAnimated:YES];
            }];
            NELPLogInfo(@"[demo] 进入房间失败.[%@]", error);
        }
    }];
}

- (void)exitChatroomWithUserMode:(NTESUserMode)userMode {
    [_playerManager stop];
    [[NERtcEngine sharedEngine] leaveChannel];
    
    __weak typeof(self) weakSelf = self;
    NSString *roomId = _dataSource.chatroom.roomId;
    [[NIMSDK sharedSDK].chatroomManager exitChatroom:roomId completion:^(NSError * _Nullable error) {
        if (error) {
            NELPLogError(@"[demo] exit chatroom error![%@]", error);
        }
        if (userMode == NTESUserModeAnchor) {
            if (weakSelf.delegate
                && [weakSelf.delegate respondsToSelector:@selector(didDestoryChatroom:)]) {
                [weakSelf.delegate didDestoryChatroom:weakSelf.dataSource.chatroomInfo];
            }
        }
        [weakSelf.navigationController popViewControllerAnimated:YES];
    }];
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
            for (NIMChatroomMember *member in members) {
                if ([member.userId isEqualToString:creator]) {
                    NTESAccountInfo *info = [[NTESAccountInfo alloc] init];
                    info.account = member.userId;
                    info.nickName = member.roomNickname;
                    info.icon = member.roomAvatar;
                    weakSelf.headerView.accountInfo = info;
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
                wself.micQueueView.datas = wself.dataSource.micInfoArray;
            }
        } else {
            NELPLogError(@"[demo] chatroomqueue更新失败.[%@]", error);
        }
    }];
}

- (void)joinMeeting {
    __weak typeof(self) wself = self;
    [[NERtcEngine sharedEngine] joinChannelWithToken:@""
                                         channelName:_dataSource.chatroomInfo.roomId
                                               myUid:_dataSource.myAccountInfo.uid
                                          completion:^(NSError * _Nullable error, uint64_t channelId, uint64_t elapesd) {
        if (error) {
            NELPLogError(@"[demo] 加入meeting失败.%@", error);
            [NTESChatroomAlertView showAlertWithMessage:@"进入音视频房间失败" completion:^{
                [wself exitChatroomWithUserMode:wself.dataSource.userMode];
            }];
        } else {
            [[NERtcEngine sharedEngine] setLoudspeakerMode:YES];
            [[NERtcEngine sharedEngine] uploadSdkInfo];
        }
    }];
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
            }
            //被踢了
            else if (micInfo.micReason == NTESMicReasonMicKicked){
                NELPLogInfo(@"[demo] YAT be kicked");
                [NTESChatroomAlertView showAlertWithMessage:@"您已被主播踢下麦"];
                [[NERtcEngine sharedEngine] enableLocalAudio:NO];
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
            _headerView.userMode = NTESUserModeAudience;
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
            }
            
            //被抱麦了
            else if (micInfo.micReason == NTESMicReasonConnectInvited){
                NELPLogInfo(@"[demo] YAT be on mic");
                NELP_AUTHORITY_CHECK;
                NSString *msg = [NSString stringWithFormat:@"您已被主播抱上\"麦位%d\"\n现在可以进行语音互动啦\n如需下麦，可点击自己的头像或者下麦按钮",
                                 (int)micInfo.micOrder];
                [NTESChatroomAlertView showAlertWithMessage:msg];
                [[NERtcEngine sharedEngine] enableLocalAudio:YES];
            }
            
            //恢复语音
            else if (micInfo.micReason == NTESMicReasonResumeMasked) {
                NELPLogInfo(@"[demo] YAT be resume masked");
                [[NERtcEngine sharedEngine] muteLocalAudio:NO];
                [NTESChatroomAlertView showAlertWithMessage:@"该麦位被主播\"解除语音屏蔽\"\n现在您可以在此进行语音互动了"];
                _dataSource.isMasked = NO;
            }
            //刷新布局
            _headerView.userMode = NTESUserModeConnector;
            _dataSource.userMode = NTESUserModeConnector;
        }
            break;
        case NTESMicStatusClosed:
            _headerView.userMode = NTESUserModeAudience;
            _dataSource.userMode = NTESUserModeAudience;
            if (micInfo.micReason == NTESMicReasonConnectRejected){
                NELPLogInfo(@"[demo] YAT be rejected");
                [self.view dismissToast];
                [NTESChatroomAlertView showAlertWithMessage:@"你的申请已被拒绝"];
            }
            break;
        case NTESMicStatusMasked:
            _headerView.userMode = NTESUserModeAudience;
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
            _headerView.userMode = NTESUserModeConnector;
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
                _headerView.userMode = NTESUserModeConnector;
                _dataSource.userMode = NTESUserModeConnector;
                _dataSource.isMasked = YES;
            }
        }
            break;
        default:
            break;
    }
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
- (void)didInviteeUserToMicInfo:(NTESMicInfo *)dstMicInfo {
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

//麦克静音
- (void)didMicMute:(BOOL)mute {
    [[NERtcEngine sharedEngine] setRecordDeviceMute:mute];
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
    [[NERtcEngine sharedEngine] setPlayoutDeviceMute:mute];
    NSString *msg = (mute ? @"声音已关闭" : @"声音已打开");
    [self.view makeToast:msg duration:1 position:CSToastPositionCenter];
}

#pragma mark - NTESChatroomNotificationHandlerDelegate
- (void)didShowMessages:(NSArray<NIMMessage *> *)messages {
    [_chatView addMessages:messages];
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

    //加入请求连麦队列
    [_dataSource.connectorArray addObject:micInfo];
    [self.connectListView refreshWithDataArray:_dataSource.connectorArray];
    
    //更新队列
    [self didUpdateChatroomQueueWithMicInfo:micInfo];
    
    //弹出提示框
    [self.connectListView showAsAlertOnView:self.view];
}

- (void)didReceiveMicBeDropped:(NTESMicInfo *)micInfo
{
    NSInteger micOrder = micInfo.micOrder;
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
- (void)didUpdateChatroomQueueWithMicInfokey:(NSString *)key micInfoValue:(NSString *)value
{
    NELPLogInfo(@"[demo] didUpdateChatroomQueueWithMicInfo");
    
    //获取更新的信息
    NTESMicInfo *micInfo = [NTESChatroomQueueHelper micInfoByChatroomQueueValue:value];
    if (_dataSource.userMode == NTESUserModeAnchor
        && micInfo.micOrder == _selectMicOrder) {
        [_alerView dismiss];
    }
    
    //更新自己的信息
    if ([micInfo.userInfo.account isEqualToString:_dataSource.myAccountInfo.account]) {
        [self didUpdateMyMicInfo:micInfo];
    } else { //异常：其他上了自己申请麦位
        if ((micInfo.micReason == NTESMicReasonConnectAccepted || micInfo.micReason == NTESMicReasonConnectInvited)
            && _dataSource.myMicInfo.micStatus == NTESMicStatusConnecting
            && micInfo.micOrder == _dataSource.myMicInfo.micOrder) {
            [self.view dismissToast];
            [self.view makeToast:@"该麦位已被其他人上麦" duration:1 position:CSToastPositionCenter];
            _dataSource.myMicInfo.micStatus = NTESMicStatusNone;
            _dataSource.myMicInfo.micReason = NTESMicReasonNone;
        }
    }
    
    //更新mic队列
    if (micInfo.micOrder > 0 && micInfo.micOrder <= _dataSource.micInfoArray.count) {
        _dataSource.micInfoArray[micInfo.micOrder - 1] = micInfo;
    } else {
        NELPLogError(@"[demo] update queue micinfo error, micorder [%d] error!",
                     (int)micInfo.micOrder);
    }
    [_micQueueView updateCellWithMicInfo:micInfo];
}

- (void)didUpdateChatroomQueueWithMicInfo:(NTESMicInfo *)micInfo {
    if (!micInfo) {
        return;
    }
    
    NSString *roomId = _dataSource.chatroom.roomId;
    [NTESChatroomQueueHelper updateChatroomQueueWithRoomId:roomId
                                                   micInfo:micInfo];
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
    _headerView.chatroomInfo = _dataSource.chatroomInfo;
    
    NSString *text = [NSString stringWithFormat:@"\"%@\" %@房间",
                      member.nick, (enter ? @"加入":@"离开")];
    NIMMessage *message = [NTESChatroomMessageHelper systemMessageWithText:text];
    [_chatView addMessages:@[message]];

    if (_dataSource.userMode == NTESUserModeAnchor) {
        //清理请求连麦列表
        __block NTESMicInfo *micInfo = [_dataSource userInfoOnConnectorArray:member.userId];
        if (micInfo) {
            [_dataSource.connectorArray removeObject:micInfo];
            [_connectListView refreshWithDataArray:_dataSource.connectorArray];
        }
        
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
        [self didUpdateChatroomQueueWithMicInfo:micInfo];
    }
}

- (void)didChatroomMember:(NIMChatroomNotificationMember *)member mute:(BOOL)mute { //禁言某个人
    NSString *text = [NSString stringWithFormat:@"\"%@\" %@", member.nick, (mute?@"被禁言":@"恢复发言")];
    NIMMessage *message = [NTESChatroomMessageHelper systemMessageWithText:text];
    [_chatView addMessages:@[message]];
    if ([member.userId isEqualToString:_dataSource.myAccountInfo.account]) {
        _dataSource.meIsMute = mute;
        [self updateInputView];
    }
}

- (void)didChatroomMute:(BOOL)mute { //聊天室禁言
    NSString *text = (mute ? @"聊天室 被禁言" : @"聊天室 解除禁言");
    NIMMessage *message = [NTESChatroomMessageHelper systemMessageWithText:text];
    [_chatView addMessages:@[message]];
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
    if (_delegate && [_delegate respondsToSelector:@selector(didRoomClosed:)]) {
        [_delegate didRoomClosed:_dataSource.chatroomInfo];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didChatroomAnchorMicMute:(BOOL)micMute { //主播关闭话筒
    _dataSource.chatroomInfo.micMute = micMute;
    _headerView.chatroomInfo = _dataSource.chatroomInfo;;
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

#pragma mark - NTESChatroomMicQueueViewDelegate
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
                _micQueueView.datas = _dataSource.micInfoArray;
                
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
#pragma mark - NTESTextInputViewDelegate
- (void)didSendText:(NSString *)text {
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

- (void)topDidChange:(CGFloat)offset {
    _headerView.top += offset;
    _micQueueView.top += offset;
    _chatView.top += offset;
    _playerManager.view.top += offset;
}

#pragma mark - NTESChatroomHeaderDelegate
- (void)headerDidReceiveExitAction {
    if (_dataSource.userMode == NTESUserModeAnchor) {
        [self.alerView showWithTypes:@[@(NTESAlertActionTypeExistRoom)]
                                       info:_dataSource.myMicInfo];
    } else if (_dataSource.userMode == NTESUserModeConnector){
        //下麦
        [NTESCustomNotificationHelper sendDropMicNotication:_dataSource.chatroom.creator
                                                       micInfo:_dataSource.myMicInfo];
        //退出房间
        [self exitChatroomWithUserMode:_dataSource.userMode];
    } else {
        [self exitChatroomWithUserMode:_dataSource.userMode];
    }
}

- (void)headerDidReceiveDropMicAction {
    [self.alerView showWithTypes:@[@(NTESAlertActionTypeDropMic)]
                               info:_dataSource.myMicInfo];
}

- (void)headerDidReceiveSoundMuteAction:(BOOL)mute {
    [self didSoundMute:mute];
}

- (void)headerDidReceiveMicMuteAction:(BOOL)mute {
    [self didMicMute:mute];
}

- (void)headerDidReceiveNoSpeekingAciton {
    [self goMuteListVC];
}

- (void)headerDidReceiveSettingAciton {
    [NTESSettingPanelView showWithController:self earbackSwifth:_enableEarback volume:_gatherVolume];
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
              [vc.view makeToast:msg duration:1 position:CSToastPositionCenter];
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
        case kNERtcLsStatePushFail:
            NELPLogDebug(@"Stream for task [%@] failed", taskID);
            break;
        default:
            NELPLogDebug(@"Unknown state for task [%@]", taskID);
            break;
    }
}

- (void)onNERtcEngineUserAudioDidStart:(uint64_t)userID
{
    [[NERtcEngine sharedEngine] subscribeRemoteAudio:YES forUserID:userID];
}

- (void)onNERtcEngineUserDidJoinWithUserID:(uint64_t)userID userName:(NSString *)userName
{
    NELPLogDebug(@"userID: %lld, userName: %@", userID, userName);
}

- (void)onNERtcEngineUserDidLeaveWithUserID:(uint64_t)userID reason:(NERtcSessionLeaveReason)reason
{
    NELPLogDebug(@"userID: %lld, reason: %ld", userID, (long)reason);
}

#pragma mark - NERtcEngineAudioSessionObserver

- (void)onNERtcEngineAudioDeviceRoutingDidChange:(NERtcAudioOutputRouting)routing
{
    NELPLogDebug(@"routing: %ld", (long)routing);
}

#pragma mark - NERtcEngineDelegateExt

- (void)onAudioMixingStateChanged:(NERtcAudioMixingState)state errorCode:(NERtcAudioMixingErrorCode)errorCode
{
    if (errorCode == kNERtcAudioMixingErrorOK && state == kNERtcAudioMixingStateFinished) {
        [_playerManager onAudioMixingStateChanged:state];
    }
}

- (void)onLocalAudioVolumeIndication:(int)volume
{
    NSTimeInterval cur = [[NSDate date] timeIntervalSince1970];
    if (cur -  _lastVolumeMy <= 1) {
        return;
    }
    
    _lastVolumeMy = cur;
    if (_dataSource.userMode == NTESUserModeAnchor) {
        if (volume == 0) {
            [_headerView stopSoundAnimation];
        } else {
            [_headerView startAnimationWithValue:volume];
        }
    } else if (_dataSource.userMode == NTESUserModeConnector){
        NTESMicInfo *info = [_dataSource userInfoOnMicInfoArray:_dataSource.myAccountInfo.account];
        if (info) {
            if (volume == 0) {
                info.isMicMute = YES;
                _dataSource.myMicInfo.isMicMute = YES;
                [_micQueueView stopSoundAnimation:info.micOrder];
            } else {
                info.isMicMute = NO;
                _dataSource.myMicInfo.isMicMute = NO;
                [_micQueueView startSoundAnimation:info.micOrder volume:volume];
            }
        }
    }
}

-(void)onRemoteAudioVolumeIndication:(nullable NSArray<NERtcAudioVolumeInfo*> *)speakers totalVolume:(int)totalVolume
{
    NSTimeInterval cur = [[NSDate date] timeIntervalSince1970];
    if (cur - _lastVolumeRemote <= 1) {
        return;
    }
    _lastVolumeRemote = cur;
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [_dataSource.onSoundUsers enumerateObjectsUsingBlock:^(NERtcAudioVolumeInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        BOOL isExistInReport = NO;
        NERtcAudioVolumeInfo *tempInfo = nil;
        NSString *uidStr = [NSString stringWithFormat:@"user%lld", obj.uid];
        for (NERtcAudioVolumeInfo *info in speakers) {
            if (info.uid == obj.uid) { //存在了
                isExistInReport = YES;
                tempInfo = info;
                [dic setObject:@(1) forKey:uidStr];
                break;
            }
        }
        
        [weakSelf soundAnimateEnable:isExistInReport volume:tempInfo.volume uid:uidStr];
    }];
    
    [speakers enumerateObjectsUsingBlock:^(NERtcAudioVolumeInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *uidStr = [NSString stringWithFormat:@"user%lld", obj.uid];
        if ([weakSelf.dataSource userIsCreator:uidStr]) {
            [weakSelf.headerView startAnimationWithValue:obj.volume];
        } else {
            if (!dic[uidStr]) {
                NTESMicInfo *info = [weakSelf.dataSource userInfoOnMicInfoArray:uidStr];
                if (info.micStatus == NTESMicStatusConnectFinished) {
                    info.isMicMute = NO;
                    [weakSelf.micQueueView startSoundAnimation:info.micOrder volume:obj.volume];
                } else {
                    info.isMicMute = YES;
                    [weakSelf.micQueueView stopSoundAnimation:info.micOrder];
                }
            }
        }
    }];
    _dataSource.onSoundUsers = speakers;
}

- (void)soundAnimateEnable:(BOOL)enable volume:(NSInteger)volume uid:(NSString *)uid
{
    if ([self.dataSource userIsCreator:uid]) {
        if (enable && volume > 60) {
            [self.headerView startAnimationWithValue:volume];
        } else {
            [self.headerView stopSoundAnimation];
        }
    } else {
        NTESMicInfo *info = [self.dataSource userInfoOnMicInfoArray:uid];
        if (enable && volume > 60) {
            info.isMicMute = YES;
            [self.micQueueView startSoundAnimation:info.micOrder volume:volume];
        } else {
            info.isMicMute = NO;
            [self.micQueueView stopSoundAnimation:info.micOrder];
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
                                                    micInfo:_dataSource.myMicInfo];
    }
}

#pragma mark - Getter
- (NTESConnectListView *)connectListView {
    if (!_connectListView) {
        _connectListView = [[NTESConnectListView alloc] initWithFrame:CGRectMake(15, 0, self.view.width - 2* 15, 0)];
        _connectListView.delegate = self;
    }
    return _connectListView;
}

- (NTESTextInputView *)textInputView {
    if (!_textInputView) {
        _textInputView = [[NTESTextInputView alloc] init];
        _textInputView.delegate = self;
    }
    return _textInputView;
}

- (NTESLiveChatView *)chatView {
    if (!_chatView) {
        _chatView = [[NTESLiveChatView alloc] initWithFrame:CGRectMake(0, 0, 100, 200)];
    }
    return _chatView;
}

- (NTESChatroomHeaderView *)headerView {
    if (!_headerView) {
        _headerView = [[NTESChatroomHeaderView alloc] init];
        _headerView.userMode = _dataSource.userMode;
        _headerView.chatroomInfo = _dataSource.chatroomInfo;
        _headerView.delegate = self;
    }
    return _headerView;
}

- (NTESChatroomMicQueueView *)micQueueView {
    if (!_micQueueView) {
        _micQueueView = [[NTESChatroomMicQueueView alloc] init];
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

- (BOOL)networkNotReachable {
    return ([NTESDemoSystemManager shareInstance].netStatus == NotReachable);
}

- (UIAlertController *)setupAudioStatusAlert {
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"是" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // 选择耳机
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"否" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        // 选择音响
    }];
    UIAlertController *ret = [UIAlertController alertControllerWithTitle:@"耳机检测" message:@"检测有设备插入，是否插入了耳机" preferredStyle:UIAlertControllerStyleAlert];
    [ret addAction:action];
    [ret addAction:cancel];
    return ret;
}

@end
