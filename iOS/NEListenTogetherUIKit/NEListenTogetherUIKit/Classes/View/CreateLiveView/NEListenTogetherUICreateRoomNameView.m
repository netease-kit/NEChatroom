// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEListenTogetherUICreateRoomNameView.h"
#import <Masonry/Masonry.h>
#import <NEListenTogetherKit/NEListenTogetherKit-Swift.h>
#import "NEListenTogetherFontMacro.h"
#import "NEListenTogetherGlobalMacro.h"
#import "NEListenTogetherLocalized.h"
#import "NEListenTogetherToast.h"
#import "NEListenTogetherUI.h"
#import "NEListenTogetherUICreateRoomTitleButton.h"
#import "NEListenTogetherUIViewFactory.h"
#import "UIButton+NEListenTogetherLayout.h"
#import "UIImage+ListenTogether.h"

@interface NEListenTogetherUICreateRoomNameView () <UITextViewDelegate>
@property(nonatomic, strong) NSArray *titleArray;
@property(nonatomic, strong) UIButton *chatRoomButton;
@property(nonatomic, strong) UIButton *ktvButton;
@property(nonatomic, strong) UIView *divideView;
@property(nonatomic, strong) UIView *slideView;
@property(nonatomic, strong) UITextView *contentTextView;
@property(nonatomic, strong) UIButton *randomThemeButton;
@property(nonatomic, copy) NSString *bgImageUrl;
@end

@implementation NEListenTogetherUICreateRoomNameView

- (void)ntes_bindViewModel {
  [self createRandomRoomName];
}

- (void)ntes_setupViews {
  self.backgroundColor = UIColorFromRGBA(0x0C0C0D, 0.6);
  [self addSubview:self.chatRoomButton];
  //  [self addSubview:self.ktvButton];
  [self addSubview:self.divideView];
  //  [self addSubview:self.slideView];
  [self addSubview:self.contentTextView];
  [self addSubview:self.randomThemeButton];

  [self.chatRoomButton mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(self);
    make.left.equalTo(self).offset(16);
    make.height.mas_equalTo(48);
  }];

  //  [self.ktvButton mas_makeConstraints:^(MASConstraintMaker *make) {
  //    make.top.right.equalTo(self);
  //    make.left.equalTo(self.mas_centerX);
  //    make.height.mas_equalTo(48);
  //  }];

  [self.divideView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(self).offset(48);
    make.left.equalTo(self).offset(12);
    make.right.equalTo(self).offset(-12);
    make.height.mas_equalTo(0.5);
  }];

  //  [self.slideView mas_makeConstraints:^(MASConstraintMaker *make) {
  //    make.bottom.equalTo(self.divideView.mas_top);
  //    make.centerX.equalTo(self.chatRoomButton);
  //    make.size.mas_equalTo(CGSizeMake(20, 3));
  //  }];

  [self.randomThemeButton mas_makeConstraints:^(MASConstraintMaker *make) {
    make.size.mas_equalTo(CGSizeMake(20, 20));
    make.top.equalTo(self.divideView.mas_bottom).offset(12);
    make.right.equalTo(self).offset(-12);
  }];

  [self.contentTextView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self).offset(12);
    make.bottom.equalTo(self).offset(-12);
    make.top.equalTo(self.divideView.mas_bottom);
    make.right.equalTo(self.randomThemeButton.mas_left).offset(-12);
  }];
}

- (void)layoutSubviews {
  [super layoutSubviews];
  //  [self.ktvButton layoutButtonWithEdgeInsetsStyle:QSButtonEdgeInsetsStyleLeft
  //  imageTitleSpace:2];
  [self.chatRoomButton layoutButtonWithEdgeInsetsStyle:QSButtonEdgeInsetsStyleLeft
                                       imageTitleSpace:2];
}

// 点击语聊房
- (void)chatRoomButtonClick {
  self.chatRoomButton.alpha = 1;
  self.ktvButton.alpha = 0.5;
  //  [self.slideView mas_remakeConstraints:^(MASConstraintMaker *make) {
  //    make.bottom.equalTo(self.divideView.mas_top);
  //    make.centerX.equalTo(self.chatRoomButton);
  //    make.size.mas_equalTo(CGSizeMake(20, 3));
  //  }];
  if (_delegate && [_delegate respondsToSelector:@selector(createRoomResult)]) {
    [_delegate createRoomResult];
  }
}

// 点击ktv房间
- (void)ktvButtonClick {
  self.chatRoomButton.alpha = 0.5;
  self.ktvButton.alpha = 1;
  //  [self.slideView mas_remakeConstraints:^(MASConstraintMaker *make) {
  //    make.bottom.equalTo(self.divideView.mas_top);
  //    make.centerX.equalTo(self.ktvButton);
  //    make.size.mas_equalTo(CGSizeMake(20, 3));
  //  }];
  if (_delegate && [_delegate respondsToSelector:@selector(createRoomResult)]) {
    [_delegate createRoomResult];
  }
}

- (NSString *)getRoomName {
  return self.contentTextView.text;
}
- (NSString *)getRoomBgImageUrl {
  return self.bgImageUrl;
}
- (void)createRandomRoomName {
  [NEListenTogetherKit.getInstance
      getCreateRoomDefaultInfo:^(NSInteger code, NSString *_Nullable msg,
                                 NECreateVoiceRoomDefaultInfo *_Nullable info) {
        if (code != 0) {
          [NEListenTogetherToast showToast:NELocalizedString(@"获取房间随机主题失败")];
          return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
          if (info) {
            self.contentTextView.text = info.topic;
            self.bgImageUrl = info.livePicture;
          }
        });
      }];
}

- (BOOL)textView:(UITextView *)textView
    shouldChangeTextInRange:(NSRange)range
            replacementText:(NSString *)text {
  if ([text isEqualToString:@"\n"]) {
    [textView resignFirstResponder];
    return NO;
  }
  NSString *newString = [textView.text stringByReplacingCharactersInRange:range withString:text];
  return newString.length <= 20;  // 限制 20字符
}

#pragma mark - lazyMethod

- (UIButton *)chatRoomButton {
  if (!_chatRoomButton) {
    _chatRoomButton = [[UIButton alloc] init];
    [_chatRoomButton setTitle:NELocalizedString(@"一起听") forState:UIControlStateNormal];
    [_chatRoomButton setImage:[NEListenTogetherUI ne_listen_imageName:@"chatroom_titleIcon"]
                     forState:UIControlStateNormal];
    _chatRoomButton.titleLabel.textColor = UIColor.whiteColor;
    _chatRoomButton.titleLabel.font = TextFont_16;
    [_chatRoomButton addTarget:self
                        action:@selector(chatRoomButtonClick)
              forControlEvents:UIControlEventTouchUpInside];
  }
  return _chatRoomButton;
}

- (UIButton *)ktvButton {
  if (!_ktvButton) {
    _ktvButton = [[UIButton alloc] init];
    [_ktvButton setTitle:@"KTV" forState:UIControlStateNormal];
    [_ktvButton setImage:[NEListenTogetherUI ne_listen_imageName:@"ktv_titleIcon"]
                forState:UIControlStateNormal];
    _ktvButton.titleLabel.textColor = UIColor.whiteColor;
    _ktvButton.titleLabel.font = TextFont_16;
    [_ktvButton addTarget:self
                   action:@selector(ktvButtonClick)
         forControlEvents:UIControlEventTouchUpInside];
    _ktvButton.alpha = 0.5;
    _ktvButton.hidden = true;
  }
  return _ktvButton;
}

- (UIView *)divideView {
  if (!_divideView) {
    _divideView = [NEListenTogetherUIViewFactory createViewFrame:CGRectZero
                                                 BackgroundColor:UIColorFromRGBA(0xffffff, 0.2)];
  }
  return _divideView;
}

- (UIView *)slideView {
  if (!_slideView) {
    _slideView = [NEListenTogetherUIViewFactory createViewFrame:CGRectZero
                                                BackgroundColor:HEXCOLOR(0x337EFF)];
  }
  return _slideView;
}

- (UITextView *)contentTextView {
  if (!_contentTextView) {
    _contentTextView = [[UITextView alloc] init];
    _contentTextView.backgroundColor = UIColor.clearColor;
    _contentTextView.textColor = UIColor.whiteColor;
    _contentTextView.font = TextFont_14;
    _contentTextView.delegate = self;
    _contentTextView.text = NELocalizedString(@"随机");
  }
  return _contentTextView;
}

- (UIButton *)randomThemeButton {
  if (!_randomThemeButton) {
    _randomThemeButton = [[UIButton alloc] init];
    [_randomThemeButton setBackgroundImage:[UIImage voiceRoom_imageNamed:@"createRoom_randomIcon"]
                                  forState:UIControlStateNormal];
    [_randomThemeButton addTarget:self
                           action:@selector(createRandomRoomName)
                 forControlEvents:UIControlEventTouchUpInside];
  }
  return _randomThemeButton;
}
@end
