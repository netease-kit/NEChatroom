//
//  NTESProgressHUD.m
//  NEChatroom-iOS-ObjC
//
//  Created by vvj on 2021/2/3.
//  Copyright © 2021 netease. All rights reserved.
//

#import "NTESProgressHUD.h"

@implementation NTESProgressHUD


+ (void)defaultSet {
    [self setDefaultMaskType:SVProgressHUDMaskTypeClear];//默认背景样式
    [self setDefaultStyle:SVProgressHUDStyleCustom];
    [self setMinimumSize:CGSizeZero];
    [self setCornerRadius:5];
    [self setMaximumDismissTimeInterval:2];
    [self setMinimumDismissTimeInterval:1];
    [[self class] resetOffsetFromCenter];
    [self setFont:TextFont_14];
    [self setForegroundColor:[UIColor whiteColor]];
    [self setBackgroundColor:UIColorFromRGBA(0x000000, 0.6)];
}

+ (void)ntes_show {
    [self defaultSet];
    [self show];
}

/**
 显示加载等待视图（顶部转圈，下面显示文字）
 @param status 等待视图下面的提示文字
*/
+ (void)ntes_showWithstatus:(NSString *)status {
    [self defaultSet];
    [[self class] setMinimumSize:CGSizeMake(120, 100)];
    [[self class] setRingRadius:16.5];
    [[self class] showWithStatus:status];
}

+ (void)ntes_dismiss {
    [self defaultSet];
    [self dismiss];
}

+ (void)ntes_showHUD:(NSString *)status {
    [self defaultSet];
    [self showWithStatus:status];
}

+ (void)ntes_showInfo:(NSString *)status {
    [self defaultSet];
    [self showImage:[UIImage imageNamed:@""] status:status];
}

+ (void)ntes_showSuccess:(NSString *)status {
    [self defaultSet];
    [self setMinimumSize:CGSizeMake(120, 100)];
    [self setImageViewSize:CGSizeMake(33, 33)];
    [self setSuccessImage: [UIImage imageNamed:@"progress_success"]];
    [self showSuccessWithStatus:status];
}

+ (void)ntes_showError:(NSString *)status {
    [self defaultSet];
    [self showErrorWithStatus:status];
}

+ (void)ntes_showInfo:(NSString *)status style:(SVProgressHUDStyle)style {
    [[self class] resetOffsetFromCenter];
    [self setDefaultStyle:style];
    [self showImage:[UIImage imageNamed:@""] status:status];
}

+ (void)ntes_showSuccess:(NSString *)status style:(SVProgressHUDStyle)style {
    [[self class] resetOffsetFromCenter];
    [self setDefaultStyle:style];
    [self showSuccessWithStatus:status];
}

+ (void)ntes_showError:(NSString *)status style:(SVProgressHUDStyle)style {
    [[self class] resetOffsetFromCenter];
    [self setDefaultStyle:style];
    [self showErrorWithStatus:status];
}

+ (void)ntes_showHUD:(NSString *)status style:(SVProgressHUDStyle)style {
    [[self class] resetOffsetFromCenter];
    [self setDefaultStyle:style];
    [self showWithStatus:status];
}

@end
