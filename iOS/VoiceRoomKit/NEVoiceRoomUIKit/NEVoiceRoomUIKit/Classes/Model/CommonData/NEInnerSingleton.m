// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEInnerSingleton.h"

static NEInnerSingleton *singleton = nil;
@implementation NEInnerSingleton
+ (instancetype)singleton {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    singleton = [NEInnerSingleton new];
  });
  return singleton;
}
- (NSArray<NEVoiceRoomSeatItem *> *)fetchAudienceSeatItems:
    (NSArray<NEVoiceRoomSeatItem *> *)seatItems {
  NSMutableArray *tempArr = @[].mutableCopy;
  for (NEVoiceRoomSeatItem *item in seatItems) {
    if (![item.user isEqualToString:self.roomInfo.anchor.userUuid]) {
      [tempArr addObject:item];
    }
  }
  return tempArr.copy;
}
- (NEVoiceRoomSeatItem *)fetchAnchorItem:(NSArray<NEVoiceRoomSeatItem *> *)seatItems {
  NEVoiceRoomSeatItem *anchorItem = nil;
  for (NEVoiceRoomSeatItem *item in seatItems) {
    if ([item.user isEqualToString:self.roomInfo.anchor.userUuid]) {
      anchorItem = item;
    }
  }
  return anchorItem;
}
@end
