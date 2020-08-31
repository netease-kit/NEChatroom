//
//  NTESHomePageStateView.m
//  NERtcAudioChatroom
//
//  Created by Netease on 2019/3/4.
//  Copyright © 2019年 netease. All rights reserved.
//

#import "NTESHomePageStateView.h"
#import "UIView+NTES.h"

@interface NTESHomePageStateView ()
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *infoLab;
@property (nonatomic, strong) UILabel *exInfoLab;
@property (nonatomic, strong) UIButton *tapBtn;
@end

@implementation NTESHomePageStateView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor blackColor];
        [self addSubview:self.imageView];
        [self addSubview:self.infoLab];
        [self addSubview:self.exInfoLab];
        [self addSubview:self.tapBtn];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _imageView.size = CGSizeMake(self.width, 80.0);
    _imageView.top = 100.0;
    _imageView.centerX = self.width/2;
    _infoLab.frame = CGRectMake(0,
                                _imageView.bottom + 20.0,
                                self.width,
                                _infoLab.height);
    _exInfoLab.frame = CGRectMake(_infoLab.left,
                                  _infoLab.bottom + 16,
                                  _infoLab.width,
                                  _exInfoLab.height);
    _tapBtn.frame = self.bounds;
}

- (void)setMode:(NTESHomePageStateViewMode)mode {
    switch (mode) {
        case NTESHomePageStateViewEmpty:
            _imageView.hidden = NO;
            _imageView.image = [UIImage imageNamed:@"empty_list"];
            _infoLab.hidden = NO;
            _infoLab.text = @"暂时没有房间～";
            [_infoLab sizeToFit];
            _exInfoLab.text = @"请点击下方“+“创建房间";
            [_exInfoLab sizeToFit];
            _exInfoLab.hidden = NO;
            _tapBtn.hidden = YES;
            break;
        case NTESHomePageStateViewNetworkError:
            _imageView.hidden = NO;
            _imageView.image = [UIImage imageNamed:@"network_error"];
            _infoLab.hidden = NO;
            _infoLab.text = @"网络错误，点击重试";
            [_infoLab sizeToFit];
            _exInfoLab.hidden = YES;
            _tapBtn.hidden = NO;
            break;
        case NTESHomePageStateViewHidden:
            _imageView.hidden = YES;
            _infoLab.hidden = YES;
            _exInfoLab.hidden = YES;
            _tapBtn.hidden = YES;
            break;
        default:
            break;
    }
    _mode = mode;
}

#pragma mark - Action
- (void)tapAction:(UIButton *)btn {
    if (_delegate
        && [_delegate respondsToSelector:@selector(stateViewDidReceiveRetryAction)]) {
        [_delegate stateViewDidReceiveRetryAction];
    }
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.backgroundColor = [UIColor blackColor];
    }
    return _imageView;
}

- (UILabel *)infoLab {
    if (!_infoLab) {
        _infoLab = [[UILabel alloc] init];
        _infoLab.font = [UIFont systemFontOfSize:14.0];
        _infoLab.textAlignment = NSTextAlignmentCenter;
        _infoLab.textColor = [UIColor whiteColor];
        _infoLab.text = @"未知";
        [_infoLab sizeToFit];
    }
    return _infoLab;
}

- (UILabel *)exInfoLab {
    if (!_exInfoLab) {
        _exInfoLab = [[UILabel alloc] init];
        _exInfoLab.font = [UIFont systemFontOfSize:14.0];
        _exInfoLab.textAlignment = NSTextAlignmentCenter;
        _exInfoLab.textColor = [UIColor whiteColor];
        _exInfoLab.hidden = YES;
        _exInfoLab.text = @"未知";
        [_exInfoLab sizeToFit];
    }
    return _exInfoLab;
}

- (UIButton *)tapBtn {
    if (!_tapBtn) {
        _tapBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_tapBtn addTarget:self
                    action:@selector(tapAction:)
          forControlEvents:UIControlEventTouchUpInside];
    }
    return _tapBtn;
}

@end
