// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
/// 背景音乐模型
@interface NEListenTogetherUIBackgroundMusicModel : NSObject
/// 曲名
@property(nonatomic, copy) NSString *title;
/// 歌手
@property(nonatomic, copy) NSString *artist;
/// 专辑名称
@property(nonatomic, copy) NSString *albumName;
/// 路径
@property(nonatomic, copy) NSString *fileName;
@end

NS_ASSUME_NONNULL_END
