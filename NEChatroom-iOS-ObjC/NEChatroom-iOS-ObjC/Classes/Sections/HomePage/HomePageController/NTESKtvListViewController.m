//
//  NTESKtvLiveRoomListViewController.m
//  NEChatroom-iOS-ObjC
//
//  Created by vvj on 2021/2/3.
//  Copyright © 2021 netease. All rights reserved.
//

#import "NTESKtvListViewController.h"
#import "NTESOpenRoomViewController.h"
#import "NTESLiveRoomViewController.h"


#import "NETSEmptyListView.h"
#import "NETSLiveListCell.h"

#import "NETSLiveListViewModel.h"
#import "NTESDataCenter.h"

@interface NTESKtvListViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIButton *createLiveRoomButton;
@property (nonatomic, strong) NETSEmptyListView *emptyView;
@property (nonatomic, strong) NETSLiveListViewModel *liveListViewModel;
@property (nonatomic, assign) BOOL hasEntered;

@end

@implementation NTESKtvListViewController


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.hasEntered) {
        [self ntes_getNewData];
    }
    self.hasEntered = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}



- (void)ntes_getNewData {
    [NTESProgressHUD ntes_show];
    [self.liveListViewModel loadNewDataWithLiveType:NTESCreateRoomTypeKTV];
}

- (void)ntes_bindViewModel {
    @weakify(self);
    [RACObserve(self.liveListViewModel, datas) subscribeNext:^(NSArray *array) {
        @strongify(self);
        [NTESProgressHUD ntes_dismiss];
        [self.collectionView reloadData];
        self.emptyView.hidden = [array count] > 0;
    }];
    
    [RACObserve(self.liveListViewModel, isLoading) subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        if (self.liveListViewModel.isLoading == NO) {
            [self.collectionView.mj_header endRefreshing];
            [self.collectionView.mj_footer endRefreshing];
        }
    }];
    
    [RACObserve(self.liveListViewModel, error) subscribeNext:^(NSError * _Nullable err) {
        if (!err) { return; }
        if (err.code == 1003) {
            [NTESProgressHUD ntes_showInfo:@"直播列表为空"];

        } else {
            NSString *msg = err.userInfo[NSLocalizedDescriptionKey] ?: @"请求直播列表错误";
            [NTESProgressHUD ntes_showInfo:msg];

        }
    }];
}

- (void)ntes_addSubViews {
    [self.view addSubview:self.collectionView];
    [self.view addSubview:self.createLiveRoomButton];
    
    self.emptyView.centerX = self.collectionView.centerX;
    self.emptyView.centerY = self.collectionView.centerY-40;
    [self.collectionView addSubview:self.emptyView];
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.view);
        make.height.mas_equalTo(UIScreenHeight-[NTESDeviceSizeInfo get_iPhoneNavBarHeight]);
    }];
    
    [self.createLiveRoomButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(90, 90));
        make.right.equalTo(self.view).offset(-20);
        make.bottom.equalTo(self.view).offset(-[NTESDeviceSizeInfo get_iPhoneTabBarHeight]);
    }];
    
    @weakify(self);
    MJRefreshGifHeader *mjHeader = [MJRefreshGifHeader headerWithRefreshingBlock:^{
        @strongify(self);
        [self.liveListViewModel loadNewDataWithLiveType:NTESCreateRoomTypeKTV];
    }];
    [mjHeader setTitle:@"下拉更新" forState:MJRefreshStateIdle];
    [mjHeader setTitle:@"下拉更新" forState:MJRefreshStatePulling];
    [mjHeader setTitle:@"更新中..." forState:MJRefreshStateRefreshing];
    mjHeader.lastUpdatedTimeLabel.hidden = YES;
    [mjHeader setTintColor:[UIColor whiteColor]];
    self.collectionView.mj_header = mjHeader;
    
    self.collectionView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        @strongify(self);
        if (self.liveListViewModel.isEnd) {
            [NTESProgressHUD ntes_showInfo:@"无更多内容"];
            [self.collectionView.mj_footer endRefreshing];
        } else {
            [self.liveListViewModel loadMoreWithLiveType:NTESCreateRoomTypeKTV];
        }
    }];
}


//开始直播
- (void)createChatRoomAction {
    NTESOpenRoomViewController *chatRoomCtrl = [[NTESOpenRoomViewController alloc] initWithRoomType:NTESCreateRoomTypeKTV];
    [self.navigationController pushViewController:chatRoomCtrl animated:YES];
}

#pragma mark - UICollectionView delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.liveListViewModel.datas count];

}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{

    
    return [NETSLiveListCell cellWithCollectionView:collectionView
                                          indexPath:indexPath
                                              datas:self.liveListViewModel.datas];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{

    if ([self.liveListViewModel.datas count] > indexPath.row) {
        NTESChatroomInfo *roomInfoModel = self.liveListViewModel.datas[indexPath.row];
        NTESLiveRoomViewController *vc = [[NTESLiveRoomViewController alloc]initWithChatroomInfo:roomInfoModel accountInfo:[NTESDataCenter shareCenter].myAccount userMode:NTESUserModeAudience pushType:roomInfoModel.pushType roomType:roomInfoModel.roomType];
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}

#pragma mark - lazy load

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = [NETSLiveListCell size];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        layout.minimumInteritemSpacing = 8;
        layout.minimumLineSpacing = 8;
        layout.sectionInset = UIEdgeInsetsMake(8, 8, 8, 8);
        
        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        _collectionView.backgroundColor = UIColor.whiteColor;
        [_collectionView registerClass:[NETSLiveListCell class] forCellWithReuseIdentifier:[NETSLiveListCell description]];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsVerticalScrollIndicator = NO;
        if (@available(iOS 11.0, *)) {
            _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return _collectionView;
}

- (UIButton *)createLiveRoomButton {
    if (!_createLiveRoomButton) {
        _createLiveRoomButton = [NTESViewFactory createBtnFrame:CGRectZero title:@"" bgImage:@"start_toLive_icon" selectBgImage:@"" image:@"" target:self action:@selector(createChatRoomAction)];
//        _createLiveRoomButton.enabled = NO;
    }
    return _createLiveRoomButton;
}

- (NETSEmptyListView *)emptyView
{
    if (!_emptyView) {
        _emptyView = [[NETSEmptyListView alloc] initWithFrame:CGRectZero];
        _emptyView.tintColor = UIColorFromRGB(0xE6E7EB);
    }
    return _emptyView;
}

- (NETSLiveListViewModel *)liveListViewModel {
    if (!_liveListViewModel) {
        _liveListViewModel = [[NETSLiveListViewModel alloc]init];
    }
    return _liveListViewModel;
}
@end
