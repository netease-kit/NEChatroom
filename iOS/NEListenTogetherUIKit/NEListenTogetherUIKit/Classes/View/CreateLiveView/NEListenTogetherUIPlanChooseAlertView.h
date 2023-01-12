// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol NTESPlanChooseDelegate <NSObject>

- (void)planChooseResult;

@end

@interface NEListenTogetherUIPlanChooseAlertView : UIView

@property(nonatomic, weak) id<NTESPlanChooseDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
