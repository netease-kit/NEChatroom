// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEVoiceRoomGiftNumCell.h"
#import "NTESGlobalMacro.h"
@interface NEVoiceRoomGiftNumCell ()
@property(nonatomic, strong) UILabel *info;
@property(nonatomic, strong) UIView *foreCoverView;

@end
@implementation NEVoiceRoomGiftNumCell

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
  }
  return self;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier {
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    self.contentView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.foreCoverView];
    [self.contentView addSubview:self.info];
  }
  return self;
}

- (void)layoutSubviews {
  self.foreCoverView.frame = CGRectMake(12, 0, 96, 28);
  self.info.frame = CGRectMake(12, 0, 96, 28);
}

+ (NEVoiceRoomGiftNumCell *)cellWithTableView:(UITableView *)tableView
                                    indexPath:(NSIndexPath *)indexPath
                                currentNumber:(NSString *)number
                                        datas:(NSArray *)datas {
  NEVoiceRoomGiftNumCell *cell =
      [tableView dequeueReusableCellWithIdentifier:NEVoiceRoomGiftNumCell.description
                                      forIndexPath:indexPath];
  NSNumber *value = datas[indexPath.row];
  NSString *valueString = [NSString stringWithFormat:@"%@", value];
  cell.info.text = valueString;
  if ([valueString isEqualToString:number]) {
    cell.info.textColor = HEXCOLOR(0x337EFF);
    cell.foreCoverView.backgroundColor = HEXCOLOR(0x337EFF);
    cell.foreCoverView.alpha = 0.1;
  } else {
    cell.info.textColor = HEXCOLOR(0x333333);
    cell.foreCoverView.backgroundColor = [UIColor clearColor];
    cell.foreCoverView.alpha = 1;
  }
  return cell;
}

#pragma mark - lazy load

- (UIView *)foreCoverView {
  if (!_foreCoverView) {
    _foreCoverView = [[UIView alloc] init];
    _foreCoverView.layer.masksToBounds = YES;
    _foreCoverView.layer.cornerRadius = 14;
  }
  return _foreCoverView;
}

- (UILabel *)info {
  if (!_info) {
    _info = [[UILabel alloc] init];
    _info.font = [UIFont systemFontOfSize:14];
    _info.textColor = HEXCOLOR(0x333333);
    _info.numberOfLines = 1;
    _info.textAlignment = NSTextAlignmentCenter;
  }
  return _info;
}

@end
