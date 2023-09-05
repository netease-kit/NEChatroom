// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <NEVoiceRoomKit/NEVoiceRoomKit-Swift.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class NEUIConnectListView;

@protocol NEUIConnectListViewDelegate <NSObject>
@optional
- (void)connectListView:(NEUIConnectListView *)connectListView
    onAcceptWithSeatItem:(NEVoiceRoomSeatItem *)seatItem;
- (void)connectListView:(NEUIConnectListView *)connectListView
    onRejectWithSeatItem:(NEVoiceRoomSeatItem *)seatItem;
@end

@interface NEUIConnectListView : UIControl
@property(nonatomic, weak) id<NEUIConnectListViewDelegate> delegate;
- (void)refreshWithDataArray:(NSMutableArray *)dataArray;
- (void)showAsAlertOnView:(UIView *)view;
@end

NS_ASSUME_NONNULL_END
