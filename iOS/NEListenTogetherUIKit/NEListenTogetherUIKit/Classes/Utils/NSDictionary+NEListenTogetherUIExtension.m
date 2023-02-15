// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NSDictionary+NEListenTogetherUIExtension.h"

@implementation NSDictionary (NEListenTogetherUIExtension)
- (id)ne_find:(BOOL (^)(id _Nonnull))block {
  NSCParameterAssert(block != nil);
  for (id key in self) {
    id value = self[key];
    if (block(value)) return value;
  }
  return nil;
}

- (NSDictionary *)ne_filter:(BOOL (^)(id _Nonnull))block {
  NSCParameterAssert(block != nil);
  NSSet *keys =
      [self keysOfEntriesPassingTest:^BOOL(id _Nonnull key, id _Nonnull obj, BOOL *_Nonnull stop) {
        return block(obj);
      }];
  return [self dictionaryWithValuesForKeys:keys.allObjects];
}
- (NSDictionary *)ne_map:(id _Nonnull (^)(id _Nonnull))block {
  NSCParameterAssert(block != nil);
  return [self ne_mapKeysAndValues:^id _Nonnull(id _, id _Nonnull obj) {
    return block(obj);
  }];
}
- (NSDictionary *)ne_mapKeysAndValues:(id _Nonnull (^)(id _Nonnull, id _Nonnull))block {
  NSCParameterAssert(block != nil);
  NSMutableDictionary *result = @{}.mutableCopy;
  [self ne_each:^(id _Nonnull key, id _Nonnull value) {
    id transformed = block(key, value);
    if (transformed) {
      result[key] = transformed;
    }
  }];
  return result;
}
- (void)ne_each:(void (^)(id key, id value))iterator {
  NSCParameterAssert(iterator != nil);
  [self enumerateKeysAndObjectsUsingBlock:^(id _Nonnull key, id _Nonnull obj, BOOL *_Nonnull stop) {
    iterator(key, obj);
  }];
}
- (NSDictionary *)ne_extend:(NSDictionary *)dictionary {
  if (!self) return dictionary;
  if (!dictionary) return self;
  NSMutableDictionary *result = [self mutableCopy];
  [self ne_each:^(id _Nonnull key, id _Nonnull value) {
    result[key] = value;
  }];
  return result;
}
@end
