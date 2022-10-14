// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEUIBaseView.h"

@interface NEUIBaseView ()

@property(nonatomic, readwrite, strong) id model;

@end

@implementation NEUIBaseView

- (instancetype)initWithFrame:(CGRect)frame model:(id<NEUIBaseModelProtocol>)model {
  self = [super initWithFrame:frame];
  if (self) {
    _model = model;
    self.backgroundColor = [UIColor whiteColor];
    [self ntes_setupViews];
    [self ntes_bindViewModel];
  }
  return self;
}

- (instancetype)init {
  return [self initWithFrame:CGRectZero model:nil];
}

- (instancetype)initWithFrame:(CGRect)frame {
  return [self initWithFrame:frame model:nil];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
  return [self initWithFrame:CGRectZero model:nil];
}

- (void)ntes_setupViews {
}

- (void)ntes_bindViewModel {
}

@end
