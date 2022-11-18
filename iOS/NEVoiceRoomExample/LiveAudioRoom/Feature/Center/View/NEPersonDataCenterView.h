// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^SelectDataCenter)(long index);

@interface NEPersonDataCenterView : UIView
@property(nonatomic, strong) SelectDataCenter selectDataCenter;
@property(nonatomic, strong) UILabel *dataCenterLabel;
@property(nonatomic, strong) UILabel *chinaLabel;
@property(nonatomic, strong) UIButton *chinaButton;
@property(nonatomic, strong) UILabel *outOfChinaLabel;
@property(nonatomic, strong) UIButton *outOfChinaButton;
- (void)updateDataCenter:(long)index;
@end

NS_ASSUME_NONNULL_END
