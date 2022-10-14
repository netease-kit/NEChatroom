// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <NEVoiceRoomUIKit/NEVoiceRoomUIManager.h>
#import <YXLogin/YXLogin.h>
#import "AppDelegate+VoiceRoom.h"
#import "AppKey.h"
@interface AppDelegate (VoiceRoom) <NEVoiceRoomUIDelegate>

@end

@implementation AppDelegate (VoiceRoom)
- (NSString *)getAppkey {
  BOOL isOutsea = [[NSUserDefaults standardUserDefaults] boolForKey:isOutOdChinaDataCenter];  if (isOutsea) {
    return @"";
  } else {
    return @"";
  }
}
- (void)vr_setupLoginSDK {
  BOOL isOutsea = [[NSUserDefaults standardUserDefaults] boolForKey:isOutOdChinaDataCenter];
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
                        }
                      }];
        }];
  }
}

- (void)vr_setupVoiceRoom {
  NEVoiceRoomKitConfig *config = [[NEVoiceRoomKitConfig alloc] init];
  config.appKey = [self getAppkey];
  BOOL isOutsea = [[NSUserDefaults standardUserDefaults] boolForKey:isOutOdChinaDataCenter];
  if (isOutsea) {

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
