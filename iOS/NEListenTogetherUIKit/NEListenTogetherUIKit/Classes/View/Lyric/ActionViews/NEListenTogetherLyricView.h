// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <NECopyrightedMedia/NECopyrightedMediaPublic.h>
#import <NELyricUIKit/NELyricUIKit.h>
#import <UIKit/UIKit.h>

@import NEListenTogetherKit;

NS_ASSUME_NONNULL_BEGIN

@interface NEListenTogetherLyricView : UIView

@property(nonatomic, copy) NSString *path;
@property(nonatomic, copy) NSString *content;
@property(nonatomic, assign) NSInteger duration;
@property(nonatomic, assign) bool seekBtnHidden;
@property(nonatomic, copy) NSInteger (^timeForCurrent)(void);
@property(nonatomic, copy) void (^seek)(NSInteger);

- (void)update;

/// 设置路径
/// @param path 路径
/// @param type 类型
- (void)setPath:(NSString *)path lyricType:(NELyricType)type;
/// 设置歌词内容
/// @param content 内容
/// @param type 类型
- (void)setContent:(NSString *)content lyricType:(NELyricType)type;
@end

NS_ASSUME_NONNULL_END
