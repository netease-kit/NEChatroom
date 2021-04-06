//
//  NTESProgressHUD.h
//  NEChatroom-iOS-ObjC
//
//  Created by vvj on 2021/2/3.
//  Copyright © 2021 netease. All rights reserved.
//
#import <SVProgressHUD/SVProgressHUD.h>

@interface NTESProgressHUD : SVProgressHUD

/**
 只显示加载等待视图
 */
+ (void)ntes_show;

/**
显示加载等待视图（顶部转圈，下面显示文字）
 @param status 等待视图下面的提示文字
*/
+ (void)ntes_showWithstatus:(NSString *)status;

/**
  视图消失
 */
+ (void)ntes_dismiss;

/**
 显示带提示信息的加载等待视图
 
 @param status 提示文字
 */
+ (void)ntes_showHUD:(NSString *)status;

/**
 显示提示信息

 @param status 提示文字
 */
+ (void)ntes_showInfo:(NSString *)status;

/**
 显示成功提示

 @param status 成功提示文字
 */
+ (void)ntes_showSuccess:(NSString *)status;

/**
 显示错误提示

 @param status 错误提示文字
 */
+ (void)ntes_showError:(NSString *)status;

/**
 显示提示信息(可更改显示样式)

 @param status 提示文字
 @param style 显示样式
 */
+ (void)ntes_showInfo:(NSString *)status style:(SVProgressHUDStyle)style;

/**
 显示成功提示信息(可更改样式)

 @param status 提示文字
 @param style 显示样式
 */
+ (void)ntes_showSuccess:(NSString *)status style:(SVProgressHUDStyle)style;

/**
 显示错误提示信息(可更改样式)
 
 @param status 提示文字
 @param style 显示样式
 */
+ (void)ntes_showError:(NSString *)status style:(SVProgressHUDStyle)style;

/**
 显示加载等待提示视图(可更改样式)
 
 @param status 提示文字
 @param style 显示样式
 */
+ (void)ntes_showHUD:(NSString *)status style:(SVProgressHUDStyle)style;

@end
