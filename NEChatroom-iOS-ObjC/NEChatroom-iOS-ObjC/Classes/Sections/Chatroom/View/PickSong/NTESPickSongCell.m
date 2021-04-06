//
//  NTESPickSongCell.m
//  NEChatroom-iOS-ObjC
//
//  Created by Think on 2021/2/1.
//  Copyright © 2021 netease. All rights reserved.
//

#import "NTESPickSongCell.h"
#import "NTESPickSongModel.h"
#import "UIImageView+YYWebImage.h"
#import "UIView+NTES.h"

@interface NTESPickSongCell ()

/// 头部分割线
@property (nonatomic, strong)   UIView      *topLine;
/// 歌手头像
@property (nonatomic, strong)   UIImageView *avatar;
/// 歌手名字
@property (nonatomic, strong)   UILabel     *name;
/// 歌曲名
@property (nonatomic, strong)   UILabel     *songName;
/// 点歌按钮
@property (nonatomic, strong)   UIButton    *pickBtn;
/// 歌曲信息
@property (nonatomic, strong)   NTESPickSongModel   *song;

@end

@implementation NTESPickSongCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

/**
 self code
 */

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self.contentView addSubview:self.topLine];
        [self.contentView addSubview:self.avatar];
        [self.contentView addSubview:self.name];
        [self.contentView addSubview:self.songName];
        [self.contentView addSubview:self.pickBtn];
    }
    return self;
}

- (void)layoutSubviews
{
    self.topLine.frame = CGRectMake(20, 0, self.contentView.width - 40, 0.5);
    self.avatar.frame = CGRectMake(20, 12, 44, 44);
    self.songName.frame = CGRectMake(self.avatar.right + 8, self.avatar.top, 200, 22);
    self.name.frame = CGRectMake(self.songName.left, self.songName.bottom + 4, self.songName.width, 18);
    self.pickBtn.frame = CGRectMake(self.contentView.width - 20 - 52, 20, 52, 28);
}

#pragma mark - private method

- (void)_installWithData:(NTESPickSongModel *)data indexPath:(NSIndexPath *)indexPath
{
    _song = data;
    
    self.topLine.hidden = (indexPath.row == 0);
    NSURL *url = [NSURL URLWithString:data.avatar];
    [self.avatar yy_setImageWithURL:url placeholder:nil];
    self.name.text = data.singer;
    self.songName.text = data.name;
}

- (void)_pickBtnClick:(UIButton *)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(didClickPickSong:)]) {
        if ([NSObject isNullOrNilWithObject:_song.lyricUrl]) {
            YXAlogInfo(@"Error choose a song,musicLyricUrl is %@",_song.lyricUrl);
        }
        [_delegate didClickPickSong:_song];
    }
}

#pragma mark - public method

+ (NTESPickSongCell *)cellWithTableView:(UITableView *)tableView
                                    data:(NTESPickSongModel *)data
                               indexPath:(NSIndexPath *)indexPath
{
    NTESPickSongCell *cell = [tableView dequeueReusableCellWithIdentifier:[NTESPickSongCell description]];
    [cell _installWithData:data indexPath:indexPath];
    return cell;
}

+ (CGFloat)height
{
    return 68;
}

#pragma mark - lazy load

- (UIView *)topLine
{
    if (!_topLine) {
        _topLine = [[UIView alloc] init];
        _topLine.backgroundColor = UIColorFromRGB(0xdddddd);
    }
    return _topLine;
}

- (UIImageView *)avatar
{
    if (!_avatar) {
        _avatar = [[UIImageView alloc] init];
        _avatar.layer.cornerRadius = 4;
        _avatar.layer.masksToBounds = YES;
        _avatar.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _avatar;
}

- (UILabel *)name
{
    if (!_name) {
        _name = [[UILabel alloc] init];
        _name.font = [UIFont systemFontOfSize:12];
        _name.textColor = UIColorFromRGB(0x999999);
    }
    return _name;
}

- (UILabel *)songName
{
    if (!_songName) {
        _songName = [[UILabel alloc] init];
        _songName.font = [UIFont systemFontOfSize:14];
        _songName.textColor = UIColorFromRGB(0x222222);
    }
    return _songName;
}

- (UIButton *)pickBtn
{
    if (!_pickBtn) {
        _pickBtn = [[UIButton alloc] init];
        [_pickBtn setTitle:@"点歌" forState:UIControlStateNormal];
        [_pickBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _pickBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        _pickBtn.layer.cornerRadius = 14;
        _pickBtn.layer.masksToBounds = YES;
        
        [_pickBtn addTarget:self action:@selector(_pickBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        gradientLayer.frame = CGRectMake(0, 0, 52, 28);
        gradientLayer.colors = @[(__bridge id)[UIColorFromRGB(0x5e93fb) colorWithAlphaComponent:1.0].CGColor,
                                 (__bridge id)[UIColorFromRGB(0xbb94ef) colorWithAlphaComponent:1.0].CGColor];
        gradientLayer.startPoint = CGPointMake(.0, .0);
        gradientLayer.endPoint = CGPointMake(1.0, 0.0);

        [_pickBtn.layer insertSublayer:gradientLayer atIndex:0];
    }
    return _pickBtn;
}

@end
