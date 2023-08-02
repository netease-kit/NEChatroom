// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <UIKit/UIKit.h>

#import "FUSlider.h"

@class FUViewModel, FUFunctionView;

NS_ASSUME_NONNULL_BEGIN

@protocol FUFunctionViewDelegate <NSObject>

- (void)functionView:(FUFunctionView *)functionView didSelectFunctionAtIndex:(NSInteger)index;

- (void)functionView:(FUFunctionView *)functionView didChangeSliderValue:(CGFloat)value;

- (void)functionViewDidEndSlide:(FUFunctionView *)functionView;

@optional

- (void)functionViewDidClickRecover:(FUFunctionView *)functionView;

@end

@interface FUFunctionView : UIView

@property (nonatomic, readonly, strong) FUViewModel *viewModel;

@property (nonatomic, readonly, strong) FUSlider *slider;

@property (nonatomic, weak) id<FUFunctionViewDelegate> delegate;

/// 初始化方法
/// @param frame Frame
/// @param viewModel FUViewModel
- (instancetype)initWithFrame:(CGRect)frame viewModel:(FUViewModel *)viewModel;

/// 刷新界面
- (void)refreshSubviews;

@end

@interface FUFunctionCell : UICollectionViewCell

@property (nonatomic, readonly, strong) UIImageView *fuImageView;

@property (nonatomic, readonly, strong) UILabel *fuTitleLabel;

@end

NS_ASSUME_NONNULL_END
