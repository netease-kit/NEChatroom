//
//  NTESPickSongVC.m
//  NEChatroom-iOS-ObjC
//
//  Created by Think on 2021/2/1.
//  Copyright © 2021 netease. All rights reserved.
//

#import "NTESPickSongVC.h"
#import "NTESPickSongModel.h"
#import "NTESChatroomApi.h"
#import "NTESPickSongCell.h"
#import "NTESAccountInfo.h"
#import "NTESChatroomQueueHelper.h"
#import "NTESHasPickedSongsVC.h"
#import "NTESPickMusicService.h"
#import "NTESMicInfo.h"
#import <MJRefresh/MJRefresh.h>
#import "NTESListEmptyView.h"

@interface NTESPickSongVC () <UITableViewDelegate, UITableViewDataSource, NTESPickSongCellDelegate>

/// 数据源
@property (nonatomic, strong)   NTESPickMusicService            *service;

/// 点歌容器
@property (nonatomic, strong)   UITableView                     *tableView;
/// 数据集合
@property (nonatomic, strong)   NSArray<NTESPickSongModel *>    *datas;
/// 左标题
@property (nonatomic, strong)   UILabel                         *titleLab;
/// 右标题
@property (nonatomic, strong)   UILabel                         *rightLab;
/// 空数据视图
@property (nonatomic, strong)   NTESListEmptyView               *emptyView;

@property (nonatomic, assign)   int32_t                         offset;
@property (nonatomic, assign)   int32_t                         limit;
@property (nonatomic, assign)   BOOL                            isLoading;
@property (nonatomic, assign)   BOOL                            isEnd;
@property (nonatomic, assign)   NSError                         *error;

@end

@implementation NTESPickSongVC

- (instancetype)initWithService:(NTESPickMusicService *)service
{
    self = [super init];
    if (self) {
        _service = service;
        _offset = 0;
        _limit = 20;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self _buildView];
    [self _bindEvent];
    [self _load];
}

- (void)_buildView
{
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.tableView];
    CGSize size = [self preferredContentSize];
    self.tableView.frame = CGRectMake(0, 0, size.width, size.height - kSafeAreaHeight);
    
    self.titleLab.frame = CGRectMake(0, 0, 40, 20);
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:self.titleLab];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    self.rightLab.frame = CGRectMake(0, 0, 100, 20);
    self.rightLab.attributedText = [self _rightBarAttriTitleWithNum:[_service.pickSongs count]];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:self.rightLab];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    self.emptyView.frame = CGRectMake((self.tableView.width - 100) * 0.5, 80, 100, 114);
    [self.tableView addSubview:self.emptyView];
}

- (CGSize)preferredContentSize
{
    CGFloat preferedHeight = UIScreenHeight * 0.7 + kSafeAreaHeight;
    return CGSizeMake(UIScreenWidth, preferedHeight);
}

#pragma mark - private methods

- (void)_bindEvent
{
    @weakify(self);
    [RACObserve(self, datas) subscribeNext:^(NSArray  * _Nullable x) {
        @strongify(self);
        [self.tableView reloadData];
        self.emptyView.hidden = [x count] > 0;
    }];
    [RACObserve(self.service, pickSongs) subscribeNext:^(NSArray *x) {
        @strongify(self);
        NSInteger count = [x count];
        ntes_main_async_safe(^{
            self.rightLab.attributedText = [self _rightBarAttriTitleWithNum:count];
        });
    }];
    [RACObserve(self, isLoading) subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        if (!self.isLoading) {
            [self.tableView.mj_header endRefreshing];
            [self.tableView.mj_footer endRefreshing];
        }
    }];
    [RACObserve(self, error) subscribeNext:^(NSError * _Nullable err) {
        if (!err) { return; }
        NSString *msg = err.userInfo[NSLocalizedDescriptionKey] ?: @"获取歌单失败";
        [NTESProgressHUD ntes_showError:msg];
    }];
    
    MJRefreshGifHeader *mjHeader = [MJRefreshGifHeader headerWithRefreshingBlock:^{
        @strongify(self);
        self.offset = 0;
        [self _load];
    }];
    [mjHeader setTitle:@"下拉更新" forState:MJRefreshStateIdle];
    [mjHeader setTitle:@"下拉更新" forState:MJRefreshStatePulling];
    [mjHeader setTitle:@"更新中..." forState:MJRefreshStateRefreshing];
    mjHeader.lastUpdatedTimeLabel.hidden = YES;
    self.tableView.mj_header = mjHeader;
    
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        @strongify(self);
        if (self.isEnd) {
            [self.tableView.mj_footer endRefreshing];
            [NTESProgressHUD ntes_showInfo:@"无更多内容"];
            return;
        }
        [self _loadMore];
    }];
}

- (void)_load
{
    _offset = 0;
    _isLoading = YES;
    
    [NTESProgressHUD ntes_show];
    [NTESChatroomApi fetchMusicListWithPageLimit:_limit pageOffset:_offset successBlock:^(NSDictionary * _Nonnull response) {
        [NTESProgressHUD ntes_dismiss];
        NTESPickSongList *data = response[@"/data"];
        self.datas = data.list;
        
        self.isLoading = NO;
        self.error = nil;
        self.isEnd = ([self.datas count] >= data.total);
    } errorBlock:^(NSError * _Nonnull error, NSDictionary * _Nullable response) {
        [NTESProgressHUD ntes_dismiss];
        self.isLoading = NO;
        self.error = error;
    }];
}

- (void)_loadMore
{
    if (_isEnd) { return; }
    _offset += _limit;
    _isLoading = YES;
    
    [NTESProgressHUD ntes_show];
    [NTESChatroomApi fetchMusicListWithPageLimit:20 pageOffset:_offset successBlock:^(NSDictionary * _Nonnull response) {
        [NTESProgressHUD ntes_dismiss];
        NTESPickSongList *data = response[@"/data"];
        if ([data.list count] > 0) {
            NSMutableArray *tmp = [NSMutableArray arrayWithArray:self.datas];
            [tmp addObjectsFromArray:data.list];
            self.datas = [tmp copy];
        }
        
        self.isLoading = NO;
        self.error = nil;
        self.isEnd = ([self.datas count] >= data.total);
    } errorBlock:^(NSError * _Nonnull error, NSDictionary * _Nullable response) {
        [NTESProgressHUD ntes_dismiss];
        self.isLoading = NO;
        self.error = error;
    }];
}

- (NSAttributedString *)_rightBarAttriTitleWithNum:(NSInteger)num
{
    NSDictionary *norDic = @{
        NSForegroundColorAttributeName: UIColorFromRGB(0x222222),
        NSFontAttributeName: [UIFont systemFontOfSize:14]
    };
    NSDictionary *stressDic = @{
        NSForegroundColorAttributeName: UIColorFromRGB(0x337EFF),
        NSFontAttributeName: [UIFont systemFontOfSize:14]
    };
    NSMutableAttributedString *res = [[NSMutableAttributedString alloc] initWithString:@"已点" attributes:norDic];
    NSString *str = [NSString stringWithFormat:@"%ld", (long)num];
    NSAttributedString *numStr = [[NSAttributedString alloc] initWithString:str attributes:stressDic];
    [res appendAttributedString:numStr];
    NSAttributedString *tail = [[NSAttributedString alloc] initWithString:@"首" attributes:norDic];
    [res appendAttributedString:tail];
    
    NSTextAttachment *attchment = [[NSTextAttachment alloc]init];
    attchment.bounds = CGRectMake(0, -3, 14, 14);
    attchment.image = [UIImage imageNamed:@"right_narrow_ico"];
    NSAttributedString *icoStr = [NSAttributedString attributedStringWithAttachment:attchment];
    [res appendAttributedString:icoStr];
    
    return [res copy];
}

- (void)_showPickedSongsVC
{
    NTESHasPickedSongsVC *vc = [[NTESHasPickedSongsVC alloc] initWithService:_service];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - NTESPickSongCellDelegate

- (void)didClickPickSong:(NTESPickSongModel *)song
{
    if (_service.userMode != NTESUserModeAudience) {
        [_service pickMusic:song successBlock:^{
            YXAlogInfo(@"成功点歌, song: %@", song);
        } failedBlock:^(NSError * _Nullable error) {
            NSString *msg = error.userInfo[NSLocalizedDescriptionKey] ?: @"点歌失败";
            [NTESProgressHUD ntes_showInfo:msg];
        }];
    } else {
        [NTESProgressHUD ntes_showInfo:@"上麦后才能点歌"];
    }
}

#pragma mark - UITableView delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_datas count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [NTESPickSongCell height];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_datas count] > indexPath.row) {
        NTESPickSongModel *data = _datas[indexPath.row];
        NTESPickSongCell *cell = [NTESPickSongCell cellWithTableView:tableView data:data indexPath:indexPath];
        cell.delegate = self;
        return cell;
    }
    return [UITableViewCell new];
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
        [_tableView registerClass:[NTESPickSongCell class] forCellReuseIdentifier:[NTESPickSongCell description]];
    }
    return _tableView;
}

- (UILabel *)titleLab
{
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
        _titleLab.textColor = UIColorFromRGB(0x222222);
        _titleLab.text = @"点歌";
    }
    return _titleLab;
}

- (UILabel *)rightLab
{
    if (!_rightLab) {
        _rightLab = [[UILabel alloc] init];
        _rightLab.font = [UIFont systemFontOfSize:14];
        _rightLab.textAlignment = NSTextAlignmentRight;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_showPickedSongsVC)];
        _rightLab.userInteractionEnabled = YES;
        [_rightLab addGestureRecognizer:tap];
    }
    return _rightLab;
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
