// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>
#import <NEVoiceRoomKit/NEVoiceRoomKit-Swift.h>
NS_ASSUME_NONNULL_BEGIN

@interface NEChatroomListViewModel : NSObject

/// 数据源集合
@property(nonatomic, strong, readonly) NSArray<NEVoiceRoomInfo *> *datas;
/// 是否结束
@property(nonatomic, assign, readonly) BOOL isEnd;
/// 是否正在加载
@property(nonatomic, assign, readonly) BOOL isLoading;
/// 加载error
@property(nonatomic, assign, readonly) NSError *error;

// 麦位组件
// 加载新数据
- (void)requestNewDataWithLiveType:(NELiveRoomType)roomType;
// 加载更多
- (void)requestMoreDataWithLiveType:(NELiveRoomType)roomType;

@end

NS_ASSUME_NONNULL_END
