// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEVoiceRoomUIAlertView.h"
#import "NEVoiceRoomViewController.h"
NS_ASSUME_NONNULL_BEGIN

@interface NEVoiceRoomViewController (UI)
/// 添加子视图
- (void)addSubviews;
/// 监听键盘处理
- (void)observeKeyboard;
/// 创建alert弹框 需要的所有action
- (NSMutableArray<NEVoiceRoomUIAlertAction *> *)setupAlertActions;
@end

NS_ASSUME_NONNULL_END
