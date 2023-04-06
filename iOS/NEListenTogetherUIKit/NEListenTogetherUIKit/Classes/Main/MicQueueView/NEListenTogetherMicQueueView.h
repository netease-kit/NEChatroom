// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <UIKit/UIKit.h>
#import "NEListenTogetherMicQueueCell.h"
#import "NEListenTogetherMicQueueViewProtocol.h"

NS_ASSUME_NONNULL_BEGIN

/**
 麦位队列视图
 */
@interface NEListenTogetherMicQueueView
    : UIView <NEListenTogetherMicQueueCellDelegate, NEListenTogetherMicQueueViewProtocol>

///// 单行刷新
///// @param rowIndex 需要刷新的row
//- (void)reloadCollectionRowWithIndex:(NSInteger)rowIndex;

- (void)play;
- (void)stop;
- (void)pause;

/// 单人时候的耳机图片显示
- (void)singleListen;

/// 一起听时候的耳机图片显示
- (void)togetherListen;
- (void)showListenButton:(BOOL)show;
- (void)showDownloadingProcess:(BOOL)isHost show:(BOOL)show;

- (void)updateWithRemoteVolumeInfos:(NSArray<NEListenTogetherMemberVolumeInfo *> *)volumeInfos;

- (void)updateWithLocalVolume:(NSInteger)volume;

@end

NS_ASSUME_NONNULL_END
