// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>
#import <NEVoiceRoomKit/NEVoiceRoomKit-Swift.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 登录事件枚举
typedef NS_ENUM(NSInteger, NEVoiceRoomClientEvent) {
  /// 被踢出登录
  NEVoiceRoomClientEventKicOut,
  /// 服务器禁止登录
  NEVoiceRoomClientEventForbidden,
  /// 账号或密码错误
  NEVoiceRoomClientEventAccountTokenError,
  /// 登录成功
  NEVoiceRoomClientEventLoggedIn,
  /// 未登录
  NEVoiceRoomClientEventLoggedOut,
  /// 授权错误
  NEVoiceRoomClientEventIncorrectToken,
  /// Token过期
  NEVoiceRoomClientEventTokenExpored,
};

@protocol NEVoiceRoomUIDelegate <NSObject>

- (void)onVoiceRoomClientEvent:(NEVoiceRoomClientEvent)event;
- (void)onVoiceRoomJoinRoom;
- (void)onVoiceRoomLeaveRoom;

@end

@interface NEVoiceRoomUIManager : NSObject

@property(nonatomic, copy) NSString *nickname;

@property(nonatomic, assign, readonly) bool isLoggedIn;

@property(nonatomic, weak) id<NEVoiceRoomUIDelegate> delegate;

@property(nonatomic, strong) NEVoiceRoomKitConfig *config;

+ (NEVoiceRoomUIManager *)sharedInstance;

- (void)initializeWithConfig:(NEVoiceRoomKitConfig *)config
                    callback:(void (^)(NSInteger, NSString *_Nullable, id _Nullable))callback;

- (void)loginWithAccount:(NSString *)account
                   token:(NSString *)token
                nickname:(NSString *)nickname
                callback:(void (^)(NSInteger, NSString *_Nullable, id _Nullable))callback;

- (void)logoutWithCallback:(void (^)(NSInteger, NSString *_Nullable, id _Nullable))callback;

/// 房间创建界面
- (UINavigationController *)createViewController;

/// 房间列表页
- (UINavigationController *)roomListViewController;

@end

NS_ASSUME_NONNULL_END
