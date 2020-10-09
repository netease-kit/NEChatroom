//
//  NTESChatroomHeaderView.m
//  NERtcAudioChatroom
//
//  Created by Netease on 2019/3/5.
//  Copyright © 2019年 netease. All rights reserved.
//

#import "NTESChatroomHeaderView.h"
#import "NTESIconView.h"
#import "UIView+NTES.h"
#import "NTESChatroomInfo.h"
#import "NTESAccountInfo.h"

#define kBtnWidth (36.0)

@interface NTESChatroomHeaderView ()

@property (nonatomic, strong) NTESIconView *iconView; //用户头像和名称
@property (nonatomic, strong) UILabel *chatRoomInfoLab; //房间信息
@property (nonatomic, strong) UIButton *exitButton;       //退出
@property (nonatomic, strong) UIButton *voiceButton;      //声音
@property (nonatomic, strong) UIButton *micMuteButton;    //麦克
@property (nonatomic, strong) UIButton *noSpeakingButton; //禁言
@property (nonatomic, strong) UIButton *dropMicButton;    //下麦
@property (nonatomic, strong) UIButton *settingButton;  // 设置
@property (nonatomic, strong) NSArray *cacheSubviews;

@end

@implementation NTESChatroomHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.iconView];
        [self addSubview:self.chatRoomInfoLab];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.width != 0 && self.height != 0) {
        CGFloat iconViewWidth = (self.width - 2 * 30.0 - 3 * 25.0) / 4;
        _iconView.frame = CGRectMake(20.0, 0.0, iconViewWidth, self.height);
        
        CGFloat maxLabWidth = MAX(0, self.width - 20.0 - 20.0 - 16.0 - _iconView.width);
        _chatRoomInfoLab.frame = CGRectMake(self.width-20.0-maxLabWidth,
                                            4.0,
                                            maxLabWidth,
                                            _chatRoomInfoLab.height);
        
        [self doLayoutButtons];
    }
}

- (CGFloat)calculateHeightWithWidth:(CGFloat)width {
    CGFloat iconViewWidth = (width - 2 * 30.0 - 3 * 25.0) / 4;
    return iconViewWidth + 24.0;
}

- (void)doLayoutButtons {
    if (self.width != 0 && self.height != 0) {
        __weak typeof(self)weakSelf = self;
        [_cacheSubviews enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            UIButton *btn = (UIButton *)obj;
            btn.frame = CGRectMake(weakSelf.width-kBtnWidth*(idx+1) - 16.0,
                                   weakSelf.chatRoomInfoLab.bottom + 8.0,
                                   kBtnWidth,
                                   kBtnWidth);
        }];
    }
}

- (void)selectSubviewsWithUserMode:(NTESUserMode)userMode {
    switch (userMode) {
        case NTESUserModeAnchor:
            self.cacheSubviews = @[self.exitButton,self.voiceButton,self.micMuteButton, self.settingButton, self.noSpeakingButton];
            break;
        case NTESUserModeAudience:
            self.cacheSubviews = @[self.exitButton,self.voiceButton];
            break;
        case NTESUserModeConnector:
            self.cacheSubviews = @[self.exitButton,self.dropMicButton, self.voiceButton,self.micMuteButton, self.settingButton];
            break;
        default:
            break;
    }
}

//开始声音动画
- (void)startAnimationWithValue:(NSInteger)value {
    [_iconView startAnimationWithValue:value];
}

//停止声音动画
- (void)stopSoundAnimation {
    [_iconView stopAnimation];
}

#pragma mark - Action
- (void)onAction:(UIButton *)button {
    NSInteger tag = button.tag;
    switch (tag) {
        case NTESActionTypeExit: //退出
        {
            if (_delegate && [_delegate respondsToSelector:@selector(headerDidReceiveExitAction)]) {
                [_delegate headerDidReceiveExitAction];
            }
            break;
        }
        case NTESActionTypeSoundMute: //音频
        {
            if (_delegate && [_delegate respondsToSelector:@selector(headerDidReceiveSoundMuteAction:)]) {
                [_delegate headerDidReceiveSoundMuteAction:!button.selected];
            }
            button.selected = !button.selected;
            break;
        }
        case NTESActionTypeMicMute: //麦克
        {
            if (_delegate && [_delegate respondsToSelector:@selector(headerDidReceiveMicMuteAction:)]) {
                [_delegate headerDidReceiveMicMuteAction:!button.selected];
            }
            button.selected = !button.selected;
            break;
        }
        case NTESActionTypeNoSpeaking: //禁言
        {
            if (_delegate && [_delegate respondsToSelector:@selector(headerDidReceiveNoSpeekingAciton)]) {
                [_delegate headerDidReceiveNoSpeekingAciton];
            }
            break;
        }
        case NTESActionTypeDropMic: //下麦
        {
            if (_delegate && [_delegate respondsToSelector:@selector(headerDidReceiveDropMicAction)]) {
                [_delegate headerDidReceiveDropMicAction];
            }
            break;
        }
        case NTESActionTypeSetting: //设置
        {
            if (_delegate && [_delegate respondsToSelector:@selector(headerDidReceiveSettingAciton)]) {
                [_delegate headerDidReceiveSettingAciton];
            }
            break;
        }
        default:
            break;
    }
}

#pragma mark - Setter
- (void)setUserMode:(NTESUserMode)userMode {
    _userMode = userMode;
    [self.cacheSubviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self selectSubviewsWithUserMode:userMode];
    for (UIButton *btn in self.cacheSubviews) {
        [self addSubview:btn];
    }
    [self doLayoutButtons];
}

- (void)setChatroomInfo:(NTESChatroomInfo *)chatroomInfo {
    if (!chatroomInfo) {
        return;
    }
    NSString *info = [NSString stringWithFormat:@"房间：%@(%@人)",
                      chatroomInfo.name ?:@"未知", @(chatroomInfo.onlineUserCount).stringValue];
    _chatRoomInfoLab.text = info;
    _iconView.mute = chatroomInfo.micMute;
}

- (void)setAccountInfo:(NTESAccountInfo *)accountInfo {
    if (!accountInfo) {
        return;
    }
    [_iconView setName:accountInfo.nickName
               iconUrl:accountInfo.icon];
}

#pragma mark - Getter
- (NTESIconView *)iconView {
    if (!_iconView) {
        _iconView = [[NTESIconView alloc] init];
        _iconView.nameColor = UIColorFromRGBA(0x828282, 1);
    }
    return _iconView;
}

- (UILabel *)chatRoomInfoLab {
    if (!_chatRoomInfoLab) {
        _chatRoomInfoLab = [[UILabel alloc] init];
        _chatRoomInfoLab.font = [UIFont systemFontOfSize:14.0];
        _chatRoomInfoLab.textColor = UIColorFromRGBA(0x828282, 1);
        _chatRoomInfoLab.text = @"房间：未知(0人)";
        _chatRoomInfoLab.textAlignment = NSTextAlignmentRight;
        [_chatRoomInfoLab sizeToFit];
    }
    return _chatRoomInfoLab;
}

- (UIButton *)exitButton
{
    if (!_exitButton) {
        UIButton *exitButton = [UIButton buttonWithType:UIButtonTypeCustom];
        exitButton.tag = NTESActionTypeExit;
        [exitButton addTarget:self action:@selector(onAction:)  forControlEvents:UIControlEventTouchUpInside];
        [exitButton setImage:[UIImage imageNamed:@"icon_no_n"] forState:UIControlStateNormal];
        _exitButton = exitButton;
    }
    return _exitButton;
}

- (UIButton *)voiceButton
{
    if (!_voiceButton) {
        UIButton *voiceButton = [UIButton buttonWithType:UIButtonTypeCustom];
        voiceButton.tag = NTESActionTypeSoundMute;
        [voiceButton addTarget:self action:@selector(onAction:)  forControlEvents:UIControlEventTouchUpInside];
        [voiceButton setImage:[UIImage imageNamed:@"icon_sound_on_n"] forState:UIControlStateNormal];
        [voiceButton setImage:[UIImage imageNamed:@"icon_sound_off_n"] forState:UIControlStateSelected];
        _voiceButton = voiceButton;
    }
    return _voiceButton;
}

- (UIButton *)micMuteButton
{
    if (!_micMuteButton) {
        UIButton *micMuteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        micMuteButton.tag = NTESActionTypeMicMute;
        [micMuteButton addTarget:self action:@selector(onAction:)  forControlEvents:UIControlEventTouchUpInside];
        [micMuteButton setImage:[UIImage imageNamed:@"icon_mic_on_n"] forState:UIControlStateNormal];
        [micMuteButton setImage:[UIImage imageNamed:@"icon_mic_off_n"] forState:UIControlStateSelected];
        _micMuteButton = micMuteButton;
    }
    return _micMuteButton;
}

- (UIButton *)noSpeakingButton
{
    if (!_noSpeakingButton) {
        UIButton *noSpeakingButton = [UIButton buttonWithType:UIButtonTypeCustom];
        noSpeakingButton.tag = NTESActionTypeNoSpeaking;
        [noSpeakingButton addTarget:self action:@selector(onAction:)  forControlEvents:UIControlEventTouchUpInside];
        [noSpeakingButton setImage:[UIImage imageNamed:@"icon_speaking_off_n"] forState:UIControlStateNormal];
        _noSpeakingButton = noSpeakingButton;
    }
    return _noSpeakingButton;
}

- (UIButton *)dropMicButton
{
    if (!_dropMicButton) {
        UIButton *dropMicButton = [UIButton buttonWithType:UIButtonTypeCustom];
        dropMicButton.tag = NTESActionTypeDropMic;
        [dropMicButton addTarget:self action:@selector(onAction:)  forControlEvents:UIControlEventTouchUpInside];
        [dropMicButton setImage:[UIImage imageNamed:@"icon_drop_mic_n"] forState:UIControlStateNormal];
        _dropMicButton = dropMicButton;
    }
    return _dropMicButton;
}

- (UIButton *)settingButton
{
    if (!_settingButton) {
        UIButton *settingButton = [UIButton buttonWithType:UIButtonTypeCustom];
        settingButton.tag = NTESActionTypeSetting;
        [settingButton addTarget:self action:@selector(onAction:)  forControlEvents:UIControlEventTouchUpInside];
        [settingButton setImage:[UIImage imageNamed:@"setting_ico"] forState:UIControlStateNormal];
        _settingButton = settingButton;
    }
    return _settingButton;
}

@end
