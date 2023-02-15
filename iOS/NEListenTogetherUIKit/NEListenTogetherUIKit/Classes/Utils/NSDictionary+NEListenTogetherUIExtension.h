// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary (NEListenTogetherUIExtension)

/// 字典中查找元素
/// @param block 符合条件的key-value的闭包，block不能为nil
/// 返回字典中任意符合条件的value
- (nullable id)ne_find:(BOOL (^)(id obj))block;

/// 筛选字典中的键值对
/// @param block 符合条件的key-value的闭包，block不能为nil
/// 返回所有符合条件的键值对
- (nullable NSDictionary *)ne_filter:(BOOL (^)(id objc))block;

/// 映射字典
/// @param block 符合条件的key-value的闭包，block不能为nil
- (nullable NSDictionary *)ne_map:(id (^)(id obj))block;

/// 映射字典
/// @param block 符合条件的key-value的闭包，block不能为nil
- (nullable NSDictionary *)ne_mapKeysAndValues:(id (^)(id key, id obj))block;

/// 遍历字典
/// @param iterator 迭代器
- (void)ne_each:(void (^)(id key, id value))iterator;

/// 字典扩展
/// @param dictionary 需要追加的字典
- (nullable NSDictionary *)ne_extend:(nullable NSDictionary *)dictionary;
@end

NS_ASSUME_NONNULL_END
