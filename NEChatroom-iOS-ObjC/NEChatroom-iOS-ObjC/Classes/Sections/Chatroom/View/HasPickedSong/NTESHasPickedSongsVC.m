//
//  NTESHasPickedSongsVC.m
//  NEChatroom-iOS-ObjC
//
//  Created by Think on 2021/2/3.
//  Copyright © 2021 netease. All rights reserved.
//

#import "NTESHasPickedSongsVC.h"
#import "NTESHasPickedSongCell.h"
#import "NTESChatroomDataSource.h"
#import "NTESChatroomQueueHelper.h"
#import "NTESPickMusicService.h"
#import "NTESListEmptyView.h"

@interface NTESHasPickedSongsVC () <UITableViewDelegate, UITableViewDataSource, NTESHasPickedSongCellDelegate>

/// 数据源
@property (nonatomic, strong)   NTESPickMusicService        *service;
/// 显示控件
@property (nonatomic, strong)   UITableView                 *tableView;
/// 空数据视图
@property (nonatomic, strong)   NTESListEmptyView           *emptyView;

@end

@implementation NTESHasPickedSongsVC

- (instancetype)initWithService:(NTESPickMusicService *)service
{
    self = [super init];
    if (self) {
        _service = service;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self _buildView];
    [self _bindEvent];
    [self.tableView reloadData];
}

- (void)_buildView
{
    self.view.backgroundColor = [UIColor whiteColor];
    NSArray *songs = _service.pickSongs;
    self.title = [NSString stringWithFormat:@"已点歌曲(%zd)", [songs count]];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back_ico_16"] style:UIBarButtonItemStylePlain target:self action:@selector(_back)];
    self.navigationItem.leftBarButtonItem = backItem;
    
    CGSize size = [self preferredContentSize];
    self.tableView.frame = CGRectMake(0, 0, size.width, size.height - kSafeAreaHeight);
    [self.view addSubview:self.tableView];
    
    self.emptyView.frame = CGRectMake((self.tableView.width - 100) * 0.5, 80, 100, 114);
    [self.tableView addSubview:self.emptyView];
}

- (CGSize)preferredContentSize
{
    CGFloat preferedHeight = UIScreenHeight * 0.7 + kSafeAreaHeight;
    return CGSizeMake(UIScreenWidth, preferedHeight);
}

- (void)_bindEvent
{
    @weakify(self);
    [RACObserve(self.service, pickSongs) subscribeNext:^(NSMutableArray<NTESQueueMusic *>  *arr) {
        ntes_main_async_safe(^{
            @strongify(self);
            self.title = [NSString stringWithFormat:@"已点歌曲(%zd)", [arr count]];
            [self.tableView reloadData];
            self.emptyView.hidden = [arr count] > 0;
        });
    }];
}

- (void)_back
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableView delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *songs = _service.pickSongs;
    return [songs count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [NTESHasPickedSongCell height];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *songs = _service.pickSongs;
    NSDictionary *avgs = @{@"service": _service ?: @""};
    NTESHasPickedSongCell *cell = [NTESHasPickedSongCell cellWithTableView:tableView datas:songs indexPath:indexPath avgs:avgs];
    cell.delegate = self;
    
    return cell;
}

#pragma mark - NTESHasPickedSongCellDelegate

- (void)didCancelPickedMusic:(NTESQueueMusic *)music
{
    [_service cancelPickedSong:music successBlock:^(NTESQueueMusic * _Nonnull music) {
        YXAlogInfo(@"取消点歌成功, music: %@", music);
    } failedBlock:^(NSError * _Nullable error, NSDictionary<NSString *,NSString *> * _Nullable element) {
        YXAlogInfo(@"取消点歌失败, error: %@, element: %@", error, element);
    }];
}

#pragma mark - lazy load

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 68;
        _tableView.showsVerticalScrollIndicator = NO;
        [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [_tableView registerClass:[NTESHasPickedSongCell class] forCellReuseIdentifier:[NTESHasPickedSongCell description]];
    }
    return _tableView;
}

- (NTESListEmptyView *)emptyView
{
    if (!_emptyView) {
        _emptyView = [[NTESListEmptyView alloc] init];
        _emptyView.msg = @"还没有人点歌哦";
    }
    return _emptyView;
}

@end
