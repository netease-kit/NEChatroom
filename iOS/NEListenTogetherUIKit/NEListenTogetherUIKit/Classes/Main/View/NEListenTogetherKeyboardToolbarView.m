// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEListenTogetherKeyboardToolbarView.h"
#import <Masonry/Masonry.h>
#import "NEListenTogetherGlobalMacro.h"
#import "NEListenTogetherLocalized.h"

@interface NEListenTogetherKeyboardToolbarView () <UITextFieldDelegate>
@property(nonatomic, strong, readwrite) UITextField *textField;
@property(nonatomic, strong, readwrite) UIButton *sendBtn;

@end

@implementation NEListenTogetherKeyboardToolbarView

- (void)ntes_setupViews {
  [self addSubview:self.textField];
  [self addSubview:self.sendBtn];
  [self.sendBtn mas_makeConstraints:^(MASConstraintMaker *make) {
    make.centerY.equalTo(self);
    make.right.equalTo(self).offset(-8);
    make.size.mas_equalTo(CGSizeMake(60, 32));
  }];

  [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self).offset(8);
    make.centerY.equalTo(self);
    make.right.equalTo(self.sendBtn.mas_left).offset(-12);
    make.height.mas_equalTo(32);
  }];
}

- (void)sendBtnClick:(UIButton *)sender {
  if (self.cusDelegate && [self.cusDelegate respondsToSelector:@selector(didToolBarSendText:)]) {
    [self.cusDelegate didToolBarSendText:self.textField.text];
  }
  self.textField.text = @"";
  [self.textField resignFirstResponder];
}

- (void)becomeFirstResponse {
  [self.textField becomeFirstResponder];
}

- (void)setUpInputContent:(NSString *)content {
  self.textField.text = content;
}

#pragma mark - lazy load

- (UITextField *)textField {
  if (!_textField) {
    _textField = [[UITextField alloc] init];
    _textField.font = [UIFont systemFontOfSize:14];
    _textField.backgroundColor = HEXCOLOR(0xF0F0F2);
    _textField.textColor = [UIColor blackColor];
    _textField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, 0)];
    _textField.leftViewMode = UITextFieldViewModeAlways;
    _textField.layer.cornerRadius = 16;
  }
  return _textField;
}

- (UIButton *)sendBtn {
  if (!_sendBtn) {
    _sendBtn = [[UIButton alloc] init];
    [_sendBtn setTitle:NELocalizedString(@"发送") forState:UIControlStateNormal];
    _sendBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    _sendBtn.layer.cornerRadius = 16;
    _sendBtn.layer.masksToBounds = YES;
    _sendBtn.backgroundColor = HEXCOLOR(0x337EFF);
    [_sendBtn addTarget:self
                  action:@selector(sendBtnClick:)
        forControlEvents:UIControlEventTouchUpInside];
  }
  return _sendBtn;
}

@end
