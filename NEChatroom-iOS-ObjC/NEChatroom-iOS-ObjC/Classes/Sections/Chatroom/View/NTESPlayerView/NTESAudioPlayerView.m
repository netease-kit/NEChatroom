//
//  NTESAudioPlayerView.m
//  NERtcAudioChatroom
//
//  Created by Netease on 2019/3/7.
//  Copyright © 2019年 netease. All rights reserved.
//

#import "NTESAudioPlayerView.h"
#import "UIView+NTES.h"

@interface NTESAudioPlayerView ()

@property (nonatomic, strong) UILabel *titleLab;
@property (nonatomic, strong) UIButton *playBtn;
@property (nonatomic, strong) UIButton *nextBtn;
@property (nonatomic, strong) UIButton *moreBtn;
@property (nonatomic, strong) UIView *wrapperView;

@end

@implementation NTESAudioPlayerView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.clipsToBounds = YES;
        [self addSubview:self.wrapperView];
        [self addSubview:self.titleLab];
        [self addSubview:self.moreBtn];
        [self addSubview:self.nextBtn];
        [self addSubview:self.playBtn];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _wrapperView.frame = CGRectMake(0, 0, self.width + 10.0, self.height);
    _wrapperView.layer.cornerRadius = 10.0;
    _titleLab.frame = CGRectMake(13.0, 5.0, self.width-5.0-13.0, 16.0);
    _playBtn.frame = CGRectMake(4.0, _titleLab.bottom, 32.0, 36.0);
    _nextBtn.frame = CGRectMake(_playBtn.right, _playBtn.top, _playBtn.width, _playBtn.height);
    _moreBtn.frame = CGRectMake(_nextBtn.right, _nextBtn.top, _playBtn.width, _playBtn.height);

}

- (void)setPlayState:(BOOL)playState {
    _playState = playState;
    _playBtn.selected = !playState;
    self.musicName = _musicName;
}

- (void)setMusicName:(NSString *)musicName {
    if (musicName.length == 0) {
        return;
    }
    _musicName = musicName;
    _titleLab.attributedText = [self titleInfoWithMusicName:musicName play:_playState];
}

#pragma mark - Action
- (void)playAction:(UIButton *)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(didStartPlayAction:)]) {
        [_delegate didStartPlayAction:!sender.selected];
    }
}

- (void)nextAction:(UIButton *)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(didNextAction)]) {
        [_delegate didNextAction];
    }
}

- (void)moreAction:(UIButton *)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(didMoreAction)]) {
        [_delegate didMoreAction];
    }
}

#pragma mark - Getter
- (NSMutableAttributedString *)titleInfoWithMusicName:(NSString *)name play:(BOOL)play {
    NSString *infoString = [NSString stringWithFormat:@"%@%@", name, play?@"播放中...":@"已暂停"];
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:infoString];
    NSRange nameRanage = [infoString rangeOfString:name];
    [text setAttributes:@{NSForegroundColorAttributeName:UIColorFromRGB(0xffa410),
                          NSFontAttributeName:Chatroom_Message_Font}
                  range:nameRanage];
    NSRange infoRanage = NSMakeRange(nameRanage.location + name.length, text.length - name.length);
    [text setAttributes:@{NSForegroundColorAttributeName:UIColorFromRGB(0xc7c7c7),
                          NSFontAttributeName:Chatroom_Message_Font}
                  range:infoRanage];
    return text;
}

- (UILabel *)titleLab {
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.font = [UIFont systemFontOfSize:13.0];
        _titleLab.backgroundColor = [UIColor clearColor];
    }
    return _titleLab;
}

- (UIView *)wrapperView {
    if (!_wrapperView) {
        _wrapperView = [[UIView alloc] init];
        _wrapperView.backgroundColor = UIColorFromRGBA(0xffffff, 0.3);
    }
    return _wrapperView;
}

- (UIButton *)playBtn {
    if (!_playBtn) {
        _playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playBtn setImage:[UIImage imageNamed:@"audio_player_pause"] forState:UIControlStateNormal];
        [_playBtn setImage:[UIImage imageNamed:@"audio_player_play"] forState:UIControlStateSelected];
        [_playBtn addTarget:self action:@selector(playAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playBtn;
}

- (UIButton *)nextBtn {
    if (!_nextBtn) {
        _nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_nextBtn setImage:[UIImage imageNamed:@"audio_player_next"] forState:UIControlStateNormal];
        [_nextBtn addTarget:self action:@selector(nextAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _nextBtn;
}

- (UIButton *)moreBtn {
    if (!_moreBtn) {
        _moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_moreBtn setImage:[UIImage imageNamed:@"audio_player_more"] forState:UIControlStateNormal];
        [_moreBtn addTarget:self action:@selector(moreAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _moreBtn;
}

@end
