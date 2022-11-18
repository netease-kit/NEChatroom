// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "AppDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface AppDelegate (VoiceRoom)

/// 统一登录
- (void)vr_setupLoginSDK;
/// VoiceRoom 初始化
- (void)vr_setupVoiceRoom;
@end

NS_ASSUME_NONNULL_END
