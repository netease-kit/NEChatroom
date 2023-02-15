// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^ClickButton)(void);

@interface NEListenTogetherPointedSongTableViewCell : UITableViewCell

// 播放中图标
@property(nonatomic, strong) UIImageView *playingImageView;
// 播放列表
@property(nonatomic, strong) UILabel *songNumberLabel;
// 歌曲封面
@property(nonatomic, strong) UIImageView *songIconImageView;
// 歌曲名
@property(nonatomic, strong) UILabel *songNameLabel;
// 用户头像
@property(nonatomic, strong) UIImageView *userIconImageView;
// 用户昵称
@property(nonatomic, strong) UILabel *userNickNameLabel;
// 歌曲时长
@property(nonatomic, strong) UILabel *songDurationLabel;
// 状态
@property(nonatomic, strong) UILabel *statueLabel;
// cancel
@property(nonatomic, strong) UIButton *cancelButton;
@property(nonatomic, copy) ClickButton clickCancel;
// top
//@property(nonatomic, strong) UIButton *topButton;
//@property(nonatomic, copy) ClickButton clickTop;

@end

NS_ASSUME_NONNULL_END
