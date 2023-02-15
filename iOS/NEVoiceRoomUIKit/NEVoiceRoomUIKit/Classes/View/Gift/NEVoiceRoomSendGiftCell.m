// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEVoiceRoomSendGiftCell.h"
#import "NEVoiceRoomUI.h"
#import "NTESGlobalMacro.h"
#import "UIImage+VoiceRoom.h"
@interface NEVoiceRoomSendGiftCell ()

@property(nonatomic, strong) UIView *bgView;
@property(nonatomic, strong) UIImageView *icon;
@property(nonatomic, strong) UILabel *info;
@property(nonatomic, strong) UIView *foreCoverView;

@end

@implementation NEVoiceRoomSendGiftCell

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    self.contentView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.bgView];
    [self.bgView addSubview:self.foreCoverView];
    [self.bgView addSubview:self.icon];
    [self.bgView addSubview:self.info];
  }
  return self;
}

- (void)layoutSubviews {
  self.bgView.frame = CGRectMake(4, 20, 72, 98);
  self.foreCoverView.frame = CGRectMake(1, 1, 70, 96);
  self.icon.frame = CGRectMake(16, 8, 40, 40);
  self.info.frame =
      CGRectMake(0, self.icon.frame.size.height + self.icon.frame.origin.y + 4, 72, 40);
}

- (void)setSelected:(BOOL)selected {
  if (selected) {
    self.bgView.layer.borderColor = HEXCOLOR(0x337EFF).CGColor;
    self.bgView.layer.borderWidth = 1;
    self.foreCoverView.backgroundColor = HEXCOLOR(0xECF3FF);
  } else {
    self.bgView.layer.borderWidth = 0;
    self.foreCoverView.backgroundColor = [UIColor clearColor];
  }
}

- (void)installWithModel:(NEVoiceRoomUIGiftModel *)model {
  self.icon.image = [UIImage nevoiceRoom_imageNamed:model.icon];
  self.info.attributedText = [self descriptionWithGift:model];
  self.info.textAlignment = NSTextAlignmentCenter;
}

- (NSAttributedString *)descriptionWithGift:(NEVoiceRoomUIGiftModel *)gift {
  NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
  style.minimumLineHeight = 20;
  style.maximumLineHeight = 20;

  NSDictionary *displayDic = @{
    NSFontAttributeName : [UIFont systemFontOfSize:13],
    NSForegroundColorAttributeName : HEXCOLOR(0x333333),
    NSParagraphStyleAttributeName : style
  };
  NSMutableAttributedString *res = [[NSMutableAttributedString alloc] initWithString:gift.display
                                                                          attributes:displayDic];

  UIFont *font = [UIFont systemFontOfSize:10];
  NSString *price = [NSString stringWithFormat:@" %d", gift.price];
  // 1.初始化富文本对象
  NSMutableAttributedString *attributedString =
      [[NSMutableAttributedString alloc] initWithString:price];
  // 2.字体属性
  [attributedString addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, price.length)];
  [attributedString addAttribute:NSForegroundColorAttributeName
                           value:HEXCOLOR(0xFFC86B)
                           range:NSMakeRange(0, price.length)];
  // 3.初始化NSTextAttachment对象
  NSTextAttachment *attchment = [[NSTextAttachment alloc] init];
  attchment.image = [NEVoiceRoomUI ne_imageName:@"gift_icon"];                 // 设置图片
  attchment.bounds = CGRectMake(0, round(font.capHeight - 10) / 2.0, 10, 10);  // 设置frame
  // 4.创建带有图片的富文本
  NSAttributedString *string =
      [NSAttributedString attributedStringWithAttachment:(NSTextAttachment *)(attchment)];
  [attributedString insertAttributedString:string atIndex:0];  // 插入到第几个下标
  [res appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
  [res appendAttributedString:attributedString];
  return [res copy];
}
- (NSAttributedString *)descriptionWithGasdift:(NEVoiceRoomUIGiftModel *)gift {
  NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
  style.minimumLineHeight = 20;
  style.maximumLineHeight = 20;

  NSDictionary *displayDic = @{
    NSFontAttributeName : [UIFont systemFontOfSize:13],
    NSForegroundColorAttributeName : [UIColor whiteColor],
    NSParagraphStyleAttributeName : style
  };
  NSDictionary *priceDic = @{
    NSFontAttributeName : [UIFont systemFontOfSize:12],
    NSForegroundColorAttributeName : HEXCOLOR(0x666666),
    NSParagraphStyleAttributeName : style
  };
  NSMutableAttributedString *res = [[NSMutableAttributedString alloc] initWithString:gift.display
                                                                          attributes:displayDic];
  NSAttributedString *price = [[NSAttributedString alloc]
      initWithString:[NSString stringWithFormat:NSLocalizedString(@"\n(%d云币)", nil), gift.price]
          attributes:priceDic];
  [res appendAttributedString:price];
  return [res copy];
}

+ (NEVoiceRoomSendGiftCell *)cellWithCollectionView:(UICollectionView *)collectionView
                                          indexPath:(NSIndexPath *)indexPath
                                              datas:(NSArray<NEVoiceRoomUIGiftModel *> *)datas {
  NEVoiceRoomSendGiftCell *cell =
      [collectionView dequeueReusableCellWithReuseIdentifier:[NEVoiceRoomSendGiftCell description]
                                                forIndexPath:indexPath];
  if ([datas count] > indexPath.row) {
    NEVoiceRoomUIGiftModel *gift = datas[indexPath.row];
    [cell installWithModel:gift];
  }
  return cell;
}

/// 计算直播列表页cell size
+ (CGSize)size {
  return CGSizeMake(([UIScreen mainScreen].bounds.size.width - 32) / 4.0, 136);
  //  return CGSizeMake(80, 136);
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

- (UIView *)foreCoverView {
  if (!_foreCoverView) {
    _foreCoverView = [[UIView alloc] init];
    _foreCoverView.layer.masksToBounds = YES;
    _foreCoverView.layer.cornerRadius = 4;
  }
  return _foreCoverView;
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
    _info.numberOfLines = 2;
  }
  return _info;
}

@end
