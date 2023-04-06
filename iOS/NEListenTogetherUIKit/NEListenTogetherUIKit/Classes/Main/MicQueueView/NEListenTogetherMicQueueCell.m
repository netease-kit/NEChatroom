// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEListenTogetherMicQueueCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "NEListenTogetherInnerSingleton.h"
#import "NEListenTogetherLocalized.h"
#import "NEListenTogetherUI.h"
#import "NSArray+NEListenTogetherUIExtension.h"
#import "UIImage+ListenTogether.h"

@implementation NEListenTogetherMicQueueCell

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    [self.contentView addSubview:self.lottieView];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.connectBtn];
    [self.contentView addSubview:self.avatar];
    [self.contentView addSubview:self.smallIcon];
    [self.contentView addSubview:self.singIco];
    [self.contentView addSubview:self.loadingIco];
  }
  return self;
}

- (void)startSoundAnimationWithValue:(NSInteger)value {
  [_connectBtn startCustomAnimation];
  _connectBtn.info = @(value).stringValue;
}

- (void)stopSoundAnimation {
  [_connectBtn stopCustomAnimation];
  _connectBtn.info = nil;
}

- (void)startSpeakAnimation {
  [self.lottieView play];
}

- (void)stopSpeakAnimation {
  [self.lottieView stop];
}

- (void)refresh:(NEListenTogetherSeatItem *)micInfo {
  _micInfo = micInfo;
  // 判断直播
  if ([micInfo.user
          isEqualToString:NEListenTogetherInnerSingleton.singleton.roomInfo.anchor.userUuid]) {
    [self _anchorRefresh:micInfo];
  } else {
    [self _audienceRefresh:micInfo];
  }
}

/// 刷新主播麦位信息
- (void)_anchorRefresh:(NEListenTogetherSeatItem *)micInfo {
  self.nameLabel.text = micInfo.userName ?: NELocalizedString(@"房主");
  [self.avatar sd_setImageWithURL:[NSURL URLWithString:micInfo.icon]];
  self.connectBtn.layer.borderWidth = 1;

  NEListenTogetherMember *anchorMember =
      [NEListenTogetherKit.getInstance.allMemberList ne_find:^BOOL(NEListenTogetherMember *obj) {
        return [obj.account isEqualToString:micInfo.user];
      }];

  if (!anchorMember) return;
  if (anchorMember.isAudioBanned) {
    [self.smallIcon setImage:[NEListenTogetherUI ne_listen_imageName:@"mic_shield_ico"]];
  } else {
    if (anchorMember.isAudioOn) {
      [self.smallIcon setImage:[UIImage voiceRoom_imageNamed:@"mic_open_ico"]];
      self.smallIcon.hidden = NO;
    } else {
      [self.smallIcon setImage:[UIImage voiceRoom_imageNamed:@"mic_close_ico"]];
      self.smallIcon.hidden = NO;
    }
  }
}

/// 刷新观众麦位信息
- (void)_audienceRefresh:(NEListenTogetherSeatItem *)micInfo {
  NEListenTogetherMember *audienceMember =
      [NEListenTogetherKit.getInstance.allMemberList ne_find:^BOOL(NEListenTogetherMember *obj) {
        return [obj.account isEqualToString:micInfo.user];
      }];
  switch (micInfo.status) {
    case NEListenTogetherSeatItemStatusInitial: {  // 无人
      self.nameLabel.text = [NSString stringWithFormat:NELocalizedString(@"麦位%zd"), 1];
      [self _setAvatarWithUrl:nil];
      self.connectBtn.layer.borderWidth = 0;
      [self.connectBtn stopCustomAnimation];
      self.smallIcon.hidden = YES;
      self.loadingIco.hidden = YES;
      [self.connectBtn setImage:[NEListenTogetherUI ne_listen_imageName:@"mic_none_ico"]
                       forState:UIControlStateNormal];
      [self.lottieView stop];
    } break;
    case NEListenTogetherSeatItemStatusWaiting: {  // 等待
      self.nameLabel.text = micInfo.userName ?: @"";
      [self _setAvatarWithUrl:[NSURL URLWithString:micInfo.icon]];
      self.connectBtn.layer.borderWidth = 1;
      [self.connectBtn stopCustomAnimation];
      self.smallIcon.hidden = YES;
      self.loadingIco.hidden = NO;
    } break;
    case NEListenTogetherSeatItemStatusTaken: {  // 占用
      if (audienceMember.isAudioBanned) {        // 禁麦
        [self.connectBtn stopCustomAnimation];
        self.nameLabel.text = micInfo.userName ?: @"";
        [self _setAvatarWithUrl:[NSURL URLWithString:micInfo.icon]];
        self.connectBtn.layer.borderWidth = 1;
        [self.smallIcon setImage:[NEListenTogetherUI ne_listen_imageName:@"mic_shield_ico"]];
        self.smallIcon.hidden = NO;
        self.loadingIco.hidden = YES;
        [self.connectBtn stopCustomAnimation];
      } else if (audienceMember.isAudioOn) {  // 话筒打开
        self.nameLabel.text = micInfo.userName ?: @"";
        [self _setAvatarWithUrl:[NSURL URLWithString:micInfo.icon]];
        self.connectBtn.layer.borderWidth = 1;
        [self.smallIcon setImage:[NEListenTogetherUI ne_listen_imageName:@"mic_open_ico"]];
        self.smallIcon.hidden = NO;
        self.loadingIco.hidden = YES;
        [self.connectBtn stopCustomAnimation];
      } else {
        [self.connectBtn startCustomAnimation];
        self.nameLabel.text = micInfo.userName ?: @"";
        [self _setAvatarWithUrl:[NSURL URLWithString:micInfo.icon]];
        self.connectBtn.layer.borderWidth = 1;
        [self.smallIcon setImage:[NEListenTogetherUI ne_listen_imageName:@"mic_close_ico"]];
        self.smallIcon.hidden = NO;
        self.loadingIco.hidden = YES;
      }
    } break;
    default: {  // 关闭
      self.nameLabel.text =
          [NSString stringWithFormat:NELocalizedString(@"麦位%zd"), micInfo.index - 1];
      [self.connectBtn setImage:[NEListenTogetherUI ne_listen_imageName:@"icon_mic_closed_n"]
                       forState:UIControlStateNormal];
      [self _setAvatarWithUrl:nil];
      self.connectBtn.layer.borderWidth = 0;
      [self.connectBtn stopCustomAnimation];
      self.smallIcon.hidden = YES;
      self.loadingIco.hidden = YES;
    } break;
  }
}

- (void)_setAvatarWithUrl:(nullable NSURL *)url {
  if (url) {
    self.avatar.hidden = NO;
    [self.avatar sd_setImageWithURL:url];
  } else {
    self.avatar.hidden = YES;
  }
}

- (void)onConnectBtnPressed {
  if (self.delegate &&
      [self.delegate respondsToSelector:@selector(onConnectBtnPressedWithMicInfo:)]) {
    [self.delegate onConnectBtnPressedWithMicInfo:self.micInfo];
  }
}

+ (NEListenTogetherMicQueueCell *)cellWithCollectionView:(UICollectionView *)collectionView
                                                    data:(NEListenTogetherSeatItem *)data
                                               indexPath:(NSIndexPath *)indexPath {
  // need override
  return [NEListenTogetherMicQueueCell new];
}

+ (CGSize)size {
  // need override
  return CGSizeZero;
}

+ (CGFloat)cellPaddingH {
  // need override
  return 0;
}

+ (CGFloat)cellPaddingW {
  // need override
  return 0;
}

@end
