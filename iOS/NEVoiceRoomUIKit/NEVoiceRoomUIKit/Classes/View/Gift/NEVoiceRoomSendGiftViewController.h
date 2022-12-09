// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <UIKit/UIKit.h>
#import "NEVoiceRoomUIGiftModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol NEVoiceRoomSendGiftViewtDelegate <NSObject>

- (void)didSendGift:(NEVoiceRoomUIGiftModel *)gift;

@end

@interface NEVoiceRoomSendGiftViewController : UIViewController

+ (void)showWithTarget:(id<NEVoiceRoomSendGiftViewtDelegate>)target
        viewController:(UIViewController *)viewController;

@end

NS_ASSUME_NONNULL_END
