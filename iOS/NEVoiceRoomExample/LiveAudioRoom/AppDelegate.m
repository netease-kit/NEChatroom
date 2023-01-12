// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "AppDelegate.h"
//  #import <NEVoiceRoomUIKit/NEVoiceRoomUIManager.h>
#import "AppDelegate+UIWindow.h"
#import "AppDelegate+VoiceRoom.h"
#import "AppKey.h"

@interface AppDelegate ()


@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  // Override point for customization after application launch.
  [self vr_initWindow];
  [self vr_setupVoiceRoom];

  [application setIdleTimerDisabled:YES];
  return YES;
}
- (UIInterfaceOrientationMask)application:(UIApplication *)application
    supportedInterfaceOrientationsForWindow:(nullable UIWindow *)window {
  return UIInterfaceOrientationMaskPortrait;
}


@end
