//
//  NTESHomePageViewController.m
//  NERtcAudioChatroom
//
//  Created by Simon Blue on 2019/1/15.
//  Copyright © 2019年 netease. All rights reserved.
//

#import "NTESHomePageViewController.h"
#import "NTESDemoService.h"
#import "NTESAccountInfo.h"
#import "UIView+NTES.h"
#import "NSString+NTES.h"
#import "UIView+Toast.h"
#import "NTESIconView.h"
#import "NTESHomePageStateView.h"
#import "NTESChatroomTableViewCell.h"
#import "NTESChatroomViewController.h"
#import "NTESDataCenter.h"
#import <MJRefresh.h>
#import "NTESDemoSystemManager.h"
#import "NTESChatroomAlertView.h"
#import "NTESPlanChooseAlertView.h"

typedef NS_ENUM(NSUInteger, NTESHomePageProcessStatus){
    NTESHomePageProcessDidInit = 0,
    NTESHomePageProcessDidRequestAccount,
    NTESHomePageProcessDidLogin,
    NTESHomePageProcessDidRefresh,
};

@interface NTESHomePageViewController ()<UITableViewDelegate,
                                         UITableViewDataSource,
                                         NTESHomePageStateDelegate,
                                         NTESChatroomVCDelegate,
                                         UITextFieldDelegate,
                                         NTESPlanChooseDelegate>

@property (nonatomic,assign) NTESHomePageProcessStatus status;
@property (nonatomic,strong) NSMutableArray *chatroomInfos;
@property (nonatomic,strong) NTESAccountInfo *myAccountInfo;
@property (nonatomic,assign) NSInteger currentOffset;
@property (nonatomic,assign) NSInteger nextListCountPerPage;
@property (nonatomic,assign) NSInteger firstPageListCount;
@property (nonatomic,assign) BOOL roomIsClosedClient; //观众收到主播解散通知
@property (nonatomic,assign) BOOL roomIsClosedAnchor; //主播自己解散

@property (nonatomic,strong) NTESIconView *iconView;
@property (nonatomic,strong) UITableView *tabelview;
@property (nonatomic,strong) UIButton *createRoomBtn;
@property (nonatomic,strong) NTESHomePageStateView *emptyView;
@property (nonatomic,strong) NTESHomePageStateView *networkErrorView;
@property (nonatomic,weak) UIAlertAction *createAction;
@property (nonatomic,assign) NSInteger inputTextLength;
@property (nonatomic,assign) BOOL inputComplete;
//输入的房间名称
@property (nonatomic, strong) NSString *inputRoomName;
@property (nonatomic, assign) NTESPushType pushType;
@end

@implementation NTESHomePageViewController

- (void)dealloc {
    NELPLogInfo(@"NTESChatroomViewController 释放");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self doSetupVariable];
    [self doSetupUI];
    [self doSetupRefresh];
    [self doSetupNotication];
    [self doLogin];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    if (_roomIsClosedClient) {
        [NTESChatroomAlertView showAlertWithMessage:@"该房间已经被主播解散了"];
        [_tabelview reloadData];
        _roomIsClosedClient = NO;
    }
    if (_roomIsClosedAnchor) {
        [self.view makeToast:@"房间已解散" duration:2 position:CSToastPositionCenter];
        _roomIsClosedAnchor = NO;
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (IPHONE_X) {
        _iconView.origin = CGPointMake(0, IPHONE_X_HairHeight + 8);
    } else {
        _iconView.origin = CGPointMake(0, 20 + 8);
    }
    _iconView.centerX = self.view.width/2;
    _tabelview.frame = CGRectMake(0,
                                  _iconView.bottom+8,
                                  self.view.width,
                                  self.view.height-_iconView.height-8);
    _networkErrorView.frame = _tabelview.frame;
    _createRoomBtn.size = CGSizeMake(UIMinAdapter(90.0), UIMinAdapter(90.0));
    _createRoomBtn.bottom = self.view.height - 16.0;
    _createRoomBtn.centerX = self.view.width/2;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - UI
- (void)showChatRoomVCWithMode:(NTESUserMode)mode
                          info:(NTESChatroomInfo *)info
                          pushType:(NTESPushType)pushType{
//    NTESChatroomViewController *vc = [[NTESChatroomViewController alloc] initWithChatroomInfo:info
//                                                                                  accountInfo:_myAccountInfo
//                                                                                     userMode:mode];
    NTESChatroomViewController *vc = [[NTESChatroomViewController alloc] initWithChatroomInfo:info
                                                                                     accountInfo:_myAccountInfo
                                                                                     userMode:mode pushType:pushType];
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)doSetupUI {
    self.view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.iconView];
    [self.view addSubview:self.tabelview];
    [self.view addSubview:self.createRoomBtn];
}

- (void)doSetupRefresh {
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self
                                                                     refreshingAction:@selector(refreshAction)];
    [header setTitle:@"下拉刷新" forState:MJRefreshStateIdle];
    [header setTitle:@"结束刷新" forState:MJRefreshStatePulling];
    [header setTitle:@"刷新中..." forState:MJRefreshStateRefreshing];
    header.stateLabel.font = [UIFont systemFontOfSize:14.0];
    header.stateLabel.textColor = [UIColor whiteColor];
    header.lastUpdatedTimeLabel.hidden = YES;
    self.tabelview.mj_header = header;
    
    MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self
                                                                             refreshingAction:@selector(nextPageChatroomList)];
    // 设置文字
    [footer setTitle:@"" forState:MJRefreshStateIdle];
    [footer setTitle:@"加载中..." forState:MJRefreshStateRefreshing];
    [footer setTitle:@"" forState:MJRefreshStateNoMoreData];
    footer.stateLabel.textColor = [UIColor whiteColor];
    footer.stateLabel.font = [UIFont systemFontOfSize:14.0];
    self.tabelview.mj_footer = footer;
}

- (void)doSetupVariable {
    _firstPageListCount = 50;
    _nextListCountPerPage = 20;
    _chatroomInfos = [NSMutableArray array];
    _status = NTESHomePageProcessDidInit;
}

- (void)doSetupNotication {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appReachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
}

- (void)showNetworkErrorView:(BOOL)show {
    if (show) {
        self.networkErrorView.frame = self.tabelview.bounds;
        [self.tabelview addSubview:self.networkErrorView];
    } else {
        [self.networkErrorView removeFromSuperview];
    }
}

- (void)showEmptyView:(BOOL)show {
    if (show) {
        self.emptyView.mode = NTESHomePageStateViewEmpty;
    } else {
        self.emptyView.mode = NTESHomePageStateViewHidden;
    }
}
//选择rtc还是cdn方案
- (void)choosePlan {
    NTESPlanChooseAlertView *chooseAlertView = [[NTESPlanChooseAlertView alloc]initWithFrame:CGRectMake(0, 0, UIScreenWidth, UIScreenHeight)];
    chooseAlertView.delegate = self;
    [[UIApplication sharedApplication].keyWindow addSubview:chooseAlertView];
}

#pragma mark - Fuction - Login
- (void)doLogin {
    __weak typeof(self) weakSelf = self;
    [SVProgressHUD showWithStatus:@"登录中..."];
    [self doCleanLastChatroom:^(NSError *error) {
        [weakSelf doRequestAccount:^(NTESAccountInfo *accountInfo, NSError *error) {
            if (!error) {
                NELPLogInfo(@"accountInfo:[%@]", accountInfo);
                weakSelf.status = NTESHomePageProcessDidRequestAccount;
                weakSelf.myAccountInfo = accountInfo;
                [weakSelf doLoginWithAccount:accountInfo.account
                                       token:accountInfo.token];
                [weakSelf.iconView setName:accountInfo.nickName
                                   iconUrl:accountInfo.icon];
                weakSelf.createRoomBtn.enabled = YES;
            } else {
                [SVProgressHUD showInfoWithStatus:@"登录失败"];
                NetworkStatus netStatus = [NTESDemoSystemManager shareInstance].netStatus;
                [self showNetworkErrorView:(netStatus == NotReachable)];
                NELPLogError(@"[demo] request login info fail.[%@]", error);
            }
        }];
    }];
}

- (void)doRequestAccount:(NTESAccountHandler)completion {
    if ([NTESDemoSystemManager shareInstance].netStatus == NotReachable) {
        NELPLogError(@"[demo] networ is not reachable!");
        NSError *error = [NSError errorWithDomain:@"ntes.demo.homepage" code:0x1001 userInfo:nil];
        completion(nil, error);
        return;
    }
    
    NTESAccountInfo *info = [NTESDataCenter shareCenter].myAccount;
    if ([info valid]) {
        completion(info, nil);
        return;
    } else {
        [NTESDataCenter shareCenter].myAccount = nil;
    }

    [[NTESDemoService sharedService] requestUserAccount:nil
                                             completion:^(NTESAccountInfo *accountInfo, NSError *error) {
         if (!error) {
             [NTESDataCenter shareCenter].myAccount = accountInfo;
         }
         completion(accountInfo, error);
     }];
}

//清理上次创建并且没解散的房间（异常情况）
- (void)doCleanLastChatroom:(void (^)(NSError *error))completion {
    NSString *userId = [NTESDataCenter shareCenter].myAccount.account;
    NTESChatroomInfo *myCreateChatroom = [NTESDataCenter shareCenter].myCreateChatroom;
    if (userId.length != 0 && myCreateChatroom) {
        __weak typeof(self) weakSelf = self;
        [[NIMSDK sharedSDK].chatroomManager exitChatroom:myCreateChatroom.roomId completion:nil];
        NSInteger roomId = [myCreateChatroom.roomId integerValue];
        [weakSelf doDestoryChatroomWithUserId:userId
                                       roomId:roomId
                                   completion:^(NSError *error) {
             NELPLogInfo(@"[demo] clean chatroom %@", error ? @"success" : error);
             if (!error) {
                 [NTESDataCenter shareCenter].myCreateChatroom = nil;
             }
             completion(error);
        }];
    } else {
        completion(nil);
    }
}

- (void)doLoginWithAccount:(NSString *)account
                     token:(NSString *)token {
    __weak typeof(self) weakSelf = self;
    [[[NIMSDK sharedSDK] loginManager] login:account
                                       token:token
                                  completion:^(NSError *error) {
          if (error == nil) {
              NELPLogInfo(@"[demo] login success!");
              weakSelf.status = NTESHomePageProcessDidLogin;
              [SVProgressHUD dismiss];
              [weakSelf refreshChatroomList];
          } else {
              [SVProgressHUD showInfoWithStatus:@"登录失败"];
              NetworkStatus netStatus = [NTESDemoSystemManager shareInstance].netStatus;
              [self showNetworkErrorView:(netStatus == NotReachable)];
              NELPLogError(@"[demo] login failed!%@", error);
          }
     }];
}

- (void)doCreateChatroom {
//    NSString *account = _myAccountInfo.account;
    [self choosePlan];//方案选择
//    [[NTESDemoService sharedService] createChatroomWithSid:account
//                                                  roomName:roomName
//                                                completion:^(NTESChatroomInfo *chatroomInfo, NSError *error) {
//        if (!error) {
//            chatroomInfo.audioQuality = NTESAudioQualityHDMusic;
//            [NTESDataCenter shareCenter].myCreateChatroom = chatroomInfo;
//            [weakSelf showChatRoomVCWithMode:NTESUserModeAnchor
//                                        info:chatroomInfo];
//        } else {
//            [self.view makeToast:@"创建房间失败!" duration:2 position:CSToastPositionCenter];
//            NELPLogError(@"[demo] create room request error![%@]", error);
//        }
//    }];
}

- (void)doDestoryChatroomWithUserId:(NSString *)userId
                             roomId:(NSInteger)roomId
                         completion:(void (^)(NSError *error))completion{
    [[NTESDemoService sharedService] closeChatroomWithSid:userId
                                                   roomId:roomId
                                               completion:^(NSError *error) {
        if (!error) {
            [NTESDataCenter shareCenter].myCreateChatroom = nil;
        } else {
            NELPLogError(@"[demo] destory room request error![%@]", error);
        }
        if (completion) {
            completion(error);
        }
    }];
}

#pragma mark - Fuction - Room list refresh
- (void)refreshAction {
    if (_status != NTESHomePageProcessDidLogin &&
        _status != NTESHomePageProcessDidRefresh) {
        [self didInitRetry];
    } else {
        [self refreshChatroomList];
    }
}

- (void)refreshChatroomList {
    NTESDemoService *requestService = [NTESDemoService sharedService];
    __weak typeof(self) weakSelf = self;
    [SVProgressHUD showWithStatus:@"加载中..."];
    _currentOffset = 0;
    [requestService requestChatrommListWithLimit:_firstPageListCount
                                          offset:_currentOffset
                                      completion:^(NSMutableArray<NTESChatroomInfo *> *chatroomInfos, NSError *error) {
        [weakSelf.tabelview.mj_header endRefreshing];
        if (!error) {
            [SVProgressHUD dismiss];
            weakSelf.currentOffset = chatroomInfos.count;
            [weakSelf.chatroomInfos removeAllObjects];
            if (chatroomInfos.count != 0) {
                [weakSelf.chatroomInfos addObjectsFromArray:chatroomInfos];
                [weakSelf.tabelview reloadData];
            }
            weakSelf.status = NTESHomePageProcessDidRefresh;
        } else {
            [SVProgressHUD showInfoWithStatus:@"加载失败"];
            NELPLogError(@"[demo] refresh chatroom fail!%@", error);
        }
        [weakSelf showEmptyView:(weakSelf.chatroomInfos.count == 0)];
    }];
}

- (void)nextPageChatroomList {
    NTESDemoService *requestService = [NTESDemoService sharedService];
    __weak typeof(self) weakSelf = self;
    [requestService requestChatrommListWithLimit:_nextListCountPerPage
                                          offset:_currentOffset
                                      completion:^(NSMutableArray<NTESChatroomInfo *> *chatroomInfos, NSError *error) {
        if (!error) {
            weakSelf.currentOffset = chatroomInfos.count;
            if (chatroomInfos.count != 0) {
                [weakSelf.tabelview.mj_footer endRefreshing];
                [weakSelf.chatroomInfos addObjectsFromArray:chatroomInfos];
                [weakSelf.tabelview reloadData];
            } else {
                [weakSelf.tabelview.mj_footer endRefreshingWithNoMoreData];
            }
        } else {
            [weakSelf.tabelview.mj_footer endRefreshing];
            NELPLogError(@"[demo] request offset = %ld chatroom list fail!%@",
                  (long)weakSelf.currentOffset, error);
        }
        [weakSelf showEmptyView:(weakSelf.chatroomInfos.count == 0)];
    }];
    
}

#pragma mark - User Interaction
- (void)onCreateRoomBtnPressed {
    __weak typeof(self) weakSelf = self;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"请输入房间名" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        weakSelf.inputComplete = NO;
    }];
    [alertController addAction:cancelAction];
    
    UIAlertAction *createAction = [UIAlertAction actionWithTitle:@"创建房间" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *roomNameTextField = alertController.textFields.firstObject;
        weakSelf.inputComplete = NO;
        weakSelf.inputRoomName = roomNameTextField.text;
        [weakSelf choosePlan];
    }];
    _createAction = createAction;
    createAction.enabled = NO;
    [alertController addAction:createAction];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField*_Nonnull textField) {
        textField.placeholder = @"请输入房间名";
        [textField addTarget:weakSelf
                      action:@selector(textFieldDidChange:)
            forControlEvents:UIControlEventEditingChanged];
        textField.delegate = weakSelf;
    }];
    
    if (IS_IPAD) {
        UIPopoverPresentationController *popPresenter = [alertController popoverPresentationController];
        popPresenter.sourceView = self.view;
        popPresenter.sourceRect = self.view.bounds;
    }
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _chatroomInfos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NTESChatroomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[NTESChatroomTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                reuseIdentifier:@"cell"];
    }
    [cell refresh:_chatroomInfos[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NTESChatroomInfo *chatroomInfo = _chatroomInfos[indexPath.row];
    [self showChatRoomVCWithMode:NTESUserModeAudience info:chatroomInfo pushType:chatroomInfo.pushType];
}
#pragma mark - NTESPlanChooseDelegate
- (void)planChooseResult:(NTESPushType)selectIndex {
    __weak __typeof(self)weakSelf = self;
    self.pushType = selectIndex;
    [[NTESDemoService sharedService] createChatroomWithSid:_myAccountInfo.account roomName:self.inputRoomName pushType:selectIndex completion:^(NTESChatroomInfo * _Nullable chatroomInfo, NSError * _Nullable error) {
        if (!error) {
            chatroomInfo.audioQuality = NTESAudioQualityHDMusic;
            [NTESDataCenter shareCenter].myCreateChatroom = chatroomInfo;
            [weakSelf showChatRoomVCWithMode:NTESUserModeAnchor
                                        info:chatroomInfo pushType:self.pushType];
        } else {
            [self.view makeToast:@"创建房间失败!" duration:2 position:CSToastPositionCenter];
            NELPLogError(@"[demo] create room request error![%@]", error);
        }
    }];
}


#pragma mark - <NTESHomePageStateDelegate>
- (void)didInitRetry {
    [self showNetworkErrorView:NO];
    switch (_status) {
        case NTESHomePageProcessDidInit:
            [self doLogin];
            break;
        case NTESHomePageProcessDidRequestAccount:
            [self doLoginWithAccount:_myAccountInfo.account
                               token:_myAccountInfo.token];
            break;
        case NTESHomePageProcessDidLogin:
        case NTESHomePageProcessDidRefresh:
            [self refreshChatroomList];
            break;
        default:
            break;
    }
}

- (void)stateViewDidReceiveRetryAction {
    [self didInitRetry];
}

#pragma mark - <NTESChatroomVCDelegate>
- (void)didRoomClosed:(NTESChatroomInfo *)roomInfo {
    [_chatroomInfos removeObject:roomInfo];
    [_tabelview reloadData];
    _roomIsClosedClient = YES;
}

- (void)didDestoryChatroom:(NTESChatroomInfo *)roomInfo {
    NSString *userId = [[NIMSDK sharedSDK].loginManager currentAccount];
    NSInteger roomId = [roomInfo.roomId integerValue];
    [self doDestoryChatroomWithUserId:userId roomId:roomId completion:nil];
    [_chatroomInfos removeObject:roomInfo];
    [_tabelview reloadData];
    _roomIsClosedAnchor = YES;
}

#pragma mark - Notication
- (void)appReachabilityChanged:(NSNotification *)note {
    Reachability *reach = [note object];
    if(![reach isKindOfClass:[Reachability class]]){
        return;
    }
    NetworkStatus networkStatus = [reach currentReachabilityStatus];
    [self showNetworkErrorView:(networkStatus == NotReachable)];
    if (_chatroomInfos.count == 0) {
        self.emptyView.mode = NTESHomePageStateViewEmpty;
    } else {
        self.emptyView.mode = NTESHomePageStateViewHidden;
    }
}

- (void)textFieldDidChange:(UITextField *)sender {
    NSString *toBeString = sender.text;
    _createAction.enabled = (sender.text.length != 0);
    UITextRange *selectedRange = [sender markedTextRange];
    UITextPosition *position = [sender positionFromPosition:selectedRange.start offset:0];
    if (!position) {
        NSInteger length = 0;
        for (int i = 0; i < toBeString.length; i++) {
            NSString *subStr = [toBeString substringWithRange:NSMakeRange(i, 1)];
            length += ([subStr isChinese] ? 2 : 1);
            if (length > 16) {
                _inputComplete = YES;
                sender.text = [toBeString substringWithRange:NSMakeRange(0, i)];
                break;
            }
        }
        _inputComplete = (length > 16);
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return !(string.length != 0 && _inputComplete);
}

#pragma mark - Getter
- (UITableView *)tabelview
{
    if (!_tabelview) {
        _tabelview =[[UITableView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)
                                                 style:UITableViewStylePlain];
        _tabelview.delegate = self;
        _tabelview.dataSource = self;
        _tabelview.showsVerticalScrollIndicator = NO;
        _tabelview.showsHorizontalScrollIndicator = NO;
        _tabelview.backgroundColor = [UIColor blackColor];
        _tabelview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        _tabelview.tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
        _tabelview.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tabelview.backgroundView = self.emptyView;
        _tabelview.rowHeight = UIHeightAdapter(100.0);
    }
    return _tabelview;
}

- (UIButton *)createRoomBtn
{
    if (!_createRoomBtn) {
        _createRoomBtn = [[UIButton alloc] initWithFrame:CGRectZero];
        [_createRoomBtn addTarget:self
                           action:@selector(onCreateRoomBtnPressed)
                 forControlEvents:UIControlEventTouchUpInside];
        [_createRoomBtn setImage:[UIImage imageNamed:@"new_room"]
                        forState:UIControlStateNormal];
        _createRoomBtn.enabled = NO;
    }
    return _createRoomBtn;
}

- (NTESIconView *)iconView {
    if (!_iconView) {
        _iconView = [[NTESIconView alloc] init];
        _iconView.backgroundColor = [UIColor blackColor];
        _iconView.size = CGSizeMake(UIMinAdapter(32), UIMaxAdapter(52));
    }
    return _iconView;
}

- (NTESHomePageStateView *)emptyView{
    if (!_emptyView) {
        _emptyView = [[NTESHomePageStateView alloc] init];
        _emptyView.mode = NTESHomePageStateViewHidden;
    }
    return _emptyView;
}

- (NTESHomePageStateView *)networkErrorView {
    if (!_networkErrorView) {
        _networkErrorView = [[NTESHomePageStateView alloc] init];
        _networkErrorView.mode = NTESHomePageStateViewNetworkError;
        _networkErrorView.delegate = self;
    }
    return _networkErrorView;
}

@end
