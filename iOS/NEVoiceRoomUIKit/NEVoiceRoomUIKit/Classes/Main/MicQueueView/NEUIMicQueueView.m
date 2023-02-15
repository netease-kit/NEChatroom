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
/// 音量信息
//@property(nonatomic, strong) NSArray<NEVoiceRoomMemberVolumeInfo *> *volumeInfos;

@end

@implementation NEUIMicQueueView

@synthesize delegate = _delegate, anchorMicInfo = _anchorMicInfo, datas = _datas,
            giftDatas = _giftDatas;

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
    [RACObserve(self, giftDatas) subscribeNext:^(id _Nullable x) {
      @weakify(self);
      @strongify(self);
      ntes_main_sync_safe(^{
        [self updateAnchorGift];
        [self.collectionView reloadData];
      });
    }];
  }
  return self;
}

- (void)updateWithVolumeInfos:(NSArray<NEVoiceRoomMemberVolumeInfo *> *)volumeInfos {
  //  self.volumeInfos = volumeInfos;
  if (volumeInfos.count == 1 &&
      [volumeInfos[0].userUuid isEqualToString:[NEVoiceRoomKit getInstance].localMember.account]) {
    // 自己讲话，单独更新
    if ([[NEVoiceRoomKit getInstance].localMember.account isEqualToString:_anchorMicInfo.user]) {
      // 自己是主播
      bool isAnchorSpeaking = volumeInfos[0].volume > 0;
      if (isAnchorSpeaking) {
        [_anchorCell startSpeakAnimation];
      } else {
        [_anchorCell stopSpeakAnimation];
      }
    } else {
      // 自己不是主播
      for (int i = 0; i < self.datas.count; i++) {
        NEVoiceRoomSeatItem *data = self.datas[i];
        if ([data.user isEqualToString:volumeInfos[0].userUuid]) {
          NEUIMicQueueCell *cell = [self cellWithMicOrder:i];
          if (volumeInfos[0].volume > 0) {
            [cell startSpeakAnimation];
          } else {
            [cell stopSpeakAnimation];
          }
        } else {
          NEUIMicQueueCell *cell = [self cellWithMicOrder:i];
          [cell stopSpeakAnimation];
        }
      }
    }
  } else {
    // 其他人讲话
    if ([[NEVoiceRoomKit getInstance].localMember.account isEqualToString:_anchorMicInfo.user]) {
      // 自己是主播
      for (int i = 0; i < self.datas.count; i++) {
        bool isIn = false;
        for (NEVoiceRoomMemberVolumeInfo *volume in volumeInfos) {
          NEVoiceRoomSeatItem *data = self.datas[i];
          if ([data.user isEqualToString:volume.userUuid]) {
            isIn = true;
            NEUIMicQueueCell *cell = [self cellWithMicOrder:i];
            if (volume.volume > 0) {
              [cell startSpeakAnimation];
            } else {
              [cell stopSpeakAnimation];
            }
          }
        }
        if (!isIn) {
          NEUIMicQueueCell *cell = [self cellWithMicOrder:i];
          [cell stopSpeakAnimation];
        }
      }
    } else {
      // 自己不是主播
      bool isAnchorSpeaking = false;
      for (int i = 0; i < self.datas.count; i++) {
        bool isIn = false;
        for (NEVoiceRoomMemberVolumeInfo *volume in volumeInfos) {
          if ([volume.userUuid isEqualToString:_anchorMicInfo.user] && volume.volume > 0) {
            isAnchorSpeaking = true;
          }
          NEVoiceRoomSeatItem *data = self.datas[i];
          if (![data.user isEqualToString:[NEVoiceRoomKit getInstance].localMember.account]) {
            if ([data.user isEqualToString:volume.userUuid]) {
              isIn = true;
              NEUIMicQueueCell *cell = [self cellWithMicOrder:i];
              if (volume.volume > 0) {
                [cell startSpeakAnimation];
              } else {
                [cell stopSpeakAnimation];
              }
            }
          } else {
            isIn = true;
          }
        }
        if (!isIn) {
          NEUIMicQueueCell *cell = [self cellWithMicOrder:i];
          [cell stopSpeakAnimation];
        }
      }
      if (isAnchorSpeaking) {
        [_anchorCell startSpeakAnimation];
      } else {
        [_anchorCell stopSpeakAnimation];
      }
    }
  }
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
  [self updateAnchorGift];
}

- (void)updateAnchorGift {
  for (NEVoiceRoomBatchSeatUserReward *seatUserReward in _giftDatas) {
    if ([seatUserReward.userUuid isEqualToString:_anchorMicInfo.user]) {
      [self.anchorCell
          updateGiftLabel:[NSString stringWithFormat:@"%ld", seatUserReward.rewardTotal]];
    }
  }
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
    //      NEVoiceRoomBatchSeatUserReward *giftData = giftDatas[indexPath.row];
    NEUIMicQueueCell *cell = [NEUIChatroomMicCell cellWithCollectionView:self.collectionView
                                                                    data:data
                                                               indexPath:indexPath];
    NSString *rewardString;
    for (NEVoiceRoomBatchSeatUserReward *seatUserReward in _giftDatas) {
      //        NSLog(@"seatUserRewardDataCollection --- %@ --- %ld ---
      //        %d",seatUserReward.userUuid,(long)seatUserReward.rewardTotal,data.status);
      if (seatUserReward.userUuid && data.user &&
          [seatUserReward.userUuid isEqualToString:data.user] &&
          data.status == NEVoiceRoomSeatItemStatusTaken) {
        rewardString = [NSString stringWithFormat:@"%ld", (long)seatUserReward.rewardTotal];
        break;
      }
    }
    if (rewardString) {
      [cell updateGiftLabel:rewardString];
    } else {
      [cell updateGiftLabel:nil];
    }

    cell.delegate = self;
    [cell stopSpeakAnimation];
    return cell;
  }
  return [NEUIMicQueueCell new];
}

/// 更新礼物值，单独开方法 是因为多线程
- (void)updateGiftDatas:(NSMutableArray<NEVoiceRoomBatchSeatUserReward *> *)giftDatas {
  @synchronized(self) {
    self.giftDatas = giftDatas;
    //    for (NEVoiceRoomBatchSeatUserReward *batchSeatUserReward in giftDatas) {
    //      NSLog(@"礼物值 ---- %ld", batchSeatUserReward.rewardTotal);
    //    }
  }
}

/// 更新礼物值，删除礼物 ，单独开方法，因为多线程
- (void)updateGiftData:(NSString *)account {
  if (!account || account.length <= 0) {
    return;
  }
  @synchronized(self) {
    /// 清除本地礼物值
    for (int index = 0; index < self.giftDatas.count; index++) {
      NEVoiceRoomBatchSeatUserReward *batchSeatUserReward = self.giftDatas[index];
      if ([batchSeatUserReward.userUuid isEqualToString:account]) {
        batchSeatUserReward.rewardTotal = 0;
        break;
      }
    }
  }
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
    _collectionView.scrollEnabled = NO;
    [_collectionView registerClass:[NEUIChatroomMicCell class]
        forCellWithReuseIdentifier:[NEUIChatroomMicCell description]];
    _collectionView.contentInset = UIEdgeInsetsMake(18.0f, 18.0f, 18.0f, 18.0f);
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
