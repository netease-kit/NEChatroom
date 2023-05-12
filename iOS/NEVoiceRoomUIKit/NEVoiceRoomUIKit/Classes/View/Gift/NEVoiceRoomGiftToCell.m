// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEVoiceRoomGiftToCell.h"
#import <SDWebImage/SDWebImage.h>
#import "NEVoiceRoomGiftEngine.h"
#import "NEVoiceRoomLocalized.h"
#import "NEVoiceRoomUI.h"
#import "NTESGlobalMacro.h"

@interface NEVoiceRoomGiftToCell ()
@property(nonatomic, strong) UIView *bgView;
@property(nonatomic, strong) UIImageView *icon;
@property(nonatomic, strong) UILabel *info;
@property(nonatomic, strong) UILabel *backColorLabel;

@end
@implementation NEVoiceRoomGiftToCell

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    self.contentView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.bgView];
    [self.bgView addSubview:self.backColorLabel];
    [self.bgView addSubview:self.icon];
    [self.bgView addSubview:self.info];
  }
  return self;
}

- (void)layoutSubviews {
  self.bgView.frame = CGRectMake(0, 0, 38, 47);
  self.backColorLabel.frame = CGRectMake(3, 1, 32, 32);
  self.backColorLabel.backgroundColor = HEXCOLOR(0x337EFF);
  self.backColorLabel.layer.masksToBounds = YES;
  self.backColorLabel.layer.cornerRadius = 16;
  self.icon.frame = CGRectMake(4, 2, 30, 30);
  self.icon.layer.masksToBounds = YES;
  self.icon.layer.cornerRadius = 15;
  self.info.textAlignment = NSTextAlignmentCenter;
  self.info.font = [UIFont systemFontOfSize:10];
  self.info.frame =
      CGRectMake(0, self.icon.frame.size.height + self.icon.frame.origin.y + 4, 38, 12);
}

/// 计算直播列表页cell size
+ (CGSize)size {
  return CGSizeMake(([UIScreen mainScreen].bounds.size.width - 32) / 9.0, 47);
  //  return CGSizeMake(38, 47);
}

+ (NEVoiceRoomGiftToCell *)cellWithCollectionView:(UICollectionView *)collectionView
                                        indexPath:(NSIndexPath *)indexPath
                                       anchorData:(NEVoiceRoomSeatItem *)anchorData
                                            datas:(NSArray<NEVoiceRoomSeatItem *> *)datas {
  NEVoiceRoomGiftToCell *cell =
      [collectionView dequeueReusableCellWithReuseIdentifier:[NEVoiceRoomGiftToCell description]
                                                forIndexPath:indexPath];
  if ([[NEVoiceRoomGiftEngine getInstance].selectedSeatDatas
          containsObject:[NSNumber numberWithLong:indexPath.row]]) {
    cell.backColorLabel.hidden = NO;
    cell.info.textColor = HEXCOLOR(0x337EFF);
  } else {
    cell.backColorLabel.hidden = YES;
    cell.info.textColor = HEXCOLOR(0x666666);
  }
  cell.icon.image = [NEVoiceRoomUI ne_voice_imageName:@"default_seat_icon"];
  if (indexPath.row == 0) {
    NSLog(@"主播头像 --- %@", anchorData.icon);
    [cell installWithModel:anchorData];
    cell.info.text = NELocalizedString(@"主持");
  } else {
    cell.info.text = [NSString stringWithFormat:@"%ld", indexPath.row];
    if ([datas count] > indexPath.row - 1) {
      NEVoiceRoomSeatItem *item = datas[indexPath.row - 1];
      NSLog(@"ceollcetion model - index %ld ,status = %ld ,icon = %@", (long)indexPath.row - 1,
            (long)item.status, item.icon);
      if (item.status == NEVoiceRoomSeatItemStatusTaken) {
        [cell installWithModel:item];
      }
    }
  }

  return cell;
}

- (void)installWithModel:(NEVoiceRoomSeatItem *)model {
  if (model.icon.length > 0) {
    [self.icon sd_setImageWithURL:[NSURL URLWithString:model.icon]
                 placeholderImage:[NEVoiceRoomUI ne_voice_imageName:@"default_seat_icon"]];
  }
}

#pragma mark - lazy load

- (UIView *)bgView {
  if (!_bgView) {
    _bgView = [[UIView alloc] init];
    _bgView.layer.cornerRadius = 4;
    _bgView.layer.masksToBounds = YES;
  }
  return _bgView;
}

- (UIImageView *)icon {
  if (!_icon) {
    _icon = [[UIImageView alloc] init];
  }
  return _icon;
}

- (UILabel *)info {
  if (!_info) {
    _info = [[UILabel alloc] init];
    _info.numberOfLines = 1;
    _info.textAlignment = NSTextAlignmentCenter;
  }
  return _info;
}
- (UILabel *)backColorLabel {
  if (!_backColorLabel) {
    _backColorLabel = [[UILabel alloc] init];
  }
  return _backColorLabel;
}

@end
