// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEListenTogetherUIAlertView.h"
#import "NEListenTogetherViewController.h"
NS_ASSUME_NONNULL_BEGIN

@interface NEListenTogetherViewController (UI)
/// 添加子视图
- (void)addSubviews;
/// 监听键盘处理
- (void)observeKeyboard;
/// 创建alert弹框 需要的所有action
- (NSMutableArray<NEListenTogetherUIAlertAction *> *)setupAlertActions;
/// 获取已点列表
- (void)fetchPickedSongList;
/// 消息发送
- (void)sendChatroomNotifyMessage:(NSString *)content;
@end

NS_ASSUME_NONNULL_END
