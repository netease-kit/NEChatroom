//
//  NTESBackgroundMusicViewController.m
//  NEChatroom-iOS-ObjC
//
//  Created by Wenchao Ding on 2021/1/29.
//  Copyright © 2021 netease. All rights reserved.
//

#import "NTESBackgroundMusicViewController.h"
#import "NTESBackgroundMusic.h"
#import <NERtcSDK/NERtcSDK.h>
#import <AVFoundation/AVFoundation.h>

@interface NTESBackgroundMusicViewController () <UITableViewDataSource,UITableViewDelegate>

// 列表
@property (nonatomic, strong) UITableView *tableView;

// 单元格总和
@property (nonatomic, copy) NSArray<UITableViewCell *> *cells;

// 高度
@property (nonatomic, copy) NSArray<NSNumber *> *heights;

// 音效1
@property (nonatomic, strong) UIButton *effect1Button;

// 音效2
@property (nonatomic, strong) UIButton *effect2Button;

// 伴音名称
@property (nonatomic, copy) NSArray<NSString *> *backgroundMusicNames;

// 伴音
@property (nonatomic, copy) NSArray<NTESBackgroundMusic *> *backgroundMusics;

// 音效音量
@property (nonatomic, assign) uint32_t currVolume;

// 点击音效
- (void)effectAction:(UIButton *)sender;

@end

@implementation NTESBackgroundMusicViewController

- (void)loadView {
    UIView *view = [[UIView alloc] initWithFrame:self.navigationController.view.bounds];
    view.backgroundColor = UIColor.whiteColor;
    self.view = view;
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.scrollEnabled = NO;
    self.tableView.allowsSelection = NO;
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 20, 0, 20);
    self.tableView.clipsToBounds = YES;
    self.tableView.separatorColor = [UIColor.lightGrayColor colorWithAlphaComponent:0.4];
    [self.view addSubview:self.tableView];
    
    UIView *tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 60)];
    CGFloat buttonWidth = (self.tableView.frame.size.width - 20.0*2 - 12)/2.0;
    // 音效1
    self.effect1Button = [UIButton buttonWithType:UIButtonTypeCustom];
    self.effect1Button.frame = CGRectMake(20, 12, buttonWidth, tableHeaderView.frame.size.height-12*2.0);
    self.effect1Button.tag = 1;
    self.effect1Button.clipsToBounds = YES;
    self.effect1Button.layer.cornerRadius = 6;
    self.effect1Button.backgroundColor = [UIColor colorWithRed:242/255.0 green:243/255.0 blue:245/255.0 alpha:1.0];
    [self.effect1Button setImage:[UIImage imageNamed:@"icon_effect_applaud"] forState:UIControlStateNormal];
    [self.effect1Button addTarget:self action:@selector(effectAction:) forControlEvents:UIControlEventTouchUpInside];
    [tableHeaderView addSubview:self.effect1Button];
    // 音效2
    self.effect2Button = [UIButton buttonWithType:UIButtonTypeCustom];
    self.effect2Button.frame = CGRectMake(20+buttonWidth+12, 12, buttonWidth, tableHeaderView.frame.size.height-12*2.0);
    self.effect2Button.tag = 2;
    self.effect2Button.clipsToBounds = YES;
    self.effect2Button.layer.cornerRadius = 6;
    self.effect2Button.backgroundColor = [UIColor colorWithRed:242/255.0 green:243/255.0 blue:245/255.0 alpha:1.0];
    [self.effect2Button setImage:[UIImage imageNamed:@"icon_effect_laugh"] forState:UIControlStateNormal];
    [self.effect2Button addTarget:self action:@selector(effectAction:) forControlEvents:UIControlEventTouchUpInside];
    [tableHeaderView addSubview:self.effect2Button];
    self.tableView.tableHeaderView = tableHeaderView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.backgroundMusicNames = @[@"1",@"2"];
}

- (void)dealloc {
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
}

- (CGSize)preferredContentSize {
    CGFloat preferedHeight = 0;
    if (@available(iOS 11.0, *)) {
        CGFloat safeAreaBottom = UIApplication.sharedApplication.delegate.window.safeAreaInsets.bottom;
        preferedHeight += safeAreaBottom;
    }
    preferedHeight += [[self.heights valueForKeyPath:@"@sum.self"] doubleValue];
    preferedHeight += 20;
    return CGSizeMake(self.navigationController.view.bounds.size.width, preferedHeight);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.backgroundMusics.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)effectAction:(UIButton *)sender {
    [[NERtcEngine sharedEngine] stopAllEffects];
    uint32_t eid = (uint32_t)sender.tag;
    NSString *fileName = [NSString stringWithFormat:@"audio_effect_%ld", sender.tag];
    NERtcCreateAudioEffectOption *opt = [[NERtcCreateAudioEffectOption alloc] init];
    opt.path = [NSBundle.mainBundle pathForResource:fileName ofType:@"wav"];
    opt.playbackVolume = _currVolume;
    opt.sendVolume = _currVolume;
    opt.loopCount = 1;
    [[NERtcEngine sharedEngine] playEffectWitdId:eid effectOption:opt];
}

- (NSArray<NTESBackgroundMusic *> *)backgroundMusics {
    if (!self.backgroundMusicNames) {
        return nil;
    }
    if (!_backgroundMusics) {
        NSMutableArray *array = NSMutableArray.array;
        for (NSString *name in self.backgroundMusicNames) {
            NTESBackgroundMusic *music = [[NTESBackgroundMusic alloc] init];
            NSURL *fileURL = [NSBundle.mainBundle URLForResource:name withExtension:@"mp3"];
            AVURLAsset *asset = [AVURLAsset URLAssetWithURL:fileURL options:nil];
            AVMetadataItem *title = [AVMetadataItem metadataItemsFromArray:asset.commonMetadata withKey:AVMetadataCommonKeyTitle keySpace:AVMetadataKeySpaceCommon].firstObject;
            music.title = (NSString *)title.value;
            AVMetadataItem *artist = [AVMetadataItem metadataItemsFromArray:asset.commonMetadata withKey:AVMetadataCommonKeyArtist keySpace:AVMetadataKeySpaceCommon].firstObject;
            music.artist = (NSString *)artist.value;
            AVMetadataItem *albumName = [AVMetadataItem metadataItemsFromArray:asset.commonMetadata withKey:AVMetadataCommonKeyAlbumName keySpace:AVMetadataKeySpaceCommon].firstObject;
            music.albumName = (NSString *)albumName.value;
            [array addObject:music];
            _backgroundMusics = [NSArray arrayWithArray:array];
        }
    }
    return _backgroundMusics;
}

@end
