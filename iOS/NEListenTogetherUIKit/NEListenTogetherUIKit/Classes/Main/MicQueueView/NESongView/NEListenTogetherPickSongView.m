// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEListenTogetherPickSongView.h"
#import <MJRefresh/MJRefresh.h>
#import <Masonry/Masonry.h>
#import <SDWebImage/SDWebImage.h>
#import <libextobjc/extobjc.h>
#import "NEListenTogetherGlobalMacro.h"
#import "NEListenTogetherLocalized.h"
#import "NEListenTogetherPickSongColorDefine.h"
#import "NEListenTogetherPickSongEngine.h"
#import "NEListenTogetherPointSongTableViewCell.h"
#import "NEListenTogetherPointedSongTableViewCell.h"
#import "NEListenTogetherSongEmptyView.h"
#import "NEListenTogetherSongItem.h"
#import "NEListenTogetherSongPlayControlView.h"
#import "NEListenTogetherToast.h"
#import "NEListenTogetherUI.h"
#import "NEListenTogetherUILog.h"

@interface NEListenTogetherPickSongView () <UITableViewDelegate,
                                            UITableViewDataSource,
                                            NESongPreloadProtocol,
                                            NESongPointProtocol,
                                            UITextFieldDelegate,
                                            NEListenTogetherSongPlayControlViewDelegate>
// 顶部切换视图
@property(nonatomic, strong) UIView *mainTopView;
// 搜索父视图
@property(nonatomic, strong) UIView *searchMainView;
// 搜索子视图
@property(nonatomic, strong) UIView *searchSuperView;
// 搜索TextFiled
@property(nonatomic, strong) UITextField *searchTextField;
// 是否处于搜索中
@property(nonatomic, assign) BOOL isSearching;
// 搜索图标
@property(nonatomic, strong) UIImageView *searchImageView;
// 搜索清空按钮
@property(nonatomic, strong) UIButton *searchClearButton;

@property(nonatomic, strong) UITableView *pickSongsTableView;
@property(nonatomic, strong) UITableView *pickedSongsTableView;
// 点歌按钮
@property(nonatomic, strong) UIButton *pickSongButton;
// 已点按钮
@property(nonatomic, strong) UIButton *pickedSongButton;

// button底部light
@property(nonatomic, strong) UILabel *lightLabel;

// 当前是否选中点歌菜单的记录
@property(nonatomic, assign) bool pointButtonSelected;

@property(nonatomic, strong) NEListenTogetherInfo *detail;

@property(nonatomic, strong) NEListenTogetherSongEmptyView *emptyView;

@property(nonatomic, strong) NEListenTogetherSongPlayControlView *playControlView;

// 当前点歌数据：用于麦位申请的时候
@property(nonatomic, strong) NEListenTogetherSongItem *currentOrderSong;

@end
@implementation NEListenTogetherPickSongView

- (instancetype)initWithFrame:(CGRect)frame detail:(NEListenTogetherInfo *)detail {
  self = [super initWithFrame:frame];
  if (self) {
    [self initPickSongView];
    [self refreshData];
    self.detail = detail;
    [SDImageCache sharedImageCache].config.maxMemoryCost = 1024 * 1024 * 100;
    [SDImageCache sharedImageCache].config.maxMemoryCount = 20;
    //        [SDImageCache sharedImageCache].config.shouldDecompressImages = 20;
    //        [[NEKaraoSongEngine getInstance] addKaraokeSongProtocolObserve:self];
    [[NEListenTogetherPickSongEngine sharedInstance] addObserve:self];
  }
  return self;
}

- (void)refreshData {
  [[NEListenTogetherPickSongEngine sharedInstance] updateSongArray];
  @weakify(self)[[NEListenTogetherPickSongEngine sharedInstance]
      getKaraokeSongList:^(NSError *_Nullable error) {
        if (error) {
          [NEListenTogetherToast showToast:NELocalizedString(@"获取歌曲列表失败")];
        } else {
          @strongify(self) @weakify(self) dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self)[self.pickSongsTableView reloadData];
            [[NEListenTogetherPickSongEngine sharedInstance] updatePageNumber:NO];
          });
        }
      }];
  [[NEListenTogetherPickSongEngine sharedInstance]
      getKaraokeSongOrderedList:^(NSError *_Nullable error) {
        @strongify(self) @weakify(self) if (error) {
          [NEListenTogetherToast showToast:NELocalizedString(@"获取已点列表失败")];
        }
        else {
          @strongify(self) @weakify(self) dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self)[self.pickedSongButton
                setTitle:[NSString stringWithFormat:@"%@(%lu)", NELocalizedString(@"歌曲列表"),
                                                    [NEListenTogetherPickSongEngine sharedInstance]
                                                        .pickedSongArray.count]
                forState:UIControlStateNormal];
            if (!self.pointButtonSelected) {
              self.emptyView.hidden =
                  [NEListenTogetherPickSongEngine sharedInstance].pickedSongArray.count;
            }
            [self.pickedSongsTableView reloadData];
          });
        }
      }];
}

- (void)refreshPickedSongView {
  // 获取房间内播放歌曲
  [[NEListenTogetherKit getInstance]
      queryPlayingSongInfo:^(NSInteger code, NSString *_Nullable msg,
                             NEListenTogetherPlayMusicInfo *_Nullable songModel) {
        if (code == NEListenTogetherErrorCode.success) {
          NEListenTogetherSongModel *model = [[NEListenTogetherSongModel alloc] init];
          model.playMusicInfo = songModel;
          [NEListenTogetherPickSongEngine sharedInstance].currrentSongModel = model;
          /// 获取已点列表数据
          [[NEListenTogetherPickSongEngine sharedInstance]
              getKaraokeSongOrderedList:^(NSError *_Nullable error) {
                if (error == nil) {
                  dispatch_async(dispatch_get_main_queue(), ^{
                    [self.pickedSongsTableView reloadData];
                  });
                }
              }];
        }
      }];
}
- (void)initPickSongView {
  UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
  UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
  effectView.backgroundColor = [UIColor colorWithRed:0.192 green:0.239 blue:0.235 alpha:0.5];
  //  [self addSubview:effectView];
  //  [effectView mas_makeConstraints:^(MASConstraintMaker *make) {
  //    make.left.right.top.bottom.equalTo(self);
  //  }];
  self.backgroundColor = [UIColor whiteColor];
  //    [UIColor karaoke_colorWithHex:color_313D3C];
  // 顶部视图
  self.mainTopView = [[UIButton alloc] init];
  [self addSubview:self.mainTopView];
  [self.mainTopView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.left.right.equalTo(self);
    make.height.equalTo(@50);
  }];
  self.pickSongButton = [[UIButton alloc] init];
  [self.pickSongButton setTitle:NELocalizedString(@"点歌") forState:UIControlStateNormal];
  [self.pickSongButton setTitleColor:HEXCOLOR(0x222222) forState:UIControlStateNormal];
  [self.pickSongButton addTarget:self
                          action:@selector(clickPickButton:)
                forControlEvents:UIControlEventTouchUpInside];
  self.pickSongButton.titleLabel.font = [UIFont systemFontOfSize:16];
  [self.mainTopView addSubview:self.pickSongButton];
  [self.pickSongButton mas_makeConstraints:^(MASConstraintMaker *make) {
    make.centerY.equalTo(self.mainTopView);
    make.right.equalTo(self.mainTopView.mas_centerX).offset(-12);
  }];

  self.pickedSongButton = [[UIButton alloc] init];
  [self.pickedSongButton
      setTitle:[NSString stringWithFormat:@"%@(%lu)", NELocalizedString(@"歌曲列表"),
                                          [NEListenTogetherPickSongEngine sharedInstance]
                                              .pickedSongArray.count]
      forState:UIControlStateNormal];
  [self.pickedSongButton setTitleColor:HEXCOLOR(0x999999) forState:UIControlStateNormal];
  [self.pickedSongButton addTarget:self
                            action:@selector(clickPickedButton:)
                  forControlEvents:UIControlEventTouchUpInside];
  self.pickedSongButton.titleLabel.font = [UIFont systemFontOfSize:16];
  [self.mainTopView addSubview:self.pickedSongButton];
  [self.pickedSongButton mas_makeConstraints:^(MASConstraintMaker *make) {
    make.centerY.equalTo(self.mainTopView);
    make.left.equalTo(self.mainTopView.mas_centerX).offset(12);
  }];

  self.lightLabel = [[UILabel alloc] init];
  self.lightLabel.backgroundColor = HEXCOLOR(0x337EFF);
  self.lightLabel.layer.cornerRadius = 2;
  self.lightLabel.layer.masksToBounds = YES;
  [self.mainTopView addSubview:self.lightLabel];
  [self.lightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.bottom.equalTo(self.mainTopView);
    make.height.equalTo(@2);
    make.width.equalTo(@19);
    make.centerX.equalTo(self.pickSongButton.mas_centerX);
  }];

  UILabel *topViewBottomLightLabel = [[UILabel alloc] init];
  topViewBottomLightLabel.backgroundColor = HEXCOLOR(0xE6E7EB);
  [self addSubview:topViewBottomLightLabel];
  [topViewBottomLightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(self.mainTopView.mas_bottom);
    make.height.equalTo(@1);
    make.left.right.equalTo(self);
  }];

  _pointButtonSelected = YES;

  // searchMain
  self.searchMainView = [[UIView alloc] init];
  [self addSubview:self.searchMainView];
  [self.searchMainView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(topViewBottomLightLabel.mas_bottom).offset(13);
    make.left.right.equalTo(self);
    make.height.equalTo(@48);
  }];

  self.searchSuperView = [[UIView alloc] init];
  self.searchSuperView.layer.masksToBounds = YES;
  self.searchSuperView.layer.cornerRadius = 16;
  self.searchSuperView.backgroundColor = HEXCOLOR(0xF2F3F5);
  [self.searchMainView addSubview:self.searchSuperView];
  [self.searchSuperView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.centerY.equalTo(self.searchMainView);
    make.left.equalTo(self.searchMainView).offset(20);
    make.right.equalTo(self.searchMainView).offset(-20);
    make.height.equalTo(@32);
  }];

  self.searchImageView =
      [[UIImageView alloc] initWithImage:[NEListenTogetherUI ne_listen_imageName:@"icon_search"]];
  [self.searchSuperView addSubview:self.searchImageView];
  [self.searchImageView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self.searchSuperView).offset(17);
    make.centerY.equalTo(self.searchSuperView);
    make.width.height.equalTo(@15);
  }];

  self.searchTextField = [[UITextField alloc] init];
  self.searchTextField.backgroundColor = [UIColor clearColor];
  NSAttributedString *attrString =
      [[NSAttributedString alloc] initWithString:NELocalizedString(@"搜索")
                                      attributes:@{
                                        NSForegroundColorAttributeName : HEXCOLOR(0x333333),
                                        NSFontAttributeName : [UIFont systemFontOfSize:16]
                                      }];

  self.searchTextField.attributedPlaceholder = attrString;
  if ([self.searchTextField respondsToSelector:@selector(setReturnKeyType:)]) {
    self.searchTextField.returnKeyType = UIReturnKeySearch;
  }
  self.searchTextField.delegate = self;
  self.searchTextField.textColor = HEXCOLOR(0x333333);
  [self.searchSuperView addSubview:self.searchTextField];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(textfieldDidChangeValue:)
                                               name:UITextFieldTextDidChangeNotification
                                             object:nil];
  [self.searchTextField mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self.searchImageView.mas_right).offset(8);
    make.right.equalTo(self.searchSuperView).offset(-25);
    make.top.bottom.equalTo(self.searchSuperView);
  }];

  self.searchClearButton = [[UIButton alloc] init];
  [self.searchSuperView addSubview:self.searchClearButton];
  [self.searchClearButton
      setBackgroundImage:[NEListenTogetherUI ne_listen_imageName:@"icon_search_cancel"]
                forState:UIControlStateNormal];
  self.searchClearButton.titleLabel.textAlignment = NSTextAlignmentCenter;
  self.searchClearButton.layer.masksToBounds = YES;
  self.searchClearButton.layer.cornerRadius = 8;
  [self.searchClearButton addTarget:self
                             action:@selector(clickSearchClearButton:)
                   forControlEvents:UIControlEventTouchUpInside];
  self.searchClearButton.hidden = YES;
  [self.searchClearButton mas_makeConstraints:^(MASConstraintMaker *make) {
    make.right.equalTo(self.searchSuperView).offset(-5);
    make.centerY.equalTo(self.searchSuperView);
    make.height.width.equalTo(@20);
  }];

  // picksongstableView
  self.pickSongsTableView = [[UITableView alloc] init];
  [self.pickSongsTableView registerClass:[NEListenTogetherPointSongTableViewCell class]
                  forCellReuseIdentifier:@"Identifier"];

  self.pickSongsTableView.delegate = self;
  self.pickSongsTableView.dataSource = self;
  self.pickSongsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
  self.pickSongsTableView.backgroundColor = [UIColor clearColor];
  [self addSubview:self.pickSongsTableView];
  [self.pickSongsTableView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(self.searchMainView.mas_bottom).offset(8);
    make.left.bottom.right.equalTo(self);
  }];

  // pickedSongsTableView
  self.pickedSongsTableView = [[UITableView alloc] init];
  [self.pickedSongsTableView registerClass:[NEListenTogetherPointedSongTableViewCell class]
                    forCellReuseIdentifier:@"Identifier2"];

  self.pickedSongsTableView.delegate = self;
  self.pickedSongsTableView.dataSource = self;
  self.pickedSongsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
  self.pickedSongsTableView.backgroundColor = [UIColor clearColor];
  [self addSubview:self.pickedSongsTableView];
  [self.pickedSongsTableView mas_makeConstraints:^(MASConstraintMaker *make) {
    //    make.top.equalTo(self.searchMainView.mas_bottom);
    make.top.equalTo(topViewBottomLightLabel.mas_bottom).offset(13);
    make.left.right.equalTo(self);
    make.bottom.equalTo(self).offset(-100);
  }];

  self.pickedSongsTableView.hidden = YES;

  /// 控制台
  [self addSubview:self.playControlView];
  [self.playControlView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.right.equalTo(self.pickedSongsTableView);
    make.top.equalTo(self.pickedSongsTableView.mas_bottom);
    make.bottom.equalTo(self);
  }];

  self.playControlView.hidden = YES;

  self.emptyView = [[NEListenTogetherSongEmptyView alloc] init];
  [self addSubview:self.emptyView];
  [self.emptyView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(topViewBottomLightLabel.mas_bottom);
    make.left.bottom.right.equalTo(self);
  }];

  self.emptyView.hidden = YES;

  @weakify(self);
  MJRefreshGifHeader *mjHeader = [MJRefreshGifHeader headerWithRefreshingBlock:^{
    @strongify(self);
    [self refreshList];
  }];
  [mjHeader setTitle:NELocalizedString(@"下拉更新") forState:MJRefreshStateIdle];
  [mjHeader setTitle:NELocalizedString(@"下拉更新") forState:MJRefreshStatePulling];
  [mjHeader setTitle:NELocalizedString(@"更新中...") forState:MJRefreshStateRefreshing];
  mjHeader.lastUpdatedTimeLabel.hidden = YES;
  [mjHeader setTintColor:[UIColor whiteColor]];
  self.pickSongsTableView.mj_header = mjHeader;

  self.pickSongsTableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
    @strongify(self);
    if ([NEListenTogetherPickSongEngine sharedInstance].noMore) {
      [NEListenTogetherToast showToast:NELocalizedString(@"无更多内容")];
      [self.pickSongsTableView.mj_footer endRefreshing];
    } else {
      [self loadMore];
    }
  }];
}

- (void)refreshList {
  [[NEListenTogetherPickSongEngine sharedInstance] updateSongArray];
  if (self.isSearching) {
    [NEListenTogetherPickSongEngine sharedInstance].searchPageNum = 0;
    [self getKaraokeSearchSongsList];
  } else {
    [NEListenTogetherPickSongEngine sharedInstance].pageNum = 0;
    [self getKaraokeSongsList];
  }
}

- (void)loadMore {
  if (self.isSearching) {
    [self getKaraokeSearchSongsList];
  } else {
    [self getKaraokeSongsList];
  }
}

- (void)getKaraokeSongsList {
  @weakify(self);
  [[NEListenTogetherPickSongEngine sharedInstance] getKaraokeSongList:^(NSError *_Nullable error) {
    if (error) {
      dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        [self.pickSongsTableView.mj_header endRefreshing];
        [self.pickSongsTableView.mj_footer endRefreshing];
        [NEListenTogetherToast showToast:NELocalizedString(@"获取歌曲列表失败")];
        if ([self.pickSongsTableView.refreshControl isRefreshing]) {
          [self.pickSongsTableView.refreshControl endRefreshing];
        }
      });
    } else {
      @strongify(self);
      @weakify(self);
      dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        [self.pickSongsTableView.mj_header endRefreshing];
        [self.pickSongsTableView.mj_footer endRefreshing];
        {
          if (self.pointButtonSelected) {
            self.emptyView.hidden = YES;
          } else {
            self.emptyView.hidden =
                [NEListenTogetherPickSongEngine sharedInstance].pickedSongArray.count;
          }
          [[NEListenTogetherPickSongEngine sharedInstance] updatePageNumber:NO];
          [self.pickSongsTableView reloadData];
          if ([self.pickSongsTableView.refreshControl isRefreshing]) {
            [self.pickSongsTableView.refreshControl endRefreshing];
          }
        }
      });
    }
  }];
}

// click 事件
- (void)clickPickButton:(UIButton *)sender {
  self.emptyView.hidden = YES;
  [self.pickSongButton setTitleColor:HEXCOLOR(0x222222) forState:UIControlStateNormal];
  [self.pickedSongButton setTitleColor:HEXCOLOR(0x999999) forState:UIControlStateNormal];
  [self.lightLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
    make.bottom.equalTo(self.mainTopView);
    make.height.equalTo(@2);
    make.width.equalTo(@19);
    make.centerX.equalTo(self.pickSongButton.mas_centerX);
  }];
  if (_pointButtonSelected != YES) {
    _pointButtonSelected = YES;
  }
  self.emptyView.hidden = YES;
  self.pickSongsTableView.hidden = NO;
  self.pickedSongsTableView.hidden = YES;
  self.playControlView.hidden = YES;
  self.searchMainView.hidden = NO;
}

- (void)clickPickedButton:(UIButton *)sender {
  [self.pickSongButton setTitleColor:HEXCOLOR(0x999999) forState:UIControlStateNormal];
  [self.pickedSongButton setTitleColor:HEXCOLOR(0x222222) forState:UIControlStateNormal];
  [self.lightLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
    make.bottom.equalTo(self.mainTopView);
    make.height.equalTo(@2);
    make.width.equalTo(@19);
    make.centerX.equalTo(self.pickedSongButton.mas_centerX);
  }];
  if (_pointButtonSelected != NO) {
    _pointButtonSelected = NO;
  }
  self.emptyView.hidden = YES;
  self.pickSongsTableView.hidden = YES;
  self.pickedSongsTableView.hidden = NO;
  self.playControlView.hidden =
      ![NEListenTogetherPickSongEngine sharedInstance].pickedSongArray.count;
  self.emptyView.hidden = [NEListenTogetherPickSongEngine sharedInstance].pickedSongArray.count;
  self.searchMainView.hidden = YES;
}
#pragma mark tableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  //    return 10;
  if (tableView == self.pickSongsTableView) {
    return [NEListenTogetherPickSongEngine sharedInstance].pickSongArray.count;
  } else {
    return [NEListenTogetherPickSongEngine sharedInstance].pickedSongArray.count;
  }
}
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (tableView == self.pickSongsTableView) {
    // 歌曲列表页面
    NEListenTogetherPointSongTableViewCell *cell =
        [tableView dequeueReusableCellWithIdentifier:@"Identifier" forIndexPath:indexPath];
    if ([NEListenTogetherPickSongEngine sharedInstance].pickSongArray.count <= indexPath.row) {
      return cell;
    }
    NEListenTogetherSongItem *item =
        [NEListenTogetherPickSongEngine sharedInstance].pickSongArray[indexPath.row];
    NSString *downlaodingStatus =
        [NEListenTogetherPickSongEngine sharedInstance].pickSongDownloadingArray[indexPath.row];
    if (item.songCover.length > 0) {
      [cell.songImageView sd_setImageWithURL:[NSURL URLWithString:item.songCover]];
    } else {
      cell.songImageView.image = [NEListenTogetherUI ne_listen_imageName:@"empty_song_cover"];
    }

    cell.songLabel.text = item.songName;
    cell.progress = item.downloadProcess;
    NECopyrightedSinger *singer = item.singers.firstObject;
    if (singer) {
      cell.anchorLabel.text =
          [NSString stringWithFormat:@"%@:%@", NELocalizedString(@"歌手"), singer.singerName];
    }
    if (item.channel == CLOUD_MUSIC) {
      cell.resourceImageView.image =
          [NEListenTogetherUI ne_listen_imageName:@"pointsong_clouldmusic"];
    } else if (item.channel == MIGU) {
      cell.resourceImageView.image = [NEListenTogetherUI ne_listen_imageName:@"pointsong_migu"];
    } else {
      //            cell.resourceImageView.image = [UIImage imageNamed:@"pointsong_noresource"];
    }
    if ([downlaodingStatus isEqualToString:@"0"]) {
      cell.statueBottomLabel.hidden = YES;
      cell.statueTopLabel.hidden = YES;
      cell.downloadingLabel.hidden = YES;
      cell.pointButton.hidden = NO;
    } else {
      cell.statueBottomLabel.hidden = NO;
      cell.statueTopLabel.hidden = NO;
      cell.downloadingLabel.hidden = NO;
      cell.pointButton.hidden = YES;
    }
    @weakify(cell);
    cell.clickPointButton = ^{
      @strongify(cell);
      NSString *logInfo = [NSString stringWithFormat:@"点击开始下载文件:%@", item.songId];
      [NEListenTogetherUILog successLog:ListenTogetherUILog desc:logInfo];

      {
        [[NEListenTogetherPickSongEngine sharedInstance].pickSongDownloadingArray
            replaceObjectAtIndex:indexPath.row
                      withObject:@"1"];
        cell.statueBottomLabel.hidden = NO;
        cell.statueTopLabel.hidden = NO;
        cell.downloadingLabel.hidden = NO;
        cell.pointButton.hidden = YES;
        NSString *viewLogInfo =
            [NSString stringWithFormat:@"点击开始下载文件,界面变更为下载中:%@", item.songId];
        [NEListenTogetherUILog successLog:ListenTogetherUILog desc:viewLogInfo];
        [[NEListenTogetherPickSongEngine sharedInstance].currentOrderSongArray addObject:item];
        NSString *downloadingLogInfo =
            [NSString stringWithFormat:@"点击开始下载文件,下载中列表数据变更:%@", item.songId];
        [NEListenTogetherUILog successLog:ListenTogetherUILog desc:downloadingLogInfo];
        [[NEListenTogetherPickSongEngine sharedInstance] preloadSong:item.songId
                                                             channel:item.channel];
      }
    };
    return cell;

  } else {
    NEListenTogetherOrderSongModel *item =
        [NEListenTogetherPickSongEngine sharedInstance].pickedSongArray[indexPath.row];
    NEListenTogetherPointedSongTableViewCell *cell =
        [tableView dequeueReusableCellWithIdentifier:@"Identifier2" forIndexPath:indexPath];
    if ([[NEListenTogetherPickSongEngine sharedInstance].currrentSongModel.playMusicInfo.songId
            isEqualToString:item.songId] &&
        [NEListenTogetherPickSongEngine sharedInstance]
                .currrentSongModel.playMusicInfo.oc_channel == item.oc_channel &&
        item.oc_status == 1) {
      cell.playingImageView.hidden = NO;
      cell.songNumberLabel.hidden = YES;
      cell.statueLabel.hidden = NO;
    } else {
      cell.playingImageView.hidden = YES;
      cell.songNumberLabel.hidden = NO;
      cell.statueLabel.hidden = YES;
    }
    cell.cancelButton.hidden = NO;
    cell.clickCancel = ^{
      // 点击取消
      [[NEListenTogetherKit getInstance]
          deleteSongWithOrderId:item.orderId
                       callback:^(NSInteger code, NSString *_Nullable msg, id _Nullable obj) {
                         if (code != 0) {
                           [NEListenTogetherToast
                               showToast:[NSString
                                             stringWithFormat:@"%@ %@",
                                                              NELocalizedString(@"删除歌曲失败"),
                                                              msg]];
                         }
                       }];
    };
    cell.songNumberLabel.text = [NSString stringWithFormat:@"%02d", (int)indexPath.row + 1];
    [cell.songIconImageView sd_setImageWithURL:[NSURL URLWithString:item.songCover]];
    cell.songNameLabel.text = [NSString stringWithFormat:@"%@ - %@", item.songName, item.singer];
    if (item.icon) {
      [cell.userIconImageView sd_setImageWithURL:[NSURL URLWithString:item.icon]];
    } else {
      [cell.userIconImageView
          setImage:[NEListenTogetherUI ne_listen_imageName:@"user_default_icon"]];
    }

    cell.userNickNameLabel.text = [NSString stringWithFormat:@"%@", item.userName];
    cell.songDurationLabel.hidden = NO;
    // duration暂时不做处理
    cell.songDurationLabel.text = [self formatSeconds:[item oc_songTime]];
    // 歌曲状态 -2 已唱 -1 删除 0:等待唱 1 唱歌中
    // 状态第一行直接显示正在演唱
    cell.statueLabel.text = NELocalizedString(@"正在播放");
    return cell;
  }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 68;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  if (tableView == self.pickedSongsTableView) {
    /// 已点列表
    NEListenTogetherOrderSongModel *item =
        [NEListenTogetherPickSongEngine sharedInstance].pickedSongArray[indexPath.row];
    if (self.delegate && [self.delegate respondsToSelector:@selector(nextSong:)]) {
      [self.delegate nextSong:item];
    }
  }
}
#pragma makr format sec
- (NSString *)formatSeconds:(NSInteger)milSeconds {
  long seconds = milSeconds / 1000;
  NSString *str_minute = [NSString stringWithFormat:@"%02ld", (seconds % 3600) / 60];
  NSString *str_second = [NSString stringWithFormat:@"%02ld", seconds % 60];
  return [NSString stringWithFormat:@"%@:%@", str_minute, str_second];
}

#pragma mark NEListenTogetherSongProtocol
- (void)onOrderSongRefresh {
  @weakify(self)[[NEListenTogetherPickSongEngine sharedInstance]
      getKaraokeSongOrderedList:^(NSError *_Nullable error) {
        @strongify(self) @weakify(self) dispatch_async(dispatch_get_main_queue(), ^{
          @strongify(self) if (error) {
            [NEListenTogetherToast showToast:NELocalizedString(@"获取已点列表失败")];
          }
          else {
            [self.pickedSongButton
                setTitle:[NSString stringWithFormat:@"%@(%lu)", NELocalizedString(@"歌曲列表"),
                                                    [NEListenTogetherPickSongEngine sharedInstance]
                                                        .pickedSongArray.count]
                forState:UIControlStateNormal];
            if (!self.pointButtonSelected) {
              self.emptyView.hidden =
                  [NEListenTogetherPickSongEngine sharedInstance].pickedSongArray.count;
              self.playControlView.hidden =
                  ![NEListenTogetherPickSongEngine sharedInstance].pickedSongArray.count;
            }
            [self.pickedSongsTableView reloadData];
          }
        });
      }];
}

- (void)cancelApply {
  self.currentOrderSong = nil;
}
- (void)applyFaile {
  self.currentOrderSong = nil;
}
- (void)applySuccess {
  //  [[NEListenTogetherPickSongEngine sharedInstance]
  //      applySuccessWithSong:self.currentOrderSong
  //                  complete:^{
  //                    [[NEListenTogetherPickSongEngine sharedInstance].currentOrderSongArray
  //                        addObject:self.currentOrderSong];
  //
  //                    [[NEListenTogetherKit getInstance] preloadSong:self.currentOrderSong.songId
  //                                                          observe:self];
  //                  }];
}

#pragma mark NESongPointProtocol
- (void)onSourceReloadIndex:(NSIndexPath *)index process:(float)progress {
  dispatch_async(dispatch_get_main_queue(), ^{
    if ([NEListenTogetherPickSongEngine sharedInstance].pickSongArray.count > index.row) {
      NEListenTogetherPointSongTableViewCell *cell =
          [self.pickSongsTableView cellForRowAtIndexPath:index];
      cell.progress = progress;
    } else {
      NSString *progressLogInfo =
          [NSString stringWithFormat:@"数据刷新导致目前列表中无下载数据,index:%@,\n progress:%.2f",
                                     index, progress];
      [NEListenTogetherUILog successLog:ListenTogetherUILog desc:progressLogInfo];
    }
  });
}
- (void)onSourceReloadIndex:(NSIndexPath *)index isSonsList:(BOOL)isSonsList {
  if (isSonsList) {
    dispatch_async(dispatch_get_main_queue(), ^{
      if ([NEListenTogetherPickSongEngine sharedInstance].pickSongArray.count > index.row) {
        NEListenTogetherPointSongTableViewCell *cell =
            [self.pickSongsTableView cellForRowAtIndexPath:index];
        cell.statueBottomLabel.hidden = YES;
        cell.statueTopLabel.hidden = YES;
        cell.downloadingLabel.hidden = YES;
        cell.pointButton.hidden = NO;
      }
    });
  }
}

- (void)onOrderSong:(NEListenTogetherOrderSongModel *)songModel error:(NSString *)errorMessage {
  if (errorMessage && errorMessage.length > 0) {
    [NEListenTogetherToast showToast:errorMessage];
  }
}

#pragma mark textFiledDelegate
- (void)textfieldDidChangeValue:(NSNotification *)notification {
  UITextField *textField = notification.object;
  if (textField.text.length > 0) {
    self.searchClearButton.hidden = NO;
  } else {
    self.searchClearButton.hidden = YES;
  }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  // 按下搜索
  // 收回键盘
  [self endEditing:YES];
  if (self.searchTextField.text.length <= 0) {
    return YES;
  }
  // 请求接口
  self.isSearching = YES;
  [[NEListenTogetherPickSongEngine sharedInstance] resetPageNumber];
  [[NEListenTogetherPickSongEngine sharedInstance] updateSongArray];
  [self getKaraokeSearchSongsList];
  return YES;
}
- (void)getKaraokeSearchSongsList {
  @weakify(self);
  [[NEListenTogetherPickSongEngine sharedInstance]
      getKaraokeSearchSongList:self.searchTextField.text
                      callback:^(NSError *_Nullable error) {
                        @strongify(self);
                        @weakify(self);
                        dispatch_async(dispatch_get_main_queue(), ^{
                          @strongify(self);
                          [self.pickSongsTableView.mj_header endRefreshing];
                          [self.pickSongsTableView.mj_footer endRefreshing];
                          if (error) {
                            if ([self.pickSongsTableView.refreshControl isRefreshing]) {
                              [self.pickSongsTableView.refreshControl endRefreshing];
                            }
                            [self.pickSongsTableView reloadData];
                            [NEListenTogetherToast
                                showToast:NELocalizedString(@"没有找到合适的结果")];
                          } else {
                            [[NEListenTogetherPickSongEngine sharedInstance] updatePageNumber:YES];
                            [self.pickSongsTableView reloadData];
                            if ([self.pickSongsTableView.refreshControl isRefreshing]) {
                              [self.pickSongsTableView.refreshControl endRefreshing];
                            }
                            if ([[NEListenTogetherPickSongEngine sharedInstance] pickSongArray]
                                    .count <= 0) {
                              [NEListenTogetherToast
                                  showToast:NELocalizedString(@"没有找到合适的结果")];
                            }
                          }
                        });
                      }];
}

- (void)clickSearchClearButton:(id)sender {
  self.searchTextField.text = @"";
  self.searchClearButton.hidden = YES;
  if (!self.isSearching) {
    [self endEditing:YES];
    return;
  }

  self.isSearching = NO;
  [[NEListenTogetherPickSongEngine sharedInstance] updateSongArray];
  [[NEListenTogetherPickSongEngine sharedInstance] resetPageNumber];
  [self refreshList];
}
- (void)dealloc {
  [[NEListenTogetherPickSongEngine sharedInstance] resetPageNumber];
  [[SDImageCache sharedImageCache] clearMemory];
}

- (void)onVoiceRoomSongTokenExpired {
  [NEListenTogetherToast showToast:NELocalizedString(@"版权token过期，请稍后再试")];
}

- (void)setPlayingStatus:(BOOL)status {
  self.playControlView.isPlaying = status;
}
/// 设置音量
- (void)setVolume:(float)volume {
  [self.playControlView setVolume:volume];
}

- (float)getVolume {
  return self.playControlView.volume;
}

#pragma mark---- Getter
- (NEListenTogetherSongPlayControlView *)playControlView {
  if (!_playControlView) {
    _playControlView = [[NEListenTogetherSongPlayControlView alloc] init];
    _playControlView.delegate = self;
  }
  return _playControlView;
}

#pragma mark---- NEListenTogetherSongPlayControlViewDelegate

- (void)pauseSong:(NEListenTogetherSongPlayControlView *)view {
  if (self.delegate && [self.delegate respondsToSelector:@selector(pauseSong)]) {
    [self.delegate pauseSong];
  }
}

- (void)resumeSong:(NEListenTogetherSongPlayControlView *)view {
  if (self.delegate && [self.delegate respondsToSelector:@selector(resumeSong)]) {
    [self.delegate resumeSong];
  }
}

- (void)nextSong:(NEListenTogetherSongPlayControlView *)view {
  if (self.delegate && [self.delegate respondsToSelector:@selector(nextSong:)]) {
    [self.delegate nextSong:nil];
  }
}

- (void)volumeChanged:(float)volume view:(NEListenTogetherSongPlayControlView *)view {
  if (self.delegate && [self.delegate respondsToSelector:@selector(volumeChanged:)]) {
    [self.delegate volumeChanged:volume];
  }
}

@end
