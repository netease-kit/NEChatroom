// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEListenTogetherUIUserInfoCell.h"
#import <NEUIKit/UIColor+NEUIExtension.h>
#import <NEUIKit/UIFont+NEUIExtension.h>
#import <NEUIKit/UIView+NEUIExtension.h>
#import <SDWebImage/SDWebImage.h>
#import "NEListenTogetherLocalized.h"
#import "NEListenTogetherUI.h"

@interface NEListenTogetherUIUserInfoCell () {
  CGRect _preRect;
}
@property(nonatomic, strong) UIImageView *iconView;
@property(nonatomic, strong) UILabel *titleLab;
@property(nonatomic, strong) UIImage *placeholder;
@property(nonatomic, strong) UIView *bottomLineView;
@end

@implementation NEListenTogetherUIUserInfoCell

- (void)awakeFromNib {
  [super awakeFromNib];
  // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
  [super setSelected:selected animated:animated];

  // Configure the view for the selected state
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier {
  if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
    self.backgroundColor = [UIColor clearColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self addSubview:self.iconView];
    [self addSubview:self.titleLab];
    [self addSubview:self.bottomLineView];
  }
  return self;
}

- (void)layoutSubviews {
  [super layoutSubviews];
  if (!CGRectEqualToRect(self.bounds, _preRect)) {
    _iconView.frame = CGRectMake(15.0, 0, 32.0, 32.0);
    _iconView.centerY = self.height / 2;
    _titleLab.frame = CGRectMake(_iconView.right + 10, 0, self.width - 10 - _iconView.right - 10,
                                 _titleLab.height);
    _titleLab.centerY = _iconView.centerY;
    _preRect = self.bounds;
    _bottomLineView.frame = CGRectMake(20, self.height - 0.5, self.width - 40, 0.5);
  }
  [_iconView ne_cornerRadii:CGSizeMake(_iconView.width / 2, _iconView.width / 2)
             addRectCorners:UIRectCornerAllCorners];
}

- (void)refresh:(NEListenTogetherMember *)member {
  // title
  _titleLab.text = member.name ?: @"";
  [_titleLab sizeToFit];

  // image
  if (member.avatar) {
    NSURL *url = [NSURL URLWithString:member.avatar];
    [_iconView sd_setImageWithURL:url
                 placeholderImage:[NEListenTogetherUI ne_listen_imageName:@"default_user_icon"]];
  }
}

#pragma mark - Getter
- (UIImageView *)iconView {
  if (!_iconView) {
    _iconView = [[UIImageView alloc] init];
    _iconView.contentMode = UIViewContentModeScaleAspectFit;
    _placeholder = [UIImage imageNamed:@"default_user_icon"];
    _iconView.image = _placeholder;
  }
  return _iconView;
}

- (UILabel *)titleLab {
  if (!_titleLab) {
    _titleLab = [[UILabel alloc] init];
    _titleLab.textColor = [UIColor ne_colorWithHex:0x222222];
    _titleLab.font = [UIFont ne_font:14];
    _titleLab.text = NELocalizedString(@"未知");
    [_titleLab sizeToFit];
  }
  return _titleLab;
}

- (UIView *)bottomLineView {
  if (!_bottomLineView) {
    _bottomLineView = [[UIView alloc] init];
    _bottomLineView.backgroundColor = [UIColor ne_colorWithHex:0xE6E7EB];
  }
  return _bottomLineView;
}

@end
