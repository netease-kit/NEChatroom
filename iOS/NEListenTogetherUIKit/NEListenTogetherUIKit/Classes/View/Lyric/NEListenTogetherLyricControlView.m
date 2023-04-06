// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEListenTogetherLyricControlView.h"
#import <BlocksKit/BlocksKit+UIKit.h>
#import <Masonry/Masonry.h>
#import <libextobjc/extobjc.h>
#import "NEListenTogetherLocalized.h"
#import "NEListenTogetherUI.h"
#import "UIImage+NEUIExtension.h"

@interface NEListenTogetherControlButton : UIView

@property(nonatomic, copy) NSString *title;
@property(nonatomic, copy) NSString *selectedTitle;
@property(nonatomic, strong) UIImage *icon;
@property(nonatomic, strong) UIImage *selectedIcon;
@property(nonatomic, assign) bool enable;
@property(nonatomic, assign) bool selected;

@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UIImageView *iconImage;

@end

@implementation NEListenTogetherControlButton

- (instancetype)initWithFrame:(CGRect)frame {
  // 先写死一个尺寸
  if ([super initWithFrame:CGRectMake(0, 0, 40, 60)]) {
    [self setupView];
  }
  return self;
}

- (void)addAction:(void (^)(NEListenTogetherControlButton *))block {
  [self bk_whenTapped:^{
    if (self.enable) {
      block(self);
    }
  }];
}

- (void)setupView {
  [self addSubview:self.iconImage];
  [self.iconImage mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(self);
    make.centerX.equalTo(self);
    make.width.height.mas_equalTo(28);
  }];

  [self addSubview:self.titleLabel];
  [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.bottom.equalTo(self);
    make.top.equalTo(self.iconImage.mas_bottom).offset(2);
    make.left.right.equalTo(self);
  }];
}

- (void)setTitle:(NSString *)title {
  _title = title;
  if (!self.selected) {
    _titleLabel.text = title;
  }
  [self setEnable:self.enable];
}

- (void)setSelectedTitle:(NSString *)selectedTitle {
  _selectedTitle = selectedTitle;
  if (self.selected) {
    _titleLabel.text = selectedTitle;
  }
  [self setEnable:self.enable];
}

- (void)setIcon:(UIImage *)icon {
  _icon = icon;
  if (!self.selected) {
    _iconImage.image = icon;
  }
  [self setEnable:self.enable];
}

- (void)setSelectedIcon:(UIImage *)selectedIcon {
  _selectedIcon = selectedIcon;
  if (self.selected) {
    _iconImage.image = selectedIcon;
  }
  [self setEnable:self.enable];
}

- (void)setSelected:(bool)selected {
  _selected = selected;
  if (selected && _selectedIcon) {
    _iconImage.image = _selectedIcon;
  } else {
    _iconImage.image = _icon;
  }
  if (selected && _selectedTitle) {
    _titleLabel.text = _selectedTitle;
  } else {
    _titleLabel.text = _title;
  }
  [self setEnable:self.enable];
}

- (void)setEnable:(bool)enable {
  _enable = enable;
  if (enable) {
    self.titleLabel.textColor = [UIColor whiteColor];
    if (self.selected && self.selectedIcon) {
      self.iconImage.image = self.selectedIcon;
    } else {
      self.iconImage.image = self.icon;
    }
  } else {
    self.titleLabel.textColor = [UIColor colorWithWhite:1 alpha:0.4];
    if (self.iconImage.image) {
      self.iconImage.image =
          [self.iconImage.image ne_imageWithTintColor:[UIColor colorWithWhite:1 alpha:0.4]];
    }
  }
}

- (UILabel *)titleLabel {
  if (!_titleLabel) {
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:10];
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
  }
  return _titleLabel;
}

- (UIImageView *)iconImage {
  if (!_iconImage) {
    _iconImage = [UIImageView new];
  }
  return _iconImage;
}

@end

@interface NEListenTogetherLyricControlView ()

@property(nonatomic, strong) NEListenTogetherControlButton *pauseBtn;
@property(nonatomic, strong) NEListenTogetherControlButton *nextBtn;

@end

@implementation NEListenTogetherLyricControlView

- (instancetype)initWithFrame:(CGRect)frame {
  if ([super initWithFrame:frame]) {
    [self setupView];
  }
  return self;
}

- (void)setupView {
  self.hidden = YES;
  self.backgroundColor = [UIColor clearColor];

  [self addSubview:self.pauseBtn];
  [self addSubview:self.nextBtn];

  [self.pauseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
    make.centerY.mas_equalTo(self);
    make.top.bottom.mas_equalTo(self);
    make.width.mas_equalTo(40);
    make.centerX.mas_equalTo(self).offset(-50);
  }];

  [self.nextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
    make.centerY.mas_equalTo(self);
    make.top.bottom.mas_equalTo(self);
    make.width.mas_equalTo(40);
    make.centerX.mas_equalTo(self).offset(50);
  }];
}

- (void)setIsPlaying:(BOOL)isPlaying {
  _isPlaying = isPlaying;
  self.pauseBtn.selected = !isPlaying;
}

- (NEListenTogetherControlButton *)pauseBtn {
  if (!_pauseBtn) {
    _pauseBtn = [[NEListenTogetherControlButton alloc] initWithFrame:self.frame];
    _pauseBtn.enable = true;
    _pauseBtn.title = @"暂停";
    _pauseBtn.icon = [NEListenTogetherUI ne_listen_imageName:@"pause_icon"];
    _pauseBtn.selectedTitle = @"播放";
    _pauseBtn.selectedIcon = [NEListenTogetherUI ne_listen_imageName:@"resume_icon"];
    _pauseBtn.selected = !self.isPlaying;
    @weakify(self)[_pauseBtn addAction:^(NEListenTogetherControlButton *button) {
      @strongify(self) if (button.selected) {
        if ([self.delegate respondsToSelector:@selector(resumeSongWithView:)]) {
          [self.delegate resumeSongWithView:self];
        }
      }
      else {
        if ([self.delegate respondsToSelector:@selector(pauseSongWithView:)]) {
          [self.delegate pauseSongWithView:self];
        }
      }
    }];
  }
  return _pauseBtn;
}

- (NEListenTogetherControlButton *)nextBtn {
  if (!_nextBtn) {
    _nextBtn = [[NEListenTogetherControlButton alloc] initWithFrame:self.frame];
    _nextBtn.enable = true;
    _nextBtn.title = @"切歌";
    _nextBtn.icon = [NEListenTogetherUI ne_listen_imageName:@"next"];
    @weakify(self)[_nextBtn addAction:^(NEListenTogetherControlButton *button) {
      @strongify(self) if ([self.delegate respondsToSelector:@selector(nextSongWithView:)]) {
        [self.delegate nextSongWithView:self];
      }
    }];
  }
  return _nextBtn;
}

@end
