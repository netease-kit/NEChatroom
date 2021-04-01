//
//  NTESMicQueueView.h
//  NEChatroom-iOS-ObjC
//
//  Created by Think on 2021/2/3.
//  Copyright © 2021 netease. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NTESMicQueueCell.h"
#import "NTESMicQueueViewProtocol.h"

NS_ASSUME_NONNULL_BEGIN

/**
 麦位队列视图
 */
@interface NTESMicQueueView : UIView
<
    UICollectionViewDelegate,
    UICollectionViewDataSource,
    NTESMicQueueCellDelegate,
    NTESMicQueueViewProtocol
>

@end

NS_ASSUME_NONNULL_END
