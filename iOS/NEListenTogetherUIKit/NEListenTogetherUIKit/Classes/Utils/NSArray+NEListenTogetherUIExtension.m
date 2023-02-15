// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NSArray+NEListenTogetherUIExtension.h"

@implementation NSArray (NEListenTogetherUIExtension)
- (id)ne_find:(BOOL (^)(id obj))block {
  NSCParameterAssert(block != nil);
  if (!self) return nil;

  NSUInteger index =
      [self indexOfObjectPassingTest:^BOOL(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        return block(obj);
      }];
  return index == NSNotFound ? nil : self[index];
}

- (NSArray *)ne_filter:(BOOL (^)(id _Nonnull))block {
  NSCParameterAssert(block != nil);

  NSIndexSet *indexes = [self
      indexesOfObjectsPassingTest:^BOOL(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        return block(obj);
      }];
  return [self objectsAtIndexes:indexes];
}
- (NSArray *)ne_map:(id (^)(id _Nonnull))block {
  NSCParameterAssert(block != nil);
  if (!self) return nil;
  return [self ne_mapWithIndex:^id _Nonnull(id _Nonnull obj, NSUInteger _) {
    return block(obj);
  }];
}
- (NSArray *)ne_mapWithIndex:(id (^)(id obj, NSUInteger idx))block {
  NSCParameterAssert(block != nil);
  if (!self) return nil;
  NSMutableArray *result = @[].mutableCopy;
  [self ne_each:^(id _Nonnull obj, NSUInteger idx) {
    id transformed = block(obj, idx);
    if (transformed) {
      [result addObject:transformed];
    }
  }];
  return result;
}

- (void)ne_each:(void (^)(id, NSUInteger))iterator {
  NSCParameterAssert(iterator != nil);
  [self enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
    iterator(obj, idx);
  }];
}

- (NSArray *)ne_flatten {
  if (!self) return nil;

  NSMutableArray *result = @[].mutableCopy;
  for (id element in self) {
    if ([element isKindOfClass:NSArray.class]) {
      [result addObjectsFromArray:element];
    } else {
      [result addObject:element];
    }
  }
  return result;
}

static NSComparator const NECompare = ^NSComparisonResult(id a, id b) {
  return [a compare:b];
};

- (NSArray *)ne_sort {
  if (!self) return nil;
  return [self ne_sortWithComparator:NECompare];
}
- (NSArray *)ne_sortWithComparator:(NSComparator)comparator {
  return [self sortedArrayUsingComparator:comparator];
}
@end
