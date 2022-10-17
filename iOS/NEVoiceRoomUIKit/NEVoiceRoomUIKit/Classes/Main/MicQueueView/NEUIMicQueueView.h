// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <UIKit/UIKit.h>
#import "NEUIMicQueueCell.h"
#import "NEUIMicQueueViewProtocol.h"

NS_ASSUME_NONNULL_BEGIN

/**
 麦位队列视图
 */
@interface NEUIMicQueueView : UIView <UICollectionViewDelegate,
                                      UICollectionViewDataSource,
                                      NEUIMicQueueCellDelegate,
                                      NEUIMicQueueViewProtocol>

///// 单行刷新
///// @param rowIndex 需要刷新的row
//- (void)reloadCollectionRowWithIndex:(NSInteger)rowIndex;
@end

NS_ASSUME_NONNULL_END
