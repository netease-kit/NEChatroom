// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEUIMicQueueView.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import "NEUIChatroomMicCell.h"
#import "NTESGlobalMacro.h"
#import "UIView+NEUIExtension.h"

@interface NEUIMicQueueView ()

/// 麦位控件
@property(nonatomic, strong) UICollectionView *collectionView;
/// 主播控件
@property(nonatomic, strong) NEUIMicQueueCell *anchorCell;
/// 语聊室布局
@property(nonatomic, strong) UICollectionViewFlowLayout *layout;

@end

@implementation NEUIMicQueueView

@synthesize delegate = _delegate, anchorMicInfo = _anchorMicInfo, datas = _datas;

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    [self addSubview:self.anchorCell];
    [self addSubview:self.collectionView];

    @weakify(self);
    [RACObserve(self, datas) subscribeNext:^(id _Nullable x) {
      @strongify(self);
      ntes_main_sync_safe(^{
        [self.collectionView reloadData];
      });
    }];
  }
  return self;
}

- (void)layoutSubviews {
  self.anchorCell.left = (self.width - self.anchorCell.width) * 0.5;
  [self.anchorCell layoutIfNeeded];
  CGFloat height = [self calculateHeightWithWidth:self.width] - [NEUIChatroomMicCell size].height -
                   [NEUIChatroomMicCell cellPaddingH];
  self.collectionView.frame = CGRectMake(
      0, self.anchorCell.bottom + [NEUIChatroomMicCell cellPaddingH], self.width, height);
}

- (void)updateCellWithMicInfo:(NEVoiceRoomSeatItem *)micInfo {
  if (!micInfo) {
    return;
  }
  ntes_main_async_safe(^{
    NEUIMicQueueCell *cell = [self cellWithMicOrder:micInfo.index];
    [cell refresh:micInfo];
  });
}

- (CGFloat)calculateHeightWithWidth:(CGFloat)width {
  CGSize size = [NEUIChatroomMicCell size];
  CGFloat paddingH = [NEUIChatroomMicCell cellPaddingH];
  return 3 * size.height + 2 * paddingH;
}
- (NEUIMicQueueCell *)cellWithMicOrder:(NSInteger)micOrder {
  NSIndexPath *indexPath = [NSIndexPath indexPathForRow:micOrder inSection:0];
  NEUIMicQueueCell *cell =
      (NEUIMicQueueCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
  return cell;
}

- (void)startSoundAnimation:(NSInteger)micOrder volume:(NSInteger)volume {
  NEUIMicQueueCell *cell = [self cellWithMicOrder:micOrder];
  [cell startSoundAnimationWithValue:volume];
}

- (void)stopSoundAnimation:(NSInteger)micOrder {
  NEUIMicQueueCell *cell = [self cellWithMicOrder:micOrder];
  [cell stopSoundAnimation];
}

#pragma mark - getter/setter
- (void)setAnchorMicInfo:(NEVoiceRoomSeatItem *)anchorMicInfo {
  if (!anchorMicInfo) return;

  _anchorMicInfo = anchorMicInfo;
  [self.anchorCell refresh:anchorMicInfo];
}

#pragma mark - NEUIMicQueueCellDelegate

- (void)onConnectBtnPressedWithMicInfo:(NEVoiceRoomSeatItem *)micInfo {
  if (_delegate &&
      [_delegate respondsToSelector:@selector(micQueueConnectBtnPressedWithMicInfo:)]) {
    [_delegate micQueueConnectBtnPressedWithMicInfo:micInfo];
  }
}

#pragma mark - UICollectionView delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
  return _datas.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  if ([_datas count] > indexPath.row) {
    NEVoiceRoomSeatItem *data = _datas[indexPath.row];
    NEUIMicQueueCell *cell = [NEUIChatroomMicCell cellWithCollectionView:self.collectionView
                                                                    data:data
                                                               indexPath:indexPath];
    cell.delegate = self;
    return cell;
  }
  return [NEUIMicQueueCell new];
}

#pragma mark - lazy load

- (NEUIMicQueueCell *)anchorCell {
  if (!_anchorCell) {
    CGSize size = [NEUIChatroomMicCell size];
    _anchorCell =
        [[NEUIChatroomMicCell alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
  }
  return _anchorCell;
}

- (UICollectionView *)collectionView {
  if (!_collectionView) {
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero
                                         collectionViewLayout:self.layout];
    _collectionView.backgroundColor = [UIColor clearColor];
    _collectionView.showsVerticalScrollIndicator = NO;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.bounces = NO;
    //        _collectionView.clipsToBounds = NO;
    [_collectionView registerClass:[NEUIChatroomMicCell class]
        forCellWithReuseIdentifier:[NEUIChatroomMicCell description]];
  }
  return _collectionView;
}

- (UICollectionViewFlowLayout *)layout {
  if (!_layout) {
    _layout = [[UICollectionViewFlowLayout alloc] init];
    _layout.itemSize = [NEUIChatroomMicCell size];
    _layout.minimumInteritemSpacing = [NEUIChatroomMicCell cellPaddingW];
    _layout.minimumLineSpacing = [NEUIChatroomMicCell cellPaddingH];
  }
  return _layout;
}

@end
