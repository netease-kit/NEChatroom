//
//  NTESConnectListView.h
//  NERtcAudioChatroom
//
//  Created by Simon Blue on 2019/1/28.
//  Copyright © 2019年 netease. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class NTESMicInfo;

@protocol NTESConnectListViewDelegate <NSObject>
- (void)onAcceptBtnPressedWithMicInfo:(NTESMicInfo *)micInfo;
- (void)onRejectBtnPressedWithMicInfo:(NTESMicInfo *)micInfo;
@end

@interface NTESConnectListView : UIControl<NIMChatroomManagerDelegate>

@property (nonatomic, weak)id<NTESConnectListViewDelegate> delegate;
- (void)refreshWithDataArray:(NSMutableArray *)dataArray;
- (void)showAsAlertOnView:(UIView *)view;
@property (nonatomic, copy) NSString *roomId;
@end

NS_ASSUME_NONNULL_END
