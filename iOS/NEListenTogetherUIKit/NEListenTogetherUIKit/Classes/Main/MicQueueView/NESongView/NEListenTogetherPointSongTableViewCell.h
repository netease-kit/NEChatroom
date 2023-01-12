// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^ClickPointButton)(void);

@interface NEListenTogetherPointSongTableViewCell : UITableViewCell

// 歌曲封面
@property(nonatomic, strong) UIImageView *songImageView;
// 歌曲名称
@property(nonatomic, strong) UILabel *songLabel;
// 歌手名
@property(nonatomic, strong) UILabel *anchorLabel;
// 来源
@property(nonatomic, strong) UIImageView *resourceImageView;
// 状态
@property(nonatomic, strong) UIButton *pointButton;
@property(nonatomic, copy) ClickPointButton clickPointButton;

// 下载中状态
@property(nonatomic, strong) UILabel *downloadingLabel;
// 底层状态
@property(nonatomic, strong) UILabel *statueBottomLabel;
// 顶部状态
@property(nonatomic, strong) UILabel *statueTopLabel;

@property(nonatomic, assign) CGFloat progress;

@end

NS_ASSUME_NONNULL_END
