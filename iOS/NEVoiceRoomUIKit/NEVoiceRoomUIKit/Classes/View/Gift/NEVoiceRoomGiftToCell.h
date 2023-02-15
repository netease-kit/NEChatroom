// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <NEVoiceRoomKit/NEVoiceRoomKit-Swift.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NEVoiceRoomGiftToCell : UICollectionViewCell

/// cell size
+ (CGSize)size;
+ (NEVoiceRoomGiftToCell *)cellWithCollectionView:(UICollectionView *)collectionView
                                        indexPath:(NSIndexPath *)indexPath
                                       anchorData:(NEVoiceRoomSeatItem *)anchorData
                                            datas:(NSArray<NEVoiceRoomSeatItem *> *)datas;
@end

NS_ASSUME_NONNULL_END
