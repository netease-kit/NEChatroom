// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <Lottie/Lottie.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 背景音乐 cell
@interface NEListenTogetherUIBackgroundMusiceCell : UITableViewCell
/// 序号
@property(nonatomic, strong) UILabel *indexLabel;
/// 播放动效
@property(nonatomic, strong) LOTAnimationView *playingAnimationView;
@end

NS_ASSUME_NONNULL_END
