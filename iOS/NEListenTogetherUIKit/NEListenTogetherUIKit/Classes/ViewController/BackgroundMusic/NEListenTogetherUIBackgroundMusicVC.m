// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEListenTogetherUIBackgroundMusicVC.h"
#import <AVFoundation/AVFoundation.h>
#import <NEListenTogetherKit/NEListenTogetherKit-Swift.h>
#import <NEUIKit/UIImage+NEUIExtension.h>
#import "NEListenTogetherLocalized.h"
#import "NEListenTogetherUI.h"
#import "NEListenTogetherUIBackgroundMusicModel.h"
#import "NEListenTogetherUIBackgroundMusiceCell.h"

static CGFloat kTableRowHeight = 60.0;
static CGFloat kTableHeaderHeight = 60.0;
static CGFloat kTableFooterHeight = 60.0;

static void *KVOContext = &KVOContext;

@interface NEListenTogetherUIBackgroundMusicVC () <UITableViewDataSource, UITableViewDelegate>
// 列表
@property(nonatomic, strong) UITableView *tableView;
// 音效1
@property(nonatomic, strong) UIButton *effect1Button;
// 音效2
@property(nonatomic, strong) UIButton *effect2Button;
// 暂停
@property(nonatomic, strong) UIButton *pauseButton;
// 恢复
@property(nonatomic, strong) UIButton *resumeButton;
// 伴音名称
@property(nonatomic, copy) NSArray<NSString *> *backgroundMusicNames;
// 伴音
@property(nonatomic, copy) NSArray<NEListenTogetherUIBackgroundMusicModel *> *backgroundMusics;
@property(nonatomic, strong) NEListenTogetherContext *context;
@end

@implementation NEListenTogetherUIBackgroundMusicVC
- (instancetype)initWithContext:(NEListenTogetherContext *)context {
  self = [super init];
  if (self) {
    self.context = context;
  }
  return self;
}
- (void)loadView {
  UIView *view = [[UIView alloc] initWithFrame:self.navigationController.view.bounds];
  view.backgroundColor = UIColor.whiteColor;
  self.view = view;

  self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
  self.tableView.dataSource = self;
  self.tableView.delegate = self;
  self.tableView.scrollEnabled = NO;
  self.tableView.separatorInset = UIEdgeInsetsMake(0, 20, 0, 20);
  self.tableView.clipsToBounds = YES;
  self.tableView.rowHeight = kTableRowHeight;
  self.tableView.separatorColor = [UIColor.lightGrayColor colorWithAlphaComponent:0.4];
  [self.tableView registerClass:NEListenTogetherUIBackgroundMusiceCell.class
         forCellReuseIdentifier:@"cell"];
  [self.view addSubview:self.tableView];

  // 头部音效
  UIView *tableHeaderView = [[UIView alloc]
      initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, kTableHeaderHeight)];
  CGFloat buttonWidth = (self.tableView.frame.size.width - 20.0 * 2 - 12) / 2.0;
  // 音效1
  self.effect1Button = [UIButton buttonWithType:UIButtonTypeCustom];
  self.effect1Button.frame =
      CGRectMake(20, 12, buttonWidth, tableHeaderView.frame.size.height - 12 * 2.0);
  self.effect1Button.tag = 1;
  self.effect1Button.clipsToBounds = YES;
  self.effect1Button.layer.cornerRadius = 6;
  self.effect1Button.titleEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 0);
  self.effect1Button.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 8);
  self.effect1Button.titleLabel.font = [UIFont systemFontOfSize:14];
  [self.effect1Button setImage:[NEListenTogetherUI ne_listen_imageName:@"icon_bgm_applaud"]
                      forState:UIControlStateNormal];
  [self.effect1Button
      setBackgroundImage:[UIImage ne_imageWithColor:[UIColor colorWithRed:242 / 255.0
                                                                    green:243 / 255.0
                                                                     blue:245 / 255.0
                                                                    alpha:1.0]]
                forState:UIControlStateNormal];
  [self.effect1Button setTitle:NELocalizedString(@"鼓掌声") forState:UIControlStateNormal];
  [self.effect1Button setTitleColor:[UIColor colorWithRed:34 / 255.0
                                                    green:34 / 255.0
                                                     blue:34 / 255.0
                                                    alpha:1.0]
                           forState:UIControlStateNormal];
  [self.effect1Button addTarget:self
                         action:@selector(effectAction:)
               forControlEvents:UIControlEventTouchUpInside];
  [tableHeaderView addSubview:self.effect1Button];
  // 音效2
  self.effect2Button = [UIButton buttonWithType:UIButtonTypeCustom];
  self.effect2Button.frame = CGRectMake(20 + buttonWidth + 12, 12, buttonWidth,
                                        tableHeaderView.frame.size.height - 12 * 2.0);
  self.effect2Button.tag = 2;
  self.effect2Button.clipsToBounds = YES;
  self.effect2Button.layer.cornerRadius = 6;
  self.effect2Button.titleLabel.font = [UIFont systemFontOfSize:14];
  self.effect2Button.titleEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 0);
  self.effect2Button.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 8);
  [self.effect2Button setImage:[NEListenTogetherUI ne_listen_imageName:@"icon_bgm_laugh"]
                      forState:UIControlStateNormal];
  [self.effect2Button
      setBackgroundImage:[UIImage ne_imageWithColor:[UIColor colorWithRed:242 / 255.0
                                                                    green:243 / 255.0
                                                                     blue:245 / 255.0
                                                                    alpha:1.0]]
                forState:UIControlStateNormal];
  [self.effect2Button setTitle:NELocalizedString(@"笑声") forState:UIControlStateNormal];
  [self.effect2Button setTitleColor:[UIColor colorWithRed:34 / 255.0
                                                    green:34 / 255.0
                                                     blue:34 / 255.0
                                                    alpha:1.0]
                           forState:UIControlStateNormal];
  [self.effect2Button addTarget:self
                         action:@selector(effectAction:)
               forControlEvents:UIControlEventTouchUpInside];
  [tableHeaderView addSubview:self.effect2Button];
  self.tableView.tableHeaderView = tableHeaderView;

  // 底部
  UIView *tableFoolterView = [[UIView alloc]
      initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, kTableFooterHeight)];
  tableFoolterView.backgroundColor = UIColor.whiteColor;
  //  self.tableView.tableFooterView = tableFoolterView;

  // 暂停
  UIButton *pauseButton = [UIButton buttonWithType:UIButtonTypeCustom];
  pauseButton.frame = CGRectMake(20, 12, 40, 40);
  pauseButton.clipsToBounds = YES;
  pauseButton.layer.cornerRadius = 20;
  [pauseButton setBackgroundImage:[UIImage ne_imageWithColor:[UIColor colorWithRed:242 / 255.0
                                                                             green:243 / 255.0
                                                                              blue:245 / 255.0
                                                                             alpha:1.0]]
                         forState:UIControlStateNormal];
  [pauseButton setImage:[NEListenTogetherUI ne_listen_imageName:@"icon_bgm_pause"]
               forState:UIControlStateNormal];
  [pauseButton addTarget:self
                  action:@selector(pauseAction:)
        forControlEvents:UIControlEventTouchUpInside];
  [tableFoolterView addSubview:pauseButton];
  self.pauseButton = pauseButton;

  // 播放
  UIButton *resumeButton = [UIButton buttonWithType:UIButtonTypeCustom];
  resumeButton.frame = CGRectMake(20, 12, 40, 40);
  resumeButton.clipsToBounds = YES;
  resumeButton.layer.cornerRadius = 20;
  resumeButton.hidden = YES;
  [resumeButton setImage:[NEListenTogetherUI ne_listen_imageName:@"icon_bgm_play"]
                forState:UIControlStateNormal];
  [resumeButton setBackgroundImage:[UIImage ne_imageWithColor:[UIColor colorWithRed:242 / 255.0
                                                                              green:243 / 255.0
                                                                               blue:245 / 255.0
                                                                              alpha:1.0]]
                          forState:UIControlStateNormal];
  [resumeButton addTarget:self
                   action:@selector(resumeAction:)
         forControlEvents:UIControlEventTouchUpInside];
  [tableFoolterView addSubview:resumeButton];
  self.resumeButton = resumeButton;

  // 切换下一首
  UIButton *switchNextButton = [UIButton buttonWithType:UIButtonTypeCustom];
  switchNextButton.frame = CGRectOffset(pauseButton.frame, 40 + 12, 0);
  switchNextButton.clipsToBounds = YES;
  switchNextButton.layer.cornerRadius = 20;
  [switchNextButton setImage:[NEListenTogetherUI ne_listen_imageName:@"icon_bgm_switch_next"]
                    forState:UIControlStateNormal];
  [switchNextButton setBackgroundImage:[UIImage ne_imageWithColor:[UIColor colorWithRed:242 / 255.0
                                                                                  green:243 / 255.0
                                                                                   blue:245 / 255.0
                                                                                  alpha:1.0]]
                              forState:UIControlStateNormal];
  [switchNextButton addTarget:self
                       action:@selector(switchNextAction:)
             forControlEvents:UIControlEventTouchUpInside];
  [tableFoolterView addSubview:switchNextButton];

  // 音量图标
  UIImageView *volumeImageView = [[UIImageView alloc]
      initWithImage:[NEListenTogetherUI ne_listen_imageName:@"icon_bgm_volume"]];
  volumeImageView.frame = CGRectMake(tableFoolterView.bounds.size.width / 2.0 + 8,
                                     tableFoolterView.bounds.size.height / 2.0 - 8, 16, 16);
  [tableFoolterView addSubview:volumeImageView];

  // 音量
  UISlider *volumeSlider =
      [[UISlider alloc] initWithFrame:CGRectMake(CGRectGetMaxX(volumeImageView.frame) + 8,
                                                 tableFoolterView.frame.size.height / 2.0 - 8,
                                                 tableFoolterView.frame.size.width -
                                                     CGRectGetMaxX(volumeImageView.frame) - 8 - 20,
                                                 16)];
  volumeSlider.maximumValue = 100;
  volumeSlider.value = self.context.rtcConfig.effectVolume;
  [volumeSlider setThumbImage:[NEListenTogetherUI ne_listen_imageName:@"icon_bgm_slider_thumb"]
                     forState:UIControlStateNormal];
  [volumeSlider addTarget:self
                   action:@selector(volumeDidChange:)
         forControlEvents:UIControlEventValueChanged];
  [tableFoolterView addSubview:volumeSlider];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.title = NELocalizedString(@"音效");
  //  self.backgroundMusicNames = @[ @"1", @"2", @"3" ];
  //  self.pauseButton.hidden = self.context.isBackgroundMusicPaused;
  //  self.resumeButton.hidden = !self.pauseButton.hidden;
  self.pauseButton.hidden = YES;
  self.resumeButton.hidden = YES;
  //  [self.context addObserver:self
  //                 forKeyPath:@"isBackgroundMusicPaused"
  //                    options:NSKeyValueObservingOptionNew
  //                    context:KVOContext];
  //  [self.context addObserver:self
  //                 forKeyPath:@"currentBgm"
  //                    options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
  //                    context:KVOContext];
}
- (void)dealloc {
  self.tableView.dataSource = nil;
  self.tableView.delegate = nil;
  //  [self.context removeObserver:self forKeyPath:@"isBackgroundMusicPaused"];
  //  [self.context removeObserver:self forKeyPath:@"currentBgm"];
}

- (CGSize)preferredContentSize {
  CGFloat preferedHeight = 0;
  if (@available(iOS 11.0, *)) {
    if ([[UIApplication sharedApplication].delegate respondsToSelector:@selector(window)]) {
      CGFloat safeAreaBottom =
          UIApplication.sharedApplication.delegate.window.safeAreaInsets.bottom;
      preferedHeight += safeAreaBottom;
    }
  }
  preferedHeight += kTableHeaderHeight;
  preferedHeight += self.backgroundMusics.count * kTableRowHeight;
  preferedHeight += kTableFooterHeight;
  return CGSizeMake(self.navigationController.view.bounds.size.width, preferedHeight);
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey, id> *)change
                       context:(void *)context {
  if (context != KVOContext) {
    return [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
  }
  if ([keyPath isEqualToString:@"isBackgroundMusicPaused"]) {
    self.pauseButton.hidden = self.context.isBackgroundMusicPaused;
    self.resumeButton.hidden = !self.pauseButton.hidden;
  }
  if ([keyPath isEqualToString:@"currentBgm"]) {
    [NEListenTogetherKit.getInstance stopAudioMixing];
    if (self.context.currentBgm) {
      NEListenTogetherCreateAudioMixingOption *opt = [NEListenTogetherCreateAudioMixingOption new];
      opt.path = [[NEListenTogetherUI ne_listen_sourceBundle]
          pathForResource:self.context.currentBgm.fileName
                   ofType:@"mp3"];
      opt.sendVolume = self.context.rtcConfig.audioMixingVolume;
      opt.playbackVolume = self.context.rtcConfig.audioMixingVolume;
      opt.loopCount = 0;
      NSInteger code = [NEListenTogetherKit.getInstance startAudioMixing:opt];
      if (code == 0) {
        [self.tableView reloadData];
      }
    }
  }
}
#pragma mark - UITableViewDataSource & UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.backgroundMusics.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  NEListenTogetherUIBackgroundMusicModel *music = self.backgroundMusics[indexPath.row];
  NEListenTogetherUIBackgroundMusiceCell *cell =
      [tableView dequeueReusableCellWithIdentifier:@"cell"];
  cell.textLabel.text = music.title;
  cell.detailTextLabel.text = [NSString stringWithFormat:@"%@-%@", music.artist, music.albumName];
  cell.indexLabel.text = [NSString stringWithFormat:@"%02ld", indexPath.row + 1];
  if ([music isEqual:self.context.currentBgm]) {
    cell.indexLabel.hidden = YES;
    [cell.playingAnimationView play];
    cell.textLabel.textColor = [UIColor colorWithRed:51 / 255.0
                                               green:126 / 255.0
                                                blue:255 / 255.0
                                               alpha:1.0];
    cell.playingAnimationView.hidden = NO;
  } else {
    cell.indexLabel.hidden = NO;
    cell.playingAnimationView.hidden = YES;
    [cell.playingAnimationView stop];
    cell.textLabel.textColor = [UIColor colorWithRed:34 / 255.0
                                               green:34 / 255.0
                                                blue:34 / 255.0
                                               alpha:1.0];
  }
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  [self resumeAction:nil];
  NEListenTogetherUIBackgroundMusicModel *music = self.backgroundMusics[indexPath.row];
  if ([music isEqual:self.context.currentBgm]) {
    return;
  }
  self.context.currentBgm = music;
}

- (void)effectAction:(UIButton *)sender {
  // 停止正在播放的音效
  [[NEListenTogetherKit getInstance] stopEffectWithEffectId:1];
  [[NEListenTogetherKit getInstance] stopEffectWithEffectId:2];

  uint32_t eid = (uint32_t)sender.tag;
  NSString *fileName = [NSString stringWithFormat:@"audio_effect_%ld", sender.tag];
  NEListenTogetherCreateAudioEffectOption *opt = [NEListenTogetherCreateAudioEffectOption new];
  opt.path = [[NEListenTogetherUI ne_listen_sourceBundle] pathForResource:fileName ofType:@"wav"];
  opt.sendVolume = self.context.rtcConfig.effectVolume;
  opt.playbackVolume = self.context.rtcConfig.effectVolume;
  opt.loopCount = 1;
  opt.sendWithAudioType = NEListenTogetherAudioStreamTypeMain;
  [NEListenTogetherKit.getInstance playEffect:eid option:opt];
}

- (void)pauseAction:(UIButton *)sender {
  NSInteger code = [NEListenTogetherKit.getInstance pauseAudioMixing];
  if (code != 0) return;

  self.context.isBackgroundMusicPaused = YES;
  self.pauseButton.hidden = YES;
  self.resumeButton.hidden = NO;
}

- (void)resumeAction:(UIButton *)sender {
  NSInteger code = [NEListenTogetherKit.getInstance resumeAudioMixing];
  if (code != 0) return;

  self.context.isBackgroundMusicPaused = NO;
  self.pauseButton.hidden = NO;
  self.resumeButton.hidden = YES;
}

- (void)switchNextAction:(UIButton *)sender {
  NSInteger nextIndex = ([self.backgroundMusics indexOfObject:self.context.currentBgm] + 1) %
                        self.backgroundMusics.count;
  [self tableView:self.tableView
      didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:nextIndex inSection:0]];
}

- (void)volumeDidChange:(UISlider *)sender {
  self.context.rtcConfig.audioMixingVolume = sender.value;
  self.context.rtcConfig.effectVolume = sender.value;
  [NEListenTogetherKit.getInstance setAudioMixingVolume:sender.value];
  //    [NERtcEngine.sharedEngine setAudioMixingSendVolume:sender.value];
  //    [NERtcEngine.sharedEngine setAudioMixingPlaybackVolume:sender.value];
}

- (NSArray<NEListenTogetherUIBackgroundMusicModel *> *)backgroundMusics {
  if (!self.backgroundMusicNames) {
    return nil;
  }
  if (!_backgroundMusics) {
    NSMutableArray *array = NSMutableArray.array;
    for (NSString *name in self.backgroundMusicNames) {
      NEListenTogetherUIBackgroundMusicModel *music =
          [[NEListenTogetherUIBackgroundMusicModel alloc] init];
      music.fileName = name;
      NSURL *fileURL = [[NEListenTogetherUI ne_listen_sourceBundle] URLForResource:name
                                                                     withExtension:@"mp3"];
      AVURLAsset *asset = [AVURLAsset URLAssetWithURL:fileURL options:nil];
      AVMetadataItem *title = [AVMetadataItem metadataItemsFromArray:asset.commonMetadata
                                                             withKey:AVMetadataCommonKeyTitle
                                                            keySpace:AVMetadataKeySpaceCommon]
                                  .firstObject;
      music.title = (NSString *)title.value;
      AVMetadataItem *artist = [AVMetadataItem metadataItemsFromArray:asset.commonMetadata
                                                              withKey:AVMetadataCommonKeyArtist
                                                             keySpace:AVMetadataKeySpaceCommon]
                                   .firstObject;
      music.artist = (NSString *)artist.value;
      AVMetadataItem *albumName =
          [AVMetadataItem metadataItemsFromArray:asset.commonMetadata
                                         withKey:AVMetadataCommonKeyAlbumName
                                        keySpace:AVMetadataKeySpaceCommon]
              .firstObject;
      music.albumName = (NSString *)albumName.value;
      [array addObject:music];
      _backgroundMusics = [NSArray arrayWithArray:array];
    }
  }
  return _backgroundMusics;
}

@end
