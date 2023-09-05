// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <UIKit/UIKit.h>
#import "NEUIMicQueueViewProtocol.h"
#import "NEVoiceRoomUIGiftModel.h"
NS_ASSUME_NONNULL_BEGIN

@protocol NEVoiceRoomSendGiftViewtDelegate <NSObject>

- (void)didSendGift:(NEVoiceRoomUIGiftModel *)gift
          giftCount:(int)giftCount
          userUuids:(NSArray *)userUuids;

@end

@interface NEVoiceRoomSendGiftViewController : UIViewController <NEUIMicQueueViewProtocol>

+ (NEVoiceRoomSendGiftViewController *)showWithTarget:(id<NEVoiceRoomSendGiftViewtDelegate>)target
                                       viewController:(UIViewController *)viewController;

@end

NS_ASSUME_NONNULL_END
