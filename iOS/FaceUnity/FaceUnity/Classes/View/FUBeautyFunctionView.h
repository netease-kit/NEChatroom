// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <UIKit/UIKit.h>

#import "FUFunctionView.h"

@class FUSubModel;

NS_ASSUME_NONNULL_BEGIN

@interface FUBeautyFunctionView : FUFunctionView

@end

@interface FUBeautyFunctionCell : FUFunctionCell

@property (nonatomic, strong) FUSubModel *subModel;

@end

NS_ASSUME_NONNULL_END
