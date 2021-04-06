//
//  NTESPickSongCell.h
//  NEChatroom-iOS-ObjC
//
//  Created by Think on 2021/2/1.
//  Copyright © 2021 netease. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class NTESPickSongModel;

@protocol NTESPickSongCellDelegate <NSObject>

/**
 点击点歌按钮
 @param song    - 被点的歌曲信息
 */
- (void)didClickPickSong:(NTESPickSongModel *)song;

@end

/**
 点歌cell
 */
@interface NTESPickSongCell : UITableViewCell

/// 代理句柄
@property (nonatomic, weak) id<NTESPickSongCellDelegate> delegate;

/**
 实例化点歌cell
 @param tableView   - tableView
 @param data        - 数据源
 @param indexPath   - 排列信息
 @return 点歌cell
 */
+ (NTESPickSongCell *)cellWithTableView:(UITableView *)tableView
                                    data:(NTESPickSongModel *)data
                               indexPath:(NSIndexPath *)indexPath;

/**
 获取点歌cell高度
 @return 点歌cell高度
 */
+ (CGFloat)height;

@end

NS_ASSUME_NONNULL_END
