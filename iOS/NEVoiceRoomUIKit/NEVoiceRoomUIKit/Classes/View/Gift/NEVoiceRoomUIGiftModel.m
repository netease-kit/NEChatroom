// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEVoiceRoomUIGiftModel.h"

@implementation NEVoiceRoomUIGiftModel

- (instancetype)initWithGiftId:(int32_t)giftId
                          icon:(NSString *)icon
                       display:(NSString *)display
                         price:(int32_t)price {
  self = [super init];
  if (self) {
    _giftId = giftId;
    _icon = icon;
    _display = display;
    _price = price;
  }
  return self;
}

+ (NSArray<NEVoiceRoomUIGiftModel *> *)defaultGifts {
  NEVoiceRoomUIGiftModel *gift1 = [[NEVoiceRoomUIGiftModel alloc] initWithGiftId:1
                                                                            icon:@"gift03_ico"
                                                                         display:@"荧光棒"
                                                                           price:9];
  NEVoiceRoomUIGiftModel *gift2 = [[NEVoiceRoomUIGiftModel alloc] initWithGiftId:2
                                                                            icon:@"gift04_ico"
                                                                         display:@"安排"
                                                                           price:99];
  NEVoiceRoomUIGiftModel *gift3 = [[NEVoiceRoomUIGiftModel alloc] initWithGiftId:3
                                                                            icon:@"gift02_ico"
                                                                         display:@"跑车"
                                                                           price:199];
  NEVoiceRoomUIGiftModel *gift4 = [[NEVoiceRoomUIGiftModel alloc] initWithGiftId:4
                                                                            icon:@"gift01_ico"
                                                                         display:@"火箭"
                                                                           price:999];
  return @[ gift1, gift2, gift3, gift4 ];
}

+ (nullable NEVoiceRoomUIGiftModel *)getRewardWithGiftId:(NSInteger)giftId {
  NEVoiceRoomUIGiftModel *gift = nil;
  for (NEVoiceRoomUIGiftModel *tmp in [NEVoiceRoomUIGiftModel defaultGifts]) {
    if (tmp.giftId == giftId) {
      gift = tmp;
      break;
    }
  }
  return gift;
}

@end
