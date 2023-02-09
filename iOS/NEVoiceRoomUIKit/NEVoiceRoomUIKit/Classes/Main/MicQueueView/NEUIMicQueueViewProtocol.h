// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <NEVoiceRoomKit/NEVoiceRoomKit-Swift.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class NEUIMicQueueCell;

/**
 麦位视图代理
 */
@protocol NEUIMicQueueViewDelegate <NSObject>

- (void)micQueueConnectBtnPressedWithMicInfo:(NEVoiceRoomSeatItem *)micInfo;

@end

/**
 麦位视图
 */
@protocol NEUIMicQueueViewProtocol <NSObject>

@optional

/// 演唱者id
@property(nonatomic, copy, nullable) NSString *singerAccountId;

@required

/// 代理句柄
@property(nonatomic, weak) id<NEUIMicQueueViewDelegate> delegate;
/// 主播信息
@property(nonatomic, strong) NEVoiceRoomSeatItem *anchorMicInfo;
/// 麦位信息
@property(nonatomic, strong) NSArray<NEVoiceRoomSeatItem *> *datas;
/// 礼物信息
@property(nonatomic, strong) NSMutableArray<NEVoiceRoomBatchSeatUserReward *> *giftDatas;

/**
 更新麦位信息
 @param micInfo - 麦位信息
 */
- (void)updateCellWithMicInfo:(NEVoiceRoomSeatInfo *)micInfo;

/**
 计算视图高度
 @param width   - cell宽度
 */
- (CGFloat)calculateHeightWithWidth:(CGFloat)width;

/**
 开始麦位声音动画
 @param micOrder     - 麦位顺序
 @param volume          - 麦位音量
 */
- (void)startSoundAnimation:(NSInteger)micOrder volume:(NSInteger)volume;

/**
 停止麦位声音动画
 */
- (void)stopSoundAnimation:(NSInteger)micOrder;

@end
NS_ASSUME_NONNULL_END
