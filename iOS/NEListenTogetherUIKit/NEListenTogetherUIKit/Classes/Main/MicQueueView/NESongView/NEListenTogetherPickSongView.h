// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <NEListenTogetherKit/NEListenTogetherKit-Swift.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN
@protocol NEListenTogetherPickSongViewProtocol <NSObject>

- (void)pauseSong;

- (void)resumeSong;

- (void)nextSong:(NEListenTogetherOrderSongModel *_Nullable)orderSongModel;

- (void)volumeChanged:(float)volume;

@end

typedef bool (^IsUserOnSeat)(void);
typedef void (^ApplyOnSeat)(void);

@interface NEListenTogetherPickSongView : UIView

- (instancetype)initWithFrame:(CGRect)frame detail:(NEListenTogetherInfo *)detail;

@property(nonatomic, copy) IsUserOnSeat isUserOnSeat;
@property(nonatomic, copy) ApplyOnSeat applyOnseat;

@property(nonatomic, weak) id<NEListenTogetherPickSongViewProtocol> delegate;

// 申请连麦相关
- (void)cancelApply;
- (void)applyFaile;
- (void)applySuccess;

- (void)setPlayingStatus:(BOOL)status;

// 数据刷新
- (void)refreshPickedSongView;

/// 设置音量
- (void)setVolume:(float)volume;
- (float)getVolume;

@end

NS_ASSUME_NONNULL_END
