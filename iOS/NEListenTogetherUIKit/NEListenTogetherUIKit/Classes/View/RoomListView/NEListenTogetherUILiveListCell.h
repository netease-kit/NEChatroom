// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

// #import <NEListenTogetherKit/NEListenTogetherKit-Swift.h>
#import <NEListenTogetherKit/NEListenTogetherKit-Swift.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NEListenTogetherUILiveListCell : UICollectionViewCell
/// 实例化直播列表页cell
+ (NEListenTogetherUILiveListCell *)cellWithCollectionView:(UICollectionView *)collectionView
                                                 indexPath:(NSIndexPath *)indexPath
                                                     datas:(NSArray<NEListenTogetherInfo *> *)datas;

/// 计算直播列表页cell size
+ (CGSize)size;
@end

NS_ASSUME_NONNULL_END
