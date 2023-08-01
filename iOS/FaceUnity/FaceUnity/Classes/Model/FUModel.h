// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>

#import "FUDefines.h"

NS_ASSUME_NONNULL_BEGIN

@interface FUSubModel : NSObject

/// 功能类型
@property (nonatomic, assign) NSUInteger functionType;

/// 名称
@property (nonatomic, copy) NSString *title;

/// 需要显示的icon名称
@property (nonatomic, strong) NSString *imageName;

/// 是否从中间双向滑动调节值大小，默认为NO
@property (nonatomic, assign) BOOL isBidirection;

/// 默认值
@property (nonatomic) double defaultValue;

/// 当前值（用于调整滤镜程度、美肤程度等）
@property (nonatomic) double currentValue;

/// slider 进度条显示比例
/// 原因是: 部分属性值取值范围并不是0 - 1.0， 所以进度条为了归一化必须进行倍率处理
/// 默认值1.0
@property (nonatomic) float ratio;

/// 是否禁用
@property (nonatomic, assign) BOOL disabled;

/// 目前只为了存滤镜是否被选中
@property (nonatomic, assign) BOOL isSelected;

/// 为实现设置持久化存储，转成json保存
- (NSDictionary *)toJson;

@end

@interface FUModel : NSObject

/// 功能模块分类
@property (nonatomic, assign) FUModuleType type;
/// 功能模块名称
@property (nonatomic, copy) NSString *name;
/// 检测提示
@property (nonatomic, copy) NSString *tip;
/// 功能模块数据
@property (nonatomic, copy) NSArray<FUSubModel *> *moduleData;

/// 为实现设置持久化存储，转成json保存
- (NSArray<NSDictionary *> *)toJson;

/// 将数据存到userData
- (void)save;

@end

NS_ASSUME_NONNULL_END
