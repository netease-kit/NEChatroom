// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <UIKit/UIKit.h>
@class NEListenTogetherLyricControlView;

NS_ASSUME_NONNULL_BEGIN

@protocol NEListenTogetherLyricControlViewDelegate <NSObject>

- (void)pauseSongWithView:(NEListenTogetherLyricControlView *_Nullable)view;

- (void)resumeSongWithView:(NEListenTogetherLyricControlView *_Nullable)view;

- (void)nextSongWithView:(NEListenTogetherLyricControlView *_Nullable)view;

@end

@interface NEListenTogetherLyricControlView : UIView

@property(nonatomic, weak) id<NEListenTogetherLyricControlViewDelegate> delegate;
/// 通过设置该值来决定显示播放按钮还是暂停按钮
@property(nonatomic, assign) BOOL isPlaying;

@end

NS_ASSUME_NONNULL_END
