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
    }
}

- (void)refresh:(NIMChatroomMember *)member {
    //title
    _titleLab.text = member.roomNickname ?: @"";
    [_titleLab sizeToFit];
    
    //image
    if (member.roomAvatar) {
        NSURL *url = [NSURL URLWithString:member.roomAvatar];
        __weak typeof(self) weakSelf = self;
        [_iconView yy_setImageWithURL:url
                          placeholder:_placeholder
                              options:YYWebImageOptionAvoidSetImage
                           completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
                            if (!error) {
                                image = [image yy_imageByRoundCornerRadius:(image.size.width/2)];
                                weakSelf.iconView.image = image;
                            }
                        }];
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
        _titleLab.textColor = [UIColor whiteColor];
        _titleLab.font = [UIFont systemFontOfSize:15.0];
        _titleLab.text = @"未知";
        [_titleLab sizeToFit];
    }
    return _titleLab;
}

@end
