//
//  NTESAuthorityHelper.m
//  NERtcAudioChatroom
//
//  Created by Netease on 2019/3/20.
//  Copyright © 2019年 netease. All rights reserved.
//

#import "NTESAuthorityHelper.h"
#import <AVFoundation/AVFoundation.h>
#import "NTESDemoSystemManager.h"

@import CoreTelephony;

@interface NTESAuthorityHelper ()

@property (nonatomic, strong) CTCellularData *cellularData;

@end

@implementation NTESAuthorityHelper

+ (instancetype)shareInstance {
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NTESAuthorityHelper alloc] init];
    });
    return instance;
}

+ (void)startNetworkAuthorityLinstener {
    [[NTESAuthorityHelper shareInstance] startNetworkAuthorityListener];
}

- (void)startNetworkAuthorityListener {
    _cellularData = [[CTCellularData alloc] init];
    _cellularData.cellularDataRestrictionDidUpdateNotifier = ^(CTCellularDataRestrictedState state){
        if (state == kCTCellularDataRestricted) {
            if ([[NTESDemoSystemManager shareInstance] netStatus] == NotReachable) {
                [NTESAuthorityHelper showWarnningAlert:@"网络设置出错，请前往系统设置进行修改"];
            }
        }
    };
}

+ (BOOL)checkMicAuthority {
    BOOL isAvalible = NO;
    
    NSString *mediaType = AVMediaTypeAudio;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    
    //用户尚未授权->申请权限
    if (authStatus == AVAuthorizationStatusNotDetermined)
    {
        [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
            if(!granted) //没有授权
            {
                [NTESAuthorityHelper showWarnningAlert:@"麦克风权限未打开，请前往系统设置进行修改"];//提示用户开启麦克风权限
            }
        }];
    }
    //用户已经授权
    else if (authStatus == AVAuthorizationStatusAuthorized)
    {
        isAvalible = YES;
    }
    //用户拒绝授权
    else
    {
        [NTESAuthorityHelper showWarnningAlert:@"麦克风权限未打开，请前往系统设置进行修改"];//提示用户开启麦克风权限
    }
    return isAvalible;
}

+ (void)goSettingPage {
    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if ([[UIApplication sharedApplication] canOpenURL:url])
    {
        [[UIApplication sharedApplication] openURL:url];
    }
}

+ (void)showWarnningAlert:(NSString *)message {
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    
    UIAlertAction *sure = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [NTESAuthorityHelper goSettingPage];
    }];
    
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil
                                                                     message:message
                                                              preferredStyle:UIAlertControllerStyleAlert];
    [alertVC addAction:cancel];
    [alertVC addAction:sure];
    UINavigationController *rootVC = (UINavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *topVC = [rootVC.viewControllers lastObject];
    if (IS_IPAD) {
        UIPopoverPresentationController *popPresenter = [alertVC popoverPresentationController];
        popPresenter.sourceView = topVC.view;
        popPresenter.sourceRect = topVC.view.bounds;
    }
    ntes_main_sync_safe(^{
        [topVC presentViewController:alertVC animated:YES completion:nil];
    });
}

@end
