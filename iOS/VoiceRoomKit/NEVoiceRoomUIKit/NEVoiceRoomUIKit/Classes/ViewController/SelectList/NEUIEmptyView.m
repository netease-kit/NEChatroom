// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEUIEmptyView.h"
#import <NEUIKit/UIColor+NEUIExtension.h>
#import <NEUIKit/UIView+NEUIExtension.h>
#import "NEVoiceRoomUI.h"
@import NESocialUIKit;

@interface NEUIEmptyView ()
@property(nonatomic, strong) UIImageView *imgView;
@property(nonatomic, strong) UILabel *infoLab;
@end

@implementation NEUIEmptyView

- (instancetype)initWithInfo:(NSString *)info {
  if (self = [super init]) {
    self.backgroundColor = [UIColor whiteColor];
    _info = info;
    [self addSubview:self.imgView];
    [self addSubview:self.infoLab];
  }
  return self;
}

- (void)layoutSubviews {
  [super layoutSubviews];

  _imgView.size = CGSizeMake(80, 80);
  _imgView.top = 54.0;
  _imgView.centerX = self.width / 2;
  _infoLab.top = _imgView.bottom + 18.0;
  _infoLab.centerX = self.width / 2;
}

#pragma mark - Getter
- (UIImageView *)imgView {
  if (!_imgView) {
    _imgView = [[UIImageView alloc] init];
    _imgView.contentMode = UIViewContentModeScaleAspectFit;
    _imgView.image = [NESocialBundle loadImage:@"empty_ico"];
  }
  return _imgView;
}

- (UILabel *)infoLab {
  if (!_infoLab) {
    _infoLab = [[UILabel alloc] init];
    _infoLab.textColor = [UIColor ne_colorWithHex:0xBFBFBF];
    _infoLab.font = [UIFont systemFontOfSize:15.0];
    _infoLab.text = _info ?: @"";
    [_infoLab sizeToFit];
  }
  return _infoLab;
}

- (void)setInfo:(NSString *)info {
  _info = info;
  _infoLab.text = info;
  [_infoLab sizeToFit];
}

@end
