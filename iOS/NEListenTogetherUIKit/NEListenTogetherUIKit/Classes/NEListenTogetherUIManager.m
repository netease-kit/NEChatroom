// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEListenTogetherUIManager.h"
#import <NEListenTogetherKit/NEListenTogetherLog.h>
#import "NEListenTogetherUILog.h"

@interface NEListenTogetherUIManager () <NEListenTogetherAuthListener>

@end

@implementation NEListenTogetherUIManager

+ (NEListenTogetherUIManager *)sharedInstance {
  static NEListenTogetherUIManager *instance = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    instance = [[NEListenTogetherUIManager alloc] init];
  });
  return instance;
}
- (instancetype)init {
  self = [super init];
  if (self) {
  }
  return self;
}
- (void)initializeWithConfig:(NEListenTogetherKitConfig *)config
                    callback:(void (^)(NSInteger, NSString *_Nullable, id _Nullable))callback {
  self.config = config;
  [NEListenTogetherKit.getInstance initializeWithConfig:config callback:callback];
  [NEListenTogetherLog setUp:config.appKey];
  [NEListenTogetherUILog setUp:config.appKey];
}

- (void)loginWithAccount:(NSString *)account
                   token:(NSString *)token
                nickname:(NSString *)nickname
             resumeLogin:(BOOL)resumeLogin
                callback:(void (^)(NSInteger, NSString *_Nullable, id _Nullable))callback {
  self.nickname = nickname;
  [NEListenTogetherKit.getInstance login:account
                                   token:token
                             resumeLogin:resumeLogin
                                callback:callback];
}

- (void)logoutWithCallback:(void (^)(NSInteger, NSString *_Nullable, id _Nullable))callback {
  [NEListenTogetherKit.getInstance logoutWithCallback:callback];
}

- (bool)isLoggedIn {
  return [[NEListenTogetherKit getInstance] isLoggedIn];
}

- (void)onVoiceRoomAuthEvent:(enum NEListenTogetherAuthEvent)event {
  if ([self.delegate respondsToSelector:@selector(onListenTogetherClientEvent:)]) {
    [self.delegate onListenTogetherClientEvent:event];
  }
}

- (UINavigationController *)createViewController {
  UINavigationController *c =
      [[UINavigationController alloc] initWithRootViewController:[[UIViewController alloc] init]];
  c.modalPresentationStyle = UIModalPresentationFullScreen;
  return c;
}

- (UINavigationController *)roomListViewController {
  UINavigationController *c =
      [[UINavigationController alloc] initWithRootViewController:[[UIViewController alloc] init]];
  if (@available(iOS 13.0, *)) {
    c.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
  }
  c.modalPresentationStyle = UIModalPresentationFullScreen;
  return c;
}

@end
