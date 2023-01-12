// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>
#import <NEListenTogetherKit/NEListenTogetherKit-Swift.h>

NS_ASSUME_NONNULL_BEGIN

/// 内部单例
@interface NEListenTogetherInnerSingleton : NSObject
/// 房间信息
@property(nonatomic, strong, nullable) NEListenTogetherInfo *roomInfo;
/// 单例初始化
+ (instancetype)singleton;
/// 获取 去除 主播麦位的 麦位列表
- (NSArray<NEListenTogetherSeatItem *> *)fetchAudienceSeatItems:
    (NSArray<NEListenTogetherSeatItem *> *)seatItems;
/// 获取主播麦位信息
- (NEListenTogetherSeatItem *_Nullable)fetchAnchorItem:
    (NSArray<NEListenTogetherSeatItem *> *)seatItems;
- (NEListenTogetherSeatItem *_Nullable)fetchListenTogetherItem:
    (NSArray<NEListenTogetherSeatItem *> *)seatItems;
@end

NS_ASSUME_NONNULL_END
