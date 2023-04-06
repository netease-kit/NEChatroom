// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEListenTogetherUINavigationBar.h"
#import <NEUIKit/UIFont+NEUIExtension.h>
#import <NEUIKit/UIView+NEUIExtension.h>
#import "NEListenTogetherGlobalMacro.h"
#import "NEListenTogetherLocalized.h"
#import "NEListenTogetherUI.h"

@interface NEListenTogetherUINavigationBar ()
@property(nonatomic, strong) UILabel *titleLab;

@property(nonatomic, strong) UIButton *backBtn;
@property(nonatomic, strong) UIButton *arrowButton;
@property(nonatomic, strong) UIView *bottomLineView;
@end

@implementation NEListenTogetherUINavigationBar
- (instancetype)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    self.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.titleLab];
    [self addSubview:self.backBtn];
    [self addSubview:self.arrowButton];
    [self addSubview:self.bottomLineView];
  }
  return self;
}

- (void)layoutSubviews {
  [super layoutSubviews];
  _backBtn.frame = CGRectMake(0, 0, 60, 40);
  _backBtn.centerY = self.height / 2;
  _arrowButton.frame = _backBtn.frame;
  _titleLab.frame =
      CGRectMake(_backBtn.right, 0, self.width - _backBtn.width * 2, _titleLab.height);
  _titleLab.centerY = self.height / 2;
  _bottomLineView.frame = CGRectMake(0, self.height - 0.5, self.width, 0.5);
}

#pragma mark - Public
- (void)setTitle:(NSString *)title {
  _title = title;
  _titleLab.text = title ?: @"";
}

- (void)backAction:(UIButton *)sender {
  if (_backBlock) {
    _backBlock();
  }
}

- (void)arrowBackAction:(UIButton *)sender {
  if (self.arrowBackBlock) {
    self.arrowBackBlock();
  }
}

- (void)setOperationType:(NEUIBarOperationType)operationType {
  _operationType = operationType;
  switch (operationType) {
    case NEUIBarOperationTypeCancel: {
      self.backBtn.hidden = NO;
      self.arrowButton.hidden = YES;
    } break;
    default: {
      self.backBtn.hidden = YES;
      self.arrowButton.hidden = NO;
    } break;
  }
}
#pragma mark - Getter
- (UILabel *)titleLab {
  if (!_titleLab) {
    _titleLab = [[UILabel alloc] init];
    _titleLab.text = NELocalizedString(@"未知");
    _titleLab.font = [UIFont ne_font:16 weight:NEUIFontWeightMedium];
    _titleLab.textColor = HEXCOLOR(0x222222);
    _titleLab.textAlignment = NSTextAlignmentCenter;
    [_titleLab sizeToFit];
  }
  return _titleLab;
}

- (UIButton *)backBtn {
  if (!_backBtn) {
    _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _backBtn.titleLabel.font = [UIFont ne_font:14];
    [_backBtn setTitle:NELocalizedString(@"取消") forState:UIControlStateNormal];
    [_backBtn addTarget:self
                  action:@selector(backAction:)
        forControlEvents:UIControlEventTouchUpInside];
    [_backBtn setTitleColor:HEXCOLOR(0x222222) forState:UIControlStateNormal];
  }
  return _backBtn;
}

- (UIButton *)arrowButton {
  if (!_arrowButton) {
    _arrowButton = [[UIButton alloc] init];
    [_arrowButton addTarget:self
                     action:@selector(arrowBackAction:)
           forControlEvents:UIControlEventTouchUpInside];
    [_arrowButton setImage:[NEListenTogetherUI ne_listen_imageName:@"nav_back_icon"]
                  forState:UIControlStateNormal];
    [_arrowButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 32)];
  }
  return _arrowButton;
}

- (UIView *)bottomLineView {
  if (!_bottomLineView) {
    _bottomLineView = [[UIView alloc] init];
    _bottomLineView.backgroundColor = HEXCOLOR(0xE6E7EB);
  }
  return _bottomLineView;
}
@end
