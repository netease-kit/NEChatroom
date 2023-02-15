// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSArray (NEListenTogetherUIExtension)

/// 数组中查找元素
/// @param block 符合条件的元素的闭包，block不能为nil
/// 返回 符合条件的第一个元素，或者nil
- (nullable id)ne_find:(BOOL (^)(id obj))block;

/// 筛选数组中元素
/// @param block 符合条件的元素的闭包，block不能为nil
/// 返回所有符合条件的元素
- (nullable NSArray *)ne_filter:(BOOL (^)(id obj))block;

/// 映射数组
/// @param block 符合条件的元素的闭包，block不能为nil
- (nullable NSArray *)ne_map:(id (^)(id obj))block;

/// 映射数组
/// @param block 符合条件的元素的闭包，block不能为nil
- (nullable NSArray *)ne_mapWithIndex:(id (^)(id obj, NSUInteger idx))block;

/// 遍历
/// @param iterator 迭代器
- (void)ne_each:(void (^)(id, NSUInteger))iterator;

/// 数组中的元素(数组) 拍平
- (nullable NSArray *)ne_flatten;

/// 数组排序
- (nullable NSArray *)ne_sort;

/// 数组排序
- (nullable NSArray *)ne_sortWithComparator:(NSComparator)comparator;
@end

NS_ASSUME_NONNULL_END
