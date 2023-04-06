// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <NEOrderSong/NEOrderSong-Swift.h>
#import <NEVoiceRoomUIKit/NEVoiceRoomUIManager.h>
#import "AppDelegate+VoiceRoom.h"
#import "AppKey.h"
@interface AppDelegate (VoiceRoom) <NEVoiceRoomUIDelegate>

@end

@implementation AppDelegate (VoiceRoom)
- (NSString *)getAppkey {
  if (isOverSea) {
    return APP_KEY_OVERSEA;
  } else {
    return APP_KEY_MAINLAND;
  }
}
- (void)vr_setupLoginSDK {
  [NEVoiceRoomUIManager.sharedInstance
      loginWithAccount:accountId
                 token:accessToken
              nickname:@"nickname"
              callback:^(NSInteger code, NSString *_Nullable msg, id _Nullable objc) {
                if (code != 0) {
                  NSLog(@"登录失败");
                } else {
                  NSLog(@"登录成功");
                  /// 登录后初始化点歌台的配置
                  [[NEOrderSong getInstance] loginInitConfig:accountId
                                                       token:accessToken
                                                    callback:nil];
                }
              }];
}

- (void)vr_setupVoiceRoom {
  NEVoiceRoomKitConfig *config = [[NEVoiceRoomKitConfig alloc] init];
  config.appKey = [self getAppkey];
  BOOL isOutsea = isOverSea;
  if (isOutsea) {
    config.extras = @{@"serverUrl" : @"oversea"};
  }
  [NEVoiceRoomUIManager.sharedInstance
      initializeWithConfig:config
                  callback:^(NSInteger code, NSString *_Nullable msg, id _Nullable objc) {
                    if (code != 0) return;

                    dispatch_async(dispatch_get_main_queue(), ^{
                      [self vr_setupLoginSDK];
                    });
                  }];
  [NEVoiceRoomUIManager sharedInstance].delegate = self;

  /// 点歌台属配置初始化
  NEOrderSongConfig *orderSongConfig = [[NEOrderSongConfig alloc] init];
  orderSongConfig.appKey = [self getAppkey];
  if (isOutsea) {
    orderSongConfig.extras = @{@"serverUrl" : @"oversea"};
  }
  [[NEOrderSong getInstance]
      initializeWithConfig:orderSongConfig
                  callback:^(NSInteger code, NSString *_Nullable msg, id _Nullable objc){

                  }];
}
- (void)onVoiceRoomClientEvent:(NEVoiceRoomClientEvent)event {
  if (event == NEVoiceRoomClientEventKicOut) {
    NSLog(@"账号被异地登录了,请重新启动登录");
  }
}
@end
