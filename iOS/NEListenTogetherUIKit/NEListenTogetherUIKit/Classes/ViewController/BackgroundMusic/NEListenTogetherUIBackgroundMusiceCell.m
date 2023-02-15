// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEListenTogetherUIBackgroundMusiceCell.h"

@implementation NEListenTogetherUIBackgroundMusiceCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier {
  self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
  if (self) {
    self.indexLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.indexLabel.font = [UIFont systemFontOfSize:14];
    self.indexLabel.textColor = [UIColor colorWithRed:153 / 255.0
                                                green:153 / 255.0
                                                 blue:153 / 255.0
                                                alpha:1.0];
    [self.contentView addSubview:self.indexLabel];

    self.playingAnimationView = [LOTAnimationView animationNamed:@"playing"];
    self.playingAnimationView.hidden = YES;
    self.playingAnimationView.loopAnimation = YES;
    [self.contentView addSubview:self.playingAnimationView];

    self.textLabel.font = [UIFont systemFontOfSize:14];
    self.textLabel.textColor = [UIColor colorWithRed:34 / 255.0
                                               green:34 / 255.0
                                                blue:34 / 255.0
                                               alpha:1.0];

    self.detailTextLabel.font = [UIFont systemFontOfSize:12];
    self.detailTextLabel.textColor = [UIColor colorWithRed:153 / 255.0
                                                     green:153 / 255.0
                                                      blue:153 / 255.0
                                                     alpha:1.0];
  }
  return self;
}

- (void)layoutSubviews {
  [super layoutSubviews];
  self.indexLabel.frame = CGRectMake(20, 8, 18, 22);
  self.playingAnimationView.frame = self.indexLabel.frame;
  self.textLabel.frame = CGRectMake(
      CGRectGetMaxX(self.indexLabel.frame) + 8, 8,
      self.contentView.frame.size.width - CGRectGetMaxX(self.indexLabel.frame) - 8 - 20 * 2, 22);
  self.detailTextLabel.frame =
      CGRectMake(self.textLabel.frame.origin.x, CGRectGetMaxY(self.textLabel.frame),
                 self.textLabel.frame.size.width, 18);
}
- (void)awakeFromNib {
  [super awakeFromNib];
  // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
  [super setSelected:selected animated:animated];

  // Configure the view for the selected state
}

@end
