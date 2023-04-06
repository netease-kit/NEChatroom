// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEVoiceRoomHeaderView.h"
#import <Masonry/Masonry.h>
#import "NEUICreateRoomTitleButton.h"
#import "NEUINoticePopView.h"
#import "NEUIViewFactory.h"
#import "NEVoiceRoomUI.h"
#import "NSBundle+NELocalized.h"
#import "NSString+NTES.h"
#import "NTESFontMacro.h"
#import "NTESGlobalMacro.h"
#import "UIImage+VoiceRoom.h"
#import "UIView+VoiceRoom.h"

@interface NEVoiceRoomHeaderView ()
@property(nonatomic, strong) UILabel *roomNameLabel;
@property(nonatomic, strong) UILabel *onlinePersonLabel;
@property(nonatomic, strong) UIButton *closeRoomButton;
@property(nonatomic, strong) NEUICreateRoomTitleButton *noticeButton;
@property(nonatomic, strong) UIView *headerMusicView;
@property(nonatomic, strong) UILabel *headerMusicLabel;
@property(nonatomic, strong) UIImageView *headerMusicImageView;
// 小窗按钮
@property(nonatomic, strong) UIButton *smallButton;

@end

@implementation NEVoiceRoomHeaderView

- (void)ntes_setupViews {
  self.backgroundColor = UIColor.clearColor;
  [self addSubview:self.roomNameLabel];
  [self addSubview:self.onlinePersonLabel];
  [self addSubview:self.closeRoomButton];
  [self addSubview:self.noticeButton];
  [self addSubview:self.headerMusicView];
  [self addSubview:self.smallButton];
  [self.headerMusicView addSubview:self.headerMusicImageView];
  [self.headerMusicView addSubview:self.headerMusicLabel];

  [self.roomNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.top.equalTo(self);
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
    make.height.mas_equalTo(CGSizeMake(54, 20));
    make.width.mas_equalTo(
        [NELocalizedString(@"公告") sizeWithFont:Font_Default(12) maxH:20].width + 30);
  }];

  [self.smallButton mas_makeConstraints:^(MASConstraintMaker *make) {
    make.size.mas_equalTo(CGSizeMake(24, 24));
    make.right.equalTo(self.closeRoomButton.mas_left).offset(-10);
    make.centerY.equalTo(self.closeRoomButton);
  }];
  [self.headerMusicView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self.roomNameLabel.mas_right).offset(20);
    make.right.equalTo(self.smallButton.mas_left).offset(-5);
    make.centerY.equalTo(self.roomNameLabel);
    make.height.equalTo(@20);
  }];

  [self.headerMusicImageView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self.headerMusicView.mas_left).offset(-5);
    make.centerY.equalTo(self.headerMusicView);
    make.width.height.equalTo(@14);
  }];
  [self.headerMusicLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self.headerMusicImageView.mas_right).offset(5);
    make.centerY.equalTo(self.headerMusicImageView);
    make.right.equalTo(self.smallButton.mas_left).offset(-2);
  }];
}

- (void)closeRoomButtonClickAction {
  if (_delegate && [_delegate respondsToSelector:@selector(headerExitAction)]) {
    [self.delegate headerExitAction];
  }
}
- (void)smallButtonClickAction {
  if (_delegate && [_delegate respondsToSelector:@selector(smallWindowAction)]) {
    [self.delegate smallWindowAction];
  }
}
- (void)noticeButtonClickAction {
  NEUINoticePopView *noticePopView =
      [[NEUINoticePopView alloc] initWithFrame:CGRectMake(0, 0, UIScreenWidth, UIScreenHeight)];
  [[UIApplication sharedApplication].keyWindow addSubview:noticePopView];
}
- (void)layoutSubviews {
  [super layoutSubviews];
  [self.noticeButton cutViewRounded:UIRectCornerAllCorners cornerRadii:CGSizeMake(20, 20)];
  [self.onlinePersonLabel cutViewRounded:UIRectCornerAllCorners cornerRadii:CGSizeMake(20, 20)];
  [self.closeRoomButton cutViewRounded:UIRectCornerAllCorners cornerRadii:CGSizeMake(12, 12)];
  [self.smallButton cutViewRounded:UIRectCornerAllCorners cornerRadii:CGSizeMake(12, 12)];
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

- (void)setMusicTitle:(NSString *)musicTitle {
  _musicTitle = musicTitle;
  if (musicTitle.length > 0) {
    self.headerMusicView.hidden = NO;
    self.headerMusicLabel.text = musicTitle;
  } else {
    self.headerMusicView.hidden = YES;
  }
}

#pragma mark - lazyMethod

- (UILabel *)roomNameLabel {
  if (!_roomNameLabel) {
    _roomNameLabel = [NEUIViewFactory createLabelFrame:CGRectZero
                                                 title:NELocalizedString(@"房间名称")
                                             textColor:UIColor.whiteColor
                                         textAlignment:NSTextAlignmentLeft
                                                  font:TextFont_16];
  }
  return _roomNameLabel;
}

- (UILabel *)onlinePersonLabel {
  if (!_onlinePersonLabel) {
    _onlinePersonLabel = [NEUIViewFactory createLabelFrame:CGRectZero
                                                     title:NELocalizedString(@"在线0人")
                                                 textColor:UIColor.whiteColor
                                             textAlignment:NSTextAlignmentCenter
                                                      font:Font_Default(12)];
    [_onlinePersonLabel setBackgroundColor:UIColorFromRGBA(0x000000, 0.5)];
  }
  return _onlinePersonLabel;
}

- (NEUICreateRoomTitleButton *)noticeButton {
  if (!_noticeButton) {
    _noticeButton = [[NEUICreateRoomTitleButton alloc] initWithImage:@"roomNotice_icon"
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

- (UIButton *)smallButton {
  if (!_smallButton) {
    _smallButton = [[UIButton alloc] init];
    UIImage *image = [UIImage nevoiceRoom_imageNamed:@"small_icon"];
    [_smallButton setImage:image forState:UIControlStateNormal];
    [_smallButton addTarget:self
                     action:@selector(smallButtonClickAction)
           forControlEvents:UIControlEventTouchUpInside];
    //        [_smallButton setBackgroundColor:UIColorFromRGBA(0x000000, 0.5)];
  }
  return _smallButton;
}
- (UIButton *)closeRoomButton {
  if (!_closeRoomButton) {
    _closeRoomButton = [[UIButton alloc] init];
    [_closeRoomButton setImage:[UIImage nevoiceRoom_imageNamed:@"closeroom_icon"]
                      forState:UIControlStateNormal];
    [_closeRoomButton addTarget:self
                         action:@selector(closeRoomButtonClickAction)
               forControlEvents:UIControlEventTouchUpInside];
    [_closeRoomButton setBackgroundColor:UIColorFromRGBA(0x000000, 0.5)];
  }
  return _closeRoomButton;
}

- (UIView *)headerMusicView {
  if (!_headerMusicView) {
    _headerMusicView = [[UIView alloc] init];
    _headerMusicView.hidden = YES;
  }
  return _headerMusicView;
}
- (UILabel *)headerMusicLabel {
  if (!_headerMusicLabel) {
    _headerMusicLabel = [[UILabel alloc] init];
    _headerMusicLabel.font = Font_Default(12);
    _headerMusicLabel.textColor = HEXCOLOR(0xFFFFFF);
  }
  return _headerMusicLabel;
}
- (UIImageView *)headerMusicImageView {
  if (!_headerMusicImageView) {
    _headerMusicImageView = [[UIImageView alloc] init];
    _headerMusicImageView.image = [NEVoiceRoomUI ne_voice_imageName:@"header_music"];
  }
  return _headerMusicImageView;
}
@end
