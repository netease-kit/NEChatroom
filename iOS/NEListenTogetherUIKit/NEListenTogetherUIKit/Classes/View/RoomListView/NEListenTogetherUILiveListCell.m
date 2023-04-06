// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEListenTogetherUILiveListCell.h"
#import <Masonry/Masonry.h>
#import <SDWebImage/SDWebImage.h>
#import "NEListenTogetherFontMacro.h"
#import "NEListenTogetherGlobalMacro.h"
#import "NEListenTogetherUI.h"
#import "NEListenTogetherUICreateRoomTitleButton.h"
#import "NSString+NEListenTogetherString.h"
#import "UIButton+NEListenTogetherLayout.h"
#import "UIImageView+NEListenTogetherCornerRadius.h"

@interface NEListenTogetherUILiveListCell ()

/// 封面
@property(nonatomic, strong) UIImageView *coverView;
/// 渐变阴影
@property(nonatomic, strong) CAGradientLayer *shadowLayer;
/// 房间名称
@property(nonatomic, strong) UILabel *roomName;
/// 主播名称
@property(nonatomic, strong) UILabel *anchorName;
/// 观众人数
@property(nonatomic, strong) UILabel *audienceNum;
// ktv音乐标记
@property(nonatomic, strong) UIButton *tagButton;
@end

@implementation NEListenTogetherUILiveListCell

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    [self setupViews];
  }
  return self;
}

- (void)setupViews {
  [self.contentView addSubview:self.coverView];
  [self.contentView addSubview:self.roomName];
  [self.contentView addSubview:self.anchorName];
  [self.contentView addSubview:self.audienceNum];
  [self.contentView addSubview:self.tagButton];

  [self.coverView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.edges.equalTo(self.contentView);
  }];
  [self.coverView.layer insertSublayer:self.shadowLayer atIndex:0];

  [self.roomName mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self.coverView).offset(8);
    make.right.equalTo(self.coverView).offset(-8);
    make.bottom.equalTo(self.coverView).offset(-22);
  }];

  [self.anchorName mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self.roomName);
    make.top.equalTo(self.roomName.mas_bottom);
  }];

  [self.audienceNum mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self.anchorName.mas_right);
    make.right.equalTo(self.coverView).offset(-8);
    make.centerY.equalTo(self.anchorName);
  }];

  [self.tagButton mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.left.equalTo(self.contentView).offset(8);
    make.right.mas_lessThanOrEqualTo(self.contentView.mas_right);
  }];
}

- (void)installWithModel:(NEListenTogetherInfo *)model indexPath:(NSIndexPath *)indexPath {
  self.roomName.text = model.liveModel.liveTopic;
  self.anchorName.text = model.anchor.userName;
  [self.coverView sd_setImageWithURL:[NSURL URLWithString:model.liveModel.cover]];
  self.audienceNum.text = [NSString
      stringWithFormat:@"%@人", [NSString praiseStrFormat:MAX(model.liveModel.audienceCount + 1,
                                                              model.liveModel.onSeatCount)]];
  //    if (model.roomType == NELiveRoomTypeKtv && model.currentMusicName) {
  if (model.liveModel.liveType == NEListenTogetherLiveRoomTypeListen_together) {
    self.tagButton.hidden = NO;
    //        [self.tagButton setTitle:model.currentMusicName forState:UIControlStateNormal];
  } else {
    self.tagButton.hidden = YES;
  }
}

+ (NEListenTogetherUILiveListCell *)cellWithCollectionView:(UICollectionView *)collectionView
                                                 indexPath:(NSIndexPath *)indexPath
                                                     datas:
                                                         (NSArray<NEListenTogetherInfo *> *)datas {
  if (indexPath.row >= [datas count]) {
    return [NEListenTogetherUILiveListCell new];
  }
  NEListenTogetherUILiveListCell *cell = [collectionView
      dequeueReusableCellWithReuseIdentifier:[NEListenTogetherUILiveListCell description]
                                forIndexPath:indexPath];
  NEListenTogetherInfo *model = datas[indexPath.row];
  [cell installWithModel:model indexPath:indexPath];
  return cell;
}

+ (CGSize)size {
  CGFloat length = (UIScreenWidth - 8 * 3) / 2.0;
  return CGSizeMake(length, length);
}

#pragma mark - lazy load

- (UIImageView *)coverView {
  if (!_coverView) {
    _coverView = [[UIImageView alloc] init];
    _coverView.contentMode = UIViewContentModeScaleAspectFill;
    _coverView.layer.cornerRadius = 4;
    _coverView.layer.masksToBounds = YES;
  }
  return _coverView;
}

- (CAGradientLayer *)shadowLayer {
  if (!_shadowLayer) {
    _shadowLayer = [CAGradientLayer layer];
    NSArray *colors =
        [NSArray arrayWithObjects:(id)[[UIColor colorWithWhite:1 alpha:0] CGColor],
                                  (id)[[UIColor colorWithWhite:0 alpha:0.4] CGColor], nil];
    [_shadowLayer setColors:colors];
    [_shadowLayer setStartPoint:CGPointMake(0.0f, 0.4f)];
    [_shadowLayer setEndPoint:CGPointMake(0.0f, 1.0f)];
    CGFloat length = (UIScreenWidth - 8 * 3) / 2.0;
    [_shadowLayer setFrame:CGRectMake(0, 0, length, length)];
  }
  return _shadowLayer;
}

- (UILabel *)roomName {
  if (!_roomName) {
    _roomName = [[UILabel alloc] init];
    _roomName.font = [UIFont systemFontOfSize:13];
    _roomName.textColor = [UIColor whiteColor];
    _roomName.text = @"房间名称";
  }
  return _roomName;
}

- (UILabel *)anchorName {
  if (!_anchorName) {
    _anchorName = [[UILabel alloc] init];
    _anchorName.font = [UIFont systemFontOfSize:12];
    _anchorName.textColor = [UIColor whiteColor];
    _anchorName.text = @"主播名称";
  }
  return _anchorName;
}

- (UILabel *)audienceNum {
  if (!_audienceNum) {
    _audienceNum = [[UILabel alloc] init];
    _audienceNum.font = [UIFont systemFontOfSize:12];
    _audienceNum.textColor = [UIColor whiteColor];
    _audienceNum.text = @"1234";
    _audienceNum.textAlignment = NSTextAlignmentRight;
  }
  return _audienceNum;
}
- (UIButton *)tagButton {
  if (!_tagButton) {
    _tagButton = [[UIButton alloc] init];
    [_tagButton setImage:[NEListenTogetherUI ne_listen_imageName:@"music_ico"]
                forState:UIControlStateNormal];
    [_tagButton layoutButtonWithEdgeInsetsStyle:QSButtonEdgeInsetsStyleLeft imageTitleSpace:3];
    _tagButton.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    _tagButton.hidden = YES;
  }
  return _tagButton;
}
@end
