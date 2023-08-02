// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "FUSquareButton.h"

@interface FUSquareButton()

@property(nonatomic,assign) float interval;

@end

@implementation FUSquareButton

- (instancetype)initWithFrame:(CGRect)frame interval:(float)interval{
  if (self = [super initWithFrame:frame]) {
    _interval = interval;
    self.titleLabel.font = [UIFont systemFontOfSize:10];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
  }
  return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    _interval = 8;
    self.titleLabel.font = [UIFont systemFontOfSize:10];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
  }
  return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
  if (self = [super initWithCoder:aDecoder]) {
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    _interval = 8;
    self.titleLabel.font = [UIFont systemFontOfSize:10];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
  }
  return self;
}

- (void)layoutSubviews {
  [super layoutSubviews];
  
  CGRect frame =  self.imageView.bounds;
  CGRect frame1 =  self.titleLabel.frame;
  
  
  self.imageView.frame = frame;
  CGPoint center = self.imageView.center;
  center.x = self.frame.size.width  * 0.5;
  self.imageView.center = center;
  
  frame1.origin.x = 0;
  frame1.origin.y = CGRectGetMaxY(self.imageView.frame) + _interval;
  frame1.size.height = 11;
  frame1.size.width = self.bounds.size.width;;
  self.titleLabel.frame = frame1;
}

@end
