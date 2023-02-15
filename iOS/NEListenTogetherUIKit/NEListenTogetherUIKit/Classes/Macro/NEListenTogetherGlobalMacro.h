// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>

#ifndef NEListenTogetherGlobalMacro_h
#define NEListenTogetherGlobalMacro_h

// 隐私政策URL
static NSString *kPrivatePolicyURL =
    @"https://reg.163.com/agreement_mobile_ysbh_wap.shtml?v=20171127";
// 用户协议URL
static NSString *kUserAgreementURL = @"http://yunxin.163.com/clauses";

#define UIScreenWidth ([UIScreen mainScreen].bounds.size.width)
#define UIScreenHeight ([UIScreen mainScreen].bounds.size.height)
#define UIWidthAdapter(x) ((x)*UIScreenWidth / 375.0)
#define UIHeightAdapter(x) ((x)*UIScreenHeight / 667.0)
#define UIMinAdapter(x) (UIScreenWidth > UIScreenHeight ? UIHeightAdapter(x) : UIWidthAdapter(x))
#define UIMaxAdapter(x) (UIScreenWidth < UIScreenHeight ? UIHeightAdapter(x) : UIWidthAdapter(x))
// 状态栏的高度
#define statusBarHeight [UIApplication sharedApplication].statusBarFrame.size.height
#define IPHONE_X_HairHeight 44
#define KStatusHeight [[UIApplication sharedApplication] statusBarFrame].size.height
#define KNavBottom KStatusHeight + 44

#define IPHONE_X                                                                                  \
  ({                                                                                              \
    BOOL isPhoneX = NO;                                                                           \
    if (@available(iOS 11.0, *)) {                                                                \
      isPhoneX = [[UIApplication sharedApplication] delegate].window.safeAreaInsets.bottom > 0.0; \
    }                                                                                             \
    (isPhoneX);                                                                                   \
  })

#define IS_IPAD ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)

/// 安全区高度
#define kSafeAreaHeight                                                               \
  ({                                                                                  \
    CGFloat height = 0;                                                               \
    if (@available(iOS 11.0, *)) {                                                    \
      height = UIApplication.sharedApplication.delegate.window.safeAreaInsets.bottom; \
    }                                                                                 \
    (height);                                                                         \
  })

/// weakSelf strongSelf reference
#define WEAK_SELF(weakSelf) __weak __typeof(&*self) weakSelf = self;
#define STRONG_SELF(strongSelf) __strong __typeof(&*weakSelf) strongSelf = weakSelf;

#pragma mark - UIColor宏定义
#define UIColorFromRGBA(rgbValue, alphaValue)                          \
  [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0 \
                  green:((float)((rgbValue & 0x00FF00) >> 8)) / 255.0  \
                   blue:((float)(rgbValue & 0x0000FF)) / 255.0         \
                  alpha:alphaValue]

#define HEXCOLOR(rgbValue) UIColorFromRGBA(rgbValue, 1.0)

// 线程
void ntes_main_sync_safe(dispatch_block_t block);
void ntes_main_async_safe(dispatch_block_t block);

#define kVoiceRoomUIJoinRoom @"com.voiceroomui.joinroom"
#define kVoiceRoomUILeaveRoom @"com.voiceroomui.leaveroom"

// 字符串判空
bool isEmptyString(NSString *string);

/// 配置日志
void setupLogger(void);

#endif /* NEListenTogetherGlobalMacro_h */
