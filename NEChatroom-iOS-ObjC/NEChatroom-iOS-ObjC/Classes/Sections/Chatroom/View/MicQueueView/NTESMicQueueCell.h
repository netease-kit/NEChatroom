//
//  NTESMicQueueCell.h
//  NEChatroom-iOS-ObjC
//
//  Created by Think on 2021/2/3.
//  Copyright © 2021 netease. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NTESAnimationButton.h"
#import "NTESMicInfo.h"
#import "UIImage+YYWebImage.h"
#import "UIButton+YYWebImage.h"
#import "LOTAnimationView.h"

@class NTESMicInfo, NTESAnimationButton;

NS_ASSUME_NONNULL_BEGIN

/// 麦位cell代理方法
@protocol NTESMicQueueCellDelegate <NSObject>

- (void)onConnectBtnPressedWithMicInfo:(NTESMicInfo *)micInfo;

@end

/**
 麦位cell基础类
 */
@interface NTESMicQueueCell : UICollectionViewCell

/// 代理句柄
@property (nonatomic, weak)id<NTESMicQueueCellDelegate> delegate;
/// 名字控件
@property (nonatomic, strong) UILabel *nameLabel;
/// 动画按钮
@property (nonatomic, strong) NTESAnimationButton *connectBtn;
/// 头像视图
@property (nonatomic, strong) UIImageView *avatar;
/// 状态图标
@property (nonatomic, strong) UIImageView *smallIcon;
/// 麦位信息
@property (nonatomic, strong) NTESMicInfo *micInfo;
/// 正在唱歌图标
@property (nonatomic, strong) UIImageView *singIco;
/// 正在申请动画
@property (nonatomic, strong) LOTAnimationView  *loadingIco;

/**
 开始声音动画
 @param value   - 音量值
 */
- (void)startSoundAnimationWithValue:(NSInteger)value;

/**
 停止声音动画
 */
- (void)stopSoundAnimation;

/**
 刷新麦位信息
 @param micInfo - 麦位信息
 */
- (void)refresh:(NTESMicInfo *)micInfo;

/**
 点击按钮
 */
- (void)onConnectBtnPressed;

/**
 实例化cell
 @param collectionView      - 容器控件
 @param data                            - 数据源
 @param indexPath               - 次序信息
 */
+ (NTESMicQueueCell *)cellWithCollectionView:(UICollectionView *)collectionView
                                        data:(NTESMicInfo *)data
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
