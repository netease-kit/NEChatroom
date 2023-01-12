// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <UIKit/UIKit.h>
#import "NEListenTogetherUIGiftModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol NEListenTogetherSendGiftViewtDelegate <NSObject>

- (void)didSendGift:(NEListenTogetherUIGiftModel *)gift;

@end

@interface NEListenTogetherSendGiftViewController : UIViewController

+ (void)showWithTarget:(id<NEListenTogetherSendGiftViewtDelegate>)target
        viewController:(UIViewController *)viewController;

@end

NS_ASSUME_NONNULL_END
