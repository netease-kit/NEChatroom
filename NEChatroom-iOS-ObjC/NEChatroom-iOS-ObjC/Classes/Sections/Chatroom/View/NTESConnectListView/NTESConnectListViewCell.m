//
//  NTESConnectListViewCell.m
//  NERtcAudioChatroom
//
//  Created by Simon Blue on 2019/1/28.
//  Copyright © 2019年 netease. All rights reserved.
//

#import "NTESConnectListViewCell.h"
#import "UIView+NTES.h"
#import "NTESMicInfo.h"
#import "UIImageView+YYWebImage.h"

@interface NTESConnectListViewCell ()
@property (nonatomic, strong) UIImageView *avatar;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIButton *acceptBtn;
@property (nonatomic, strong) UIButton *rejectBtn;
@property (nonatomic, strong) NTESMicInfo *micInfo;

@end

@implementation NTESConnectListViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self addSubview:self.avatar];
        [self addSubview:self.nameLabel];
        [self addSubview:self.acceptBtn];
        [self addSubview:self.rejectBtn];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _avatar.frame = CGRectMake(20, 0, 40.0, 40.0);
    _avatar.centerY = self.height / 2;
    _acceptBtn.frame = CGRectMake(self.width-32.0, 0, 32.0, 32.0);
    _acceptBtn.centerY = _avatar.centerY;
    _rejectBtn.frame = CGRectMake(self.width-_acceptBtn.width-32.0, 0, _acceptBtn.width, _acceptBtn.width);
    _rejectBtn.centerY = _acceptBtn.centerY;
    _nameLabel.frame = CGRectMake(_avatar.right + 10.0,
                                  0,
                                  _rejectBtn.left-_avatar.right-10.0,
                                  _nameLabel.height);
    _nameLabel.centerY = _avatar.centerY;
}

- (void)refresh:(NTESMicInfo *)micInfo
{
    self.micInfo = micInfo;
    NSString *info = [NSString stringWithFormat:@"%@ 申请麦位%d",
                      micInfo.userInfo.nickName, (int)micInfo.micOrder];
    _nameLabel.text = info;
    [self.avatar yy_setImageWithURL:[NSURL URLWithString:micInfo.userInfo.icon] placeholder:nil];
}

- (void)onAcceptBtnPressed
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(onAcceptBtnPressedWithMicInfo:)]) {
        [self.delegate onAcceptBtnPressedWithMicInfo:self.micInfo];
    }
}

- (void)onRejectBtnPressed
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(onRejectBtnPressedWithMicInfo:)]) {
        [self.delegate onRejectBtnPressedWithMicInfo:self.micInfo];
    }
}

- (UIImageView *)avatar
{
    if (!_avatar) {
        UIImageView *avatar = [[UIImageView alloc] initWithFrame:CGRectZero];
        _avatar = avatar;
        [self.contentView addSubview:_avatar];
    }
    return _avatar;
}

- (UILabel *)nameLabel
{
    if (!_nameLabel)
    {
        UILabel *nameLabel = [[UILabel alloc] init];
        [nameLabel setTextColor:[UIColor whiteColor]];
        nameLabel.font = [UIFont systemFontOfSize:15];
        nameLabel.text = @"未知";
        nameLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        [nameLabel sizeToFit];
        _nameLabel = nameLabel;
    }
    return _nameLabel;
}

- (UIButton *)acceptBtn
{
    if (!_acceptBtn) {
        UIButton *acceptBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [acceptBtn addTarget:self action:@selector(onAcceptBtnPressed)  forControlEvents:UIControlEventTouchUpInside];
        [acceptBtn setImage:[UIImage imageNamed:@"icon_yes_n"] forState:UIControlStateNormal];
        _acceptBtn = acceptBtn;
    }
    return _acceptBtn;
}

- (UIButton *)rejectBtn
{
    if (!_rejectBtn) {
        UIButton *rejectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [rejectBtn addTarget:self action:@selector(onRejectBtnPressed)  forControlEvents:UIControlEventTouchUpInside];
        [rejectBtn setImage:[UIImage imageNamed:@"icon_no_n"] forState:UIControlStateNormal];
        _rejectBtn = rejectBtn;
    }
    return _rejectBtn;
}
@end
