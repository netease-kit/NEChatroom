// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "FUFunctionView.h"
#import "FUSegmentBar.h"

#import "FUViewModel.h"

@interface FUFunctionView ()

@property (nonatomic, strong) FUSlider *slider;

@property (nonatomic, strong) FUViewModel *viewModel;

@end

@implementation FUFunctionView

#pragma mark - Initializer
- (instancetype)initWithFrame:(CGRect)frame viewModel:(FUViewModel *)viewModel {
  self = [super initWithFrame:frame];
  if (self) {
    self.viewModel = viewModel;
    
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
    self.layer.anchorPoint = CGPointMake(0.5, 1);
    // 设置了anchorPoint需要重新设置frame
    self.frame = frame;
    
    if (viewModel.isNeedSlider) {
      [self addSubview:self.slider];
      if (viewModel.selectedIndex > 0) {
        // 默认选中需要显示Slider
        self.frame = CGRectMake(0, CGRectGetMinY(frame) - FUFunctionSliderHeight, CGRectGetWidth(frame), FUFunctionViewHeight + FUFunctionSliderHeight);
        self.slider.hidden = NO;
        FUSubModel *subModel = self.viewModel.model.moduleData[self.viewModel.selectedIndex];
        self.slider.bidirection = subModel.isBidirection;
        self.slider.value = subModel.currentValue / subModel.ratio;
      }
    }
    self.transform = CGAffineTransformMakeScale(1, 0.001);
    self.alpha = 0;
    self.hidden = YES;
  }
  return self;
}

- (void)refreshSubviews {
  if (self.slider.isHidden) {
    return;
  }
  FUSubModel *subModel = self.viewModel.model.moduleData[self.viewModel.selectedIndex];
  self.slider.bidirection = subModel.isBidirection;
  self.slider.value = subModel.currentValue / subModel.ratio;
}

#pragma mark - Event response
- (void)sliderValueChanged {
  if (self.delegate && [self.delegate respondsToSelector:@selector(functionView:didChangeSliderValue:)]) {
    [self.delegate functionView:self didChangeSliderValue:self.slider.value];
  }
}

- (void)sliderChangeEnded {
  if (self.delegate && [self.delegate respondsToSelector:@selector(functionViewDidEndSlide:)]) {
    [self.delegate functionViewDidEndSlide:self];
  }
}

#pragma mark - Getters
-(FUSlider *)slider {
  if (!_slider) {
    _slider = [[FUSlider alloc] initWithFrame:CGRectMake(56, 16, CGRectGetWidth(self.frame) - 116, FUFunctionSliderHeight)];
    _slider.hidden = YES;
    [_slider addTarget:self action:@selector(sliderValueChanged) forControlEvents:UIControlEventValueChanged];
    [_slider addTarget:self action:@selector(sliderChangeEnded) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
  }
  return _slider;
}

@end

@interface FUFunctionCell ()

@property (nonatomic, strong) UIImageView *fuImageView;
@property (nonatomic, strong) UILabel *fuTitleLabel;

@end

@implementation FUFunctionCell

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    self.backgroundColor = [UIColor clearColor];
    
    [self.contentView addSubview:self.fuImageView];
    [self.contentView addSubview:self.fuTitleLabel];
  }
  return self;
}

#pragma mark - Getters
- (UIImageView *)fuImageView {
  if (!_fuImageView) {
    _fuImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetWidth(self.frame))];
  }
  return _fuImageView;
}

- (UILabel *)fuTitleLabel {
  if (!_fuTitleLabel) {
    _fuTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetWidth(self.frame) + 2, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) - CGRectGetWidth(self.frame) - 2)];
    _fuTitleLabel.font = [UIFont systemFontOfSize:10];
    _fuTitleLabel.textColor = [UIColor whiteColor];
    _fuTitleLabel.textAlignment = NSTextAlignmentCenter;
    _fuTitleLabel.adjustsFontSizeToFitWidth = YES;
  }
  return _fuTitleLabel;
}

@end
