//
//  NTESHomeViewController.m
//  NEChatroom-iOS-ObjC
//
//  Created by vvj on 2021/2/1.
//  Copyright © 2021 netease. All rights reserved.
//

#import "NTESHomeViewController.h"
#import "NTESOpenRoomViewController.h"
#import "NTESLiveListMainViewController.h"
#import "NTESActionSheetNavigationController.h"
#import "NTESMoreViewController.h"
#import "NTESMusicPanelLyricLoader.h"

#import "NTESHomeTableViewCell.h"
#import "NTESHomePageStateView.h"

#import "NTESHomePageCellModel.h"
#import "NTESAccountInfo.h"
#import "NTESDataCenter.h"
#import "NTESDemoService.h"
#import "NTESDemoSystemManager.h"




@interface NTESHomeViewController ()<UITableViewDelegate,UITableViewDataSource,NTESHomePageStateDelegate>

@property (nonatomic, strong) UILabel *titleLable;
@property (nonatomic, strong) UITableView *tableView;
//自定义数据源
@property (nonatomic, strong) NSArray *dataSourceArray;
//开始直播
@property(nonatomic, strong) UIButton *createLiveRoomButton;

@property (nonatomic,strong) NTESAccountInfo *myAccountInfo;

@property (nonatomic,strong) NTESHomePageStateView *networkErrorView;

@end

@implementation NTESHomeViewController

static CGFloat const kLiveButtonWidth = 90;

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)ntes_initializeConfig {
    self.navigationController.navigationBar.hidden = YES;
}

- (void)ntes_bindViewModel {
    self.dataSourceArray = [NSArray yy_modelArrayWithClass:[NTESHomePageCellModel class] json:self.dataSourceArray];
    [self.tableView reloadData];
}

-(void)ntes_getNewData {
    [self startLogin];
}

- (void)ntes_addSubViews {
    [self.view addSubview:self.titleLable];
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.createLiveRoomButton];
    
    [self.titleLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(44);
        make.top.equalTo(self.view).offset(statusBarHeight);

    }];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLable.mas_bottom).offset(8);
        make.left.right.bottom.equalTo(self.view);
    }];
    
    [self.createLiveRoomButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kLiveButtonWidth, kLiveButtonWidth));
        make.right.equalTo(self.view).offset(-5);
        make.bottom.equalTo(self.view).offset(-14);
    }];
}

//开始直播
- (void)createChatRoomAction {
    NTESOpenRoomViewController *chatRoomCtrl = [[NTESOpenRoomViewController alloc]init];
    [self.navigationController pushViewController:chatRoomCtrl animated:YES];
}

//做自动登录
- (void)startLogin {
    __weak typeof(self) weakSelf = self;
//    [SVProgressHUD showWithStatus:@"登录中..."];
    [self doCleanLastChatroom:^(NSError *error) {
        [weakSelf doRequestAccount:^(NTESAccountInfo *accountInfo, NSError *error) {
            if (!error) {
                NELPLogInfo(@"accountInfo:[%@]", accountInfo);
//                weakSelf.status = NTESHomePageProcessDidRequestAccount;
                weakSelf.myAccountInfo = accountInfo;
                [weakSelf doLoginWithAccount:accountInfo.account
                                       token:accountInfo.token];
                weakSelf.createLiveRoomButton.enabled = YES;
            } else {
                [SVProgressHUD showInfoWithStatus:@"登录失败"];
                NetworkStatus netStatus = [NTESDemoSystemManager shareInstance].netStatus;
                [self showNetworkErrorView:(netStatus == NotReachable)];
                NELPLogError(@"[demo] request login info fail.[%@]", error);
            }
        }];
    }];
}

- (void)showNetworkErrorView:(BOOL)show {
    if (show) {
        [self.view addSubview:self.networkErrorView];
    } else {
        [self.networkErrorView removeFromSuperview];
    }
}

- (void)doLoginWithAccount:(NSString *)account
                     token:(NSString *)token {
//    __weak typeof(self) weakSelf = self;
    [[[NIMSDK sharedSDK] loginManager] login:account
                                       token:token
                                  completion:^(NSError *error) {
          if (error == nil) {
              NELPLogInfo(@"[demo] login success!");
//              weakSelf.status = NTESHomePageProcessDidLogin;
//              [SVProgressHUD dismiss];
          } else {
              [SVProgressHUD showInfoWithStatus:@"登录失败"];
              NetworkStatus netStatus = [NTESDemoSystemManager shareInstance].netStatus;
              [self showNetworkErrorView:(netStatus == NotReachable)];
              NELPLogError(@"[demo] login failed!%@", error);
          }
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

#pragma mark - stateViewDidReceiveRetryAction
- (void)stateViewDidReceiveRetryAction {
    [self showNetworkErrorView:NO];
    [self startLogin];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSourceArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NTESHomeTableViewCell *cell = [NTESHomeTableViewCell loadHomePageCellWithTableView:tableView];
    cell.homePageModel = self.dataSourceArray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {//语聊房
        NTESLiveListMainViewController *chatRoomCtrl = [[NTESLiveListMainViewController alloc]initWithSelectType:NTESCreateRoomTypeChatRoom];
        [self.navigationController pushViewController:chatRoomCtrl animated:YES];
    }else if (indexPath.row == 1){//ktv
        NTESLiveListMainViewController *ktvRoomCtrl = [[NTESLiveListMainViewController alloc]initWithSelectType:NTESCreateRoomTypeKTV];
        [self.navigationController pushViewController:ktvRoomCtrl animated:YES];
    }
}

#pragma mark - lazyMethod
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView =[[UITableView alloc] initWithFrame:CGRectZero
                                                 style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.showsHorizontalScrollIndicator = NO;
        _tableView.backgroundColor = UIColor.whiteColor;
        _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        _tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.rowHeight = 114;
    }
    return _tableView;
}


- (UILabel *)titleLable {
    if (!_titleLable) {
        _titleLable = [NTESViewFactory createLabelFrame:CGRectZero title:@"云信Live" textColor:UIColorFromRGB(0x222222) textAlignment:NSTextAlignmentCenter font:Font_Size(@"PingFangSC-Medium", 17)];
        if ([NTESDeviceSizeInfo isIPhoneXSeries]) {
            _titleLable.frame = CGRectMake(0, [NTESDeviceSizeInfo get_iPhoneNavBarHeight], UIScreenWidth, 44);
        } else {
            _titleLable.frame = CGRectMake(0, statusBarHeight, UIScreenWidth, 44);
        }
        _titleLable.backgroundColor = UIColor.whiteColor;
    }
    return _titleLable;
}

- (UIButton *)createLiveRoomButton {
    if (!_createLiveRoomButton) {
        _createLiveRoomButton = [NTESViewFactory createBtnFrame:CGRectZero title:@"" bgImage:@"start_toLive_icon" selectBgImage:@"" image:@"" target:self action:@selector(createChatRoomAction)];
//        _createLiveRoomButton.enabled = NO;
    }
    return _createLiveRoomButton;
}

- (NSArray *)dataSourceArray {
    if (!_dataSourceArray) {
        _dataSourceArray = @[
            @{
                @"title":@"语音聊天室",
                @"subtitle":@"从单人直播到主播间PK、观众连麦多种玩法",
                @"bgImageName":@"homePage_chatRoom_cellBgIcon"
            },
            @{
                @"title":@"KTV",
                @"subtitle":@"从单人直播到主播间PK、观众连麦多种玩法",
                @"bgImageName":@"homePage_ktv_cellBgIcon"
            }
        ];
    }
    return _dataSourceArray;
}

- (NTESHomePageStateView *)networkErrorView {
    if (!_networkErrorView) {
        _networkErrorView = [[NTESHomePageStateView alloc] initWithFrame:self.view.bounds];
        _networkErrorView.mode = NTESHomePageStateViewNetworkError;
        _networkErrorView.delegate = self;
    }
    return _networkErrorView;
}

@end
