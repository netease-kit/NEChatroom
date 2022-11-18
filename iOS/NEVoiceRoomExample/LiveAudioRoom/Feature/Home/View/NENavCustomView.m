// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NENavCustomView.h"
#import <Masonry/Masonry.h>
@implementation NENavCustomView
- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    [self initUI];
  }
  return self;
}
- (void)initUI {
  self.backgroundColor = [UIColor blackColor];
  UIView *bgView = [[UIView alloc] init];
  [self addSubview:bgView];
  CGFloat statusHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
  [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.edges.mas_equalTo(UIEdgeInsetsMake(statusHeight, 0, 0, 0));
  }];
  UIImageView *imageView =
      [[UIImageView alloc] initWithImage:[UIImage imageNamed:NSLocalizedString(@"云信Logo", nil)]];
  [bgView addSubview:imageView];
  [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.center.equalTo(bgView);
  }];

  //    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
  //    [button setImage:[UIImage imageNamed:@"account_circle"] forState:UIControlStateNormal];
  //    [bgView addSubview:button];
  //    [button mas_makeConstraints:^(MASConstraintMaker *make) {
  //        make.right.mas_equalTo(-20);
  //        make.top.bottom.mas_equalTo(0);
  //        make.width.mas_equalTo(44);
  //    }];
  //    self.userButton = button;
}

@end
