//
//  NTESChatroomCollectionViewCell.m
//  NERtcAudioChatroom
//
//  Created by Simon Blue on 2019/1/23.
//  Copyright © 2019年 netease. All rights reserved.
//

#import "NTESChatroomCollectionViewCell.h"
#import "UIView+NTES.h"
#import "NTESMicInfo.h"
#import "UIImage+YYWebImage.h"
#import "UIButton+YYWebImage.h"
#import "NTESAnimationButton.h"
#import "UIImage+NTES.h"

@interface NTESChatroomCollectionViewCell()

@property (nonatomic, null_resettable, strong) UILabel *nameLabel;
@property (nonatomic, null_resettable, strong) NTESAnimationButton *connectBtn;
@property (nonatomic, null_resettable, strong) UIImageView *smallIcon;

@property (nonatomic, strong) NTESMicInfo *micInfo;

@end

@implementation NTESChatroomCollectionViewCell

- (void)layoutSubviews
{
    self.connectBtn.top = 0;
    self.connectBtn.left = 0;
    self.connectBtn.width = self.width;
    self.connectBtn.height = self.width;
    self.connectBtn.layer.cornerRadius = self.width/2;

    self.nameLabel.top = self.connectBtn.bottom + 6.0;
    self.nameLabel.left = 0;
    self.nameLabel.width = self.width;
    self.nameLabel.height = _nameLabel.height;
    
    self.smallIcon.width = 17;
    self.smallIcon.height = 17;
    self.smallIcon.right = self.connectBtn.right;
    self.smallIcon.bottom = self.connectBtn.bottom;
}

- (void)startSoundAnimationWithValue:(NSInteger)value {
    [_connectBtn startCustomAnimation];
    _connectBtn.info = @(value).stringValue;
}

- (void)stopSoundAnimation {
    [_connectBtn stopCustomAnimation];
    _connectBtn.info = nil;
}

- (void)refresh:(NTESMicInfo *)micInfo
{
    self.micInfo = micInfo;
    switch (micInfo.micStatus) {
        case NTESMicStatusNone:
        {
            self.nameLabel.text = [NSString stringWithFormat:@"麦位%zd",micInfo.micOrder];
            [self.connectBtn setImage:[UIImage imageNamed:@"mic_none_ico"] forState:UIControlStateNormal];
            self.connectBtn.layer.borderWidth = 0;
            micInfo.isMicMute = YES;
            [self.connectBtn stopCustomAnimation];
            self.smallIcon.hidden = YES;
        }
            break;
        case NTESMicStatusConnecting:
        {
            self.nameLabel.text = micInfo.userInfo.nickName ? : @"";
            [self.connectBtn setImage:[UIImage imageNamed:@"icon_connecting_n"] forState:UIControlStateNormal];
            self.connectBtn.layer.borderWidth = 1;
            micInfo.isMicMute = YES;
            [self.connectBtn stopCustomAnimation];
            self.smallIcon.hidden = YES;
        }
            break;
        case NTESMicStatusConnectFinished:
        {
            self.nameLabel.text = micInfo.userInfo.nickName ? : @"";
            [self setImageWithUrl:micInfo.userInfo.icon];
            self.connectBtn.layer.borderWidth = 1;
            [self.smallIcon setImage:[UIImage imageNamed:@"mic_open_ico"]];
            self.smallIcon.hidden = NO;
            if (micInfo.isMicMute) {
                [self.connectBtn stopCustomAnimation];
            } else {
                [self.connectBtn startCustomAnimation];
            }
        }
            break;
        case NTESMicStatusClosed:
        {
            self.nameLabel.text = [NSString stringWithFormat:@"麦位%zd",micInfo.micOrder];
            [self.connectBtn setImage:[UIImage imageNamed:@"icon_mic_closed_n"] forState:UIControlStateNormal];
            self.connectBtn.layer.borderWidth = 0;
            micInfo.isMicMute = YES;
            [self.connectBtn stopCustomAnimation];
            self.smallIcon.hidden = YES;
        }
            break;
        case NTESMicStatusMasked:
        {
            self.nameLabel.text = [NSString stringWithFormat:@"麦位%zd",micInfo.micOrder];
            [self.connectBtn setImage:[UIImage imageNamed:@"icon_mic_mask_n"] forState:UIControlStateNormal];
            self.connectBtn.layer.borderWidth = 0;
            micInfo.isMicMute = YES;
            [self.connectBtn stopCustomAnimation];
            
            self.smallIcon.hidden = YES;
        }
            break;
        case NTESMicStatusConnectFinishedWithMasked:
        {
            self.nameLabel.text = micInfo.userInfo.nickName ? : @"";
            [self setImageWithUrl:micInfo.userInfo.icon];
            self.connectBtn.layer.borderWidth = 1;
            [self.smallIcon setImage:[UIImage imageNamed:@"mic_shield_ico"]];
            self.smallIcon.hidden = NO;
            micInfo.isMicMute = YES;
            [self.connectBtn stopCustomAnimation];
        }
            break;
        case NTESMicStatusConnectFinishedWithMuted:
        case NTESMicStatusConnectFinishedWithMutedAndMasked:
        {
            self.nameLabel.text = micInfo.userInfo.nickName ? : @"";
            [self setImageWithUrl:micInfo.userInfo.icon];
            self.connectBtn.layer.borderWidth = 1;
            [self.smallIcon setImage:[UIImage imageNamed:@"mic_close_ico"]];
            self.smallIcon.hidden = NO;
            
            micInfo.isMicMute = YES;
            [self.connectBtn stopCustomAnimation];
        }
            break;

        default:
            break;
    }
}

- (void)setImageWithUrl:(NSString *)urlStr {
    NSURL *url = [NSURL URLWithString:urlStr];
    __weak typeof(self) weakSelf = self;
    [self.connectBtn yy_setBackgroundImageWithURL:url
                                         forState:UIControlStateNormal
                                      placeholder:nil
                                          options:YYWebImageOptionAvoidSetImage
                                       completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
       [image yy_imageByRoundCornerRadius:image.size.width/2];
       [weakSelf.connectBtn setImage:image forState:UIControlStateNormal];
    }];
}

- (void)onConnectBtnPressed
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(onConnectBtnPressedWithMicInfo:)]) {
        [self.delegate onConnectBtnPressedWithMicInfo:self.micInfo];
    }
}

- (UILabel *)nameLabel
{
    if (!_nameLabel){
        _nameLabel = [[UILabel alloc] init];
        [_nameLabel setTextColor:[UIColor whiteColor]];
        [_nameLabel setTextAlignment:NSTextAlignmentCenter];
        _nameLabel.font = [UIFont systemFontOfSize:13];
        [_nameLabel setText:@"test"];
        [_nameLabel sizeToFit];
        [self.contentView addSubview:_nameLabel];
    }
    return _nameLabel;
}

- (NTESAnimationButton *)connectBtn
{
    if (!_connectBtn) {
        NTESAnimationButton *connectBtn = [NTESAnimationButton buttonWithType:UIButtonTypeCustom];
        [connectBtn addTarget:self action:@selector(onConnectBtnPressed)  forControlEvents:UIControlEventTouchUpInside];
        UIImage *img = [UIImage imageNamed:@"mic_none_ico"];
        [connectBtn setImage:img forState:UIControlStateNormal];
        _connectBtn = connectBtn;
        _connectBtn.backgroundColor = [UIColor colorWithWhite:1 alpha:0.1];
        _connectBtn.layer.masksToBounds = YES;
        _connectBtn.layer.borderColor = [UIColor whiteColor].CGColor;
        [self.contentView addSubview:_connectBtn];
    }
    return _connectBtn;
}

- (UIImageView *)smallIcon
{
    if (!_smallIcon) {
        UIImageView *smallIcon = [[UIImageView alloc] initWithFrame:CGRectZero];
        smallIcon.hidden = YES;
        _smallIcon = smallIcon;
        [self.contentView addSubview:_smallIcon];
    }
    return _smallIcon;
}

@end
