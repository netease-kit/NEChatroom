//
//  NTESMicQueueViewProtocol.h
//  NEChatroom-iOS-ObjC
//
//  Created by Long on 2021/2/8.
//  Copyright © 2021 netease. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class NTESMicQueueCell, NTESMicInfo;

/**
 麦位视图代理
 */
@protocol NTESMicQueueViewDelegate <NSObject>

- (void)micQueueConnectBtnPressedWithMicInfo:(NTESMicInfo *)micInfo;

@end

/**
 麦位视图
 */
@protocol NTESMicQueueViewProtocol <NSObject>

@optional

/// 演唱者id
@property (nonatomic, copy, nullable) NSString              *singerAccountId;

@required

/// 代理句柄
@property (nonatomic, weak)     id<NTESMicQueueViewDelegate>   delegate;
/// 主播信息
@property (nonatomic, strong)   NTESMicInfo                 *anchorMicInfo;
/// 麦位信息
@property (nonatomic, strong)   NSArray<NTESMicInfo *>      *datas;

/**
 更新麦位信息
 @param micInfo - 麦位信息
 */
- (void)updateCellWithMicInfo:(NTESMicInfo *)micInfo;

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
- (void)startSoundAnimation:(NSInteger)micOrder
                     volume:(NSInteger)volume;

/**
 停止麦位声音动画
 */
- (void)stopSoundAnimation:(NSInteger)micOrder;

@end

NS_ASSUME_NONNULL_END
