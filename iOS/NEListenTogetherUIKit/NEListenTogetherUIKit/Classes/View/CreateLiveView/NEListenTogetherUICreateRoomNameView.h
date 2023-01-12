// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEListenTogetherUIBaseView.h"

NS_ASSUME_NONNULL_BEGIN
@protocol NEUICreateRoomDelegate <NSObject>

- (void)createRoomResult;

@end

@interface NEListenTogetherUICreateRoomNameView : NEListenTogetherUIBaseView

@property(nonatomic, weak) id<NEUICreateRoomDelegate> delegate;

// 获取聊天室名称
- (NSString *)getRoomName;
/// 获取房间背景图
- (nullable NSString *)getRoomBgImageUrl;
@end

NS_ASSUME_NONNULL_END
