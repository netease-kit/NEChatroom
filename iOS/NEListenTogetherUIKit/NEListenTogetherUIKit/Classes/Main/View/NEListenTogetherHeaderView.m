// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEListenTogetherHeaderView.h"
#import <Masonry/Masonry.h>
#import "NEListenTogetherFontMacro.h"
#import "NEListenTogetherGlobalMacro.h"
#import "NEListenTogetherLocalized.h"
#import "NEListenTogetherNoticePopView.h"
#import "NEListenTogetherUICreateRoomTitleButton.h"
#import "NEListenTogetherUIViewFactory.h"
#import "NSString+NEListenTogetherString.h"
#import "UIImage+ListenTogether.h"
#import "UIView+NEListenTogether.h"

@interface NEListenTogetherHeaderView ()
@property(nonatomic, strong) UILabel *roomNameLabel;
@property(nonatomic, strong) UILabel *onlinePersonLabel;
@property(nonatomic, strong) UIButton *closeRoomButton;
@property(nonatomic, strong) NEListenTogetherUICreateRoomTitleButton *noticeButton;

@end

@implementation NEListenTogetherHeaderView

- (void)ntes_setupViews {
  self.backgroundColor = UIColor.clearColor;
  [self addSubview:self.roomNameLabel];
  [self addSubview:self.onlinePersonLabel];
  [self addSubview:self.closeRoomButton];
  [self addSubview:self.noticeButton];

  [self.roomNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.top.equalTo(self);
    make.right.equalTo(self.closeRoomButton.mas_left);
  }];

  [self.onlinePersonLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.bottom.right.equalTo(self);
    make.height.mas_equalTo(20);
    make.width.mas_equalTo([@"在线%@人" sizeWithFont:Font_Default(12) maxH:20].width + 10);
  }];
  [self.closeRoomButton mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.right.equalTo(self);
    make.size.mas_equalTo(CGSizeMake(24, 24));
  }];

  [self.noticeButton mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.bottom.equalTo(self);
    make.height.equalTo(@20);
    make.width.mas_equalTo(
        [NELocalizedString(@"公告") sizeWithFont:Font_Default(12) maxH:20].width + 30);
  }];
}

- (void)closeRoomButtonClickAction {
  if (_delegate && [_delegate respondsToSelector:@selector(headerExitAction)]) {
    [self.delegate headerExitAction];
  }
}

- (void)noticeButtonClickAction {
  NEListenTogetherNoticePopView *noticePopView = [[NEListenTogetherNoticePopView alloc]
      initWithFrame:CGRectMake(0, 0, UIScreenWidth, UIScreenHeight)];
  [[UIApplication sharedApplication].keyWindow addSubview:noticePopView];
}
- (void)layoutSubviews {
  [super layoutSubviews];
  [self.noticeButton cutViewRounded:UIRectCornerAllCorners cornerRadii:CGSizeMake(20, 20)];
  [self.onlinePersonLabel cutViewRounded:UIRectCornerAllCorners cornerRadii:CGSizeMake(20, 20)];
  [self.closeRoomButton cutViewRounded:UIRectCornerAllCorners cornerRadii:CGSizeMake(12, 12)];
}

- (void)setTitle:(NSString *)title {
  _title = title;
  self.roomNameLabel.text = title;
}

- (void)setOnlinePeople:(NSInteger)onlinePeople {
  _onlinePeople = onlinePeople;
  NSString *onLineNumberString =
      [NSString stringWithFormat:NELocalizedString(@"在线%@人"), @(onlinePeople)];
  self.onlinePersonLabel.text = onLineNumberString;
  [self.onlinePersonLabel mas_updateConstraints:^(MASConstraintMaker *make) {
    make.width.mas_equalTo([onLineNumberString sizeWithFont:Font_Default(12) maxH:20].width + 10);
  }];
}

#pragma mark - lazyMethod

- (UILabel *)roomNameLabel {
  if (!_roomNameLabel) {
    _roomNameLabel = [NEListenTogetherUIViewFactory createLabelFrame:CGRectZero
                                                               title:NELocalizedString(@"房间名称")
                                                           textColor:UIColor.whiteColor
                                                       textAlignment:NSTextAlignmentLeft
                                                                font:TextFont_16];
  }
  return _roomNameLabel;
}

- (UILabel *)onlinePersonLabel {
  if (!_onlinePersonLabel) {
    _onlinePersonLabel =
        [NEListenTogetherUIViewFactory createLabelFrame:CGRectZero
                                                  title:NELocalizedString(@"在线0人")
                                              textColor:UIColor.whiteColor
                                          textAlignment:NSTextAlignmentCenter
                                                   font:Font_Default(12)];
    [_onlinePersonLabel setBackgroundColor:UIColorFromRGBA(0x000000, 0.5)];
  }
  return _onlinePersonLabel;
}

- (NEListenTogetherUICreateRoomTitleButton *)noticeButton {
  if (!_noticeButton) {
    _noticeButton =
        [[NEListenTogetherUICreateRoomTitleButton alloc] initWithImage:@"roomNotice_icon"
                                                               content:NELocalizedString(@"公告")];
    [_noticeButton addTarget:self
                      action:@selector(noticeButtonClickAction)
            forControlEvents:UIControlEventTouchUpInside];
    [_noticeButton setLableFont:Font_Default(12)];
    [_noticeButton setLeftMargin:8 imageSize:CGSizeMake(12, 12)];
    _noticeButton.backgroundColor = UIColorFromRGBA(0x000000, 0.5);
  }
  return _noticeButton;
}

- (UIButton *)closeRoomButton {
  if (!_closeRoomButton) {
    _closeRoomButton = [[UIButton alloc] init];
    [_closeRoomButton setImage:[UIImage voiceRoom_imageNamed:@"closeroom_icon"]
                      forState:UIControlStateNormal];
    [_closeRoomButton addTarget:self
                         action:@selector(closeRoomButtonClickAction)
               forControlEvents:UIControlEventTouchUpInside];
    [_closeRoomButton setBackgroundColor:UIColorFromRGBA(0x000000, 0.5)];
  }
  return _closeRoomButton;
}
@end
