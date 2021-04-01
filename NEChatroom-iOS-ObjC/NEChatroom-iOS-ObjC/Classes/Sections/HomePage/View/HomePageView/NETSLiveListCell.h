//
//  NETSLiveListCell.h
//  NLiteAVDemo
//
//  Created by Ease on 2020/11/9.
//  Copyright © 2020 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

///
/// 直播列表页 VM
///

@class NTESChatroomInfo;

@interface NETSLiveListCell : UICollectionViewCell

/// 实例化直播列表页cell
+ (NETSLiveListCell *)cellWithCollectionView:(UICollectionView *)collectionView
                                   indexPath:(NSIndexPath *)indexPath
                                       datas:(NSArray <NTESChatroomInfo *> *)datas;

/// 计算直播列表页cell size
+ (CGSize)size;

@end

NS_ASSUME_NONNULL_END
