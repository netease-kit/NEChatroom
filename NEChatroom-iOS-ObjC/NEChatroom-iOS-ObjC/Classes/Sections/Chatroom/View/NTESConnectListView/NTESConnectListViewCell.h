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

@property (nonatomic, weak)id<NTESConnectListViewCellDelegate> delegate;
- (void)refresh:(NTESMicInfo *)micInfo;

@end

NS_ASSUME_NONNULL_END
