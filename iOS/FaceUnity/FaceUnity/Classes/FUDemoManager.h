// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "FUDefines.h"
#import "FUManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface FUDemoManager : NSObject

+ (FUDemoManager *)shareManager;
/// Initializer
/// @param controller 目标控制器
/// @param originY Demo视图在目标视图上的Y坐标（这里指的是底部功能选择栏的Y坐标，X坐标默认为0）
- (void)showInTargetController:(UIViewController *)controller originY:(CGFloat)originY;

- (void)show;
- (void)hide;

@end

NS_ASSUME_NONNULL_END
