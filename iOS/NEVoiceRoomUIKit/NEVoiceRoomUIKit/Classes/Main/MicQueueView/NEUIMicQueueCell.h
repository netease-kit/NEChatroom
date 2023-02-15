// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <Lottie/LOTAnimationView.h>
#import <NEVoiceRoomKit/NEVoiceRoomKit-Swift.h>
#import <UIKit/UIKit.h>
#import "NEUIAnimationButton.h"
@import LottieSwift;
#define NEChatRoomAnchor @"chatRoomAnchor"

NS_ASSUME_NONNULL_BEGIN

/// 麦位cell代理方法
@protocol NEUIMicQueueCellDelegate <NSObject>

- (void)onConnectBtnPressedWithMicInfo:(NEVoiceRoomSeatItem *)micInfo;

@end

/**
 麦位cell基础类
 */
@interface NEUIMicQueueCell : UICollectionViewCell

/// 代理句柄
@property(nonatomic, weak) id<NEUIMicQueueCellDelegate> delegate;
/// 名字控件
@property(nonatomic, strong) UILabel *nameLabel;
/// 动画按钮
@property(nonatomic, strong) NEUIAnimationButton *connectBtn;
/// 头像视图
@property(nonatomic, strong) UIImageView *avatar;
/// 状态图标
@property(nonatomic, strong) UIImageView *smallIcon;
/// 麦位信息
@property(nonatomic, strong) NEVoiceRoomSeatItem *micInfo;
/// 正在唱歌图标
@property(nonatomic, strong) UIImageView *singIco;
/// 正在申请动画
@property(nonatomic, strong) LOTAnimationView *loadingIco;
/// 礼物Lable
@property(nonatomic, strong) UILabel *giftLabal;
/// 说话波纹动画
@property(nonatomic, strong) NELottieView *lottieView;

/**
 开始声音动画
 @param value   - 音量值
 */
- (void)startSoundAnimationWithValue:(NSInteger)value
    API_DEPRECATED("Use startSpeakAnimation instead.", ios(2.0, 16.0));

/**
 停止声音动画
 */
- (void)stopSoundAnimation API_DEPRECATED("Use stopSpeakAnimation instead.", ios(2.0, 16.0));

/// 开始播放说话波纹动画
- (void)startSpeakAnimation;

/// 停止播放说话波纹动画
- (void)stopSpeakAnimation;

/**
 刷新麦位信息
 @param micInfo - 麦位信息
 */
- (void)refresh:(NEVoiceRoomSeatItem *)micInfo;

/**
 点击按钮
 */
- (void)onConnectBtnPressed;

/// 更新礼物值
/// @param title 礼物值
- (void)updateGiftLabel:(NSString *)title;
/**
 实例化cell
 @param collectionView      - 容器控件
 @param data                            - 数据源
 @param indexPath               - 次序信息
 */
+ (NEUIMicQueueCell *)cellWithCollectionView:(UICollectionView *)collectionView
                                        data:(NEVoiceRoomSeatItem *)data
                                   indexPath:(NSIndexPath *)indexPath;

/**
 cell size
 */
+ (CGSize)size;

/**
 cell 上下内变局
 */
+ (CGFloat)cellPaddingH;

/**
 cell 左右内变局
 */
+ (CGFloat)cellPaddingW;

@end

NS_ASSUME_NONNULL_END
