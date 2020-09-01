//
//  NTESChatroomStateView.m
//  NERtcAudioChatroom
//
//  Created by Netease on 2019/3/6.
//  Copyright © 2019年 netease. All rights reserved.
//

#import "NTESChatroomStateView.h"
#import "UIView+NTES.h"

@interface NTESChatroomStateView ()

@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, strong) UILabel *infoLab;

@end

@implementation NTESChatroomStateView

- (instancetype)initWithInfo:(NSString *)info {
    if (self = [super init]) {
        self.backgroundColor = [UIColor blackColor];
        _info = info;
        [self addSubview:self.imgView];
        [self addSubview:self.infoLab];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _imgView.size = CGSizeMake(120, 120);
    _imgView.top = 54.0;
    _imgView.centerX = self.width/2;
    _infoLab.top = _imgView.bottom + 18.0;
    _infoLab.centerX = self.width/2;
}

#pragma mark - Getter
- (UIImageView *)imgView {
    if (!_imgView) {
        _imgView = [[UIImageView alloc] init];
        _imgView.contentMode = UIViewContentModeScaleAspectFit;
        _imgView.image = [UIImage imageNamed:@"empty_mute_list"];
    }
    return _imgView;
}

- (UILabel *)infoLab {
    if (!_infoLab) {
        _infoLab = [[UILabel alloc] init];
        _infoLab.textColor = [UIColor whiteColor];
        _infoLab.font = [UIFont systemFontOfSize:15.0];
        _infoLab.text = _info ?: @"";
        [_infoLab sizeToFit];
    }
    return _infoLab;
}

- (void)setInfo:(NSString *)info {
    _info = info;
    _infoLab.text = info;
    [_infoLab sizeToFit];
}

@end
