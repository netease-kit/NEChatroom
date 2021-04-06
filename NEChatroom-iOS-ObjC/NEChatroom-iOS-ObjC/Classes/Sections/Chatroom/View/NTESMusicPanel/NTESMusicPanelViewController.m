//
//  NTESMusicPanelViewController.m
//  NEChatroom-iOS-ObjC
//
//  Created by Wenchao Ding on 2021/1/26.
//  Copyright © 2021 netease. All rights reserved.
//

#import "NTESMusicPanelViewController.h"
#import "NTESLyricView.h"
#import "NTESChatroomDefine.h"
#import "NTESCustomAttachment.h"
#import "UIImage+NTES.h"
#import "NTESPickSongVC.h"
#import "NTESCustomNotificationHelper.h"
#import "NTESActionSheetNavigationController.h"
#import "NTESMusicPanelLyricLoader.h"
#import "NTESQueueMusic.h"
#import <NERtcSDK/NERtcSDK.h>
#import "NTESQueueMusic.h"
#import "NTESMusicConsoleViewController.h"
#import "UIView+Toast.h"
#import "NTESRtcConfig.h"
#import "NTESChatroomQueueHelper.h"

static void *KVOContext = &KVOContext;

@interface NTESMusicPanelViewController ()

// 无人点歌
@property (nonatomic, strong) UIView *emptyView;

// 暂时无人点歌
@property (nonatomic, strong) UILabel *emptyTitleLabel;

// 唱歌时请佩戴耳机避免回音
@property (nonatomic, strong) UILabel *emptyTipLabel;

// 我要点歌
@property (nonatomic, strong) UIButton *selectMusicButton;

// 歌曲
@property (nonatomic, strong) UIView *playingView;

// 背景
@property (nonatomic, strong) UIImageView *backgroundView;

// 背景图上层遮罩
@property (nonatomic, strong) UIView *lyricBackgroundMask;

// 调音台
@property (nonatomic, strong) UIButton *musicConsoleButton;

// 切歌
@property (nonatomic, strong) UIButton *switchNextButton;

// 暂停
@property (nonatomic, strong) UIButton *pauseButton;

// 播放
@property (nonatomic, strong) UIButton *playButton;

// 暂停中区域
@property (nonatomic, strong) UIView *pauseMask;

// 继续播放
@property (nonatomic, strong) UIButton *resumeButton;

// 歌曲名（左上角）
@property (nonatomic, strong) UIButton *musicNameButton;

// 下一首
@property (nonatomic, strong) UILabel *nextMusicNameLabel;

// 歌词
@property (nonatomic, strong) NTESLyricView *lyricView;

// 上下文
@property (nonatomic, strong) NTESChatroomDataSource *context;

// 准备
@property (nonatomic, strong) UIView *prepareView;

// 头像
@property (nonatomic, strong) UIImageView *singerImageView;

// xxx请准备
@property (nonatomic, strong) UILabel *singerTipLabel;

// x秒后播放
@property (nonatomic, strong) UILabel *tickLabel;

// 歌曲名(准备)
@property (nonatomic, strong) UILabel *musicNameLabel;

// 歌词加载器
@property (nonatomic, strong) NTESMusicPanelLyricLoader *lyricLoader;

// 当前歌曲
@property (nonatomic, strong) NTESQueueMusic *currentMusic;

// 下一首歌曲
@property (nonatomic, strong) NTESQueueMusic *nextMusic;

// 我是否是演唱者
@property (nonatomic, assign, readonly) BOOL isSingerOfCurrentMusic;

// 调音台
- (void)musicConsoleAction:(UIButton *)sender;

// 暂停
- (void)pauseAction:(UIButton *)sender;

// 恢复
- (void)resumeAction:(UIButton *)sender;

// 切歌
- (void)switchNextAction:(UIButton *)sender;

// 我要点歌
- (void)selectMusicAction:(UIButton *)sender;

// 切歌
- (void)topMusicDidChange:(NSNotification *)notification;

// 歌曲队列变化
- (void)musicQueueDidChange:(NSNotification *)notification;

// 歌曲播放/暂停
- (void)musicStatusDidChange:(NSNotification *)notification;

// 根据上下文变化改变UI状态
- (void)updateUIState;

// 播放当前歌曲
- (void)playCurrentMusic;

@end

@implementation NTESMusicPanelViewController

- (instancetype)initWithContext:(NTESChatroomDataSource *)context {
    self = [super init];
    if (self) {
        self.context = context;
        self.lyricLoader = [[NTESMusicPanelLyricLoader alloc] init];
    }
    return self;
}

- (void)loadView {
    UIView *view = [[UIView alloc] initWithFrame:UIScreen.mainScreen.bounds];
    view.clipsToBounds = YES;
    view.layer.cornerRadius = 6;
    self.view = view;
    // 背景图
    self.backgroundView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    self.backgroundView.image = [UIImage imageNamed:@"lyric_bg.jpg"];
    [self.view addSubview:self.backgroundView];
    // 播放区域
    self.playingView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.playingView];
    // 背景图上方遮罩
    self.lyricBackgroundMask = [[UIView alloc] initWithFrame:CGRectZero];
    self.lyricBackgroundMask.backgroundColor = [UIColor colorWithRed:34/255.0 green:26/255.0 blue:51/255.0 alpha:1.0];
    [self.backgroundView addSubview:self.lyricBackgroundMask];
    // 歌词
    self.lyricView = [[NTESLyricView alloc] initWithFrame:CGRectZero];
    [self.playingView addSubview:self.lyricView];
    // 歌曲名
    self.musicNameButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.musicNameButton.enabled = NO;
    self.musicNameButton.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail; // 省略号
    self.musicNameButton.titleLabel.font = [UIFont systemFontOfSize:12];
    self.musicNameButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft; // 居左
    self.musicNameButton.titleEdgeInsets = UIEdgeInsetsMake(0, 3, 0, 0);
    self.musicNameButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 3);
    [self.musicNameButton setImage:[UIImage imageNamed:@"icon_music_panel_music"] forState:UIControlStateNormal];
    [self.musicNameButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [self.playingView addSubview:self.musicNameButton];
    // 下一首
    self.nextMusicNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.nextMusicNameLabel.font = [UIFont systemFontOfSize:12];
    self.nextMusicNameLabel.textColor = UIColor.whiteColor;
    self.nextMusicNameLabel.lineBreakMode = NSLineBreakByTruncatingTail; // 省略号
    self.nextMusicNameLabel.textAlignment = NSTextAlignmentRight; // 居右
    [self.playingView addSubview:self.nextMusicNameLabel];
    // 暂停遮罩
    self.pauseMask = [[UIView alloc] initWithFrame:CGRectZero];
    self.pauseMask.backgroundColor = [UIColor colorWithRed:34/255.0 green:26/255.0 blue:51/255.0 alpha:0.3];
    self.pauseMask.hidden = YES;
    [self.playingView addSubview:self.pauseMask];
    // 继续播放
    self.resumeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.resumeButton.clipsToBounds = YES;
    self.resumeButton.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    self.resumeButton.layer.cornerRadius = 14;
    self.resumeButton.titleLabel.font = [UIFont systemFontOfSize:14];
    self.resumeButton.contentEdgeInsets = UIEdgeInsetsMake(5, 12, 5, 12);
    self.resumeButton.imageEdgeInsets = UIEdgeInsetsMake(0, -2, 0, 2);
    self.resumeButton.titleEdgeInsets = UIEdgeInsetsMake(0, 2, 0, -2);
    [self.resumeButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [self.resumeButton setTitle:@"继续播放" forState:UIControlStateNormal];
    [self.resumeButton addTarget:self action:@selector(resumeAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.pauseMask addSubview:self.resumeButton];
    // 调音台
    self.musicConsoleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.musicConsoleButton.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    self.musicConsoleButton.clipsToBounds = YES;
    self.musicConsoleButton.layer.cornerRadius = 14;
    [self.musicConsoleButton setImage:[UIImage imageNamed:@"icon_music_panel_music_console"] forState:UIControlStateNormal];
    [self.musicConsoleButton addTarget:self action:@selector(musicConsoleAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.playingView addSubview:self.musicConsoleButton];
    // 暂停
    self.pauseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.pauseButton.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    self.pauseButton.clipsToBounds = YES;
    self.pauseButton.layer.cornerRadius = 14;
    [self.pauseButton setImage:[UIImage imageNamed:@"icon_music_panel_pause"] forState:UIControlStateNormal];
    [self.pauseButton addTarget:self action:@selector(pauseAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.playingView addSubview:self.pauseButton];
    // 播放
    self.playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.playButton.hidden = YES;
    self.playButton.clipsToBounds = YES;
    self.playButton.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    self.playButton.layer.cornerRadius = 14;
    [self.playButton setImage:[UIImage imageNamed:@"icon_music_panel_play"] forState:UIControlStateNormal];
    [self.playButton addTarget:self action:@selector(resumeAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.playButton];
    // 切歌
    self.switchNextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.switchNextButton.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    self.switchNextButton.clipsToBounds = YES;
    self.switchNextButton.layer.cornerRadius = 14;
    [self.switchNextButton setImage:[UIImage imageNamed:@"icon_music_panel_next"] forState:UIControlStateNormal];
    [self.switchNextButton addTarget:self action:@selector(switchNextAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.playingView addSubview:self.switchNextButton];
    
    // 无人点歌区域
    self.emptyView = [[UIView alloc] initWithFrame:CGRectZero];
    self.emptyView.backgroundColor = [UIColor colorWithRed:54/255.0 green:54/255.0 blue:77/255.0 alpha:1.0];
    [self.view addSubview:self.emptyView];
    // 暂时无人点歌
    self.emptyTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.emptyTitleLabel.textColor = UIColor.whiteColor;
    self.emptyTitleLabel.font = [UIFont systemFontOfSize:16];
    self.emptyTitleLabel.text = @"暂时无人点歌";
    [self.emptyTitleLabel sizeToFit];
    [self.emptyView addSubview:self.emptyTitleLabel];
    // 唱歌时请佩戴耳机避免回音
    self.emptyTipLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.emptyTipLabel.textColor = [UIColor colorWithWhite:1 alpha:0.5];
    self.emptyTipLabel.font = [UIFont systemFontOfSize:14];
    self.emptyTipLabel.text = @"唱歌时请佩戴耳机避免回音";
    [self.emptyTipLabel sizeToFit];
    [self.emptyView addSubview:self.emptyTipLabel];
    // 我要点歌
    self.selectMusicButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.selectMusicButton.clipsToBounds = YES;
    self.selectMusicButton.layer.cornerRadius = 16;
    self.selectMusicButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.selectMusicButton setBackgroundImage:[UIImage ne_imageWithColor:UIColor.whiteColor] forState:UIControlStateNormal];
    [self.selectMusicButton setTitleColor:[UIColor colorWithRed:34/255.0 green:34/255.0 blue:34/255.0 alpha:1.0] forState:UIControlStateNormal];
    [self.selectMusicButton setTitle:@"我要点歌" forState:UIControlStateNormal];
    [self.selectMusicButton addTarget:self action:@selector(selectMusicAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.emptyView addSubview:self.selectMusicButton];
    
    // 准备区域
    self.prepareView = [[UIView alloc] initWithFrame:CGRectZero];
    self.prepareView.hidden = YES;
    [self.view addSubview:self.prepareView];
    // 准备区域用户头像
    self.singerImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.singerImageView.clipsToBounds = YES;
    self.singerImageView.layer.cornerRadius = 25;
    self.singerImageView.layer.borderWidth = 1;
    self.singerImageView.layer.borderColor = UIColor.whiteColor.CGColor;
    [self.prepareView addSubview:self.singerImageView];
    // xxx请准备
    self.singerTipLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.singerTipLabel.textAlignment = NSTextAlignmentCenter;
    self.singerTipLabel.font = [UIFont systemFontOfSize:14];
    self.singerTipLabel.textColor = UIColor.whiteColor;
    [self.prepareView addSubview:self.singerTipLabel];
    // x秒后播放
    self.tickLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.tickLabel.textAlignment = NSTextAlignmentCenter;
    self.tickLabel.font = [UIFont systemFontOfSize:14];
    self.tickLabel.textColor = UIColor.whiteColor;
    [self.prepareView addSubview:self.tickLabel];
    // 《歌曲名》
    self.musicNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.musicNameLabel.textAlignment = NSTextAlignmentCenter;
    self.musicNameLabel.font = [UIFont systemFontOfSize:16];
    self.musicNameLabel.textColor = UIColor.whiteColor;
    self.musicNameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [self.prepareView addSubview:self.musicNameLabel];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.context.pickService addObserver:self forKeyPath:@"musicPosition" options:NSKeyValueObservingOptionNew context:KVOContext];
    [self.context addObserver:self forKeyPath:@"userMode" options:NSKeyValueObservingOptionNew context:KVOContext];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(topMusicDidChange:) name:kChatroomKtvTopMusicChanged object:nil]; // 顶部歌曲变化通知
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(musicQueueDidChange:) name:kChatroomKtvMusicQueueChanged object:nil]; // 顶部歌曲变化通知
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(musicStatusDidChange:) name:kNTESChatroomPauseMusicNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(musicStatusDidChange:) name:kNTESChatroomResumeMusicNotification object:nil];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    // 播放区域
    self.playingView.frame = self.view.bounds;
    self.backgroundView.frame = self.playingView.bounds;
    self.lyricBackgroundMask.frame = self.backgroundView.bounds;
    CGFloat lyricHeight = 26 * 5.0;
    self.lyricView.frame = CGRectMake(0, self.view.bounds.size.height/2.0-lyricHeight/2.0, self.view.bounds.size.width, lyricHeight);
    self.musicConsoleButton.frame = CGRectMake(8, self.view.bounds.size.height-4-28, 28, 28);
    self.pauseButton.frame = CGRectOffset(self.musicConsoleButton.frame, 28+8, 0);
    self.playButton.frame = self.pauseButton.frame;
    self.switchNextButton.frame = CGRectOffset(self.pauseButton.frame, 28+8, 0);
    self.pauseMask.frame = self.view.bounds;
    self.resumeButton.center = CGPointMake(self.pauseMask.bounds.size.width/2.0, self.pauseMask.bounds.size.height/2.0);
    self.musicNameButton.frame = CGRectMake(8, 8, self.playingView.bounds.size.width/2.0-8-8, 18);
    self.nextMusicNameLabel.frame = CGRectMake(self.playingView.bounds.size.width/2.0+4, 8, self.playingView.bounds.size.width/2.0-8-8, 18);
    
    // 无人点歌区域
    self.emptyView.frame = self.view.bounds;
    self.emptyTitleLabel.center = CGPointMake(self.emptyView.bounds.size.width/2.0, 50+self.emptyTitleLabel.intrinsicContentSize.height/2.0);
    self.emptyTipLabel.center = CGPointMake(self.emptyView.bounds.size.width/2.0, CGRectGetMaxY(self.emptyTitleLabel.frame)+8+self.emptyTipLabel.intrinsicContentSize.height/2.0);
    self.selectMusicButton.frame = CGRectMake(self.emptyView.bounds.size.width/2.0-96/2.0, CGRectGetMaxY(self.emptyTipLabel.frame)+32, 96, 32);
    
    // 准备区域
    self.prepareView.frame = self.view.bounds;
    self.singerImageView.frame = CGRectMake(self.playingView.frame.size.width/2.0-25, 40, 50, 50);
    self.singerTipLabel.frame = CGRectMake(8, CGRectGetMaxY(self.singerImageView.frame)+8, self.prepareView.frame.size.width-16, 22);
    self.tickLabel.frame = CGRectMake(8, CGRectGetMaxY(self.singerTipLabel.frame)+8, self.prepareView.frame.size.width-16, 22);
    self.musicNameLabel.frame = CGRectMake(8, CGRectGetMaxY(self.tickLabel.frame)+8, self.prepareView.frame.size.width-16, 24);
}

- (void)dealloc {
    [self.context.pickService removeObserver:self forKeyPath:@"musicPosition" context:KVOContext];
    [self.context removeObserver:self forKeyPath:@"userMode" context:KVOContext];
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (CGSize)preferredContentSize {
    return CGSizeMake(359, 220);
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (context != KVOContext) {
        return [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
    if ([keyPath isEqualToString:@"musicPosition"]) {
        NTESPickMusicService *service = self.context.pickService;
        self.lyricView.currentTime = service.musicPosition/1000.0;
    } else if ([keyPath isEqualToString:@"userMode"]) {
        [self updateUIState];
    }
}

- (void)switchNextAction:(UIButton *)sender {
    sender.enabled = NO;
    [self.context.pickService removeTopMusicWithSuccessBlock:^(NTESQueueMusic * _Nonnull music) {
        sender.enabled = YES;
    } failedBlock:^(NSError * _Nullable error, NSDictionary<NSString *,NSString *> * _Nullable element) {
        YXAlogInfo(@"Error switch music: %@", error.localizedDescription);
        sender.enabled = YES;
    }];
}

- (void)musicConsoleAction:(UIButton *)sender {
    NTESMusicConsoleViewController *console = [[NTESMusicConsoleViewController alloc] initWithContext:self.context];
    NTESActionSheetNavigationController *nav = [[NTESActionSheetNavigationController alloc] initWithRootViewController:console];
    nav.dismissOnTouchOutside = YES;
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)pauseAction:(UIButton *)sender {
    if (self.currentMusic.status == 1) {
        return;
    }
    self.currentMusic.status = 1;
    self.currentMusic.timestamp = self.context.pickService.musicPosition;
    [NTESChatroomQueueHelper updateQueueMusic:self.currentMusic roomId:self.context.chatroom.roomId completion:^(NSError * _Nullable error) {
        if (error) {
            self.currentMusic.status = 0;
            return NELPLogError(@"Error pause music: %@", error);
        }
        NSString *me = self.context.myAccountInfo.nickName?:self.context.myAccountInfo.account;
        [NTESChatroomMessageHelper sendCustomMessage:self.context.chatroom.roomId type:NTESVoiceChatAttachmentTypePauseMusic operator:me error:&error];
        if (error) {
            return NELPLogError(@"Error pause music: %@", error);
        }
        [NSNotificationCenter.defaultCenter postNotificationName:kNTESChatroomPauseMusicNotification object:nil userInfo:@{kNTESChatroomPauseMusicOperatorUserInfoKey: me}];
    }];
    
}

- (void)resumeAction:(UIButton *)sender {
    if (self.currentMusic.status == 0) {
        return;
    }
    self.currentMusic.status = 0;
    [NTESChatroomQueueHelper updateQueueMusic:self.currentMusic roomId:self.context.chatroom.roomId completion:^(NSError * _Nullable error) {
        if (error) {
            self.currentMusic.status = 1;
            return NELPLogError(@"Error pause music: %@", error);
        }
        NSString *me = self.context.myAccountInfo.nickName?:self.context.myAccountInfo.account;
        [NTESChatroomMessageHelper sendCustomMessage:self.context.chatroom.roomId type:NTESVoiceChatAttachmentTypeResumeMusic operator:me error:&error];
        if (error) {
            return NELPLogError(@"Error resume music: %@", error);
        }
        [NSNotificationCenter.defaultCenter postNotificationName:kNTESChatroomResumeMusicNotification object:nil userInfo:@{kNTESChatroomResumeMusicOperatorUserInfoKey: me}];
    }];
}

- (void)selectMusicAction:(UIButton *)sender {
    NTESPickSongVC *pickSongVc = [[NTESPickSongVC alloc] initWithService:self.context.pickService];
    NTESActionSheetNavigationController *nav = [[NTESActionSheetNavigationController alloc] initWithRootViewController:pickSongVc];
    nav.dismissOnTouchOutside = YES;
     [self presentViewController:nav animated:YES completion:nil];
}

- (void)musicQueueDidChange:(NSNotification *)notification {
    if (self.currentMusic && !self.isSingerOfCurrentMusic) { // 正在唱歌中，歌曲队列变化后需要更新“下一首”图标
        if (self.nextMusic) {
            self.nextMusicNameLabel.hidden = NO;
            self.nextMusicNameLabel.text = [NSString stringWithFormat:@"下一首:%@", self.nextMusic.musicName];
        } else {
            self.nextMusicNameLabel.hidden = YES;
        }
    }
}

- (void)topMusicDidChange:(NSNotification *)notification {
    int ret = [NERtcEngine.sharedEngine stopAudioMixing];
    if (ret != kNERtcNoError && ret != kNERtcErrInvalidState) {
         return NELPLogError(@"Error pausing music: %@",NERtcErrorDescription(ret));
    }
    self.context.pickService.musicPosition = 0;
    if (self.currentMusic.countTimeSec > 0) {
        [self showPrepareView]; // 准备界面
    } else {
        [self updateUIState]; // 显示无人点歌界面
        if (self.currentMusic) {
            [self playCurrentMusic];
        }
    }
}

- (void)musicStatusDidChange:(NSNotification *)notification {
    if (self.isSingerOfCurrentMusic) {
        BOOL isPause = self.currentMusic.status == 1;
        int ret = isPause ? [NERtcEngine.sharedEngine pauseAudioMixing] : [NERtcEngine.sharedEngine resumeAudioMixing];
        if (ret != kNERtcNoError) {
            NELPLogError(@"Error pause music: %@", NERtcErrorDescription(ret));
        }
    }
    [self updateUIState];
}

- (void)updateUIState {
    if (!self.currentMusic) { // 没有歌曲
        self.emptyView.hidden = NO;
        self.playingView.hidden = YES;
    } else {
        self.emptyView.hidden = YES;
        self.playingView.hidden = NO;
        self.prepareView.hidden = YES;
        if (self.isSingerOfCurrentMusic) {
            // 演唱者
            self.lyricBackgroundMask.alpha = 0.8;
            self.musicNameButton.hidden = YES;
            self.nextMusicNameLabel.hidden = YES;
        } else {
            // 非演唱者
            self.lyricBackgroundMask.alpha = 0.3;
            self.musicNameButton.hidden = NO;
            self.nextMusicNameLabel.hidden = NO;
            [self.musicNameButton setTitle:self.currentMusic.musicName forState:UIControlStateNormal];
            self.nextMusicNameLabel.hidden = !self.nextMusic;
            if (self.nextMusic) {
                self.nextMusicNameLabel.hidden = NO;
                self.nextMusicNameLabel.text = [NSString stringWithFormat:@"下一首:%@", self.nextMusic.musicName];
            } else {
                self.nextMusicNameLabel.hidden = YES;
            }
        }
        if (self.context.userMode == NTESUserModeAnchor || self.isSingerOfCurrentMusic) {
            // 主播和演唱者显示控制区域
            self.pauseButton.hidden = self.currentMusic.status == 1;
            self.playButton.hidden = !self.pauseButton.hidden;
            self.switchNextButton.hidden = self.context.userMode != NTESUserModeAnchor && !self.isSingerOfCurrentMusic; // 不是房主且不是当前演唱者，隐藏
            self.musicConsoleButton.hidden = NO;
            
            self.resumeButton.enabled = YES;
            [self.resumeButton setTitle:@"继续播放" forState:UIControlStateNormal];
            [self.resumeButton setImage:[UIImage imageNamed:@"icon_music_panel_play"] forState:UIControlStateNormal];
            
        } else {
            self.pauseButton.hidden = YES;
            self.playButton.hidden = YES;
            self.switchNextButton.hidden = YES;
            self.musicConsoleButton.hidden = YES;
            
            self.resumeButton.enabled = NO;
            [self.resumeButton setTitle:@"暂停中" forState:UIControlStateNormal];
            [self.resumeButton setImage:nil forState:UIControlStateNormal];
            
        }
        self.pauseMask.hidden = self.currentMusic.status != 1;
        CGPoint center = self.resumeButton.center;
        [self.resumeButton sizeToFit];
        self.resumeButton.center = center;
    }
}

- (NTESQueueMusic *)currentMusic {
    return self.context.pickService.pickSongs.firstObject;
}

- (NTESQueueMusic *)nextMusic {
    return self.context.pickService.pickSongs.count > 1 ? self.context.pickService.pickSongs[1] : nil;
}

- (void)showPrepareView {
    self.emptyView.hidden = YES;
    self.playingView.hidden = YES;
    self.prepareView.hidden = NO;
    if (self.currentMusic.userAvatar) {
        [self.singerImageView yy_setImageWithURL:[NSURL URLWithString:self.currentMusic.userAvatar] options:YYWebImageOptionProgressiveBlur];
    }
    self.musicNameLabel.text = [NSString stringWithFormat:@"《%@》",self.currentMusic.musicName];
    self.singerTipLabel.text = [NSString stringWithFormat:@"%@ 请准备", self.currentMusic.userNickname?:self.currentMusic.userId];
    self.tickLabel.text = [NSString stringWithFormat:@"3秒后播放"];
    // 不想写timer，代码到处都是，太乱了
    // 没法用timer的block，因为要支持iOS9
    NSTimeInterval countdown = self.currentMusic.countTimeSec;
    for (int i = 1; i < countdown; i++) { // 1,2
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(i * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.tickLabel.text = [NSString stringWithFormat:@"%@秒后播放", @(countdown-i)]; // 2,1
            
            if (self.isSingerOfCurrentMusic) {
                self.currentMusic.countTimeSec = countdown - i;
                [NTESChatroomQueueHelper updateQueueMusic:self.currentMusic roomId:self.context.chatroomInfo.roomId completion:^(NSError * _Nullable error) {
                    YXAlogInfo(@"更新歌曲倒计时, second:%d, error: %@", self.currentMusic.countTimeSec, error);
                }];
            }
        });
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(countdown * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.prepareView.hidden = YES;
        [self updateUIState];
        [self playCurrentMusic];
        if (self.isSingerOfCurrentMusic) {
            self.currentMusic.countTimeSec = 0;
            [NTESChatroomQueueHelper updateQueueMusic:self.currentMusic roomId:self.context.chatroomInfo.roomId completion:^(NSError * _Nullable error) {
                YXAlogInfo(@"更新歌曲倒计时, second:0, error: %@", error);
            }];
        }
    });
}

- (void)playCurrentMusic {
    if (self.isSingerOfCurrentMusic) {
        NERtcCreateAudioMixingOption *opt = [[NERtcCreateAudioMixingOption alloc] init];
        opt.path = self.currentMusic.musicUrl;
        opt.sendVolume = self.context.rtcConfig.audioMixingVolume;
        opt.playbackVolume = self.context.rtcConfig.audioMixingVolume;
        opt.loopCount = 1;
        int ret = [NERtcEngine.sharedEngine startAudioMixingWithOption:opt];
        if (ret != kNERtcNoError) {
            return NELPLogError(@"Error start audio mixing: %@", NERtcErrorDescription(ret));
        }
    }
    
    NSURL *URL = [NSURL URLWithString:self.currentMusic.musicLyricUrl];
    if (!URL) {
        YXAlogInfo(@"Error musicLyricUrl is %@",self.currentMusic.musicLyricUrl);
    }
    __weak typeof(self) wself = self;
    wself.lyricView.hidden = YES;
    [self.lyricLoader loadWithURL:URL completion:^(NSString *content) {
        wself.lyricView.frames = [NTESLyricFrame arrayWithContents:content];
        wself.lyricView.hidden = NO;
        wself.lyricView.currentTime = wself.currentMusic.timestamp/1000.0;
    }];
}

- (BOOL)isSingerOfCurrentMusic {
    return [self.currentMusic.userId isEqualToString:NIMSDK.sharedSDK.loginManager.currentAccount];
}

@end
