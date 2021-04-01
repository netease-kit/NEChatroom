//
//  NTESMoreViewController.m
//  NEChatroom-iOS-ObjC
//
//  Created by Wenchao Ding on 2021/1/26.
//  Copyright © 2021 netease. All rights reserved.
//

#import "NTESMoreViewController.h"
#import "NTESMoreItem.h"
#import "NTESMoreCell.h"
#import "NTESMusicConsoleViewController.h"
#import "NTESActionSheetNavigationController.h"
#import "NTESBackgroundMusicViewController.h"
#import "NTESRtcConfig.h"
#import "UIView+Toast.h"
#import <NIMSDK/NIMSDK.h>
#import <NERtcSDK/NERtcSDK.h>

@interface NTESMoreViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

// 设置项视图
@property (nonatomic, strong) UICollectionView *collectionView;

// 布局
@property (nonatomic, strong)  UICollectionViewFlowLayout *flowLayout;

// 全部数据源
@property (nonatomic, copy) NSArray<NTESMoreItem *> *allItems;

// 当前角色的数据源
@property (nonatomic, copy) NSArray<NTESMoreItem *> *items;

// 上下文
@property (nonatomic, strong) NTESChatroomDataSource *context;

@end

@implementation NTESMoreViewController

- (instancetype)initWithContext:(NTESChatroomDataSource *)context {
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
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.minimumLineSpacing = 16;
    layout.itemSize = CGSizeMake(60, 84);
    layout.sectionInset = UIEdgeInsetsMake(16, 30, 16, 30);
    self.flowLayout = layout;
        
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    self.collectionView.backgroundColor = UIColor.clearColor;
    self.collectionView.scrollEnabled = NO;
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    [self.collectionView registerClass:NTESMoreCell.class forCellWithReuseIdentifier:@"cell"];
    [self.view addSubview:self.collectionView];
    
    [self.navigationItem.backBarButtonItem setTitleTextAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14]} forState:UIControlStateNormal];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"更多";
    self.allItems = @[
        [NTESMoreItem itemWithTitle:@"麦克风" onImage:[UIImage imageNamed:@"icon_more_mic_on"] offImage:[UIImage imageNamed:@"icon_more_mic_off"] tag: 0],
//        [NTESMoreItem itemWithTitle:@"扬声器" onImage:[UIImage imageNamed:@"icon_more_speaker_on"] offImage:[UIImage imageNamed:@"icon_more_speaker_off"] tag:1],
        [NTESMoreItem itemWithTitle:@"耳返" onImage:[UIImage imageNamed:@"icon_more_earback_on"] offImage:[UIImage imageNamed:@"icon_more_earback_off"] tag:2],
        [NTESMoreItem itemWithTitle:@"调音台" onImage:[UIImage imageNamed:@"icon_more_music_console"] offImage:nil tag:3],
        [NTESMoreItem itemWithTitle:@"伴音" onImage:[UIImage imageNamed:@"icon_more_accompaniment_sound"] offImage:nil tag:4],
        [NTESMoreItem itemWithTitle:@"结束直播" onImage:[UIImage imageNamed:@"icon_more_close_live"] offImage:nil tag:5]
    ];
    self.allItems[0].on = self.context.rtcConfig.micOn;
//    self.allItems[1].on = self.context.rtcConfig.speakerOn;
    self.allItems[1].on = self.context.rtcConfig.earbackOn;
    // 根据不同身份给出不同数据源
    switch (self.context.userMode) {
        case NTESUserModeAnchor: {
            self.items = self.allItems; // 房主有全部选项
            break;
        }
        case NTESUserModeConnector: {
            self.items = [self.allItems subarrayWithRange:NSMakeRange(0, 3)]; // 连麦者有3个选项
            break;
        }
        case NTESUserModeAudience: {
//            self.items = [self.allItems subarrayWithRange:NSMakeRange(1, 1)]; // 普通观众只有扬声器选项
            self.items = @[]; // 普通观众暂时看不到弹窗
            break;
        }
    }
}

- (void)dealloc {
    self.collectionView.dataSource = nil;
    self.collectionView.delegate = nil;
}

- (CGSize)preferredContentSize {
    CGFloat preferedHeight = 0;
    if (@available(iOS 11.0, *)) {
        CGFloat safeAreaBottom = UIApplication.sharedApplication.delegate.window.safeAreaInsets.bottom;
        preferedHeight += safeAreaBottom;
    }
    CGFloat preferredWidth = self.navigationController.view.frame.size.width;
    NSInteger itemsPerLine = (preferredWidth-self.flowLayout.sectionInset.left-self.flowLayout.sectionInset.right)/self.flowLayout.itemSize.width;
    CGFloat lineCount = self.items.count/itemsPerLine + (self.items.count % itemsPerLine > 0 ? 1 : 0);
    preferedHeight += lineCount * self.flowLayout.itemSize.height;
    preferedHeight += self.flowLayout.sectionInset.top;
    preferedHeight += self.flowLayout.sectionInset.bottom;
    preferedHeight += (lineCount-1) * self.flowLayout.minimumLineSpacing;
    return CGSizeMake(preferredWidth, preferedHeight);
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.items.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NTESMoreCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.imageView.image = self.items[indexPath.item].currentImage;
    cell.textLabel.text = self.items[indexPath.item].title;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NTESMoreItem *item = self.items[indexPath.row];
    switch (item.tag) {
        case 0: { // 麦克风
            item.on = !item.on;
            self.context.rtcConfig.micOn = item.on;
            [UIView performWithoutAnimation:^{
                [collectionView reloadItemsAtIndexPaths:@[indexPath]];
            }];
            if (_delegate && [_delegate respondsToSelector:@selector(didSetMicOn:)]) {
                [_delegate didSetMicOn:item.on];
            }
            break;
        }
        case 1: { // 扬声器
            item.on = !item.on;
            self.context.rtcConfig.speakerOn = item.on;
            [UIView performWithoutAnimation:^{
                [collectionView reloadItemsAtIndexPaths:@[indexPath]];
            }];
            break;
        }
        case 2: { // 耳返
            item.on = !item.on;
            self.context.rtcConfig.earbackOn = item.on;
            [UIView performWithoutAnimation:^{
                [collectionView reloadItemsAtIndexPaths:@[indexPath]];
            }];
            break;
        }
        case 3: { // 调音台
            NTESMusicConsoleViewController *musicConsole = [[NTESMusicConsoleViewController alloc] initWithContext:self.context];
            NTESActionSheetNavigationController *nav = [[NTESActionSheetNavigationController alloc] initWithRootViewController:musicConsole];
            nav.dismissOnTouchOutside = YES;
            UIViewController *lastVC = self.presentingViewController;
            [lastVC dismissViewControllerAnimated:YES completion:^{
                [lastVC presentViewController:nav animated:YES completion:nil];
            }];
            break;
        }
        case 4: { // 伴音
            NTESBackgroundMusicViewController *vc = [[NTESBackgroundMusicViewController alloc] initWithContext:self.context];
            NTESActionSheetNavigationController *nav = [[NTESActionSheetNavigationController alloc] initWithRootViewController:vc];
            nav.dismissOnTouchOutside = YES;
            UIViewController *lastVC = self.presentingViewController;
            [lastVC dismissViewControllerAnimated:YES completion:^{
                [lastVC presentViewController:nav animated:YES completion:nil];
            }];
            break;
        }
        case 5: { // 结束直播
            UINavigationController *nav = (UINavigationController *)self.presentingViewController;
            [NIMSDK.sharedSDK.chatroomManager exitChatroom:self.context.chatroom.roomId completion:^(NSError * _Nullable error) {
                if (error) {
                    [nav.view.window makeToast:error.localizedDescription];
                    [nav popViewControllerAnimated:YES];
                    return;
                }
                int ret = [NERtcEngine.sharedEngine leaveChannel];
                NSError *outError = ret == 0 ? nil : [NSError errorWithDomain:NSBundle.mainBundle.bundleIdentifier code:ret userInfo:@{NSLocalizedDescriptionKey: NERtcErrorDescription(ret)}];
                if (outError) {
                    [self.view.window makeToast:outError.localizedDescription];
                }
                [self dismissViewControllerAnimated:YES completion:^{
                    [nav popViewControllerAnimated:YES];
                }];
            }];
            break;
        }
        default:
            break;
    }
}

@end
