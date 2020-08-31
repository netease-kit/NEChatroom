//
//  NTESAudioPlayerManager.m
//  NERtcAudioChatroom
//
//  Created by Netease on 2019/3/11.
//  Copyright © 2019年 netease. All rights reserved.
//

#import "NTESAudioPlayerManager.h"

@interface NTESAudioPlayerManager ()<NTESAudioPlayerDelegate, NTESAudioPanelViewDelegate>

@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) NSInteger indexOfEffect;

@property (nonatomic, strong) NTESAudioPlayerView *playerView;
@property (nonatomic, assign) BOOL isPause;
@property (nonatomic, assign) CGFloat currentPlayVolumn;
@property (nonatomic, assign) CGFloat currentEffectVolumn;

@property (nonatomic, strong) NSArray <NERtcCreateAudioMixingOption *>   *mixOpts;
@property (nonatomic, strong) NSArray <NERtcCreateAudioEffectOption *>   *effectOpts;

@end

@implementation NTESAudioPlayerManager
@synthesize audioPanelView = _audioPanelView;
- (instancetype)init {
    if (self = [super init]) {
        self.currentPlayVolumn = 50;
        self.currentEffectVolumn = 50;
        self.playerView.musicName = @"音乐0";
        self.playerView.playState = NO;
    }
    return self;
}

- (void)stop {
    _index = 0;
    [[NERtcEngine sharedEngine] stopAudioMixing];
    self.playerView.playState = NO;
}

- (void)start {
    if ([self.mixOpts count] == 0) {
        return;
    }
    _index = _index % [self.mixOpts count];
    NERtcCreateAudioMixingOption *opt = self.mixOpts[_index];
    int result = [[NERtcEngine sharedEngine] startAudioMixingWithOption:opt];
    if (result != 0) {
        return;
    }
    self.playerView.musicName = [NSString stringWithFormat:@"音乐%d", (int)_index + 1];
    if (_playerView.playState == NO) {
        [[NERtcEngine sharedEngine] pauseAudioMixing];
    }
    [self.audioPanelView setMusicButtonSelectedAtIndex:_index];
}

- (void)playMusicAtIndex:(NSUInteger)targetIdx {
    if (self.mixOpts.count == 0 || targetIdx >= self.mixOpts.count) {
        return;
    }
    _index = targetIdx;
    
    [[NERtcEngine sharedEngine] stopAudioMixing];
    NERtcCreateAudioMixingOption *opt = self.mixOpts[_index];
    int result = [[NERtcEngine sharedEngine] startAudioMixingWithOption:opt];
    if (result != 0) {
        NELPLogError(@"play audio mix failed ...");
        return;
    }
    self.playerView.musicName = [NSString stringWithFormat:@"音乐%d", (int)_index + 1];
    _playerView.playState = YES;
    self.isPause = NO;
    [self changeMusicVolumn:_currentPlayVolumn];
}

- (void)changeMusicVolumn:(CGFloat)value {
    self.currentPlayVolumn = value;
    
    [[NERtcEngine sharedEngine] setAudioMixingSendVolume:value];
    [[NERtcEngine sharedEngine] setAudioMixingPlaybackVolume:value];
}

- (void)playEffectAtIndex:(NSUInteger)targetIdx {
    if (self.effectOpts.count == 0 || targetIdx >= self.effectOpts.count) {
        return;
    }
    
    _indexOfEffect = targetIdx;
    NERtcCreateAudioEffectOption *opt = self.effectOpts[_indexOfEffect];
    opt.playbackVolume = _currentEffectVolumn;
    [[NERtcEngine sharedEngine] stopAllEffects];
    uint32_t eid = (uint32_t)_indexOfEffect;
    [[NERtcEngine sharedEngine] playEffectWitdId:eid effectOption:opt];
}

- (void)changeEffectVolumn:(CGFloat)value {
    self.currentEffectVolumn = value;
    
    uint32_t eid = (uint32_t)_indexOfEffect;
    [[NERtcEngine sharedEngine] setEffectSendVolumeWithId:eid volume:_currentEffectVolumn];
    [[NERtcEngine sharedEngine] setEffectPlaybackVolumeWithId:eid volume:_currentEffectVolumn];
}

#pragma mark - <NTESAudioPlayerDelegate>
- (void)didStartPlayAction:(BOOL)isPause {
    if (isPause) {
        _playerView.playState = NO;
        _isPause = YES;
        [[NERtcEngine sharedEngine] pauseAudioMixing];
    } else {
        _playerView.playState = YES;
        if (!_isPause) {
            [self start];
        } else {
            [[NERtcEngine sharedEngine] resumeAudioMixing];
        }
        _isPause = NO;
    }
}

- (void)didNextAction {
    NSInteger idx = (_index + 1) % self.mixOpts.count;
    [self playMusicAtIndex:idx];
    [self.audioPanelView setMusicButtonSelectedAtIndex:idx];
}

- (void)didMoreAction {
    self.maskView.hidden = NO;
    self.audioPanelView.hidden = NO;
}

- (void)onAudioMixingStateChanged:(NERtcAudioMixingState)state
{
    if (_playerView.playState == NO) {
        return;
    }
    [self didNextAction];
}

#pragma mark - NTESAudioPanelViewDelegate
- (void)onButtonSelected:(NTESButtonType)type {
    switch (type) {
        case NTESButtonTypeMusic1:
        {
            [self playMusicAtIndex:0];
        }
            break;
        case NTESButtonTypeMusic2:
        {
            [self playMusicAtIndex:1];
        }
            break;
        case NTESButtonTypeMusicEffect1:
        {
            [self playEffectAtIndex:0];
        }
            break;
        case NTESButtonTypeMusicEffect2:
        {
            [self playEffectAtIndex:1];
        }
            break;
        default:
            break;
    }
}
- (void)onValueChangeOfType:(NTESValueChangeType)type value:(CGFloat)value {
    switch (type) {
        case NTESValueChangeTypeMusicVolumn:
        {
            [self changeMusicVolumn:value];
        }
            break;
        case NTESValueChangeTypeMusicEffect:
        {
            [self changeEffectVolumn:value];
        }
            break;
        default:
            break;
    }
}

#pragma mark - Getter
- (NTESAudioPlayerView *)playerView {
    if (!_playerView) {
        _playerView = [[NTESAudioPlayerView alloc] init];
        _playerView.delegate =self;
    }
    return _playerView;
}

- (NTESAudioPlayerView *)view {
    return self.playerView;
}

- (NTESAudioPanelView *)audioPanelView {
    if (!_audioPanelView) {
        _audioPanelView = [[NTESAudioPanelView alloc] init];
        _audioPanelView.delegate = self;
        _audioPanelView.hidden = YES;
    }
    return _audioPanelView;
}

- (UIView *)maskView {
    if (!_maskView)
    {
        _maskView = [[UIView alloc] init];
        _maskView.alpha = 0.15;
        UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onMaskTapAction:)];
        [_maskView addGestureRecognizer:tapGR];
        _maskView.hidden = YES;
    }
    return _maskView;
}

- (void)onMaskTapAction:(UITapGestureRecognizer *)sender
{
    self.maskView.hidden = YES;
    self.audioPanelView.hidden = YES;
}

- (NSArray <NERtcCreateAudioMixingOption *> *)mixOpts
{
    if (!_mixOpts) {
        NSMutableArray *temp = [NSMutableArray array];
        for (int i = 0; i < 2; i++) {
            NSString *name = [NSString stringWithFormat:@"%d", i + 1];
            NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"m4a"];
            if (path) {
                NERtcCreateAudioMixingOption *opt = [[NERtcCreateAudioMixingOption alloc] init];
                opt.path = path;
                opt.playbackVolume = _currentPlayVolumn;
                opt.sendVolume = _currentPlayVolumn;
                opt.loopCount = 1;
                [temp addObject:opt];
            }
        }
        _mixOpts = [temp copy];
    }
    return _mixOpts;
}

- (NSArray <NERtcCreateAudioEffectOption *> *)effectOpts
{
    if (!_effectOpts) {
        NSMutableArray *temp = [NSMutableArray array];
        for (int i = 0; i < 2; i++) {
            NSString *name = [NSString stringWithFormat:@"audio_effect_%d", i];
            NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"wav"];
            if (path) {
                NERtcCreateAudioEffectOption *opt = [[NERtcCreateAudioEffectOption alloc] init];
                opt.path = path;
                opt.playbackVolume = _currentEffectVolumn;
                opt.sendVolume = _currentEffectVolumn;
                opt.loopCount = 1;
                [temp addObject:opt];
            }
        }
        _effectOpts = [temp copy];
    }
    return _effectOpts;
}

@end
