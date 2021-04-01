//
//  NTESUserInfoCell.m
//  NERtcAudioChatroom
//
//  Created by Netease on 2019/3/6.
//  Copyright © 2019年 netease. All rights reserved.
//

#import "NTESUserInfoCell.h"
#import "UIView+NTES.h"
#import "UIImage+YYWebImage.h"
#import "UIImageView+YYWebImage.h"

@interface NTESUserInfoCell ()
{
    CGRect _preRect;
}
@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *titleLab;
@property (nonatomic, strong) UIImage *placeholder;
@property (nonatomic, strong) UIView *bottomLineView;

@end

@implementation NTESUserInfoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
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
        _iconView.centerY = self.height/2;
        _titleLab.frame = CGRectMake(_iconView.right + 10,
                                     0,
                                     self.width-10-_iconView.right-10,
                                     _titleLab.height);
        _titleLab.centerY = _iconView.centerY;
        _preRect = self.bounds;
        _bottomLineView.frame = CGRectMake(20, self.height-0.5, self.width-40, 0.5);
    }
    [_iconView cutViewRounded:UIRectCornerAllCorners cornerRadii:CGSizeMake(_iconView.width/2, _iconView.width/2)];
    
}

- (void)refresh:(NIMChatroomMember *)member {
    //title
    _titleLab.text = member.roomNickname ?: @"";
    [_titleLab sizeToFit];
    
    //image
    if (member.roomAvatar) {
        NSURL *url = [NSURL URLWithString:member.roomAvatar];
        [_iconView yy_setImageWithURL:url placeholder:[UIImage imageNamed:@"default_user_icon"]];
        
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
        _titleLab.textColor = UIColorFromRGB(0x222222);
        _titleLab.font = TextFont_14;
        _titleLab.text = @"未知";
        [_titleLab sizeToFit];
    }
    return _titleLab;
}

- (UIView *)bottomLineView {
    if (!_bottomLineView) {
        _bottomLineView = [[UIView alloc]init];
        _bottomLineView.backgroundColor = UIColorFromRGB(0xE6E7EB);
    }
    return _bottomLineView;
}
@end
