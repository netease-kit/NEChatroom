//
//  NTESHasPickedSongCell.m
//  NEChatroom-iOS-ObjC
//
//  Created by Think on 2021/2/4.
//  Copyright © 2021 netease. All rights reserved.
//

#import "NTESHasPickedSongCell.h"
#import "NTESQueueMusic.h"
#import "LOTAnimationView.h"
#import "NTESPickMusicService.h"
#import "NTESAccountInfo.h"

@interface NTESHasPickedSongCell ()

@property (nonatomic, strong)   UIView      *topLine;
@property (nonatomic, strong)   UILabel     *numLab;
@property (nonatomic, strong)   UIImageView *cover;
@property (nonatomic, strong)   UILabel     *name;
@property (nonatomic, strong)   UIImageView *avatar;
@property (nonatomic, strong)   UILabel     *nickname;
@property (nonatomic, strong)   UILabel     *playStatus;
@property (nonatomic, strong)   UIButton    *cancelBtn;
@property (nonatomic, strong)   LOTAnimationView    *playingAnimate;

@property (nonatomic, strong)   NTESQueueMusic  *music;

@end

@implementation NTESHasPickedSongCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self.contentView addSubview:self.topLine];
        [self.contentView addSubview:self.numLab];
        [self.contentView addSubview:self.cover];
        [self.contentView addSubview:self.name];
        [self.contentView addSubview:self.avatar];
        [self.contentView addSubview:self.nickname];
        [self.contentView addSubview:self.playStatus];
        [self.contentView addSubview:self.cancelBtn];
    }
    return self;
}

- (void)layoutSubviews
{
    self.topLine.frame = CGRectMake(20, 0, self.contentView.width - 40, 0.5);
    self.numLab.frame = CGRectMake(20, 12, 18, 24);
    self.cover.frame = CGRectMake(self.numLab.right + 8,  self.numLab.top, 44, 44);
    self.name.frame = CGRectMake(self.cover.right + 8, self.cover.top, 200, 22);
    self.avatar.frame = CGRectMake(self.name.left, self.name.bottom + 4, 18, 18);
    self.nickname.frame = CGRectMake(self.avatar.right + 4, self.avatar.top, 100, 18);
    self.playStatus.frame = CGRectMake(self.contentView.width - 50 - 20, self.nickname.top, 50, 18);
    self.cancelBtn.frame = CGRectMake(self.contentView.width - 20 - 52, (68 - 28) * 0.5, 52, 28);
}

#pragma mark - public method

+ (NTESHasPickedSongCell *)cellWithTableView:(UITableView *)tableView datas:(NSArray<NTESQueueMusic *> *)datas indexPath:(NSIndexPath *)indexPath avgs:(NSDictionary *)avgs
{
    if ([datas count] > indexPath.row) {
        NTESQueueMusic *data = datas[indexPath.row];
        NTESHasPickedSongCell *cell = [tableView dequeueReusableCellWithIdentifier:[NTESHasPickedSongCell description]];
        [cell _installWithData:data indexPath:indexPath];
        
        id obj = avgs[@"service"];
        if (obj && [obj isKindOfClass:[NTESPickMusicService class]]) {
            NTESPickMusicService *service = (NTESPickMusicService *)obj;
            
            BOOL isPlaying = (indexPath.row == 0 && data.status == 0);
            cell.isPlaying = isPlaying;
            
            BOOL cancelAuth = service.userMode == NTESUserModeAnchor || [service.userInfo.account isEqualToString:data.userId];
            cell.cancelAuth = cancelAuth;
        }
        
        return cell;
    }
    return [NTESHasPickedSongCell new];
}

+ (CGFloat)height
{
    return 68;
}

#pragma mark setter/getter

- (void)setIsPlaying:(BOOL)isPlaying
{
    _isPlaying = isPlaying;
    if (isPlaying) {
        // 播放动画
        self.playingAnimate.frame = CGRectMake(20, 12, 18, 22);
        [self.contentView addSubview:self.playingAnimate];
        self.numLab.hidden = YES;
        
        self.playStatus.hidden = NO;
    } else {
        [self.playingAnimate removeFromSuperview];
        self.numLab.hidden = NO;
        
        self.playStatus.hidden = YES;
    }
    [self _refreshCancelBtnHidden];
}

- (void)setCancelAuth:(BOOL)cancelAuth
{
    _cancelAuth = cancelAuth;
    [self _refreshCancelBtnHidden];
}

#pragma mark - private method

- (void)_installWithData:(NTESQueueMusic *)data indexPath:(NSIndexPath *)indexPath
{
    _music = data;
    
    self.topLine.hidden = (indexPath.row == 0);
    
    NSInteger row = indexPath.row + 1;
    self.numLab.text = (row < 10) ? [NSString stringWithFormat:@"0%zd", row] : [NSString stringWithFormat:@"%zd", row];
    
    NSURL *coverUrl = [NSURL URLWithString:data.musicAvatar];
    [self.cover yy_setImageWithURL:coverUrl placeholder:nil];
    self.name.text = data.musicName;
    
    NSURL *avatarUrl = [NSURL URLWithString:data.userAvatar];
    [self.avatar yy_setImageWithURL:avatarUrl placeholder:nil];
    self.nickname.text = data.userNickname;
    
//    self.playStatus.text = data.musicDuriation;
}

- (void)_cancelPickedSong:(UIButton *)sender
{
    YXAlogInfo(@"点击取消点歌, music: %@", _music);
    if (_delegate && [_delegate respondsToSelector:@selector(didCancelPickedMusic:)]) {
        [_delegate didCancelPickedMusic:_music];
    }
}

- (void)_refreshCancelBtnHidden
{
    if (_cancelAuth && !_isPlaying) {
        self.cancelBtn.hidden = NO;
    } else {
        self.cancelBtn.hidden = YES;
    }
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

- (UILabel *)numLab
{
    if (!_numLab) {
        _numLab = [[UILabel alloc] init];
        _numLab.textColor = UIColorFromRGB(0x999999);
        _numLab.font = [UIFont systemFontOfSize:14];
    }
    return _numLab;
}

- (UIImageView *)cover
{
    if (!_cover) {
        _cover = [[UIImageView alloc] init];
        _cover.contentMode = UIViewContentModeScaleAspectFill;
        _cover.layer.cornerRadius = 4;
        _cover.layer.masksToBounds = YES;
    }
    return _cover;
}

- (UILabel *)name
{
    if (!_name) {
        _name = [[UILabel alloc] init];
        _name.font = [UIFont systemFontOfSize:14];
        _name.textColor = UIColorFromRGB(0x222222);
    }
    return _name;
}

- (UIImageView *)avatar
{
    if (!_avatar) {
        _avatar = [[UIImageView alloc] init];
        _avatar.contentMode = UIViewContentModeScaleAspectFill;
        _avatar.layer.cornerRadius = 9;
        _avatar.layer.masksToBounds = YES;
    }
    return _avatar;
}

- (UILabel *)nickname
{
    if (!_nickname) {
        _nickname = [[UILabel alloc] init];
        _nickname.font = [UIFont systemFontOfSize:12];
        _nickname.textColor = UIColorFromRGB(0x999999);
    }
    return _nickname;
}

- (UILabel *)playStatus
{
    if (!_playStatus) {
        _playStatus = [[UILabel alloc] init];
        _playStatus.font = [UIFont systemFontOfSize:12];
        _playStatus.textColor = UIColorFromRGB(0x337EFF);
        _playStatus.textAlignment = NSTextAlignmentRight;
        _playStatus.hidden = YES;
        _playStatus.text = @"正在播放";
    }
    return _playStatus;
}

- (UIButton *)cancelBtn
{
    if (!_cancelBtn) {
        _cancelBtn = [[UIButton alloc] init];
        [_cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelBtn setTitleColor:UIColorFromRGB(0x222222) forState:UIControlStateNormal];
        _cancelBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        _cancelBtn.layer.cornerRadius = 14;
        _cancelBtn.layer.masksToBounds = YES;
        _cancelBtn.layer.borderColor = UIColorFromRGB(0xD9D9DB).CGColor;
        _cancelBtn.layer.borderWidth = 1;
        [_cancelBtn addTarget:self action:@selector(_cancelPickedSong:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelBtn;
}

- (LOTAnimationView *)playingAnimate
{
    if (!_playingAnimate) {
        _playingAnimate = [LOTAnimationView animationNamed:@"es_playing.json"];
        _playingAnimate.loopAnimation = YES;
        [_playingAnimate play];
    }
    return _playingAnimate;
}

@end
