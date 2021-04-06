//
//  NTESKtvMicQueueView.m
//  NEChatroom-iOS-ObjC
//
//  Created by Think on 2021/2/3.
//  Copyright © 2021 netease. All rights reserved.
//

#import "NTESKtvMicQueueView.h"
#import "NTESKtvMicCell.h"

@interface NTESKtvMicQueueView ()

/// 麦位控件
@property (nonatomic, strong)   UICollectionView            *collectionView;
/// 主播控件
@property (nonatomic, strong)   NTESMicQueueCell            *anchorCell;
/// 语聊室布局
@property (nonatomic, strong)   UICollectionViewFlowLayout  *layout;

@end

@implementation NTESKtvMicQueueView

@synthesize delegate = _delegate, anchorMicInfo = _anchorMicInfo, datas = _datas, singerAccountId = _singerAccountId;

- (void)layoutSubviews
{
    self.anchorCell.frame = CGRectMake(2, 0, 52, 60);
    [self.anchorCell layoutIfNeeded];
    self.collectionView.frame = CGRectMake(self.anchorCell.right, self.anchorCell.top, self.width - self.anchorCell.width, self.anchorCell.height);
}

- (CGFloat)calculateHeightWithWidth:(CGFloat)width
{
    CGSize size = [NTESKtvMicCell size];
    CGFloat paddingH = [NTESKtvMicCell cellPaddingH];
    return size.height + paddingH;
}

#pragma mark - getter/setter

- (void)setSingerAccountId:(nullable NSString *)singerAccountId
{
    if ([_singerAccountId isEqualToString:singerAccountId]) {
        return;
    }
    
    ntes_main_async_safe(^{
        self->_singerAccountId = singerAccountId;
        BOOL anchorSinging = [singerAccountId isEqualToString:self.anchorMicInfo.userInfo.account];
        self.anchorCell.singIco.hidden = !anchorSinging;
        [self.collectionView reloadData];
    });
}

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
    if (self.delegate
        && [self.delegate respondsToSelector:@selector(micQueueConnectBtnPressedWithMicInfo:)]) {
        [self.delegate micQueueConnectBtnPressedWithMicInfo:micInfo];
    }
}

#pragma mark - UICollectionView delegate

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.datas.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.datas count] > indexPath.row) {
        NTESMicInfo *data = self.datas[indexPath.row];
        NTESMicQueueCell *cell = [NTESKtvMicCell cellWithCollectionView:self.collectionView data:data indexPath:indexPath];
        cell.delegate = self;
        BOOL hiddenSingingIco = YES;
        if (data.micStatus == NTESMicStatusConnectFinished && [data.userInfo.account isEqualToString:self.singerAccountId]) {
            hiddenSingingIco = NO;
        }
        cell.singIco.hidden = hiddenSingingIco;
        
        return cell;
    }
    return [NTESMicQueueCell new];
}

#pragma mark - lazy load

- (NTESMicQueueCell *)anchorCell
{
    if (!_anchorCell) {
        CGSize size = [NTESKtvMicCell size];
        _anchorCell = [[NTESKtvMicCell alloc] initWithFrame:CGRectMake(8, 0, size.width, size.height)];
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
        _collectionView.bounces = YES;
//        _collectionView.clipsToBounds = NO;
        [_collectionView registerClass:[NTESKtvMicCell class] forCellWithReuseIdentifier:[NTESKtvMicCell description]];
    }
    return _collectionView;
}

- (UICollectionViewFlowLayout *)layout
{
    if (!_layout) {
        _layout = [[UICollectionViewFlowLayout alloc] init];
        _layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _layout.minimumInteritemSpacing = 0.1f;
        _layout.minimumInteritemSpacing = 0.1f;
        _layout.itemSize = [NTESKtvMicCell size];
        _layout.minimumInteritemSpacing = [NTESKtvMicCell cellPaddingH];
        _layout.minimumLineSpacing = [NTESKtvMicCell cellPaddingW];
    }
    return _layout;
}

@end
