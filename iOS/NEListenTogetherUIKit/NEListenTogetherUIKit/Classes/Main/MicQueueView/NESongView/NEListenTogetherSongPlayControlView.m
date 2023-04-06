// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEListenTogetherSongPlayControlView.h"
#import <Masonry/Masonry.h>
#import "NEListenTogetherUI.h"

@interface NEListenTogetherSongPlayControlView ()

@property(nonatomic, strong) UIButton *pauseBtn;
@property(nonatomic, strong) UIButton *nextBtn;
@property(nonatomic, strong) UIImageView *speakerImageView;
@property(nonatomic, strong) UISlider *volumeSlider;

@end

@implementation NEListenTogetherSongPlayControlView

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    [self initView];
    self.backgroundColor = [UIColor whiteColor];
  }
  return self;
}

- (void)setIsPlaying:(BOOL)isPlaying {
  _isPlaying = isPlaying;
  if (isPlaying) {
    [self.pauseBtn setImage:[NEListenTogetherUI ne_listen_imageName:@"pause_ico"]
                   forState:UIControlStateNormal];
  } else {
    [self.pauseBtn setImage:[NEListenTogetherUI ne_listen_imageName:@"resume_ico"]
                   forState:UIControlStateNormal];
  }
}

- (void)setVolume:(float)volume {
  _volume = volume;
  self.volumeSlider.value = volume;
}

- (void)initView {
  [self addSubview:self.pauseBtn];
  [self addSubview:self.nextBtn];
  [self addSubview:self.speakerImageView];
  [self addSubview:self.volumeSlider];

  [self.pauseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
    make.width.height.mas_equalTo(40);
    make.centerY.mas_equalTo(self);
    make.left.mas_offset(20);
  }];

  [self.nextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
    make.width.height.mas_equalTo(40);
    make.centerY.mas_equalTo(self);
    make.left.mas_equalTo(self.pauseBtn.mas_right).mas_offset(12);
  }];

  [self.volumeSlider mas_makeConstraints:^(MASConstraintMaker *make) {
    make.width.mas_equalTo(120);
    make.height.mas_equalTo(4);
    make.centerY.mas_equalTo(self);
    make.right.mas_equalTo(self.mas_right).mas_offset(-30);
  }];

  [self.speakerImageView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.width.height.mas_equalTo(16);
    make.centerY.mas_equalTo(self);
    make.right.mas_equalTo(self.volumeSlider.mas_left).mas_offset(-8);
  }];
}

- (UIButton *)pauseBtn {
  if (!_pauseBtn) {
    _pauseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    if (self.isPlaying) {
      [_pauseBtn setImage:[NEListenTogetherUI ne_listen_imageName:@"pause_ico"]
                 forState:UIControlStateNormal];
    } else {
      [_pauseBtn setImage:[NEListenTogetherUI ne_listen_imageName:@"resume_ico"]
                 forState:UIControlStateNormal];
    }
    [_pauseBtn addTarget:self
                  action:@selector(pauseOrResume)
        forControlEvents:UIControlEventTouchUpInside];
  }
  return _pauseBtn;
}

- (UIButton *)nextBtn {
  if (!_nextBtn) {
    _nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_nextBtn setImage:[NEListenTogetherUI ne_listen_imageName:@"next_ico"]
              forState:UIControlStateNormal];
    [_nextBtn addTarget:self
                  action:@selector(nextSong)
        forControlEvents:UIControlEventTouchUpInside];
  }
  return _nextBtn;
}

- (UIImageView *)speakerImageView {
  if (!_speakerImageView) {
    _speakerImageView =
        [[UIImageView alloc] initWithImage:[NEListenTogetherUI ne_listen_imageName:@"speaker_ico"]];
  }
  return _speakerImageView;
}

- (UISlider *)volumeSlider {
  if (!_volumeSlider) {
    _volumeSlider = [[UISlider alloc] init];
    _volumeSlider.value = self.volume;
    [_volumeSlider addTarget:self
                      action:@selector(volumeChanged:)
            forControlEvents:UIControlEventValueChanged];
    [_volumeSlider setThumbImage:[NEListenTogetherUI ne_listen_imageName:@"slider_thumb"]
                        forState:UIControlStateNormal];
  }
  return _volumeSlider;
}

- (void)pauseOrResume {
  if (_isPlaying) {
    if (self.delegate && [self.delegate respondsToSelector:@selector(pauseSong:)]) {
      [self.delegate pauseSong:self];
    }
  } else {
    if (self.delegate && [self.delegate respondsToSelector:@selector(resumeSong:)]) {
      [self.delegate resumeSong:self];
    }
  }
}

- (void)nextSong {
  if (self.delegate && [self.delegate respondsToSelector:@selector(nextSong:)]) {
    [self.delegate nextSong:self];
  }
}

- (void)volumeChanged:(UISlider *)slider {
  float val = slider.value;
  if (self.delegate && [self.delegate respondsToSelector:@selector(volumeChanged:view:)]) {
    [self.delegate volumeChanged:val view:self];
  }
}

@end
