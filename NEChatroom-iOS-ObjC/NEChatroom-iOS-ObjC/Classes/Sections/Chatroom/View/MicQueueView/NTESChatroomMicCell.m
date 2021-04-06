//
//  NTESChatroomMicCell.m
//  NEChatroom-iOS-ObjC
//
//  Created by Think on 2021/2/3.
//  Copyright © 2021 netease. All rights reserved.
//

#import "NTESChatroomMicCell.h"
#import "UIView+NTES.h"

@implementation NTESChatroomMicCell

@synthesize nameLabel = _nameLabel;
@synthesize connectBtn = _connectBtn;
@synthesize avatar = _avatar;
@synthesize smallIcon = _smallIcon;
@synthesize singIco = _singIco;
@synthesize loadingIco = _loadingIco;

- (void)layoutSubviews
{
    self.connectBtn.top = 0;
    self.connectBtn.left = 0;
    self.connectBtn.width = self.width;
    self.connectBtn.height = self.width;
    self.connectBtn.layer.cornerRadius = self.width/2;
    
    self.avatar.frame = CGRectMake(self.connectBtn.left + 0.5, self.connectBtn.top + 0.5, self.connectBtn.width - 1, self.connectBtn.height - 1);
    self.avatar.layer.cornerRadius = (self.width - 1) * 0.5;
    self.avatar.layer.masksToBounds = YES;

    self.nameLabel.top = self.connectBtn.bottom + 6.0;
    self.nameLabel.left = 0;
    self.nameLabel.width = self.width;
    self.nameLabel.height = 18;
    
    self.smallIcon.width = 17;
    self.smallIcon.height = 17;
    self.smallIcon.right = self.connectBtn.right;
    self.smallIcon.bottom = self.connectBtn.bottom;
    
    self.singIco.frame = self.smallIcon.frame;
    
    self.loadingIco.frame = self.connectBtn.frame;
    self.loadingIco.layer.cornerRadius = self.connectBtn.layer.cornerRadius;
}

+ (NTESMicQueueCell *)cellWithCollectionView:(UICollectionView *)collectionView
                                        data:(NTESMicInfo *)data
                                   indexPath:(NSIndexPath *)indexPath
{
    NTESChatroomMicCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[self description] forIndexPath:indexPath];
//    cell.delegate = self;
//    cell.clipsToBounds = NO;
    [cell refresh:data];
    return cell;
}

+ (CGSize)size
{
    CGFloat paddingW = [self cellPaddingW];
    CGFloat paddingH = [self cellPaddingH];
    CGFloat width = (UIScreenWidth - 8 * paddingW) / 4;
    CGFloat height = width + paddingH;
    return CGSizeMake(width, height);
}

+ (CGFloat)cellPaddingH
{
    return 16;
}

+ (CGFloat)cellPaddingW
{
    return 20;
}

#pragma mark - lazy load

- (UILabel *)nameLabel
{
    if (!_nameLabel){
        _nameLabel = [[UILabel alloc] init];
        [_nameLabel setTextColor:[UIColor whiteColor]];
        [_nameLabel setTextAlignment:NSTextAlignmentCenter];
        _nameLabel.font = [UIFont systemFontOfSize:12];
        [_nameLabel setText:@"用户"];
        [_nameLabel sizeToFit];
    }
    return _nameLabel;
}

- (NTESAnimationButton *)connectBtn
{
    if (!_connectBtn) {
        NTESAnimationButton *connectBtn = [NTESAnimationButton buttonWithType:UIButtonTypeCustom];
        [connectBtn addTarget:self action:@selector(onConnectBtnPressed)  forControlEvents:UIControlEventTouchUpInside];
        UIImage *img = [UIImage imageNamed:@"mic_none_ico"];
        [connectBtn setImage:img forState:UIControlStateNormal];
        _connectBtn = connectBtn;
        _connectBtn.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        _connectBtn.layer.masksToBounds = YES;
        _connectBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    }
    return _connectBtn;
}

- (UIImageView *)avatar
{
    if (!_avatar) {
        _avatar = [[UIImageView alloc] init];
        _avatar.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _avatar;
}

- (UIImageView *)smallIcon
{
    if (!_smallIcon) {
        UIImageView *smallIcon = [[UIImageView alloc] initWithFrame:CGRectZero];
        smallIcon.hidden = YES;
        _smallIcon = smallIcon;
    }
    return _smallIcon;
}

- (UIImageView *)singIco
{
    if (!_singIco) {
        UIImage *img = [UIImage imageNamed:@"mic_sing_ico"];
        _singIco = [[UIImageView alloc] initWithImage:img];
        _singIco.hidden = YES;
    }
    return _singIco;
}

- (LOTAnimationView *)loadingIco
{
    if (!_loadingIco) {
        _loadingIco = [LOTAnimationView animationNamed:@"apply_on_mic.json"];
        _loadingIco.loopAnimation = YES;
        [_loadingIco play];
        _loadingIco.hidden = YES;
        _loadingIco.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        _loadingIco.userInteractionEnabled = NO;
    }
    return _loadingIco;
}

@end
