//
//  NTESMicQueueCell.m
//  NEChatroom-iOS-ObjC
//
//  Created by Think on 2021/2/3.
//  Copyright © 2021 netease. All rights reserved.
//

#import "NTESMicQueueCell.h"

@implementation NTESMicQueueCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.nameLabel];
        [self.contentView addSubview:self.connectBtn];
        [self.contentView addSubview:self.avatar];
        [self.contentView addSubview:self.smallIcon];
        [self.contentView addSubview:self.singIco];
        [self.contentView addSubview:self.loadingIco];
    }
    return self;
}

- (void)startSoundAnimationWithValue:(NSInteger)value
{
    [_connectBtn startCustomAnimation];
    _connectBtn.info = @(value).stringValue;
}

- (void)stopSoundAnimation
{
    [_connectBtn stopCustomAnimation];
    _connectBtn.info = nil;
}

- (void)refresh:(NTESMicInfo *)micInfo
{
    self.micInfo = micInfo;
    if (micInfo.userInfo.isAnchor) {
        [self _anchorRefresh:micInfo];
    } else {
        [self _audienceRefresh:micInfo];
    }
}

/// 刷新主播麦位信息
- (void)_anchorRefresh:(NTESMicInfo *)micInfo
{
    self.nameLabel.text = micInfo.userInfo.nickName ? : @"房主";
    [self.avatar setYy_imageURL:[NSURL URLWithString:micInfo.userInfo.icon]];
    self.connectBtn.layer.borderWidth = 1;
    
    switch (micInfo.micStatus) {
        case NTESMicStatusConnectFinishedWithMuted:
        {
            [self.smallIcon setImage:[UIImage imageNamed:@"mic_close_ico"]];
            self.smallIcon.hidden = NO;
        }
            break;
            
        default:
        {
            [self.smallIcon setImage:[UIImage imageNamed:@"mic_open_ico"]];
            self.smallIcon.hidden = NO;
        }
            break;
    }
}

/// 刷新观众麦位信息
- (void)_audienceRefresh:(NTESMicInfo *)micInfo
{
    switch (micInfo.micStatus) {
        case NTESMicStatusNone:
        {
            self.nameLabel.text = [NSString stringWithFormat:@"麦位%zd",micInfo.micOrder];
            [self.connectBtn setImage:[UIImage imageNamed:@"mic_none_ico"] forState:UIControlStateNormal];
            [self _setAvatarWithUrl:nil];
            self.connectBtn.layer.borderWidth = 0;
            micInfo.isMicMute = YES;
            [self.connectBtn stopCustomAnimation];
            self.smallIcon.hidden = YES;
            self.loadingIco.hidden = YES;
            self.singIco.hidden = YES;
        }
            break;
        case NTESMicStatusConnecting:
        {
            self.nameLabel.text = micInfo.userInfo.nickName ? : @"";
            [self _setAvatarWithUrl:micInfo.userInfo.icon];
            self.connectBtn.layer.borderWidth = 1;
            micInfo.isMicMute = YES;
            [self.connectBtn stopCustomAnimation];
            self.smallIcon.hidden = YES;
            self.loadingIco.hidden = NO;
        }
            break;
        case NTESMicStatusConnectFinished:
        {
            self.nameLabel.text = micInfo.userInfo.nickName ? : @"";
            [self _setAvatarWithUrl:micInfo.userInfo.icon];
            self.connectBtn.layer.borderWidth = 1;
            [self.smallIcon setImage:[UIImage imageNamed:@"mic_open_ico"]];
            self.smallIcon.hidden = NO;
            self.loadingIco.hidden = YES;
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
            [self _setAvatarWithUrl:nil];
            self.connectBtn.layer.borderWidth = 0;
            micInfo.isMicMute = YES;
            [self.connectBtn stopCustomAnimation];
            self.smallIcon.hidden = YES;
            self.loadingIco.hidden = YES;
        }
            break;
        case NTESMicStatusMasked:
        {
            self.nameLabel.text = [NSString stringWithFormat:@"麦位%zd",micInfo.micOrder];
            [self.connectBtn setImage:[UIImage imageNamed:@"icon_mic_mask_n"] forState:UIControlStateNormal];
            [self _setAvatarWithUrl:nil];
            self.connectBtn.layer.borderWidth = 0;
            micInfo.isMicMute = YES;
            [self.connectBtn stopCustomAnimation];
            
            self.smallIcon.hidden = YES;
            self.loadingIco.hidden = YES;
        }
            break;
        case NTESMicStatusConnectFinishedWithMasked:
        {
            self.nameLabel.text = micInfo.userInfo.nickName ? : @"";
            [self _setAvatarWithUrl:micInfo.userInfo.icon];
            self.connectBtn.layer.borderWidth = 1;
            [self.smallIcon setImage:[UIImage imageNamed:@"mic_shield_ico"]];
            self.smallIcon.hidden = NO;
            self.loadingIco.hidden = YES;
            micInfo.isMicMute = YES;
            [self.connectBtn stopCustomAnimation];
        }
            break;
        case NTESMicStatusConnectFinishedWithMuted:
        case NTESMicStatusConnectFinishedWithMutedAndMasked:
        {
            self.nameLabel.text = micInfo.userInfo.nickName ? : @"";
            [self _setAvatarWithUrl:micInfo.userInfo.icon];
            self.connectBtn.layer.borderWidth = 1;
            if (micInfo.micStatus == NTESMicStatusConnectFinishedWithMuted) {
                [self.smallIcon setImage:[UIImage imageNamed:@"mic_close_ico"]];
            } else {
                [self.smallIcon setImage:[UIImage imageNamed:@"mic_shield_ico"]];
            }
            self.smallIcon.hidden = NO;
            self.loadingIco.hidden = YES;
            
            micInfo.isMicMute = YES;
            [self.connectBtn stopCustomAnimation];
        }
            break;

        default:
            break;
    }
}

- (void)_setAvatarWithUrl:(nullable NSString *)url
{
    if (url) {
        self.avatar.hidden = NO;
        self.avatar.yy_imageURL = [NSURL URLWithString:url];
    } else {
        self.avatar.hidden = YES;
    }
}

- (void)onConnectBtnPressed
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(onConnectBtnPressedWithMicInfo:)]) {
        [self.delegate onConnectBtnPressedWithMicInfo:self.micInfo];
    }
}

+ (NTESMicQueueCell *)cellWithCollectionView:(UICollectionView *)collectionView
                                        data:(NTESMicInfo *)data
                                   indexPath:(NSIndexPath *)indexPath
{
    // need override
    return [NTESMicQueueCell new];
}

+ (CGSize)size
{
    // need override
    return CGSizeZero;
}

+ (CGFloat)cellPaddingH
{
    // need override
    return 0;
}

+ (CGFloat)cellPaddingW
{
    // need override
    return 0;
}

@end
