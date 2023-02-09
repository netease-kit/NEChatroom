//// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEVoiceRoomGiftEngine.h"
#import "NEVoiceRoomSendGiftViewController.h"
@implementation NEVoiceRoomGiftEngine

+ (instancetype)getInstance {
  static NEVoiceRoomGiftEngine *instance = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    instance = [[self alloc] init];
    instance.selectedSeatDatas = [NSMutableArray array];
    [instance reInitData];
  });
  return instance;
}

- (void)updateSelectedSeatDatas:(NSInteger)index {
  if ([self.selectedSeatDatas containsObject:[NSNumber numberWithLong:index]]) {
    [self.selectedSeatDatas removeObject:[NSNumber numberWithLong:index]];
  } else {
    [self.selectedSeatDatas addObject:[NSNumber numberWithLong:index]];
  }
}

- (void)reInitData {
  [self.selectedSeatDatas removeAllObjects];
  [self.selectedSeatDatas addObject:@0];
}
@end
