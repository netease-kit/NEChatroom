//
//  NTESMicQueueView.m
//  NEChatroom-iOS-ObjC
//
//  Created by Think on 2021/2/3.
//  Copyright © 2021 netease. All rights reserved.
//

#import "NTESMicQueueView.h"
#import "NTESChatroomMicCell.h"

@interface NTESMicQueueView ()

/// 麦位控件
@property (nonatomic, strong)   UICollectionView            *collectionView;
/// 主播控件
@property (nonatomic, strong)   NTESMicQueueCell            *anchorCell;
/// 语聊室布局
@property (nonatomic, strong)   UICollectionViewFlowLayout  *layout;

@end

@implementation NTESMicQueueView

@synthesize delegate = _delegate, anchorMicInfo = _anchorMicInfo, datas = _datas;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.anchorCell];
        [self addSubview:self.collectionView];
        
        @weakify(self);
        [RACObserve(self, datas) subscribeNext:^(id  _Nullable x) {
            @strongify(self);
            [self.collectionView reloadData];
        }];
    }
    return self;
}

- (void)layoutSubviews
{
    self.anchorCell.left = (self.width - self.anchorCell.width) * 0.5;
    [self.anchorCell layoutIfNeeded];
    CGFloat height = [self calculateHeightWithWidth:self.width];
    self.collectionView.frame = CGRectMake(0, self.anchorCell.bottom + 16, self.width, height);
}

- (void)updateCellWithMicInfo:(NTESMicInfo *)micInfo
{
    if (!micInfo) {
        return;
    }
    ntes_main_async_safe(^{
        NTESMicQueueCell *cell = [self cellWithMicOrder:micInfo.micOrder];
        [cell refresh:micInfo];
    });
}

- (CGFloat)calculateHeightWithWidth:(CGFloat)width
{
    CGSize size = [NTESChatroomMicCell size];
    CGFloat paddingH = [NTESChatroomMicCell cellPaddingH];
    return 2 * size.height + paddingH + size.height + 16;
}

- (NTESMicQueueCell *)cellWithMicOrder:(NSInteger)micOrder
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:micOrder-1 inSection:0];
    NTESMicQueueCell *cell = (NTESMicQueueCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    return cell;
}

- (void)startSoundAnimation:(NSInteger)micOrder
                     volume:(NSInteger)volume
{
    NTESMicQueueCell *cell = [self cellWithMicOrder:micOrder];
    [cell startSoundAnimationWithValue:volume];
}

- (void)stopSoundAnimation:(NSInteger)micOrder
{
    NTESMicQueueCell *cell = [self cellWithMicOrder:micOrder];
    [cell stopSoundAnimation];
}

#pragma mark - getter/setter

- (void)setAnchorMicInfo:(NTESMicInfo *)anchorMicInfo
{
    if (!anchorMicInfo) {
        return;
    }
    _anchorMicInfo = anchorMicInfo;
    _anchorMicInfo.userInfo.isAnchor = YES;
    [self.anchorCell refresh:_anchorMicInfo];
}

#pragma mark - NTESMicQueueCellDelegate

- (void)onConnectBtnPressedWithMicInfo:(NTESMicInfo *)micInfo
{
    if (_delegate
        && [_delegate respondsToSelector:@selector(micQueueConnectBtnPressedWithMicInfo:)]) {
        [_delegate micQueueConnectBtnPressedWithMicInfo:micInfo];
    }
}

#pragma mark - UICollectionView delegate

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _datas.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_datas count] > indexPath.row) {
        NTESMicInfo *data = _datas[indexPath.row];
        NTESMicQueueCell *cell = [NTESChatroomMicCell cellWithCollectionView:self.collectionView data:data indexPath:indexPath];
        cell.delegate = self;
        
        return cell;
    }
    return [NTESMicQueueCell new];
}

#pragma mark - lazy load

- (NTESMicQueueCell *)anchorCell
{
    if (!_anchorCell) {
        CGSize size = [NTESChatroomMicCell size];
        _anchorCell = [[NTESChatroomMicCell alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    }
    return _anchorCell;
}

- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:self.layout];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.dataSource = self;
        _collectionView.delegate   = self;
        _collectionView.bounces = NO;
//        _collectionView.clipsToBounds = NO;
        [_collectionView registerClass:[NTESChatroomMicCell class] forCellWithReuseIdentifier:[NTESChatroomMicCell description]];
    }
    return _collectionView;
}

- (UICollectionViewFlowLayout *)layout
{
    if (!_layout) {
        _layout = [[UICollectionViewFlowLayout alloc] init];
        _layout.minimumInteritemSpacing = 0.1f;
        _layout.minimumInteritemSpacing = 0.1f;
        _layout.itemSize = [NTESChatroomMicCell size];
        _layout.minimumInteritemSpacing = [NTESChatroomMicCell cellPaddingH];
        _layout.minimumLineSpacing = [NTESChatroomMicCell cellPaddingW];
    }
    return _layout;
}

@end
