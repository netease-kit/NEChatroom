//
//  NTESKtvMicCell.m
//  NEChatroom-iOS-ObjC
//
//  Created by Think on 2021/2/3.
//  Copyright © 2021 netease. All rights reserved.
//

#import "NTESKtvMicCell.h"

@implementation NTESKtvMicCell

@synthesize nameLabel = _nameLabel;
@synthesize connectBtn = _connectBtn;
@synthesize avatar = _avatar;
@synthesize smallIcon = _smallIcon;
@synthesize singIco = _singIco;
@synthesize loadingIco = _loadingIco;

- (void)layoutSubviews
{
    self.connectBtn.frame = CGRectMake(6, 0, 40, 40);
    self.connectBtn.layer.cornerRadius = 20;
    CGFloat padding = (self.connectBtn.width - 16) * 0.5;
    [self.connectBtn setImageEdgeInsets:UIEdgeInsetsMake(padding, padding, padding, padding)];
    
    self.avatar.frame = CGRectMake(self.connectBtn.left + 0.5, self.connectBtn.top + 0.5, self.connectBtn.width - 1, self.connectBtn.height - 1);
    self.avatar.layer.cornerRadius = (self.connectBtn.width - 1) * 0.5;
    self.avatar.layer.masksToBounds = YES;

    self.nameLabel.top = self.connectBtn.bottom + 4.0;
    self.nameLabel.left = 0;
    self.nameLabel.width = self.width;
    self.nameLabel.height = 16;
    
    self.smallIcon.width = 14;
    self.smallIcon.height = 14;
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
    NTESKtvMicCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[self description] forIndexPath:indexPath];
//    cell.delegate = self;
//    cell.clipsToBounds = NO;
    [cell refresh:data];
    return cell;
}

+ (CGSize)size
{
    return CGSizeMake(52, 60);
}

+ (CGFloat)cellPaddingH
{
    return 0;
}

+ (CGFloat)cellPaddingW
{
    return 0;
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
        _connectBtn = [NTESAnimationButton buttonWithType:UIButtonTypeCustom];
        [_connectBtn addTarget:self action:@selector(onConnectBtnPressed)  forControlEvents:UIControlEventTouchUpInside];
        UIImage *img = [UIImage imageNamed:@"mic_none_ico"];
        [_connectBtn setImage:img forState:UIControlStateNormal];
        _connectBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
        _connectBtn.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        _connectBtn.layer.cornerRadius = 20;
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
