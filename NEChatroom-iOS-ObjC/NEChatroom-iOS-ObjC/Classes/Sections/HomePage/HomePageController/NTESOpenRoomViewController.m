//
//  NTESOpenRoomViewController.m
//  NEChatroom-iOS-ObjC
//
//  Created by vvj on 2021/1/28.
//  Copyright © 2021 netease. All rights reserved.
//

#import "NTESOpenRoomViewController.h"
#import "NTESLiveRoomViewController.h"

#import "NTESCreateRoomNameView.h"
#import "NTESPlanChooseAlertView.h"

#import "NTESDemoService.h"
#import "NTESDataCenter.h"
#import "UIView+Toast.h"

@interface NTESOpenRoomViewController ()<NTESCreateRoomDelegate,NTESPlanChooseDelegate>
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) NTESCreateRoomNameView *createRoomNameView;
@property (nonatomic, strong) UIButton *openLiveButton;
@property (nonatomic, assign) NTESCreateRoomType roomType;
@end

@implementation NTESOpenRoomViewController

- (instancetype)initWithRoomType:(NTESCreateRoomType)roomType {
    self = [super init];
    if (self) {
        self.roomType = roomType;
        [self createRoomResult:roomType];
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.roomType = NTESCreateRoomTypeChatRoom;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

- (void)ntes_initializeConfig {
}

- (void)ntes_bindViewModel {
    @weakify(self)
    [[self.openLiveButton rac_signalForControlEvents:UIControlEventTouchUpInside]subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self)
        [self openRoomAction];
    }];
}

- (void)ntes_addSubViews {
    
    [self.view addSubview:self.bgImageView];
    [self.bgImageView addSubview:self.backButton];
    [self.bgImageView addSubview:self.openLiveButton];
    [self.bgImageView addSubview:self.createRoomNameView];
    
    [self.bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.equalTo(self.view);
    }];
    
    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.top.equalTo(self.view).offset(statusBarHeight +10);
        make.size.mas_equalTo(CGSizeMake(24, 24));
    }];
    
    [self.openLiveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.bottom.equalTo(self.view).offset(-[NTESDeviceSizeInfo get_iPhoneBottomSafeDistance]-20);
        make.height.mas_equalTo(44);
    }];
    
    [self.createRoomNameView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.top.equalTo(self.backButton.mas_bottom).offset(20);
        make.height.mas_equalTo(116);
    }];
}

- (void)popToLastController {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    [self.view endEditing:YES];
}

//开启直播间
- (void)openRoomAction {
    NSString *roomName = [self.createRoomNameView getRoomName];
    if ([NSObject isNullOrNilWithObject:roomName]) {
        [NTESProgressHUD ntes_showInfo:@"房间名称为空"];
        return;
    }
    if (![self isValidRoomName:roomName]) {
        [NTESProgressHUD ntes_showInfo:@"房间名含有非法字符"];
        return;
    }
    if (self.roomType == NTESCreateRoomTypeChatRoom) {
        NTESPlanChooseAlertView *chooseAlertView = [[NTESPlanChooseAlertView alloc]initWithFrame:CGRectMake(0, 0, UIScreenWidth, UIScreenHeight)];
        chooseAlertView.delegate = self;
        [[UIApplication sharedApplication].keyWindow addSubview:chooseAlertView];
    }else {//创建ktv房间
        __weak __typeof(self)weakSelf = self;
        NTESAccountInfo *accountInfo = [NTESDataCenter shareCenter].myAccount;
        
        [[NTESDemoService sharedService] createChatroomWithSid:accountInfo.account roomName:self.createRoomNameView.getRoomName pushType:NTESPushTypeRtc createRoomType:NTESCreateRoomTypeKTV completion:^(NTESChatroomInfo * _Nullable chatroomInfo, NSError * _Nullable error) {
            if (!error) {
                chatroomInfo.audioQuality = NTESAudioQualityHDMusic;
                [NTESDataCenter shareCenter].myCreateChatroom = chatroomInfo;
                [weakSelf showChatRoomVCWithMode:NTESUserModeAnchor
                                            info:chatroomInfo pushType:NTESPushTypeRtc roomType:NTESCreateRoomTypeKTV];
            } else {
                [self.view makeToast:@"创建失败:参数异常" duration:2 position:CSToastPositionCenter];
                NELPLogError(@"[demo] create room request error![%@]", error);
            }
        }];
      
    }
}

//是否有特殊字符
- (BOOL)isValidRoomName:(NSString *)roomName
{
    NSString *regex = @"^[a-zA-Z0-9\u4e00-\u9fa5,\\s+]{1,20}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    if([pred evaluateWithObject:roomName]){
        return YES;
    }
    return NO;
}

//show 房间
- (void)showChatRoomVCWithMode:(NTESUserMode)mode
                          info:(NTESChatroomInfo *)info
                          pushType:(NTESPushType)pushType
                      roomType:(NTESCreateRoomType)roomType {
    NTESLiveRoomViewController *vc = [[NTESLiveRoomViewController alloc]initWithChatroomInfo:info accountInfo:[NTESDataCenter shareCenter].myAccount userMode:mode pushType:pushType roomType:roomType];
     //        vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self.openLiveButton cutViewRounded:UIRectCornerAllCorners cornerRadii:CGSizeMake(30, 30)];
    [self.createRoomNameView cutViewRounded:UIRectCornerAllCorners cornerRadii:CGSizeMake(8, 8)];
}


#pragma mark - NTESCreateRoomDelegate
-(void)createRoomResult:(NTESCreateRoomType)roomType {
    self.roomType = roomType;
    if (roomType == NTESCreateRoomTypeKTV) {
        self.bgImageView.image = [UIImage imageNamed:@"homePage_ktvBgIcon"];
        [self.openLiveButton setGradientBackgroundWithColors:@[UIColorFromRGB(0x4D88FF),UIColorFromRGB(0xD2A6FF)] locations:nil startPoint:CGPointMake(0, 0) endPoint:CGPointMake(1, 0)];
    }else if (roomType == NTESCreateRoomTypeChatRoom){
        self.bgImageView.image = [UIImage imageNamed:@"homePage_chatRoomBgIcon"];
        [self.openLiveButton setGradientBackgroundWithColors:@[UIColorFromRGB(0x6699FF),UIColorFromRGB(0x30F2F2)] locations:nil startPoint:CGPointMake(0, 0) endPoint:CGPointMake(1, 0)];
    }
}

#pragma mark - NTESPlanChooseDelegate
//创建房间类型 rtc cdn
- (void)planChooseResult:(NTESPushType)selectIndex {
    __weak __typeof(self)weakSelf = self;
//    self.pushType = selectIndex;
    selectIndex == NTESPushTypeCdn?NELPLogInfo(@"创建了CDN房间"):NELPLogInfo(@"创建了RTC房间");

     NTESAccountInfo *accountInfo = [NTESDataCenter shareCenter].myAccount;
    [[NTESDemoService sharedService] createChatroomWithSid:accountInfo.account roomName:self.createRoomNameView.getRoomName pushType:selectIndex createRoomType:NTESCreateRoomTypeChatRoom completion:^(NTESChatroomInfo * _Nullable chatroomInfo, NSError * _Nullable error) {
        if (!error) {
            chatroomInfo.audioQuality = NTESAudioQualityHDMusic;
            [NTESDataCenter shareCenter].myCreateChatroom = chatroomInfo;
            [weakSelf showChatRoomVCWithMode:NTESUserModeAnchor
                                        info:chatroomInfo pushType:selectIndex roomType:NTESCreateRoomTypeChatRoom];
        } else {
            [self.view makeToast:@"创建房间失败!" duration:2 position:CSToastPositionCenter];
            NELPLogError(@"[demo] create room request error![%@]", error);
        }
    }];
}


#pragma mark - lazyMethod
- (UIImageView *)bgImageView {
    if (!_bgImageView) {
        _bgImageView = [NTESViewFactory createImageViewFrame:CGRectZero imageName:@"homePage_chatRoomBgIcon"];
        _bgImageView.userInteractionEnabled = YES;
    }
    return _bgImageView;
}

-(NTESCreateRoomNameView *)createRoomNameView {
    if (!_createRoomNameView) {
        _createRoomNameView = [[NTESCreateRoomNameView alloc]init];
        _createRoomNameView.roomType = self.roomType;
        _createRoomNameView.delegate = self;
    }
    return _createRoomNameView;
}

- (UIButton *)backButton {
    if (!_backButton) {
        _backButton = [NTESViewFactory createBtnFrame:CGRectZero title:@"" bgImage:@"homePage_backIcon" selectBgImage:@"" image:@"" target:self action:@selector(popToLastController)];
    }
    return _backButton;
}

- (UIButton *)openLiveButton {
    if (!_openLiveButton) {
        _openLiveButton = [NTESViewFactory createSystemBtnFrame:CGRectZero title:@"开启房间" titleColor:UIColor.whiteColor backgroundColor:nil target:nil action:nil];
        [_openLiveButton setGradientBackgroundWithColors:@[UIColorFromRGB(0x6699FF),UIColorFromRGB(0x30F2F2)] locations:nil startPoint:CGPointMake(0, 0) endPoint:CGPointMake(1, 0)];
       
    }
    return _openLiveButton;
}
@end
