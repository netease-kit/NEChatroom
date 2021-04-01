//
//  NTESHasPickedSongCell.h
//  NEChatroom-iOS-ObjC
//
//  Created by Think on 2021/2/4.
//  Copyright © 2021 netease. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class NTESQueueMusic;

@protocol NTESHasPickedSongCellDelegate <NSObject>

/**
 触发取消点歌
 @param music   - 被取消的歌曲
 */
- (void)didCancelPickedMusic:(NTESQueueMusic *)music;

@end

/**
 已点歌曲cell
 */
@interface NTESHasPickedSongCell : UITableViewCell

/// 代理句柄
@property (nonatomic, weak) id<NTESHasPickedSongCellDelegate> delegate;
/// 是否正在播放
@property (nonatomic, assign)   BOOL    isPlaying;
/// 切歌权限
@property (nonatomic, assign)   BOOL    cancelAuth;

/**
 实例化点歌cell
 @param tableView   - tableView
 @param datas       - 数据源
 @param indexPath   - 排列信息
 @param avgs            - 额外参数
 @return 点歌cell
 */
+ (NTESHasPickedSongCell *)cellWithTableView:(UITableView *)tableView
                                       datas:(NSArray<NTESQueueMusic *> *)datas
                                   indexPath:(NSIndexPath *)indexPath
                                        avgs:(NSDictionary *)avgs;

/**
 获取点歌cell高度
 @return 点歌cell高度
 */
+ (CGFloat)height;

@end

NS_ASSUME_NONNULL_END
