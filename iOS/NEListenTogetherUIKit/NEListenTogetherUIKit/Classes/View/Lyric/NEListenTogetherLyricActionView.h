// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <NECopyrightedMedia/NECopyrightedMediaPublic.h>
#import <UIKit/UIKit.h>

@import NEListenTogetherKit;

NS_ASSUME_NONNULL_BEGIN

@protocol NEListenTogetherLyricActionViewDelegate <NSObject>

- (NSInteger)onLyricTime;

- (void)onLyricSeek:(NSInteger)seek;

@end

@interface NEListenTogetherLyricActionView : UIView

@property(nonatomic, weak) id<NEListenTogetherLyricActionViewDelegate> delegate;

#pragma mark - 歌词页面
@property(nonatomic, copy) NSString *songName;
@property(nonatomic, copy) NSString *songSingers;
@property(nonatomic, copy) NSString *lyricPath;
@property(nonatomic, copy) NSString *lyricContent;
@property(nonatomic, assign) NSInteger lyricDuration;
@property(nonatomic, assign) bool lyricSeekBtnHidden;
- (void)updateLyric:(NSInteger)currentTime;
- (void)seekLyricView:(uint64_t)position;

/// 设置歌词
/// @param lyricContent 歌词内容
/// @param type 类型
- (void)setLyricContent:(NSString *)lyricContent lyricType:(NELyricType)type;
@end

NS_ASSUME_NONNULL_END
