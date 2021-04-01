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
#import "UIButton+NTES.h"

@interface NTESConnectListViewCell ()

@property (nonatomic, weak)id<NTESConnectListViewCellDelegate> delegate;

@property (nonatomic, strong) UIView    *bottomLine;
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
        
        [self.contentView addSubview:self.bottomLine];
        [self.contentView addSubview:self.avatar];
        [self.contentView addSubview:self.nameLabel];
        [self.contentView addSubview:self.acceptBtn];
        [self.contentView addSubview:self.rejectBtn];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _bottomLine.frame = CGRectMake(16, self.height - 0.5, self.width - 16.0 * 2, 0.5);
    _avatar.frame = CGRectMake(16, 0, 32.0, 32.0);
    _avatar.centerY = self.height / 2;
    _acceptBtn.frame = CGRectMake(self.width - 16.0 - 16, 0, 16.0, 16.0);
    _acceptBtn.centerY = _avatar.centerY;
    _rejectBtn.frame = CGRectMake(self.width - _acceptBtn.width - 32.0 - 16.0, 0, 16, 16);
    _rejectBtn.centerY = _acceptBtn.centerY;
    _nameLabel.frame = CGRectMake(_avatar.right + 8.0,
                                  0,
                                  _rejectBtn.left-_avatar.right-10.0,
                                  _nameLabel.height);
    _nameLabel.centerY = _avatar.centerY;
}

- (void)_loadData:(NTESMicInfo *)data indexPath:(NSIndexPath *)indexPath
{
    self.micInfo = data;
    _nameLabel.text = [NSString stringWithFormat:@"%@ 申请麦位%d", data.userInfo.nickName, (int)data.micOrder];
    [self.avatar yy_setImageWithURL:[NSURL URLWithString:data.userInfo.icon] placeholder:nil];
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

+ (NTESConnectListViewCell *)cellWithTableView:(UITableView *)tableView
                                          datas:(NSArray<NTESMicInfo *> *)datas
                                      delegate:(id<NTESConnectListViewCellDelegate>)delegate
                                     indexPath:(NSIndexPath *)indexPath
{
    if ([datas count] > indexPath.row) {
        NTESMicInfo *data = [datas objectAtIndex:indexPath.row];
        NTESConnectListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[NTESConnectListViewCell description]];
        [cell _loadData:data indexPath:indexPath];
        cell.delegate = delegate;
        
        return cell;
    }
    return [NTESConnectListViewCell new];
}

#pragma mark - lazy load

- (UIView *)bottomLine
{
    if (!_bottomLine) {
        _bottomLine = [[UIView alloc] init];
        _bottomLine.backgroundColor = [UIColor colorWithWhite:1 alpha:0.2];
    }
    return _bottomLine;
}

- (UIImageView *)avatar
{
    if (!_avatar) {
        _avatar = [[UIImageView alloc] initWithFrame:CGRectZero];
        _avatar.layer.cornerRadius = 16.0;
        _avatar.layer.masksToBounds = YES;
    }
    return _avatar;
}

- (UILabel *)nameLabel
{
    if (!_nameLabel)
    {
        UILabel *nameLabel = [[UILabel alloc] init];
        [nameLabel setTextColor:[UIColor whiteColor]];
        nameLabel.font = [UIFont systemFontOfSize:14];
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
