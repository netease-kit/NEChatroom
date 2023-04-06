// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEListenTogetherUIConnectListCell.h"
#import <NEUIKit/UIView+NEUIExtension.h>
#import <SDWebImage/SDWebImage.h>
#import "NEListenTogetherLocalized.h"
#import "NEListenTogetherUI.h"

@interface NEListenTogetherUIConnectListCell ()
@property(nonatomic, strong) UIView *bottomLine;
@property(nonatomic, strong) UIImageView *avatar;
@property(nonatomic, strong) UILabel *nameLabel;
@property(nonatomic, strong) UIButton *acceptBtn;
@property(nonatomic, strong) UIButton *rejectBtn;
@property(nonatomic, strong) NEListenTogetherSeatItem *seatItem;
@end

@implementation NEListenTogetherUIConnectListCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier {
  if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
    self.backgroundColor = [UIColor clearColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self.contentView addSubview:self.bottomLine];
    [self.contentView addSubview:self.avatar];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.acceptBtn];
    [self.contentView addSubview:self.rejectBtn];
  }
  return self;
}
- (void)layoutSubviews {
  [super layoutSubviews];

  _bottomLine.frame = CGRectMake(16, self.height - 0.5, self.width - 16.0 * 2, 0.5);
  _avatar.frame = CGRectMake(16, 0, 32.0, 32.0);
  _avatar.centerY = self.height / 2;
  _acceptBtn.frame = CGRectMake(self.width - 16.0 - 16, 0, 16.0, 16.0);
  _acceptBtn.centerY = _avatar.centerY;
  _rejectBtn.frame = CGRectMake(self.width - _acceptBtn.width - 32.0 - 16.0, 0, 16, 16);
  _rejectBtn.centerY = _acceptBtn.centerY;
  _nameLabel.frame =
      CGRectMake(_avatar.right + 8.0, 0, _rejectBtn.left - _avatar.right - 10.0, _nameLabel.height);
  _nameLabel.centerY = _avatar.centerY;
}

- (void)_loadData:(NEListenTogetherSeatItem *)data indexPath:(NSIndexPath *)indexPath {
  self.seatItem = data;
  _nameLabel.text =
      [NSString stringWithFormat:@"%@ %@%d", data.userName, NELocalizedString(@"申请麦位"),
                                 (int)(data.index - 1)];
  [self.avatar sd_setImageWithURL:[NSURL URLWithString:data.icon]];
}
+ (NEListenTogetherUIConnectListCell *)cellWithTableView:(UITableView *)tableView
                                                   datas:
                                                       (NSArray<NEListenTogetherSeatItem *> *)datas
                                               indexPath:(NSIndexPath *)indexPath {
  if ([datas count] > indexPath.row) {
    NEListenTogetherSeatItem *data = [datas objectAtIndex:indexPath.row];
    NEListenTogetherUIConnectListCell *cell = [tableView
        dequeueReusableCellWithIdentifier:[NEListenTogetherUIConnectListCell description]];
    [cell _loadData:data indexPath:indexPath];
    return cell;
  }
  return [NEListenTogetherUIConnectListCell new];
}
- (void)awakeFromNib {
  [super awakeFromNib];
  // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
  [super setSelected:selected animated:animated];
  // Configure the view for the selected state
}
- (void)onAcceptBtnPressed {
  if (self.acceptBlock) {
    self.acceptBlock(self.seatItem);
  }
}
- (void)onRejectBtnPressed {
  if (self.rejectBlock) {
    self.rejectBlock(self.seatItem);
  }
}
#pragma mark------------------------ Getter ------------------------
- (UIView *)bottomLine {
  if (!_bottomLine) {
    _bottomLine = [[UIView alloc] init];
    _bottomLine.backgroundColor = [UIColor colorWithWhite:1 alpha:0.2];
  }
  return _bottomLine;
}

- (UIImageView *)avatar {
  if (!_avatar) {
    _avatar = [[UIImageView alloc] initWithFrame:CGRectZero];
    _avatar.layer.cornerRadius = 16.0;
    _avatar.layer.masksToBounds = YES;
  }
  return _avatar;
}

- (UILabel *)nameLabel {
  if (!_nameLabel) {
    UILabel *nameLabel = [[UILabel alloc] init];
    [nameLabel setTextColor:[UIColor whiteColor]];
    nameLabel.font = [UIFont systemFontOfSize:14];
    nameLabel.text = NELocalizedString(@"未知");
    nameLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    [nameLabel sizeToFit];
    _nameLabel = nameLabel;
  }
  return _nameLabel;
}

- (UIButton *)acceptBtn {
  if (!_acceptBtn) {
    UIButton *acceptBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [acceptBtn addTarget:self
                  action:@selector(onAcceptBtnPressed)
        forControlEvents:UIControlEventTouchUpInside];
    [acceptBtn setImage:[NEListenTogetherUI ne_listen_imageName:@"icon_yes_n"]
               forState:UIControlStateNormal];
    _acceptBtn = acceptBtn;
  }
  return _acceptBtn;
}

- (UIButton *)rejectBtn {
  if (!_rejectBtn) {
    UIButton *rejectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rejectBtn addTarget:self
                  action:@selector(onRejectBtnPressed)
        forControlEvents:UIControlEventTouchUpInside];
    [rejectBtn setImage:[NEListenTogetherUI ne_listen_imageName:@"icon_no_n"]
               forState:UIControlStateNormal];
    _rejectBtn = rejectBtn;
  }
  return _rejectBtn;
}
@end
