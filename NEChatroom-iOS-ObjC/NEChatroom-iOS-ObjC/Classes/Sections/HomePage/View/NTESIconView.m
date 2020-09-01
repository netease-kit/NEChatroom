//
//  NTESIconView.m
//  NERtcAudioChatroom
//
//  Created by Netease on 2019/3/4.
//  Copyright © 2019年 netease. All rights reserved.
//

#import "NTESIconView.h"
#import "NTESAnimationImageView.h"
#import "UIView+NTES.h"
#import "UIImage+YYWebImage.h"
#import "UIImageView+YYWebImage.h"

@interface NTESIconView ()
@property (nonatomic, strong) NTESAnimationImageView *image;
@property (nonatomic, strong) UILabel *titleLab;
@property (nonatomic, strong) UIImage *placeholder;
@property (nonatomic, strong) UIImageView *muteImageView;
@end

@implementation NTESIconView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.image];
        [self addSubview:self.titleLab];
        [self addSubview:self.muteImageView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _image.size = CGSizeMake(self.width, self.width);
    _image.top = 0;
    _image.centerX = self.width/2;
    _titleLab.centerX = self.width/2;
    _titleLab.top = _image.bottom + 8.0;
    _muteImageView.size = CGSizeMake(17.0, 17.0);
    _muteImageView.centerX = _image.width/2;
    _muteImageView.bottom = _image.bottom;
}

#pragma mark - Public
- (void)setMute:(BOOL)mute {
    _mute = mute;
    _muteImageView.hidden = !mute;
}

- (void)setNameColor:(UIColor *)nameColor {
    if (nameColor) {
        _titleLab.textColor = nameColor;
    }
}

- (void)setName:(NSString *)name
        iconUrl:(NSString *)iconUrl {
    
    //title
    _titleLab.text = name ?: @"";
    [_titleLab sizeToFit];
    
    //image
    NSURL *url = [NSURL URLWithString:iconUrl];
    __weak typeof(self) weakSelf = self;
    [_image yy_setImageWithURL:url
                   placeholder:_placeholder
                       options:YYWebImageOptionAvoidSetImage
                    completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
            if (!error) {
                image = [image yy_imageByRoundCornerRadius:(image.size.width/2)];
                weakSelf.image.image = image;
            }
    }];
}

- (void)startAnimationWithValue:(NSInteger)value {
    [_image startCustomAnimation];
    _image.info = @(value).stringValue;
}

- (void)stopAnimation {
    [_image stopCustomAnimation];
    _image.info = nil;
}

#pragma mark - Getter
- (NTESAnimationImageView *)image {
    if (!_image) {
        _image = [[NTESAnimationImageView alloc] init];
        _placeholder = [UIImage imageNamed:@"default_user_icon"];
        _image.image = _placeholder;
    }
    return _image;
}

- (UILabel *)titleLab {
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.font = [UIFont systemFontOfSize:14.0];
        _titleLab.textColor = [UIColor whiteColor];
        _titleLab.textAlignment = NSTextAlignmentCenter;
        _titleLab.text = @"未知";
        [_titleLab sizeToFit];
    }
    return _titleLab;
}

- (UIImageView *)muteImageView {
    if (!_muteImageView) {
        _muteImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_mic_off_small"]];
        _muteImageView.hidden = YES;
    }
    return _muteImageView;
}

@end
