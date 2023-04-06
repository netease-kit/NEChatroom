// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEListenTogetherMicQueueView.h"
#import <Masonry/Masonry.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import "NEListenTogetherChatroomMicCell.h"
#import "NEListenTogetherGlobalMacro.h"
#import "NEListenTogetherInnerSingleton.h"
#import "NEListenTogetherLocalized.h"
#import "NEListenTogetherPaddingLabel.h"
#import "NEListenTogetherUI.h"
#import "UIView+NEUIExtension.h"
@import LottieSwift;

@interface NEListenTogetherMicQueueView ()

/// 麦位控件
//@property(nonatomic, strong) UICollectionView *collectionView;
/// 主播控件
@property(nonatomic, strong) NEListenTogetherMicQueueCell *anchorCell;
@property(nonatomic, strong) UIImageView *anchorBackImage;
/// 主播控件
@property(nonatomic, strong) NEListenTogetherMicQueueCell *listenTogetherCell;
@property(nonatomic, strong) UIImageView *listenTogetherBackImage;
@property(nonatomic, strong) NEListenTogetherPaddingLabel *anchorDownloadingLabel;
@property(nonatomic, strong) NEListenTogetherPaddingLabel *audienceDownloadingLabel;

@property(nonatomic, strong) UIImageView *waveBackImage;

/// 中心视图
@property(nonatomic, strong) UIView *mainCenterView;
/// 背景图
@property(nonatomic, strong) UIImageView *backLineView;
/// 听听歌按钮
@property(nonatomic, strong) UIButton *listenSongButton;
/// 高斯模糊
@property(nonatomic, strong) UIVisualEffectView *effectView;

@property(nonatomic, strong) NELottieView *lottieView;

@end

@implementation NEListenTogetherMicQueueView

@synthesize delegate = _delegate, anchorMicInfo = _anchorMicInfo, datas = _datas;

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    [self addSubview:self.mainCenterView];
    [self.mainCenterView addSubview:self.effectView];
    [self.mainCenterView addSubview:self.lottieView];
    [self.mainCenterView addSubview:self.backLineView];
    [self.mainCenterView addSubview:self.anchorBackImage];
    [self.mainCenterView addSubview:self.anchorCell];
    [self.mainCenterView addSubview:self.listenTogetherBackImage];
    [self.mainCenterView addSubview:self.listenTogetherCell];
    [self.mainCenterView addSubview:self.waveBackImage];
    [self.mainCenterView addSubview:self.anchorDownloadingLabel];
    [self.mainCenterView addSubview:self.audienceDownloadingLabel];

    [self addSubview:self.listenSongButton];
    [self.lottieView stop];

    @weakify(self);
    [RACObserve(self, datas) subscribeNext:^(id _Nullable x) {
      @strongify(self);
      ntes_main_sync_safe(^{
        [self reloadListenTogetherData];
      });
    }];
  }
  return self;
}
- (void)play {
  dispatch_async(dispatch_get_main_queue(), ^{
    [self.lottieView play];
  });
}

- (void)pause {
  dispatch_async(dispatch_get_main_queue(), ^{
    [self.lottieView pause];
  });
}
- (void)stop {
  dispatch_async(dispatch_get_main_queue(), ^{
    [self.lottieView stop];
  });
}

- (void)updateWithLocalVolume:(NSInteger)volume {
  // local的更新
  NEListenTogetherMember *localMember = [NEListenTogetherKit getInstance].localMember;
  if (volume > 0 && localMember.isAudioOn) {
    if ([localMember.account isEqualToString:_anchorMicInfo.user]) {
      [_anchorCell startSpeakAnimation];
    } else {
      [_listenTogetherCell startSpeakAnimation];
    }
  } else {
    if ([[NEListenTogetherKit getInstance].localMember.account
            isEqualToString:_anchorMicInfo.user]) {
      [_anchorCell stopSpeakAnimation];
    } else {
      [_listenTogetherCell stopSpeakAnimation];
    }
  }
}

- (void)updateWithRemoteVolumeInfos:(NSArray<NEListenTogetherMemberVolumeInfo *> *)volumeInfos {
  if (volumeInfos.count == 0) {
    // 远端无人说话
    if ([[NEListenTogetherKit getInstance].localMember.account
            isEqualToString:_anchorMicInfo.user]) {
      [_listenTogetherCell stopSpeakAnimation];
    } else {
      [_anchorCell stopSpeakAnimation];
    }
  } else {
    // 远端有人说话
    NEListenTogetherMemberVolumeInfo *volume = volumeInfos[0];
    NEListenTogetherMember *member;
    for (NEListenTogetherMember *m in [NEListenTogetherKit getInstance].allMemberList) {
      if ([m.account isEqualToString:volume.userUuid]) {
        member = m;
      }
    }
    if (volume.volume > 0 && member.isAudioOn) {
      if ([member.account isEqualToString:_anchorMicInfo.user]) {
        [_anchorCell startSpeakAnimation];
      } else {
        [_listenTogetherCell startSpeakAnimation];
      }
    } else {
      if ([[NEListenTogetherKit getInstance].localMember.account
              isEqualToString:_anchorMicInfo.user]) {
        [_listenTogetherCell stopSpeakAnimation];
      } else {
        [_anchorCell stopSpeakAnimation];
      }
    }
  }
}

- (void)reloadListenTogetherData {
  // 根据data 刷新数据
  [self.listenTogetherCell
      refresh:[NEListenTogetherInnerSingleton.singleton fetchListenTogetherItem:self.datas]];
}
- (void)layoutSubviews {
  [self.mainCenterView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(self).offset(-50);
    make.width.height.equalTo(@(self.frame.size.width - 60));
    make.centerX.equalTo(self);
  }];

  //    [self.effectView mas_makeConstraints:^(MASConstraintMaker *make) {
  //        make.center.equalTo(self.mainCenterView);
  //        make.width.height.equalTo(@195);
  //    }];

  [self.lottieView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.center.equalTo(self.mainCenterView);
    make.width.height.equalTo(@280);
  }];

  [self.backLineView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.center.equalTo(self.mainCenterView);
    make.width.height.equalTo(@194.5);
  }];
  [self.anchorCell mas_makeConstraints:^(MASConstraintMaker *make) {
    make.centerX.equalTo(self.mainCenterView).offset(-50);
    make.centerY.equalTo(self.mainCenterView);
    make.width.height.equalTo(@55);
  }];

  [self.anchorBackImage mas_makeConstraints:^(MASConstraintMaker *make) {
    make.centerY.centerX.equalTo(self.anchorCell);
    make.width.height.equalTo(@70);
  }];

  [self.listenTogetherCell mas_makeConstraints:^(MASConstraintMaker *make) {
    make.centerX.equalTo(self.mainCenterView).offset(50);
    make.centerY.equalTo(self.mainCenterView);
    make.width.height.equalTo(@55);
  }];

  [self.listenTogetherBackImage mas_makeConstraints:^(MASConstraintMaker *make) {
    make.centerY.equalTo(self.listenTogetherCell);
    make.centerX.equalTo(self.listenTogetherCell).offset(3.5);
    make.width.height.equalTo(@70);
  }];

  [self.waveBackImage mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.mas_equalTo(self.anchorBackImage.mas_right);
    make.right.mas_equalTo(self.listenTogetherCell.mas_left);
    make.centerY.equalTo(self.mainCenterView);
    make.height.equalTo(@20);
  }];

  [self.listenSongButton mas_makeConstraints:^(MASConstraintMaker *make) {
    make.centerX.equalTo(self);
    make.width.equalTo(@128);
    make.height.equalTo(@44);
    make.bottom.equalTo(self);
  }];
  [self.anchorDownloadingLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.centerX.equalTo(self.anchorCell);
    make.top.equalTo(self.anchorCell.mas_bottom).offset(25);
    make.height.equalTo(@15);
  }];

  [self.audienceDownloadingLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.centerX.equalTo(self.listenTogetherCell);
    make.top.equalTo(self.listenTogetherCell.mas_bottom).offset(25);
    make.height.equalTo(@15);
  }];
}

- (void)updateCellWithMicInfo:(NEListenTogetherSeatItem *)micInfo {
  if (!micInfo) {
    return;
  }
  ntes_main_async_safe(^{
    [self.listenTogetherCell refresh:micInfo];
  });
}

- (CGFloat)calculateHeightWithWidth:(CGFloat)width {
  CGSize size = [NEListenTogetherChatroomMicCell size];
  CGFloat paddingH = [NEListenTogetherChatroomMicCell cellPaddingH];
  return 3 * size.height + 2 * paddingH;
}

- (void)startSoundAnimation:(NSInteger)micOrder volume:(NSInteger)volume {
  [self.listenTogetherCell startSoundAnimationWithValue:volume];
}

- (void)stopSoundAnimation:(NSInteger)micOrder {
  [self.listenTogetherCell stopSoundAnimation];
}

#pragma mark - getter/setter
- (void)setAnchorMicInfo:(NEListenTogetherSeatItem *)anchorMicInfo {
  if (!anchorMicInfo) return;

  _anchorMicInfo = anchorMicInfo;
  [self.anchorCell refresh:anchorMicInfo];
}

#pragma mark - NEListenTogetherMicQueueCellDelegate

- (void)onConnectBtnPressedWithMicInfo:(NEListenTogetherSeatItem *)micInfo {
  if (_delegate &&
      [_delegate respondsToSelector:@selector(micQueueConnectBtnPressedWithMicInfo:)]) {
    [_delegate micQueueConnectBtnPressedWithMicInfo:micInfo];
  }
}

#pragma mark - lazy load

- (NEListenTogetherMicQueueCell *)anchorCell {
  if (!_anchorCell) {
    CGSize size = [NEListenTogetherChatroomMicCell size];
    _anchorCell = [[NEListenTogetherChatroomMicCell alloc]
        initWithFrame:CGRectMake(0, 0, size.width, size.height)];
  }
  return _anchorCell;
}

- (UIImageView *)anchorBackImage {
  if (!_anchorBackImage) {
    CGSize size = [NEListenTogetherChatroomMicCell size];
    _anchorBackImage =
        [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    _anchorBackImage.hidden = true;
    _anchorBackImage.contentMode = UIViewContentModeScaleAspectFit;
  }
  return _anchorBackImage;
}

- (UIImageView *)listenTogetherBackImage {
  if (!_listenTogetherBackImage) {
    CGSize size = [NEListenTogetherChatroomMicCell size];
    _listenTogetherBackImage =
        [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    _listenTogetherBackImage.hidden = true;
    _listenTogetherBackImage.contentMode = UIViewContentModeScaleAspectFit;
  }
  return _listenTogetherBackImage;
}

- (UIImageView *)waveBackImage {
  if (!_waveBackImage) {
    _waveBackImage =
        [[UIImageView alloc] initWithImage:[NEListenTogetherUI ne_listen_imageName:@"wave"]];
    _waveBackImage.hidden = true;
    _waveBackImage.contentMode = UIViewContentModeScaleAspectFit;
  }
  return _waveBackImage;
}

- (NEListenTogetherMicQueueCell *)listenTogetherCell {
  if (!_listenTogetherCell) {
    CGSize size = [NEListenTogetherChatroomMicCell size];
    _listenTogetherCell = [[NEListenTogetherChatroomMicCell alloc]
        initWithFrame:CGRectMake(0, 0, size.width, size.height)];
  }
  return _listenTogetherCell;
}

- (UIImageView *)backLineView {
  if (!_backLineView) {
    _backLineView = [[UIImageView alloc] init];
    _backLineView.contentMode = UIViewContentModeScaleAspectFit;
    _backLineView.image = [NEListenTogetherUI ne_listen_imageName:@"backGroundImage"];
  }
  return _backLineView;
}

- (NELottieView *)lottieView {
  if (!_lottieView) {
    NSString *path = [[NSBundle mainBundle]
        pathForResource:@"Frameworks/NEListenTogetherUIKit.framework/NEListenTogetherUIKit"
                 ofType:@"bundle"];
    _lottieView = [[NELottieView alloc] initWithFrame:CGRectMake(0, 0, 280, 280)
                                               lottie:@"listen_bg_seat"
                                               bundle:[NSBundle bundleWithPath:path]];
  }
  return _lottieView;
}

- (UIView *)mainCenterView {
  if (!_mainCenterView) {
    _mainCenterView = [[UIView alloc] init];
  }
  return _mainCenterView;
}

- (UIButton *)listenSongButton {
  if (!_listenSongButton) {
    _listenSongButton = [[UIButton alloc] init];

    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = CGRectMake(0, 0, 200, 100);
    gradientLayer.startPoint = CGPointMake(0, 0);
    gradientLayer.endPoint = CGPointMake(1, 0);
    gradientLayer.locations = @[ @(0.5), @(1.0) ];  // 渐变点
    [gradientLayer setColors:@[
      (id)[HEXCOLOR(0xEF549E) CGColor],
      (id)[HEXCOLOR(0xFFA3E0) CGColor]
    ]];  // 渐变数组
    [_listenSongButton.layer addSublayer:gradientLayer];

    [_listenSongButton addTarget:self
                          action:@selector(tapListenButton:)
                forControlEvents:UIControlEventTouchUpInside];
    _listenSongButton.layer.masksToBounds = YES;
    _listenSongButton.layer.cornerRadius = 22;
    [_listenSongButton setTitle:NELocalizedString(@"听听歌") forState:UIControlStateNormal];
  }
  return _listenSongButton;
}

- (UIVisualEffectView *)effectView {
  if (!_effectView) {
    UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    _effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
    _effectView.backgroundColor = [UIColor colorWithRed:0.192 green:0.239 blue:0.235 alpha:0.5];
    _effectView.layer.masksToBounds = YES;
    _effectView.layer.cornerRadius = 97;
  }
  return _effectView;
}
- (void)tapListenButton:(UIButton *)sender {
  if (_delegate && [_delegate respondsToSelector:@selector(clickPointSongButton)]) {
    [_delegate clickPointSongButton];
  }
}

- (void)singleListen {
  self.listenTogetherBackImage.hidden = true;
  self.anchorBackImage.hidden = false;
  self.waveBackImage.hidden = true;
  self.anchorBackImage.image = [NEListenTogetherUI ne_listen_imageName:@"single_listen"];
  [self.anchorBackImage mas_updateConstraints:^(MASConstraintMaker *make) {
    make.centerY.centerX.equalTo(self.anchorCell);
    make.width.height.equalTo(@70);
  }];
}

- (void)togetherListen {
  self.listenTogetherBackImage.hidden = false;
  self.anchorBackImage.hidden = false;
  self.waveBackImage.hidden = false;
  self.listenTogetherBackImage.image =
      [NEListenTogetherUI ne_listen_imageName:@"together_listen_r"];
  self.anchorBackImage.image = [NEListenTogetherUI ne_listen_imageName:@"together_listen_l"];
  [self.anchorBackImage mas_updateConstraints:^(MASConstraintMaker *make) {
    make.centerY.equalTo(self.anchorCell);
    make.centerX.equalTo(self.anchorCell).offset(-3.5);
    make.width.height.equalTo(@70);
  }];
}

- (NEListenTogetherPaddingLabel *)anchorDownloadingLabel {
  if (!_anchorDownloadingLabel) {
    _anchorDownloadingLabel = [[NEListenTogetherPaddingLabel alloc] init];
    _anchorDownloadingLabel.hidden = YES;
    _anchorDownloadingLabel.text = NELocalizedString(@"歌曲加载中");
    _anchorDownloadingLabel.textColor = HEXCOLOR(0xFFFFFF);
    _anchorDownloadingLabel.font = [UIFont systemFontOfSize:8];
    _anchorDownloadingLabel.backgroundColor = HEXCOLOR(0x000000);
    _anchorDownloadingLabel.layer.masksToBounds = YES;
    _anchorDownloadingLabel.layer.cornerRadius = 7.5;
  }
  return _anchorDownloadingLabel;
}

- (NEListenTogetherPaddingLabel *)audienceDownloadingLabel {
  if (!_audienceDownloadingLabel) {
    _audienceDownloadingLabel = [[NEListenTogetherPaddingLabel alloc] init];
    _audienceDownloadingLabel.hidden = YES;
    _audienceDownloadingLabel.text = NELocalizedString(@"歌曲加载中");
    _audienceDownloadingLabel.textColor = HEXCOLOR(0xFFFFFF);
    _audienceDownloadingLabel.font = [UIFont systemFontOfSize:8];
    _audienceDownloadingLabel.backgroundColor = HEXCOLOR(0x000000);
    _audienceDownloadingLabel.layer.masksToBounds = YES;
    _audienceDownloadingLabel.layer.cornerRadius = 7.5;
  }
  return _audienceDownloadingLabel;
}
- (void)showListenButton:(BOOL)show {
  self.listenSongButton.hidden = !show;
}
- (void)showDownloadingProcess:(BOOL)isHost show:(BOOL)show {
  if (isHost) {
    if (show) {
      self.audienceDownloadingLabel.hidden = NO;
    } else {
      self.audienceDownloadingLabel.hidden = YES;
    }
  } else {
    if (show) {
      self.anchorDownloadingLabel.hidden = NO;
    } else {
      self.anchorDownloadingLabel.hidden = YES;
    }
  }
}
@end
