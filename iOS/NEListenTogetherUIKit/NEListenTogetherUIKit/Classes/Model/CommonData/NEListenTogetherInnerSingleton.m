// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEListenTogetherInnerSingleton.h"

static NEListenTogetherInnerSingleton *singleton = nil;
@implementation NEListenTogetherInnerSingleton
+ (instancetype)singleton {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    singleton = [NEListenTogetherInnerSingleton new];
  });
  return singleton;
}
- (NSArray<NEListenTogetherSeatItem *> *)fetchAudienceSeatItems:
    (NSArray<NEListenTogetherSeatItem *> *)seatItems {
  NSMutableArray *tempArr = @[].mutableCopy;
  for (NEListenTogetherSeatItem *item in seatItems) {
    if (![item.user isEqualToString:self.roomInfo.anchor.userUuid]) {
      [tempArr addObject:item];
    }
  }
  return tempArr.copy;
}
- (NEListenTogetherSeatItem *)fetchAnchorItem:(NSArray<NEListenTogetherSeatItem *> *)seatItems {
  NEListenTogetherSeatItem *anchorItem = nil;
  for (NEListenTogetherSeatItem *item in seatItems) {
    if ([item.user isEqualToString:self.roomInfo.anchor.userUuid]) {
      anchorItem = item;
    }
  }
  return anchorItem;
}

- (NEListenTogetherSeatItem *)fetchListenTogetherItem:
    (NSArray<NEListenTogetherSeatItem *> *)seatItems {
  NEListenTogetherSeatItem *listenTogetherItem = nil;
  for (NEListenTogetherSeatItem *item in seatItems) {
    if (![item.user isEqualToString:self.roomInfo.anchor.userUuid]) {
      listenTogetherItem = item;
      break;
    }
  }
  return listenTogetherItem;
}
@end
