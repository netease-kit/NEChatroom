// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <UIKit/UIKit.h>
#import "NEUIMicQueueCell.h"
#import "NEUIMicQueueViewProtocol.h"

NS_ASSUME_NONNULL_BEGIN

/**
 麦位队列视图
 */
@interface NEUIMicQueueView : UIView <UICollectionViewDelegate,
                                      UICollectionViewDataSource,
                                      NEUIMicQueueCellDelegate,
                                      NEUIMicQueueViewProtocol>

///// 单行刷新
///// @param rowIndex 需要刷新的row
//- (void)reloadCollectionRowWithIndex:(NSInteger)rowIndex;

/// 更新礼物值，单独开方法 因为多线程
- (void)updateGiftDatas:(NSMutableArray<NEVoiceRoomBatchSeatUserReward *> *)giftDatas;
/// 更新礼物值，删除礼物 ，单独开方法，因为多线程
- (void)updateGiftData:(NSString *)account;

- (void)updateWithRemoteVolumeInfos:(NSArray<NEVoiceRoomMemberVolumeInfo *> *)volumeInfos;

- (void)updateWithLocalVolume:(NSInteger)volume;

- (void)reloadData;

@end

NS_ASSUME_NONNULL_END
