// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEListenTogetherPointedSongTableViewCell.h"
#import <Masonry/Masonry.h>
#import "NEListenTogetherGlobalMacro.h"
#import "NEListenTogetherPickSongColorDefine.h"
#import "NEListenTogetherUI.h"
#import "NSBundle+NEListenTogetherLocalized.h"
@interface NEListenTogetherPointedSongTableViewCell ()

@end

@implementation NEListenTogetherPointedSongTableViewCell

- (void)awakeFromNib {
  [super awakeFromNib];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier {
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
    [self initView];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
  }
  return self;
}
- (void)initView {
  self.playingImageView = [[UIImageView alloc] init];
  self.playingImageView.image = [NEListenTogetherUI ne_imageName:@"pointsong_playing"];
  [self.contentView addSubview:self.playingImageView];
  [self.playingImageView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.height.equalTo(@22);
    make.width.equalTo(@18);
    make.left.equalTo(self.contentView).offset(22);
    make.centerY.equalTo(self.contentView);
  }];

  self.songNumberLabel = [[UILabel alloc] init];
  self.songNumberLabel.font = [UIFont systemFontOfSize:14];
  self.songNumberLabel.textColor = HEXCOLOR(0x999999);
  [self.contentView addSubview:self.songNumberLabel];
  [self.songNumberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.height.equalTo(@22);
    make.width.equalTo(@18);
    make.left.equalTo(self.contentView.mas_left).offset(22);
    make.centerY.equalTo(self.contentView);
  }];

  self.songIconImageView = [[UIImageView alloc] init];
  self.songIconImageView.layer.masksToBounds = YES;
  self.songIconImageView.layer.cornerRadius = 5;
  [self.contentView addSubview:self.songIconImageView];
  [self.songIconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.height.width.equalTo(@45);
    make.left.equalTo(self.playingImageView.mas_right).offset(9);
    make.centerY.equalTo(self.contentView);
  }];

  self.songNameLabel = [[UILabel alloc] init];
  self.songNameLabel.font = [UIFont systemFontOfSize:16];
  self.songNameLabel.textColor = HEXCOLOR(0x222222);
  [self.contentView addSubview:self.songNameLabel];
  [self.songNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self.songIconImageView.mas_right).offset(8);
    make.top.equalTo(self.songIconImageView.mas_top);
    make.width.lessThanOrEqualTo(@152);
  }];

  self.userIconImageView = [[UIImageView alloc] init];
  self.userIconImageView.layer.masksToBounds = YES;
  self.userIconImageView.layer.cornerRadius = 9;
  [self.contentView addSubview:self.userIconImageView];
  [self.userIconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.width.height.equalTo(@18);
    make.left.equalTo(self.songNameLabel);
    make.top.equalTo(self.songNameLabel.mas_bottom).offset(8);
  }];

  self.userNickNameLabel = [[UILabel alloc] init];
  self.userNickNameLabel.textColor = HEXCOLOR(0x999999);
  self.userNickNameLabel.font = [UIFont systemFontOfSize:12];
  [self.contentView addSubview:self.userNickNameLabel];
  [self.userNickNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self.userIconImageView.mas_right).offset(4);
    make.centerY.equalTo(self.userIconImageView);
    make.width.lessThanOrEqualTo(@100);
  }];

  self.songDurationLabel = [[UILabel alloc] init];
  self.songDurationLabel.textColor = HEXCOLOR(0x999999);
  self.songDurationLabel.font = [UIFont systemFontOfSize:12];
  [self.contentView addSubview:self.songDurationLabel];
  [self.songDurationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self.userNickNameLabel.mas_right).offset(12);
    make.centerY.equalTo(self.userNickNameLabel);
  }];

  self.cancelButton = [[UIButton alloc] init];
  [self.cancelButton addTarget:self
                        action:@selector(clickCanCelButton:)
              forControlEvents:UIControlEventTouchUpInside];
  [self.cancelButton setImage:[NEListenTogetherUI ne_imageName:@"listenTogether_cancel"]
                     forState:UIControlStateNormal];
  [self.contentView addSubview:self.cancelButton];
  [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
    make.width.equalTo(@22);
    make.height.equalTo(@22);
    make.centerY.equalTo(self.contentView);
    make.right.equalTo(self.contentView.mas_right).offset(-37);
  }];

  //  self.topButton = [[UIButton alloc] init];
  //  [self.topButton addTarget:self
  //                     action:@selector(clickTopButton:)
  //           forControlEvents:UIControlEventTouchUpInside];
  //  [self.topButton setImage:[NEListenTogetherUI ne_imageName:@"listenTogether_top"]
  //                  forState:UIControlStateNormal];
  //  self.topButton.titleLabel.font = [UIFont systemFontOfSize:14];
  //  self.topButton.titleLabel.textColor = HEXCOLOR(0x333333);
  //  [self.contentView addSubview:self.topButton];
  //  [self.topButton mas_makeConstraints:^(MASConstraintMaker *make) {
  //    make.width.equalTo(@15);
  //    make.height.equalTo(@18);
  //    make.centerY.equalTo(self.contentView);
  //    make.right.equalTo(self.cancelButton.mas_left).offset(-20);
  //  }];

  self.statueLabel = [[UILabel alloc] init];
  self.statueLabel.font = [UIFont systemFontOfSize:12];
  self.statueLabel.text = @"正在播放";
  self.statueLabel.textColor = HEXCOLOR(0x337EFF);
  [self.contentView addSubview:self.statueLabel];
  [self.statueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.right.equalTo(self.contentView.mas_right).offset(-24);
    make.centerY.equalTo(self.userIconImageView).offset(8);
  }];
}

- (void)clickCanCelButton:(UIButton *)sender {
  self.clickCancel();
}
//- (void)clickTopButton:(UIButton *)sender {
//  self.clickTop();
//}
@end
