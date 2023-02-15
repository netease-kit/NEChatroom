// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEUIEmptyListView.h"
#import <Masonry/Masonry.h>
#import "NEVoiceRoomUI.h"
#import "NSBundle+NELocalized.h"
#import "NTESGlobalMacro.h"
#import "UIImage+NEUIExtension.h"
#import "UIImage+VoiceRoom.h"

@interface NEUIEmptyListView ()

@property(nonatomic, strong) UIImageView *imgView;
@property(nonatomic, strong) UILabel *tipLabel;

@end

@implementation NEUIEmptyListView

- (instancetype)initWithFrame:(CGRect)frame {
  CGRect rect = CGRectMake(frame.origin.x, frame.origin.y, 150, 156);
  self = [super initWithFrame:rect];
  if (self) {
    [self ntes_addSubviews];
  }
  return self;
}

- (void)ntes_addSubviews {
  [self addSubview:self.imgView];
  [self addSubview:self.tipLabel];
  [self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.size.mas_equalTo(CGSizeMake(100, 100));
    make.centerX.top.equalTo(self);
  }];

  [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.size.mas_equalTo(CGSizeMake(200, 44));
    make.centerX.equalTo(self);
    make.top.equalTo(self.imgView.mas_bottom).offset(10);
  }];
}

- (void)setTintColor:(UIColor *)tintColor {
  if (_tintColor == tintColor) {
    return;
  }
  self.imgView.image = [[NEVoiceRoomUI ne_imageName:@"empty_icon"] ne_imageWithTintColor:tintColor];
  //    self.tipLabel.textColor = tintColor;
}

#pragma mark - lazy load

- (UIImageView *)imgView {
  if (!_imgView) {
    _imgView = [[UIImageView alloc] init];
    _imgView.image = [NEVoiceRoomUI ne_imageName:@"empty_icon"];
  }
  return _imgView;
}

- (UILabel *)tipLabel {
  if (!_tipLabel) {
    _tipLabel = [[UILabel alloc] init];
    _tipLabel.font = [UIFont systemFontOfSize:13];
    _tipLabel.textColor = HEXCOLOR(0x999999);
    _tipLabel.textAlignment = NSTextAlignmentCenter;
    _tipLabel.text = NELocalizedString(@"暂时没有房间\n请点击下方”+“创建房间");
    _tipLabel.numberOfLines = 0;
  }
  return _tipLabel;
}

@end
