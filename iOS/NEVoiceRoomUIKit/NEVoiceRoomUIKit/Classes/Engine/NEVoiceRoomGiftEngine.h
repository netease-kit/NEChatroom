//// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>
#import <NEVoiceRoomKit/NEVoiceRoomKit-Swift.h>

NS_ASSUME_NONNULL_BEGIN

@interface NEVoiceRoomGiftEngine : NSObject

/// 为什么不写 NEVoiceRoomViewController 中，是因为会引起循环引用，NEVoiceRoomViewController
/// 会引用NEVoiceRoomSendGiftViewController ，而 NEVoiceRoomSendGiftViewController
/// 需要用到这些数据。
///  选中麦位信息
@property(nonatomic, strong) NSMutableArray *selectedSeatDatas;

+ (instancetype)getInstance;

// 数据更新
- (void)updateSelectedSeatDatas:(NSInteger)index;
// 重新初始化数据
- (void)reInitData;
@end

NS_ASSUME_NONNULL_END
