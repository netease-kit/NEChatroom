// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEListenTogetherUIGiftModel.h"
#import "NEListenTogetherLocalized.h"

@implementation NEListenTogetherUIGiftModel

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

+ (NSArray<NEListenTogetherUIGiftModel *> *)defaultGifts {
  NEListenTogetherUIGiftModel *gift1 =
      [[NEListenTogetherUIGiftModel alloc] initWithGiftId:1
                                                     icon:@"gift03_ico"
                                                  display:NELocalizedString(@"荧光棒")
                                                    price:9];
  NEListenTogetherUIGiftModel *gift2 =
      [[NEListenTogetherUIGiftModel alloc] initWithGiftId:2
                                                     icon:@"gift04_ico"
                                                  display:NELocalizedString(@"安排")
                                                    price:99];
  NEListenTogetherUIGiftModel *gift3 =
      [[NEListenTogetherUIGiftModel alloc] initWithGiftId:3
                                                     icon:@"gift02_ico"
                                                  display:NELocalizedString(@"跑车")
                                                    price:199];
  NEListenTogetherUIGiftModel *gift4 =
      [[NEListenTogetherUIGiftModel alloc] initWithGiftId:4
                                                     icon:@"gift01_ico"
                                                  display:NELocalizedString(@"火箭")
                                                    price:999];
  return @[ gift1, gift2, gift3, gift4 ];
}

+ (nullable NEListenTogetherUIGiftModel *)getRewardWithGiftId:(NSInteger)giftId {
  NEListenTogetherUIGiftModel *gift = nil;
  for (NEListenTogetherUIGiftModel *tmp in [NEListenTogetherUIGiftModel defaultGifts]) {
    if (tmp.giftId == giftId) {
      gift = tmp;
      break;
    }
  }
  return gift;
}

@end
