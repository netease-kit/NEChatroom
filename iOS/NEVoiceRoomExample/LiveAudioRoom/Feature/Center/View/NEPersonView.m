// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEPersonView.h"
#import <Masonry/Masonry.h>
@interface NEPersonView ()

@end

@implementation NEPersonView
- (instancetype)init {
  self = [super init];
  if (self) {
    [self initUI];
  }
  return self;
}
- (void)layoutSubviews {
  if (self.iconImageView.image) {
    [self.iconImageView mas_updateConstraints:^(MASConstraintMaker *make) {
      make.left.mas_equalTo(20);
      make.top.mas_equalTo(10);
      make.bottom.mas_equalTo(-10);
      make.width.mas_equalTo(self.mas_height).offset(-20);
    }];
  } else {
    [self.iconImageView mas_updateConstraints:^(MASConstraintMaker *make) {
      make.left.mas_equalTo(20);
      make.top.mas_equalTo(10);
      make.bottom.mas_equalTo(-10);
      make.width.mas_equalTo(self.mas_height).offset(-40);
    }];
  }
  if (self.indicatorImageView.image) {
    CGFloat width = MIN(self.indicatorImageView.image.size.width, 32);
    [self.indicatorImageView mas_updateConstraints:^(MASConstraintMaker *make) {
      make.left.mas_equalTo(self.detailLabel.mas_right).offset(10);
      make.right.mas_equalTo(-20);
      make.top.bottom.mas_equalTo(0);
      make.width.mas_equalTo(width);
    }];
  }
}
- (void)initUI {
  self.backgroundColor = [UIColor colorWithRed:26 / 255.0
                                         green:26 / 255.0
                                          blue:36 / 255.0
                                         alpha:1.0];
  UILabel *lineLabel = [[UILabel alloc] init];
  lineLabel.backgroundColor = [UIColor grayColor];
  [self addSubview:lineLabel];
  [lineLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.width.equalTo(self);
    make.height.equalTo(@0.5);
  }];

  [self addSubview:self.iconImageView];
  [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.mas_equalTo(20);
    make.top.mas_equalTo(10);
    make.bottom.mas_equalTo(-10);
    make.width.mas_equalTo(0);
  }];
  [self addSubview:self.titleLabel];
  [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.mas_equalTo(self.iconImageView.mas_right).offset(10);
    make.top.bottom.mas_equalTo(0);
  }];
  [self addSubview:self.detailLabel];
  [self.detailLabel mas_updateConstraints:^(MASConstraintMaker *make) {
    make.left.mas_equalTo(self.titleLabel.mas_right).offset(10);
    make.top.bottom.mas_equalTo(0);
    //        make.width.mas_equalTo(0);
  }];
  [self addSubview:self.indicatorImageView];
  [self.indicatorImageView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.mas_equalTo(self.detailLabel.mas_right).offset(10);
    make.right.mas_equalTo(-20);
    make.top.bottom.mas_equalTo(0);
    make.width.mas_equalTo(0);
  }];
}
- (UILabel *)titleLabel {
  if (!_titleLabel) {
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.font = [UIFont systemFontOfSize:16.0];
    _titleLabel.textColor = [UIColor whiteColor];
  }
  return _titleLabel;
}
- (UILabel *)detailLabel {
  if (!_detailLabel) {
    _detailLabel = [[UILabel alloc] init];
    _detailLabel.font = [UIFont systemFontOfSize:14.0];
    _detailLabel.textColor = [UIColor whiteColor];
  }
  return _detailLabel;
}

- (UIImageView *)iconImageView {
  if (!_iconImageView) {
    _iconImageView = [[UIImageView alloc] init];
    _iconImageView.contentMode = UIViewContentModeScaleAspectFit;
  }
  return _iconImageView;
}

- (UIImageView *)indicatorImageView {
  if (!_indicatorImageView) {
    _indicatorImageView = [[UIImageView alloc] init];
    _indicatorImageView.contentMode = UIViewContentModeScaleAspectFit;
  }
  return _indicatorImageView;
}
//- (void)setIconImage:(UIImage *)iconImage {
//    _iconImage = iconImage;
//    self.iconImageView.image = iconImage;
//    CGFloat width = iconImage.size.width;
//    [self.iconImageView mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(20);
//        make.top.mas_equalTo(10);
//        make.bottom.mas_equalTo(-10);
//        make.width.mas_equalTo(width);
//    }];
//}
//- (void)setDetailImage:(UIImage *)detailImage {
//    _detailImage = detailImage;
//    self.indicatorImageView.image = detailImage;
//    CGFloat width = detailImage.size.width;
//    [self.indicatorImageView mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(self.detailLabel.mas_right).offset(10);
//        make.right.mas_equalTo(-20);
//        make.top.bottom.mas_equalTo(0);
//        make.width.mas_equalTo(width);
//    }];
//}
@end
