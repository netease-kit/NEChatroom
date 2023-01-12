// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class NEListenTogetherMicQueueCell;

/**
 麦位视图代理
 */
@protocol NEListenTogetherMicQueueViewDelegate <NSObject>

- (void)micQueueConnectBtnPressedWithMicInfo:(NEListenTogetherSeatItem *)micInfo;

- (void)clickPointSongButton;

@end

/**
 麦位视图
 */
@protocol NEListenTogetherMicQueueViewProtocol <NSObject>

@optional

/// 演唱者id
@property(nonatomic, copy, nullable) NSString *singerAccountId;

@required

/// 代理句柄
@property(nonatomic, weak) id<NEListenTogetherMicQueueViewDelegate> delegate;
/// 主播信息
@property(nonatomic, strong) NEListenTogetherSeatItem *anchorMicInfo;
/// 麦位信息
@property(nonatomic, strong) NSArray<NEListenTogetherSeatItem *> *datas;

/**
 更新麦位信息
 @param micInfo - 麦位信息
 */
- (void)updateCellWithMicInfo:(NEListenTogetherSeatInfo *)micInfo;

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
