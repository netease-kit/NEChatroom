// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <NEListenTogetherUIKit/NEListenTogetherUIManager.h>
#import <NEOrderSong/NEOrderSong-Swift.h>
#import <NEVoiceRoomUIKit/NEVoiceRoomUIManager.h>
#import <YXLogin/YXLogin.h>
#import "AppDelegate+VoiceRoom.h"
#import "AppKey.h"
@interface AppDelegate (VoiceRoom) <NEVoiceRoomUIDelegate, NEListenTogetherUIDelegate>

@end

@implementation AppDelegate (VoiceRoom)
- (NSString *)getAppkey {
  BOOL isOutsea = [[NSUserDefaults standardUserDefaults] boolForKey:isOutOfChinaDataCenter];
  if (isOutsea) {
    return @"";
  } else {
    return @"";
  }
}
- (void)vr_setupLoginSDK {
  BOOL isOutsea = [[NSUserDefaults standardUserDefaults] boolForKey:isOutOfChinaDataCenter];
  YXConfig *config = [YXConfig new];
  config.appKey = [self getAppkey];
  config.supportInternationalize = YES;
  config.isOnline = YES;
  config.parentScope = [NSNumber numberWithInt:5];
  config.scope = [NSNumber numberWithInt:4];
  config.type = YXLoginPhone;
  AuthorManager *LoginManager = [AuthorManager shareInstance];
  [LoginManager initAuthorWithConfig:config];
  /// 自动登录
  if ([LoginManager canAutologin]) {
    [LoginManager
        autoLoginWithCompletion:^(YXUserInfo *_Nullable userinfo, NSError *_Nullable error) {
          if (error) return;
          NSLog(@"统一登录sdk登录成功");
          [NEVoiceRoomUIManager.sharedInstance
              loginWithAccount:userinfo.accountId
                         token:userinfo.accessToken
                      nickname:userinfo.nickname
                      callback:^(NSInteger code, NSString *_Nullable msg, id _Nullable objc) {
                        if (code != 0) {
                          [LoginManager logoutWithCompletion:^(YXUserInfo *_Nullable userinfo,
                                                               NSError *_Nullable error){

                          }];
                        } else {
                          /// 登录后初始化点歌台的配置
                          [[NEOrderSong getInstance] loginInitConfig:userinfo.accountId
                                                               token:userinfo.accessToken
                                                            callback:nil];
                          /// 一起听 Manager 登录处理，不做真实登录
                          [NEListenTogetherUIManager.sharedInstance
                              loginWithAccount:userinfo.accountId
                                         token:userinfo.accessToken
                                      nickname:userinfo.nickname
                                      callback:^(NSInteger code, NSString *_Nullable msg,
                                                 id _Nullable obj){

                                      }];
                        }
                      }];
        }];
  } else {
    [LoginManager
        startLoginWithCompletion:^(YXUserInfo *_Nullable userinfo, NSError *_Nullable error) {
          if (error) return;
          NSLog(@"统一登录sdk登录成功");
          [NEVoiceRoomUIManager.sharedInstance
              loginWithAccount:userinfo.accountId
                         token:userinfo.accessToken
                      nickname:userinfo.nickname
                      callback:^(NSInteger code, NSString *_Nullable msg, id _Nullable objc) {
                        if (code != 0) {
                          [LoginManager logoutWithCompletion:^(YXUserInfo *_Nullable userinfo,
                                                               NSError *_Nullable error){

                          }];
                        } else {
                          /// 登录后初始化点歌台的配置
                          [[NEOrderSong getInstance] loginInitConfig:userinfo.accountId
                                                               token:userinfo.accessToken
                                                            callback:nil];
                          /// 一起听 Manager 登录处理，不做真实登录
                          [NEListenTogetherUIManager.sharedInstance
                              loginWithAccount:userinfo.accountId
                                         token:userinfo.accessToken
                                      nickname:userinfo.nickname
                                      callback:^(NSInteger code, NSString *_Nullable msg,
                                                 id _Nullable obj){

                                      }];
                        }
                      }];
        }];
  }
}

- (void)vr_setupVoiceRoom {
  NEVoiceRoomKitConfig *config = [[NEVoiceRoomKitConfig alloc] init];
  config.appKey = [self getAppkey];
  BOOL isOutsea = [[NSUserDefaults standardUserDefaults] boolForKey:isOutOfChinaDataCenter];
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
    [[AuthorManager shareInstance]
        logoutWithCompletion:^(YXUserInfo *_Nullable userinfo, NSError *_Nullable error) {
          [[AuthorManager shareInstance]
              startLoginWithCompletion:^(YXUserInfo *_Nullable userinfo, NSError *_Nullable error) {
                [NEVoiceRoomUIManager.sharedInstance
                    loginWithAccount:userinfo.accountId
                               token:userinfo.accessToken
                            nickname:userinfo.nickname
                            callback:^(NSInteger code, NSString *_Nullable msg, id _Nullable objc) {
                              if (code == 0) {
                                /// 登录后初始化点歌台的配置
                                [[NEOrderSong getInstance] loginInitConfig:userinfo.accountId
                                                                     token:userinfo.accessToken
                                                                  callback:nil];
                                /// 一起听 Manager 登录处理，不做真实登录
                                [NEListenTogetherUIManager.sharedInstance
                                    loginWithAccount:userinfo.accountId
                                               token:userinfo.accessToken
                                            nickname:userinfo.nickname
                                            callback:^(NSInteger code, NSString *_Nullable msg,
                                                       id _Nullable obj){

                                            }];
                                dispatch_async(dispatch_get_main_queue(), ^{
                                  [NSNotificationCenter.defaultCenter
                                      postNotification:[NSNotification notificationWithName:@"Login"
                                                                                     object:nil]];
                                });
                              }
                            }];
              }];
        }];
  }
}
@end
