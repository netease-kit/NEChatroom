// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <NEListenTogetherUIKit/NEListenTogetherUIManager.h>
#import <NEOrderSong/NEOrderSong-Swift.h>
#import <NEVoiceRoomUIKit/NEVoiceRoomUIManager.h>
#import "AppDelegate+VoiceRoom.h"
#import "AppKey.h"
@interface AppDelegate (VoiceRoom) <NEVoiceRoomUIDelegate, NEListenTogetherUIDelegate>

@end

@implementation AppDelegate (VoiceRoom)
- (NSString *)getAppkey {
#ifdef DEBUG
  if (isOverSea) {
    return APP_KEY_OVERSEA;
  } else {
    return @"90ba571cc31df96a086a00a54432cfcb";
  }
#else
  if (isOverSea) {
    return APP_KEY_OVERSEA;
  } else {
    return APP_KEY_MAINLAND;
  }
#endif
}
- (void)vr_setupLoginSDK {
  [NEVoiceRoomUIManager.sharedInstance
      loginWithAccount:accountId
                 token:accessToken
              nickname:@""
              callback:^(NSInteger code, NSString *_Nullable msg, id _Nullable objc) {
                if (code != 0) {
                  NSLog(@"登录失败");
                } else {
                  NSLog(@"登录成功");
                  /// 登录后初始化点歌台的配置
                  [[NEOrderSong getInstance] loginInitConfig:accountId
                                                       token:accessToken
                                                    callback:nil];
                  /// 一起听 Manager 登录处理，不做真实登录
                  [[NEListenTogetherUIManager sharedInstance]
                      loginWithAccount:accountId
                                 token:accessToken
                              nickname:@""
                           resumeLogin:YES
                              callback:^(NSInteger code, NSString *_Nullable msg, id _Nullable obj){

                              }];
                }
              }];
}

- (void)vr_setupVoiceRoom {
  NEVoiceRoomKitConfig *config = [[NEVoiceRoomKitConfig alloc] init];
  config.appKey = [self getAppkey];
#ifdef DEBUG
  config.extras = @{@"serverUrl" : @"test"};
#endif
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

  NEListenTogetherKitConfig *listenTogetherConfig = [[NEListenTogetherKitConfig alloc] init];
  listenTogetherConfig.appKey = [self getAppkey];
#ifdef DEBUG
  listenTogetherConfig.extras = @{@"serverUrl" : @"test"};
#endif
  if (isOutsea) {
    listenTogetherConfig.extras = @{@"serverUrl" : @"oversea"};
  }
  [[NEListenTogetherUIManager sharedInstance]
      initializeWithConfig:listenTogetherConfig
                  callback:^(NSInteger code, NSString *_Nullable msg, id _Nullable objc){

                  }];
  [NEListenTogetherUIManager sharedInstance].delegate = self;

  /// 点歌台属配置初始化
  NEOrderSongConfig *orderSongConfig = [[NEOrderSongConfig alloc] init];
  orderSongConfig.appKey = [self getAppkey];
#ifdef DEBUG
  orderSongConfig.extras = @{@"serverUrl" : @"test"};
#endif
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
