// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "FUViewModel.h"

@interface FUViewModel ()

/// 是否需要Slider
@property (nonatomic, assign) BOOL needSlider;

@end

@implementation FUViewModel

- (instancetype)initWithSelectedIndex:(NSInteger)selectedIndex needSlider:(BOOL)isNeedSlider {
  self = [super init];
  if (self) {
    self.selectedIndex = selectedIndex;
    self.needSlider = isNeedSlider;
  }
  return self;
}

- (instancetype)init {
  return [self initWithSelectedIndex:-1 needSlider:NO];
}

- (void)startRender {
  _rendering = YES;
}

- (void)stopRender {
  _rendering = NO;
}

- (void)updateData:(FUSubModel *)subModel {
}

- (void)recover {
  for (FUSubModel *subModel in self.model.moduleData) {
    subModel.currentValue = subModel.defaultValue;
    [self updateData:subModel];
  }
}

@end
