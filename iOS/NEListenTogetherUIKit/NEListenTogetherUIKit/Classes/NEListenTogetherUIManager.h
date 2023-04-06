// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>
#import <NEListenTogetherKit/NEListenTogetherKit-Swift.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 登录事件枚举
typedef NS_ENUM(NSInteger, NEListenTogetherClientEvent) {
  /// 被踢出登录
  NEListenTogetherClientEventKicOut,
  /// 授权过期
  NEListenTogetherClientEventUnauthorized,
  /// 服务器禁止登录
  NEListenTogetherClientEventForbidden,
  /// 账号或密码错误
  NEListenTogetherClientEventAccountTokenError,
  /// 登录成功
  NEListenTogetherClientEventLoggedIn,
  /// 未登录
  NEListenTogetherClientEventLoggedOut,
  /// 授权错误
  NEListenTogetherClientEventIncorrectToken,
  /// Token过期
  NEListenTogetherClientEventTokenExpored,
};

@protocol NEListenTogetherUIDelegate <NSObject>

- (void)onListenTogetherClientEvent:(NEListenTogetherClientEvent)event;
- (void)onListenTogetherJoinRoom;
- (void)onListenTogetherLeaveRoom;
- (BOOL)inOtherRoom;
- (void)leaveOtherRoomWithCompletion:(void (^__nullable)(void))completion;

@end

@interface NEListenTogetherUIManager : NSObject

@property(nonatomic, copy) NSString *nickname;
//
@property(nonatomic, assign, readonly) bool isLoggedIn;
//
@property(nonatomic, weak) id<NEListenTogetherUIDelegate> delegate;
//
@property(nonatomic, strong) NEListenTogetherKitConfig *config;
//
+ (NEListenTogetherUIManager *)sharedInstance;

- (void)initializeWithConfig:(NEListenTogetherKitConfig *)config
                    callback:(void (^)(NSInteger, NSString *_Nullable, id _Nullable))callback;

- (void)loginWithAccount:(NSString *)account
                   token:(NSString *)token
                nickname:(NSString *)nickname
             resumeLogin:(BOOL)resumeLogin
                callback:(void (^)(NSInteger, NSString *_Nullable, id _Nullable))callback;

- (void)logoutWithCallback:(void (^)(NSInteger, NSString *_Nullable, id _Nullable))callback;

/// 房间创建界面
- (UINavigationController *)createViewController;

/// 房间列表页
- (UINavigationController *)roomListViewController;

@end

NS_ASSUME_NONNULL_END
