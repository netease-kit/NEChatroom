// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>

#import "FUModel.h"
#import "FUDefines.h"

#import <FURenderKit/FURenderKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FUViewModel : NSObject

/// 数据模型
@property (nonatomic, strong) FUModel *model;
/// 当前选中项索引
@property (nonatomic, assign) NSInteger selectedIndex;
/// 是否需要Slider
@property (nonatomic, assign, readonly, getter=isNeedSlider) BOOL needSlider;
/// 是否正在渲染
@property (nonatomic, assign, readonly, getter=isRendering)  BOOL rendering;
/// 是否默认数据
@property (nonatomic, assign, readonly, getter=isDefaultValue) BOOL defaultValue;


/// 初始化方法
/// @param selectedIndex 选中索引
/// @param isNeedSlider 是否需要Slider
- (instancetype)initWithSelectedIndex:(NSInteger)selectedIndex needSlider:(BOOL)isNeedSlider;

/// 开始渲染
- (void)startRender;

/// 停止渲染
- (void)stopRender;

/// 更新数据
- (void)updateData:(FUSubModel *)subModel;

/// 恢复所有数据
- (void)recover;

@end

NS_ASSUME_NONNULL_END
