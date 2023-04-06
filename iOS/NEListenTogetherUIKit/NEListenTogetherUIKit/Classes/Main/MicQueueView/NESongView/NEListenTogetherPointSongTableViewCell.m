// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEListenTogetherPointSongTableViewCell.h"
#import <Masonry/Masonry.h>
#import "NEListenTogetherGlobalMacro.h"
#import "NEListenTogetherLocalized.h"
#import "NEListenTogetherPickSongColorDefine.h"

@interface NEListenTogetherPointSongTableViewCell ()

@end

@implementation NEListenTogetherPointSongTableViewCell

- (void)awakeFromNib {
  [super awakeFromNib];
  // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier {
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    [self initView];
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
  }
  return self;
}

- (void)initView {
  self.songImageView = [[UIImageView alloc] init];
  self.songImageView.layer.cornerRadius = 5;
  self.songImageView.layer.masksToBounds = YES;
  [self.contentView addSubview:_songImageView];
  [self.songImageView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.height.width.equalTo(@46);
    make.centerY.equalTo(self.contentView);
    make.left.equalTo(self.contentView.mas_left).offset(20);
  }];

  self.songLabel = [[UILabel alloc] init];
  self.songLabel.font = [UIFont systemFontOfSize:16];
  self.songLabel.textColor = HEXCOLOR(0x222222);
  [self.contentView addSubview:self.songLabel];
  [self.songLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self.songImageView.mas_right).offset(8);
    make.centerY.equalTo(self.contentView).offset(-8);
    make.width.lessThanOrEqualTo(@152);
  }];

  self.resourceImageView = [[UIImageView alloc] init];
  self.resourceImageView.contentMode = UIViewContentModeCenter;
  [self.contentView addSubview:self.resourceImageView];
  [self.resourceImageView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self.songLabel.mas_right).offset(9);
    make.centerY.equalTo(self.songLabel.mas_centerY);
    make.height.lessThanOrEqualTo(@14);
    make.width.lessThanOrEqualTo(@52);
  }];

  self.anchorLabel = [[UILabel alloc] init];
  self.anchorLabel.font = [UIFont systemFontOfSize:12];
  self.anchorLabel.textColor = HEXCOLOR(0x999999);
  [self.contentView addSubview:self.anchorLabel];
  [self.anchorLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self.songLabel);
    make.top.equalTo(self.songLabel.mas_bottom).offset(6);
  }];

  self.pointButton = [[UIButton alloc] init];
  [self.pointButton setTitle:NELocalizedString(@"点歌") forState:UIControlStateNormal];
  CAGradientLayer *gradientLayer = [CAGradientLayer layer];
  gradientLayer.frame = CGRectMake(0, 0, 48, 24);
  gradientLayer.startPoint = CGPointMake(0, 0);
  gradientLayer.endPoint = CGPointMake(1, 0);
  gradientLayer.locations = @[ @(0.5), @(1.0) ];  // 渐变点
  [gradientLayer setColors:@[
    (id)[HEXCOLOR(0xFE7081) CGColor],
    (id)[HEXCOLOR(0xFF4FA6) CGColor]
  ]];  // 渐变数组
  [self.pointButton.layer addSublayer:gradientLayer];

  self.pointButton.titleLabel.font = [UIFont systemFontOfSize:14];
  self.pointButton.titleLabel.textColor = [UIColor whiteColor];
  [self.contentView addSubview:self.pointButton];
  self.pointButton.layer.cornerRadius = 12;
  self.pointButton.layer.masksToBounds = YES;
  [self.pointButton addTarget:self
                       action:@selector(clickPointButton:)
             forControlEvents:UIControlEventTouchUpInside];
  [self.pointButton mas_makeConstraints:^(MASConstraintMaker *make) {
    make.centerY.equalTo(self.contentView);
    make.width.equalTo(@48);
    make.height.equalTo(@24);
    make.right.equalTo(self.contentView).offset(-21);
  }];

  self.downloadingLabel = [[UILabel alloc] init];
  self.downloadingLabel.text = NELocalizedString(@"下载中");
  self.downloadingLabel.textColor = HEXCOLOR(0x333333);
  self.downloadingLabel.font = [UIFont systemFontOfSize:14];
  [self.contentView addSubview:self.downloadingLabel];
  [self.downloadingLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.centerY.equalTo(self.songLabel.mas_bottom);
    make.right.equalTo(self.mas_right).offset(-40);
  }];

  self.statueBottomLabel = [[UILabel alloc] init];
  self.statueBottomLabel.layer.masksToBounds = YES;
  self.statueBottomLabel.layer.cornerRadius = 2;
  self.statueBottomLabel.backgroundColor = HEXCOLOR(0xE6EBF4);
  [self.contentView addSubview:self.statueBottomLabel];
  [self.statueBottomLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.width.equalTo(@78);
    make.height.equalTo(@4);
    make.top.equalTo(self.downloadingLabel.mas_bottom);
    make.centerX.equalTo(self.downloadingLabel.mas_centerX);
  }];

  self.statueTopLabel = [[UILabel alloc] init];
  self.statueTopLabel.backgroundColor = HEXCOLOR(0xFE7081);
  self.statueTopLabel.layer.masksToBounds = YES;
  self.statueTopLabel.layer.cornerRadius = 2;
  [self.contentView addSubview:self.statueTopLabel];
  [self.statueTopLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(self.downloadingLabel.mas_bottom);
    make.left.equalTo(self.statueBottomLabel.mas_left);
    make.width.equalTo(@0);
    make.height.equalTo(@4);
  }];
}

- (void)setProgress:(CGFloat)progress {
  _progress = progress;
  [self.statueTopLabel mas_updateConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(self.downloadingLabel.mas_bottom);
    make.left.equalTo(self.statueBottomLabel.mas_left);
    make.width.equalTo([NSNumber numberWithFloat:78 * progress]);
    make.height.equalTo(@4);
  }];
  //    [self.statueTopLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
  //        make.top.equalTo(self.downloadingLabel.mas_bottom);
  //        make.left.equalTo(self.statueBottomLabel.mas_left);
  //        make.width.equalTo([NSNumber numberWithFloat:78 * progress]);
  //        make.height.equalTo(@4);
  //    }];
}
- (void)drawRect:(CGRect)rect {
  // Drawing code
  // 1.获取上下文
  //    CGContextRef context=UIGraphicsGetCurrentContext();
  //    CGContextMoveToPoint(context, 0, 0);//先确立一个开始的点
  //
  //    ////设置终点。如果多于两个点时，可以重复调用这个方法，就会有多个折线
  //    CGContextAddLineToPoint(context, [[UIScreen
  //    mainScreen]bounds].size.width, [[UIScreen
  //    mainScreen]bounds].size.height);
  //
  //    CGContextSetLineWidth(context, 5.0);//后面的数值越大，线越粗
  //
  //    CGFloat components[] = {221.0/255,221.0/255,221.0/255,1.0f};
  //
  //    CGContextSetStrokeColor(context, components);
  //    CGContextStrokePath(context);
}

- (void)clickPointButton:(id)sender {
  self.clickPointButton();
}
@end
