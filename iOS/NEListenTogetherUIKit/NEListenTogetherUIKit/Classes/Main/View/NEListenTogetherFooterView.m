// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEListenTogetherFooterView.h"
// #import "UIImage+NTES.h"
// #import "NTESPickMusicService.h"
// #import "NTESRtcConfig.h"
#import <Masonry/Masonry.h>
#import <NEUIKit/UIColor+NEUIExtension.h>
#import <NEUIKit/UIImage+NEUIExtension.h>
#import <NEUIKit/UIView+NEUIExtension.h>
#import "NEListenTogetherFontMacro.h"
#import "NEListenTogetherGlobalMacro.h"
#import "NEListenTogetherLocalized.h"
#import "NEListenTogetherUI.h"
#import "NEListenTogetherUIViewFactory.h"
#import "UIImage+ListenTogether.h"
#import "UIView+NEListenTogether.h"

static void *KVOContext = &KVOContext;

#define kBtnWidth 36
@interface NEListenTogetherFooterView () <UITextFieldDelegate>
@property(nonatomic, strong) UIView *searchBarBgView;
@property(nonatomic, strong) UIImageView *searchImageView;
@property(nonatomic, strong) UITextField *inputTextField;
@property(nonatomic, strong) UIButton *microphoneButton;
@property(nonatomic, strong) UIButton *bannedSpeakButton;
@property(nonatomic, strong) UIButton *menuButton;
@property(nonatomic, strong) UIButton *giftButton;
@property(nonatomic, strong) NSArray *buttonsArray;
@property(nonatomic, strong) UIButton *musicButton;
@property(nonatomic, strong) UILabel *markLable;
@property(nonatomic, strong) UILabel *pickUnreadLabel;

//@property (nonatomic, strong) NTESChatroomDataSource2 *context;
@property(nonatomic, strong) NEListenTogetherContext *context;
@end

@implementation NEListenTogetherFooterView
- (instancetype)initWithContext:(NEListenTogetherContext *)context {
  self = [super initWithFrame:CGRectZero];
  if (self) {
    self.context = context;
    [self.context.rtcConfig addObserver:self
                             forKeyPath:@"micOn"
                                options:NSKeyValueObservingOptionNew
                                context:KVOContext];
  }
  return self;
}

- (void)ntes_bindViewModel {
}

- (void)ntes_setupViews {
  self.backgroundColor = UIColor.clearColor;
  [self addSubview:self.searchBarBgView];
  [self.searchBarBgView addSubview:self.searchImageView];
  [self.searchBarBgView addSubview:self.inputTextField];

  CGSize searchViewSize = CGSizeZero;
  searchViewSize = CGSizeMake(UIWidthAdapter(140), UIWidthAdapter(36));

  [self.searchBarBgView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.size.mas_equalTo(searchViewSize);
    make.left.top.equalTo(self);
  }];

  [self.searchImageView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self.searchBarBgView).offset(12);
    make.centerY.equalTo(self.searchBarBgView);
    make.size.mas_equalTo(CGSizeMake(14, 14));
  }];

  [self.inputTextField mas_makeConstraints:^(MASConstraintMaker *make) {
    make.centerY.equalTo(self.searchBarBgView);
    make.left.equalTo(self.searchImageView.mas_right).offset(4);
    make.right.equalTo(self.searchBarBgView);
  }];
}

- (void)dealloc {
  [self.context.rtcConfig removeObserver:self forKeyPath:@"micOn"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey, id> *)change
                       context:(void *)context {
  if (context != KVOContext) {
    return [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
  }
  if ([keyPath isEqualToString:@"micOn"]) {
    self.microphoneButton.selected = !self.context.rtcConfig.micOn;
  }
}

- (void)layoutSubviews {
  [super layoutSubviews];
  [_searchBarBgView cutViewRounded:UIRectCornerAllCorners cornerRadii:CGSizeMake(18, 18)];
  if (self.width != 0 && self.height != 0) {
    [self doLayoutButtons];
  }
}

- (void)doLayoutButtons {
  if (self.width != 0 && self.height != 0) {
    [self.buttonsArray
        enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
          UIButton *btn = (UIButton *)obj;
          btn.frame =
              CGRectMake(self.width - kBtnWidth * (idx + 1) - 8.0 * idx, 0, kBtnWidth, kBtnWidth);
        }];
  }
}
- (void)setRole:(NEListenTogetherRole)role {
  _role = role;
  [self.buttonsArray makeObjectsPerformSelector:@selector(removeFromSuperview)];
  [self selectSubviewsWithRole:role];
  for (UIButton *btn in self.buttonsArray) {
    [self addSubview:btn];
  }
  [self doLayoutButtons];
}

- (void)selectSubviewsWithRole:(NEListenTogetherRole)role {
  switch (role) {
    case NEListenTogetherRoleHost:
      self.buttonsArray = @[ self.menuButton, self.microphoneButton, self.musicButton ];
      break;
    case NEListenTogetherRoleAudience:
      self.buttonsArray = @[ self.giftButton ];
      break;
      //        case NEListenTogetherRoleConnector:
      //            self.buttonsArray = @[self.menuButton,self.microphoneButton];
      //            break;
    default:
      break;
  }
}

- (void)updateAudienceOperatingButton:(BOOL)isOnSeat {
  [self.buttonsArray makeObjectsPerformSelector:@selector(removeFromSuperview)];
  if (self.role == NEListenTogetherRoleHost) {
    self.buttonsArray = isOnSeat ? @[ self.menuButton, self.microphoneButton, self.musicButton ]
                                 : @[ self.giftButton ];
  } else {
    self.buttonsArray =
        isOnSeat ? @[ self.menuButton, self.microphoneButton, self.giftButton, self.musicButton ]
                 : @[ self.giftButton ];
  }
  for (UIButton *btn in self.buttonsArray) {
    [self addSubview:btn];
  }
  [self doLayoutButtons];
}
- (void)footerButtonClickAction:(UIButton *)sender {
  switch (sender.tag) {
    case NEUIFunctionAreaMicrophone: {
      if (_delegate && [_delegate respondsToSelector:@selector(footerDidReceiveMicMuteAction:)]) {
        [_delegate footerDidReceiveMicMuteAction:!sender.selected];
      }
    } break;
    case NEUIFunctionAreaBanned: {
      if (_delegate && [_delegate respondsToSelector:@selector(footerDidReceiveNoSpeekingAciton)]) {
        [_delegate footerDidReceiveNoSpeekingAciton];
      }
    } break;
    case NEUIFunctionAreaMore: {
      if (_delegate && [_delegate respondsToSelector:@selector(footerDidReceiveMenuClickAciton)]) {
        [_delegate footerDidReceiveMenuClickAciton];
      }
    } break;
    case NEUIFunctionGift: {
      [NSNotificationCenter.defaultCenter
          postNotification:[NSNotification notificationWithName:@"listenTogetherGift" object:nil]];
      if (_delegate && [_delegate respondsToSelector:@selector(footerDidReceiveGiftClickAciton)]) {
        [_delegate footerDidReceiveGiftClickAciton];
      }
    } break;

    case NEUIFunctionMusic: {
      [NSNotificationCenter.defaultCenter
          postNotification:[NSNotification notificationWithName:@"listenTogetherOrderSong"
                                                         object:nil]];
      if (_delegate && [_delegate respondsToSelector:@selector(footerDidReceiveMusicClickAciton)]) {
        [_delegate footerDidReceiveMusicClickAciton];
      }
    } break;
    default:
      break;
  }
}

- (void)setMuteWithType:(NEUIMuteType)type {
  NSString *msg = @"";
  if (type == NEUIMuteTypeSelf) {
    msg = NELocalizedString(@"您已被禁言");
  } else if (type == NEUIMuteTypeAll) {
    //        msg = @"主播已开启\"全部禁言\"";
    msg = NELocalizedString(@"聊天室被禁言");
  }
  self.inputTextField.attributedPlaceholder = [[NSAttributedString alloc]
      initWithString:msg
          attributes:@{NSForegroundColorAttributeName : HEXCOLOR(0x4b6677)}];
  self.searchBarBgView.userInteractionEnabled = NO;
}

- (void)cancelMute {
  self.searchBarBgView.userInteractionEnabled = YES;
  self.inputTextField.attributedPlaceholder = [[NSAttributedString alloc]
      initWithString:NELocalizedString(@"一起聊聊吧~")
          attributes:@{NSForegroundColorAttributeName : HEXCOLOR(0xAAACB7)}];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
  if ([self.delegate respondsToSelector:@selector(footerInputViewDidClickAction)]) {
    [self.delegate footerInputViewDidClickAction];
  }
  return NO;
}

#pragma mark - lazyMethod
- (UIView *)searchBarBgView {
  if (!_searchBarBgView) {
    _searchBarBgView =
        [NEListenTogetherUIViewFactory createViewFrame:CGRectZero
                                       BackgroundColor:UIColorFromRGBA(0x000000, 0.5)];
  }
  return _searchBarBgView;
}

- (UIImageView *)searchImageView {
  if (!_searchImageView) {
    _searchImageView = [NEListenTogetherUIViewFactory createImageViewFrame:CGRectZero
                                                                 imageName:@""];
    _searchImageView.image = [[UIImage voiceRoom_imageNamed:@"chatroom_titleIcon"]
        ne_imageWithTintColor:HEXCOLOR(0xAAACB7)];
  }
  return _searchImageView;
}

- (UITextField *)inputTextField {
  if (!_inputTextField) {
    _inputTextField = [NEListenTogetherUIViewFactory createTextfieldFrame:CGRectZero
                                                              placeHolder:@""];
    _inputTextField.attributedPlaceholder = [[NSAttributedString alloc]
        initWithString:NELocalizedString(@"一起聊聊吧~")
            attributes:@{NSForegroundColorAttributeName : HEXCOLOR(0xAAACB7)}];
    _inputTextField.font = TextFont_13;
    _inputTextField.delegate = self;
    _inputTextField.textColor = UIColor.whiteColor;
  }
  return _inputTextField;
}

- (UIButton *)microphoneButton {
  if (!_microphoneButton) {
    _microphoneButton =
        [NEListenTogetherUIViewFactory createBtnFrame:CGRectZero
                                                title:@""
                                              bgImage:@""
                                        selectBgImage:@""
                                                image:@"icon_mic_on_n"
                                               target:self
                                               action:@selector(footerButtonClickAction:)];
    [_microphoneButton setImage:[NEListenTogetherUI ne_listen_imageName:@"icon_mic_off_n"]
                       forState:UIControlStateSelected];
    [_microphoneButton setBackgroundColor:UIColorFromRGBA(0x000000, 0.5)];
    _microphoneButton.tag = NEUIFunctionAreaMicrophone;
    _microphoneButton.selected = !self.context.rtcConfig.micOn;
    _microphoneButton.layer.cornerRadius = kBtnWidth / 2;
  }
  return _microphoneButton;
}

- (UIButton *)bannedSpeakButton {
  if (!_bannedSpeakButton) {
    _bannedSpeakButton =
        [NEListenTogetherUIViewFactory createBtnFrame:CGRectZero
                                                title:@""
                                              bgImage:@""
                                        selectBgImage:@""
                                                image:@"banned_speak"
                                               target:self
                                               action:@selector(footerButtonClickAction:)];
    [_bannedSpeakButton setBackgroundColor:UIColorFromRGBA(0x000000, 0.5)];
    _bannedSpeakButton.tag = NEUIFunctionAreaBanned;
    _bannedSpeakButton.layer.cornerRadius = kBtnWidth / 2;
  }
  return _bannedSpeakButton;
}

- (UIButton *)giftButton {
  if (!_giftButton) {
    _giftButton =
        [NEListenTogetherUIViewFactory createBtnFrame:CGRectZero
                                                title:@""
                                              bgImage:@""
                                        selectBgImage:@""
                                                image:@"inupt_gift"
                                               target:self
                                               action:@selector(footerButtonClickAction:)];
    _giftButton.tag = NEUIFunctionGift;
    _giftButton.layer.cornerRadius = kBtnWidth / 2;
  }
  return _giftButton;
}

- (UIButton *)musicButton {
  if (!_musicButton) {
    _musicButton =
        [NEListenTogetherUIViewFactory createBtnFrame:CGRectZero
                                                title:@""
                                              bgImage:@""
                                        selectBgImage:@""
                                                image:@"music"
                                               target:self
                                               action:@selector(footerButtonClickAction:)];
    _musicButton.tag = NEUIFunctionMusic;
    _musicButton.layer.cornerRadius = kBtnWidth / 2;
  }
  return _musicButton;
}

- (UIButton *)menuButton {
  if (!_menuButton) {
    _menuButton =
        [NEListenTogetherUIViewFactory createBtnFrame:CGRectZero
                                                title:@""
                                              bgImage:@""
                                        selectBgImage:@""
                                                image:@"moreContent_icon"
                                               target:self
                                               action:@selector(footerButtonClickAction:)];
    [_menuButton setBackgroundColor:UIColorFromRGBA(0x000000, 0.5)];
    _menuButton.tag = NEUIFunctionAreaMore;
    _menuButton.layer.cornerRadius = kBtnWidth / 2;
  }
  return _menuButton;
}

- (UILabel *)markLable {
  if (!_markLable) {
    _markLable = [[UILabel alloc] initWithFrame:CGRectMake(kBtnWidth - 16, 0, 20, 12)];
    _markLable.textColor = HEXCOLOR(0x222222);
    _markLable.font = Font_Default(10);
    _markLable.backgroundColor = UIColor.whiteColor;
    _markLable.text = @"0";
    _markLable.textAlignment = NSTextAlignmentCenter;
    _markLable.layer.cornerRadius = 5;
    _markLable.layer.masksToBounds = YES;
  }
  return _markLable;
}

- (UILabel *)pickUnreadLabel {
  if (!_pickUnreadLabel) {
    _pickUnreadLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _pickUnreadLabel.font = [UIFont systemFontOfSize:10];
    _pickUnreadLabel.backgroundColor = UIColor.whiteColor;
    _pickUnreadLabel.textAlignment = NSTextAlignmentCenter;
    _pickUnreadLabel.textColor = HEXCOLOR(0x222222);
    _pickUnreadLabel.layer.cornerRadius = 6;
    _pickUnreadLabel.layer.masksToBounds = YES;
    _pickUnreadLabel.hidden = YES;
  }
  return _pickUnreadLabel;
}

- (void)configPickSongUnreadNumber:(NSInteger)number {
  self.pickUnreadLabel.hidden = !(number > 0);
  self.pickUnreadLabel.text = [NSString stringWithFormat:@"%ld", number];
}

@end
