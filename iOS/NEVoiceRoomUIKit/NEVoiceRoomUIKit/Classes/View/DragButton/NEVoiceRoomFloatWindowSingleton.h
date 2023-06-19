// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "NEVoiceRoomViewController.h"

// typedef void(^CallBack)(void);

@interface NEVoiceRoomFloatWindowSingleton : NSObject
//@property (nullable, nonatomic, copy)CallBack floatWindowCallBack;
+ (nonnull instancetype)Ins;
- (void)addViewControllerTarget:(NEVoiceRoomViewController *_Nullable)controller;
- (void)setNetImage:(NSString *_Nonnull)icon title:(NSString *_Nonnull)title;
//- (UIViewController *_Nullable)getViewControllerTarget;
- (void)setHideWindow:(BOOL)hide;
- (BOOL)hasFloatingView;

- (void)clickCloseButton:(BOOL)pop callback:(void (^_Nullable)(void))callback;

// TEST
- (void)dragButtonClicked:(UIButton *_Nullable)sender;
- (NSString *_Nullable)getRoomUuid;

@end
