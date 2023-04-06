// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <NEUIKit/NEUICommon.h>
#import <NEUIKit/UIColor+NEUIExtension.h>
#import <NEUIKit/UIView+NEUIExtension.h>
#import "NEListenTogetherLocalized.h"
#import "NEListenTogetherUI.h"
#import "UIView+NEListenTogetherUIToast.h"

static CGFloat kNEListenTogetherToastMinWitdh = 120.0;
static NSInteger KNEListenTogetherToastBarTag = 111;

@interface NEUIToastBar : UIView

@property(nonatomic, assign) NEListenTogetherUIToastState state;
@property(nonatomic, strong) UILabel *infoLab;
@property(nonatomic, strong) UIImageView *imgView;
@property(nonatomic, strong) UIButton *cancelBtn;
@property(nonatomic, strong) dispatch_block_t cancel;

- (instancetype)initWithState:(NEListenTogetherUIToastState)state;
- (CGFloat)setInfo:(NSString *)info;

@end

@implementation UIView (NEListenTogetherUIToast)

- (void)showToastWithMessage:(NSString *)message state:(NEListenTogetherUIToastState)state {
  [self showToastWithMessage:message state:state autoDismiss:YES];
}

- (void)showToastWithMessage:(NSString *)message
                       state:(NEListenTogetherUIToastState)state
                 autoDismiss:(BOOL)autoDismiss {
  [self showToastWithMessage:message state:state cancel:nil];

  if (autoDismiss) {
    [self performSelector:@selector(dismissToast) withObject:nil afterDelay:1];
  }
}

- (void)showToastWithMessage:(NSString *)message
                       state:(NEListenTogetherUIToastState)state
                      cancel:(nullable dispatch_block_t)cancel {
  [self dismissToast];

  NEUIToastBar *bar = [[NEUIToastBar alloc] initWithState:state];
  bar.cancel = cancel;
  bar.tag = KNEListenTogetherToastBarTag;
  CGFloat width = [bar setInfo:message];
  width = MIN(width, self.bounds.size.width);
  CGFloat offset = 38.0;
  bar.frame = CGRectMake(0, -offset, width, offset);
  bar.centerX = self.bounds.size.width / 2;

  [self addSubview:bar];
  [UIView animateWithDuration:0.25
                   animations:^{
                     bar.top = [NEUICommon ne_statusBarHeight];
                   }];
}

- (void)dismissToast {
  [NSObject cancelPreviousPerformRequestsWithTarget:self];

  UIView *bar = [self viewWithTag:KNEListenTogetherToastBarTag];
  CGFloat offset = bar.height;

  bar.top = -offset;
  [bar removeFromSuperview];
}
@end

@implementation NEUIToastBar

- (instancetype)initWithState:(NEListenTogetherUIToastState)state {
  if (self = [super init]) {
    self.clipsToBounds = YES;
    self.backgroundColor = [UIColor whiteColor];
    self.layer.cornerRadius = 19;

    switch (state) {
      case NEUIToastStateSuccess:
        [self addSubview:self.imgView];
        [self addSubview:self.infoLab];
        _imgView.image = [NEListenTogetherUI ne_listen_imageName:@"state_success"];
        break;
      case NEUIToastStateFail:
        [self addSubview:self.imgView];
        [self addSubview:self.infoLab];
        _imgView.image = [NEListenTogetherUI ne_listen_imageName:@"state_fail"];
        break;
      case NEUIToastCancel:
        [self addSubview:self.infoLab];
        [self addSubview:self.cancelBtn];
        break;
      default:
        break;
    }
    _state = state;
  }
  return self;
}

- (void)layoutSubviews {
  [super layoutSubviews];

  switch (_state) {
    case NEUIToastStateSuccess:
    case NEUIToastStateFail: {
      _imgView.frame = CGRectMake(20.0, 0, 18.0, 18.0);
      _imgView.centerY = self.height / 2;
      _infoLab.frame = CGRectMake(_imgView.right + 5.0, 0, self.width - _imgView.right - 5.0 - 20.0,
                                  self.height);
      break;
    }
    case NEUIToastCancel: {
      _infoLab.frame = CGRectMake(20.0, 0, self.width - 56.0 - 20.0, self.height);
      _cancelBtn.frame = CGRectMake(_infoLab.right, 0, self.width - _infoLab.right, self.height);
      break;
    }
    default:
      break;
  }
}

- (CGFloat)setInfo:(NSString *)info {
  _infoLab.text = info ?: @"";
  [_infoLab sizeToFit];

  CGFloat width;
  if (_state != NEUIToastCancel) {
    width = _infoLab.width + 20.0 + 18.0 + 5.0 + 20.0;
  } else {
    width = _infoLab.width + 20.0 + 56.0;
  }
  return MAX(width, kNEListenTogetherToastMinWitdh);
}

#pragma mark - Action
- (void)cancelAction:(UIButton *)sender {
  if (_cancel) {
    _cancel();
  }
}

#pragma mark - Getter

- (UIImageView *)imgView {
  if (!_imgView) {
    _imgView = [[UIImageView alloc] init];
    _imgView.contentMode = UIViewContentModeScaleAspectFit;
  }
  return _imgView;
}

- (UILabel *)infoLab {
  if (!_infoLab) {
    _infoLab = [[UILabel alloc] init];
    _infoLab.font = [UIFont systemFontOfSize:14.0];
    _infoLab.textColor = [UIColor ne_colorWithHex:0x222222];
  }
  return _infoLab;
}

- (UIButton *)cancelBtn {
  if (!_cancelBtn) {
    _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_cancelBtn setTitle:NELocalizedString(@"取消") forState:UIControlStateNormal];
    [_cancelBtn setTitleColor:[UIColor ne_colorWithHex:0x35a4ff] forState:UIControlStateNormal];
    _cancelBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
    _cancelBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
    [_cancelBtn addTarget:self
                   action:@selector(cancelAction:)
         forControlEvents:UIControlEventTouchUpInside];
  }
  return _cancelBtn;
}

@end
