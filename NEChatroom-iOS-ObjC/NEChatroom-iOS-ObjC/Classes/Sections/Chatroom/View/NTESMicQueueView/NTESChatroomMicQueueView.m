//
//  NTESChatroomMicQueueView.m
//  NERtcAudioChatroom
//
//  Created by Netease on 2019/3/5.
//  Copyright © 2019年 netease. All rights reserved.
//

#import "NTESChatroomMicQueueView.h"
#import "NTESChatroomCollectionViewCell.h"
#import "NTESMicInfo.h"
#import "UIView+NTES.h"

#define cellPaddingW 25
#define cellPaddingH 30
#define cellLabelHeight  20

@interface NTESChatroomMicQueueView ()<UICollectionViewDelegate, UICollectionViewDataSource, NTESChatroomCollectionViewCellDelegate>
{
    CGRect _preRect;
}
@property (nonatomic,strong) UICollectionView *collectionView;
@property (nonatomic,strong) UICollectionViewFlowLayout *layout;
@end

@implementation NTESChatroomMicQueueView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.collectionView];
        self.clipsToBounds = NO;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (!CGRectEqualToRect(_preRect, self.bounds)) {
        _collectionView.frame = self.bounds;
        _preRect = self.bounds;
    }
}

- (NTESChatroomCollectionViewCell *)cellWithMicOrder:(NSInteger)micOrder {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:micOrder-1 inSection:0];
    NTESChatroomCollectionViewCell *cell = (NTESChatroomCollectionViewCell *)[_collectionView cellForItemAtIndexPath:indexPath];
    return cell;
}

- (void)startSoundAnimation:(NSInteger)micOrder volume:(NSInteger)volume{
    NTESChatroomCollectionViewCell *cell = [self cellWithMicOrder:micOrder];
    [cell startSoundAnimationWithValue:volume];
}

- (void)stopSoundAnimation:(NSInteger)micOrder {
    NTESChatroomCollectionViewCell *cell = [self cellWithMicOrder:micOrder];
    [cell stopSoundAnimation];
}
- (void)updateCellWithMicInfo:(NTESMicInfo *)micInfo {
    if (!micInfo) {
        return;
    }
    NTESChatroomCollectionViewCell *cell = [self cellWithMicOrder:micInfo.micOrder];
    [cell refresh:micInfo];
}

#pragma mark - <NTESChatroomCollectionViewCellDelegate>
- (void)onConnectBtnPressedWithMicInfo:(NTESMicInfo *)micInfo {
    if (_delegate
        && [_delegate respondsToSelector:@selector(micQueueConnectBtnPressedWithMicInfo:)]) {
        [_delegate micQueueConnectBtnPressedWithMicInfo:micInfo];
    }
}

#pragma mark - <UICollectionViewDelegate, UICollectionViewDataSource>
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSInteger count = _datas.count;
    return count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NTESChatroomCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.delegate = self;
    cell.clipsToBounds = NO;
    NTESMicInfo *micInfo = _datas[indexPath.row];
    [cell refresh:micInfo];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self cellSize];
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return cellPaddingH ;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return cellPaddingW ;
}

- (CGFloat)calculateHeightWithWidth:(CGFloat)width {
    CGFloat cellWidth = (width - 3*cellPaddingW)/4;
    CGFloat cellHeight = cellWidth + cellLabelHeight;
    CGFloat height = 2*cellHeight + cellPaddingH;
    return height;
}

- (CGSize)cellSize {
    CGFloat width = (_collectionView.width - 3*cellPaddingW)/4;
    CGFloat height = width + cellLabelHeight;
    return CGSizeMake(width, height);
}

#pragma mark - Setter
- (void)setDatas:(NSMutableArray<NTESMicInfo *> *)datas {
    _datas = datas;
    [_collectionView reloadData];
}

#pragma mark - Getter
- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        UICollectionView * collectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:self.layout];
        collectionView.backgroundColor = [UIColor clearColor];
        collectionView.showsVerticalScrollIndicator = NO;
        collectionView.showsHorizontalScrollIndicator = NO;
        collectionView.dataSource = self;
        collectionView.delegate   = self;
        collectionView.bounces = NO;
        collectionView.clipsToBounds = NO;
        [collectionView registerClass:[NTESChatroomCollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
        _collectionView = collectionView;
        
    }
    return _collectionView;
}

- (UICollectionViewFlowLayout *)layout
{
    if (!_layout) {
        _layout = [[UICollectionViewFlowLayout alloc] init];
        _layout.minimumInteritemSpacing = 0.1f;
        _layout.minimumInteritemSpacing = 0.1f;
    }
    return _layout;
}

@end
