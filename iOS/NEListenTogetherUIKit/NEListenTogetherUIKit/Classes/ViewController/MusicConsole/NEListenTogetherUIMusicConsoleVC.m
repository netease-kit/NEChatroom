// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEListenTogetherUIMusicConsoleVC.h"
#import <NEListenTogetherKit/NEListenTogetherKit-Swift.h>
#import "NEListenTogetherLocalized.h"

@interface NEListenTogetherUIMusicConsoleVC () <UITableViewDataSource, UITableViewDelegate>
// 列表
@property(nonatomic, strong) UITableView *tableView;
// 耳返
@property(nonatomic, strong) UITableViewCell *earbackCell;
// 耳返开关
@property(nonatomic, strong) UISwitch *earbackSwitch;
// 采集
@property(nonatomic, strong) UITableViewCell *recordVolumeCell;
// 采集拖动条
@property(nonatomic, strong) UISlider *recordVolumeSlider;
// 伴音
@property(nonatomic, strong) UITableViewCell *audioMixingVolumeCell;
// 伴音拖动条
@property(nonatomic, strong) UISlider *audioMixingVolumeSlider;
// 单元格总和
@property(nonatomic, copy) NSArray<UITableViewCell *> *cells;
// 高度
@property(nonatomic, copy) NSArray<NSNumber *> *heights;
@property(nonatomic, strong) NEListenTogetherContext *context;
@end

@implementation NEListenTogetherUIMusicConsoleVC
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
  self.tableView.tableFooterView = UIView.new;
  self.tableView.allowsSelection = NO;
  self.tableView.separatorInset = UIEdgeInsetsMake(0, 20, 0, 20);
  self.tableView.clipsToBounds = YES;
  self.tableView.separatorColor = [UIColor.lightGrayColor colorWithAlphaComponent:0.4];
  [self.view addSubview:self.tableView];

  // 耳返
  self.earbackSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
  [self.earbackSwitch addTarget:self
                         action:@selector(earbackAction:)
               forControlEvents:UIControlEventValueChanged];
  self.earbackCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                            reuseIdentifier:nil];
  self.earbackCell.accessoryView = self.earbackSwitch;
  self.earbackCell.textLabel.text = NELocalizedString(@"耳返");
  self.earbackCell.textLabel.font = [UIFont systemFontOfSize:14];
  self.earbackCell.detailTextLabel.text = NELocalizedString(@"插入耳机后可使用耳返功能");
  self.earbackCell.detailTextLabel.font = [UIFont systemFontOfSize:12];
  self.earbackCell.detailTextLabel.textColor = UIColor.lightGrayColor;

  // 人声
  self.recordVolumeSlider = [[UISlider alloc] initWithFrame:CGRectZero];
  [self.recordVolumeSlider setThumbImage:[UIImage imageNamed:@"icon_music_console_slider_thumb"]
                                forState:UIControlStateNormal];
  [self.recordVolumeSlider addTarget:self
                              action:@selector(recordVolumeAction:)
                    forControlEvents:UIControlEventValueChanged];
  self.recordVolumeCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                 reuseIdentifier:nil];
  self.recordVolumeCell.textLabel.text = NELocalizedString(@"人声");
  self.recordVolumeCell.textLabel.font = [UIFont systemFontOfSize:14];
  [self.recordVolumeCell.contentView addSubview:self.recordVolumeSlider];

  // 伴奏
  self.audioMixingVolumeSlider = [[UISlider alloc] initWithFrame:CGRectZero];
  [self.audioMixingVolumeSlider
      setThumbImage:[UIImage imageNamed:@"icon_music_console_slider_thumb"]
           forState:UIControlStateNormal];
  [self.audioMixingVolumeSlider addTarget:self
                                   action:@selector(audioMixingVolumeAction:)
                         forControlEvents:UIControlEventValueChanged];
  self.audioMixingVolumeCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                      reuseIdentifier:nil];
  self.audioMixingVolumeCell.textLabel.text = NELocalizedString(@"伴奏");
  self.audioMixingVolumeCell.textLabel.font = [UIFont systemFontOfSize:14];
  [self.audioMixingVolumeCell.contentView addSubview:self.audioMixingVolumeSlider];

  // 主播
  if (self.context.role == NEListenTogetherRoleHost) {
    self.cells = @[ self.earbackCell, self.recordVolumeCell, self.audioMixingVolumeCell ];
    self.heights = @[ @64, @49, @49 ];
  } else {  // 观众
    self.cells = @[ self.earbackCell, self.recordVolumeCell ];
    self.heights = @[ @64, @49 ];
  }
}
- (void)viewDidLoad {
  [super viewDidLoad];
  self.title = NELocalizedString(@"调音台");
  self.earbackSwitch.on = self.context.rtcConfig.earbackOn;
  self.recordVolumeSlider.maximumValue = 400;
  self.recordVolumeSlider.value = self.context.rtcConfig.audioRecordVolume;
  self.audioMixingVolumeSlider.maximumValue = 100;
  self.audioMixingVolumeSlider.value = self.context.rtcConfig.audioMixingVolume;

  [NSNotificationCenter.defaultCenter addObserver:self
                                         selector:@selector(canUseEarback)
                                             name:@"CanUseEarback"
                                           object:nil];
  [NSNotificationCenter.defaultCenter addObserver:self
                                         selector:@selector(canNotUseEarback)
                                             name:@"CanNotUseEarback"
                                           object:nil];
}

- (void)canUseEarback {
  self.earbackSwitch.enabled = true;
  self.earbackSwitch.on = true;
}

- (void)canNotUseEarback {
  self.earbackSwitch.enabled = false;
  self.earbackSwitch.on = false;
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  self.earbackSwitch.enabled = [[NEListenTogetherKit getInstance] isHeadSetPlugging];
  if (![[NEListenTogetherKit getInstance] isHeadSetPlugging]) {
    self.earbackSwitch.on = false;
  }
}

- (void)viewDidLayoutSubviews {
  [super viewDidLayoutSubviews];

  self.tableView.frame = self.view.bounds;

  CGFloat height = 22.0;
  CGFloat top = 46.0 / 2 - height / 2;
  self.recordVolumeCell.textLabel.frame = CGRectMake(20, top, 50, height);
  self.audioMixingVolumeCell.textLabel.frame = CGRectMake(20, top, 50, height);

  CGFloat sliderWidth = self.tableView.bounds.size.width - 90;
  self.recordVolumeSlider.frame =
      CGRectMake(CGRectGetMaxX(self.recordVolumeCell.textLabel.frame), top, sliderWidth, height);
  self.audioMixingVolumeSlider.frame = CGRectMake(
      CGRectGetMaxX(self.audioMixingVolumeCell.textLabel.frame), top, sliderWidth, height);
}

- (void)dealloc {
  self.tableView.dataSource = nil;
  self.tableView.delegate = nil;

  [NSNotificationCenter.defaultCenter removeObserver:self];
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
  preferedHeight += [[self.heights valueForKeyPath:@"@sum.self"] doubleValue];
  preferedHeight += 20;
  return CGSizeMake(self.navigationController.view.bounds.size.width, preferedHeight);
}

- (void)earbackAction:(UISwitch *)sender {
  self.context.rtcConfig.earbackOn = sender.on;
}

- (void)recordVolumeAction:(UISlider *)sender {
  self.context.rtcConfig.audioRecordVolume = sender.value;
}

- (void)audioMixingVolumeAction:(UISlider *)sender {
  self.context.rtcConfig.audioRecordVolume = sender.value;
  self.context.rtcConfig.effectVolume = sender.value;
  [NEListenTogetherKit.getInstance setAudioMixingVolume:sender.value];
}

#pragma mark------------------------ UITableView datasource and delegate ------------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.cells.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  return self.cells[indexPath.row];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return self.heights[indexPath.row].doubleValue;
}

@end
