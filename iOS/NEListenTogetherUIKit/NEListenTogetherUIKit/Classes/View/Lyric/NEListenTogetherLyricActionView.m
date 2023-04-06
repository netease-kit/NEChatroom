// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEListenTogetherLyricActionView.h"
#import <Masonry/Masonry.h>
#import <libextobjc/extobjc.h>
#import "NEListenTogetherGlobalMacro.h"
#import "NEListenTogetherLyricView.h"
#import "NEListenTogetherUI.h"
#import "NEListenToghtherSlider.h"
@interface NEListenTogetherLyricActionView ()
@property(nonatomic, strong) NEListenTogetherLyricView *lyricView;
@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) NEListenToghtherSlider *slider;
@property(nonatomic, assign) BOOL sliding;
@property(nonatomic, strong) UILabel *currentTimeLabel;
@property(nonatomic, strong) UILabel *leftTimeLabel;

@end

@implementation NEListenTogetherLyricActionView

- (instancetype)initWithFrame:(CGRect)frame {
  if ([super initWithFrame:frame]) {
    [self setupView];
  }
  return self;
}

- (void)setupView {
  self.hidden = YES;
  self.sliding = NO;
  self.backgroundColor = [UIColor clearColor];
  self.layer.cornerRadius = 12;
  self.clipsToBounds = true;

  UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
  UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
  effectView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
  [self addSubview:effectView];
  [effectView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.edges.equalTo(self);
  }];

  [self addSubview:self.titleLabel];
  [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.centerX.equalTo(self);
    make.top.equalTo(self).offset(10);
  }];

  UIView *backGroundView = [[UIView alloc] init];
  backGroundView.backgroundColor = [UIColor clearColor];
  UIBlurEffect *backEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
  UIVisualEffectView *backEffectView = [[UIVisualEffectView alloc] initWithEffect:backEffect];
  effectView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
  [backGroundView addSubview:backEffectView];

  [backEffectView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.edges.equalTo(backGroundView);
  }];

  [self addSubview:backGroundView];
  [backGroundView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.right.bottom.equalTo(self);
    make.top.equalTo(self.titleLabel.mas_bottom).offset(12);
  }];

  [backGroundView addSubview:self.lyricView];
  [self.lyricView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.right.top.bottom.equalTo(backGroundView);
  }];

  [self addSubview:self.currentTimeLabel];
  [self.currentTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self).offset(8);
    make.bottom.equalTo(self).offset(-15);
  }];

  [self addSubview:self.leftTimeLabel];
  [self.leftTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.right.bottom.equalTo(self).offset(-8);
    make.bottom.equalTo(self).offset(-15);
  }];

  [self addSubview:self.slider];
  [self.slider mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self.currentTimeLabel.mas_right).offset(5);
    make.right.equalTo(self.leftTimeLabel.mas_left).offset(-5);
    make.bottom.equalTo(self).offset(-15);
  }];
}

#pragma mark - lyric view

- (NEListenTogetherLyricView *)lyricView {
  if (!_lyricView) {
    _lyricView = [[NEListenTogetherLyricView alloc] initWithFrame:self.frame];
    @weakify(self) _lyricView.timeForCurrent = ^NSInteger {
      @strongify(self) if ([self.delegate respondsToSelector:@selector(onLyricTime)]) {
        return [self.delegate onLyricTime];
      }
      else {
        return 0;
      }
    };
    _lyricView.seek = ^(NSInteger seek) {
      @strongify(self) if ([self.delegate respondsToSelector:@selector(onLyricSeek:)]) {
        [self.delegate onLyricSeek:seek];
      }
    };
  }
  return _lyricView;
}

- (UILabel *)titleLabel {
  if (!_titleLabel) {
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.textColor = HEXCOLOR(0x999999);
    _titleLabel.font = [UIFont systemFontOfSize:12];
  }
  return _titleLabel;
}

- (UILabel *)leftTimeLabel {
  if (!_leftTimeLabel) {
    _leftTimeLabel = [[UILabel alloc] init];
    _leftTimeLabel.textColor = HEXCOLOR(0x999999);
    _leftTimeLabel.font = [UIFont systemFontOfSize:10];
  }
  return _leftTimeLabel;
}
- (UILabel *)currentTimeLabel {
  if (!_currentTimeLabel) {
    _currentTimeLabel = [[UILabel alloc] init];
    _currentTimeLabel.textColor = HEXCOLOR(0x999999);
    _currentTimeLabel.font = [UIFont systemFontOfSize:10];
  }
  return _currentTimeLabel;
}
- (NEListenToghtherSlider *)slider {
  if (!_slider) {
    _slider = [NEListenToghtherSlider new];
    [_slider addTarget:self
                  action:@selector(sliderValueChanged:forEvent:)
        forControlEvents:UIControlEventValueChanged];
    [_slider setThumbImage:[NEListenTogetherUI ne_listen_imageName:@"circle"]
                  forState:UIControlStateNormal];
    _slider.minimumTrackTintColor = HEXCOLOR(0xFFFFFF);
    //        _slider.continuous = NO;
  }
  return _slider;
}

// 处理
- (void)sliderValueChanged:(UISlider *)slider forEvent:(UIEvent *)event {
  UITouch *touchEvent = event.allTouches.allObjects[0];

  switch (touchEvent.phase) {
    case UITouchPhaseBegan:
      self.sliding = YES;
      NSLog(@"开始拖动");
      break;
    case UITouchPhaseMoved:
      self.sliding = YES;
      NSLog(@"正在拖动");
      break;
    case UITouchPhaseEnded:
      NSLog(@"结束拖动");
      self.sliding = NO;
      [self sliderClick:slider];
      break;
    default:
      break;
  }
}

- (void)sliderClick:(UISlider *)slider {
  NSLog(@"===== %f", slider.value);
  if (self.lyricDuration) {
    NSInteger time = slider.value * self.lyricDuration;
    self.lyricView.seek(time);
    self.currentTimeLabel.text = [self formatSeconds:time];
  }
}

- (void)seekLyricView:(uint64_t)position {
  self.lyricView.seek(position);
}

- (void)setSongName:(NSString *)songName {
  _songName = songName;
  [self setTitleLabelText];
}

- (void)setSongSingers:(NSString *)songSingers {
  _songSingers = songSingers;
  [self setTitleLabelText];
}
- (void)setLyricPath:(NSString *)lyricPath {
  _lyricPath = lyricPath;
  self.lyricView.path = lyricPath;
}

- (void)setLyricContent:(NSString *)lyricContent lyricType:(NELyricType)type {
  self.lyricContent = lyricContent;
  [self.lyricView setContent:lyricContent lyricType:type];
}

- (void)setLyricDuration:(NSInteger)lyricDuration {
  _lyricDuration = lyricDuration;
  self.lyricView.duration = lyricDuration;
  self.leftTimeLabel.text = [self formatSeconds:self.lyricDuration];
}

- (void)setLyricSeekBtnHidden:(bool)lyricSeekBtnHidden {
  _lyricSeekBtnHidden = lyricSeekBtnHidden;
  self.lyricView.seekBtnHidden = lyricSeekBtnHidden;
}

- (void)updateLyric:(NSInteger)currentTime {
  [self.lyricView update];
  self.currentTimeLabel.text = [self formatSeconds:currentTime];
  if (self.lyricDuration && !self.sliding) {
    self.slider.value = currentTime * 1.0 / self.lyricDuration;
  }
}
- (void)setTitleLabelText {
  if (self.songName.length > 0 && self.songSingers.length > 0) {
    self.titleLabel.text = [NSString stringWithFormat:@"%@-%@", self.songName, self.songSingers];
  } else if (self.songName.length > 0) {
    self.titleLabel.text = self.songName;
  } else if (self.songSingers.length > 0) {
    self.titleLabel.text = self.songSingers;
  }
}
- (NSString *)formatSeconds:(NSInteger)milSeconds {
  long seconds = milSeconds / 1000;
  NSString *str_minute = [NSString stringWithFormat:@"%02ld", (seconds % 3600) / 60];
  NSString *str_second = [NSString stringWithFormat:@"%02ld", seconds % 60];
  return [NSString stringWithFormat:@"%@:%@", str_minute, str_second];
}

@end
