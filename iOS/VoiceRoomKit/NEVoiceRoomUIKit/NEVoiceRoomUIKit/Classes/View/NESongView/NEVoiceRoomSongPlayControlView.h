// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <UIKit/UIKit.h>
@class NEVoiceRoomSongPlayControlView;
NS_ASSUME_NONNULL_BEGIN

@protocol NEVoiceRoomSongPlayControlViewDelegate <NSObject>

- (void)pauseSong:(NEVoiceRoomSongPlayControlView *)view;

- (void)resumeSong:(NEVoiceRoomSongPlayControlView *)view;

- (void)nextSong:(NEVoiceRoomSongPlayControlView *)view;

- (void)volumeChanged:(float)volume view:(NEVoiceRoomSongPlayControlView *)view;

@end

@interface NEVoiceRoomSongPlayControlView : UIView

/// 通过设置该值来决定显示播放按钮还是暂停按钮
@property(nonatomic, assign) BOOL isPlaying;
@property(nonatomic, assign) float volume;
@property(nonatomic, weak) id<NEVoiceRoomSongPlayControlViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
