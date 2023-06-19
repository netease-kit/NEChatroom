// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <NEOrderSong/NEOrderSong-Swift.h>
#import <NEVoiceRoomKit/NEVoiceRoomKit-Swift.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN
@protocol NEVoiceRoomPickSongViewProtocol <NSObject>

- (void)pauseSong;

- (void)resumeSong;

- (void)nextSong:(NEOrderSongResponseOrderSongModel *_Nullable)orderSongModel;

- (void)volumeChanged:(float)volume;

@end

typedef void (^ApplyOnSeat)(void);

@interface NEVoiceRoomPickSongView : UIView

- (instancetype)initWithFrame:(CGRect)frame detail:(NEVoiceRoomInfo *)detail;

@property(nonatomic, copy) ApplyOnSeat applyOnseat;

@property(nonatomic, weak) id<NEVoiceRoomPickSongViewProtocol> delegate;

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
