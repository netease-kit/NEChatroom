//
//  NTESConnectListViewCell.h
//  NERtcAudioChatroom
//
//  Created by Simon Blue on 2019/1/28.
//  Copyright © 2019年 netease. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NTESMicInfo;

@protocol NTESConnectListViewCellDelegate <NSObject>

- (void)onAcceptBtnPressedWithMicInfo:(NTESMicInfo *)micInfo;

- (void)onRejectBtnPressedWithMicInfo:(NTESMicInfo *)micInfo;

@end

NS_ASSUME_NONNULL_BEGIN

@interface NTESConnectListViewCell : UITableViewCell

/**
 创建cell
 @param tableView   - 展示控件
 @param datas            - 数据
 @param delegate    - 代理句柄
 @param indexPath   - 次序
 */
+ (NTESConnectListViewCell *)cellWithTableView:(UITableView *)tableView
                                          datas:(NSArray<NTESMicInfo *> *)datas
                                      delegate:(id<NTESConnectListViewCellDelegate>)delegate
                                     indexPath:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END
