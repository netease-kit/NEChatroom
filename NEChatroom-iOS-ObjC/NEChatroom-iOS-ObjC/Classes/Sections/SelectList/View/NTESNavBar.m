//
//  NTESNavBar.m
//  NERtcAudioChatroom
//
//  Created by Netease on 2019/3/6.
//  Copyright © 2019年 netease. All rights reserved.
//

#import "NTESNavBar.h"
#import "UIView+NTES.h"

@interface NTESNavBar ()

@property (nonatomic, strong) UILabel *titleLab;

@property (nonatomic, strong) UIButton *backBtn;

@end

@implementation NTESNavBar

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor blackColor];
        [self addSubview:self.titleLab];
        [self addSubview:self.backBtn];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _backBtn.frame = CGRectMake(0, 0, 60, 40);
    _backBtn.centerY = self.height/2;
    _titleLab.frame = CGRectMake(_backBtn.right,
                                 0,
                                 self.width-_backBtn.width*2,
                                 _titleLab.height);
    _titleLab.centerY = self.height/2;
}

#pragma mark - Public
- (void)setTitle:(NSString *)title {
    _title = title;
    _titleLab.text = title ?: @"";
}

- (void)backAction:(UIButton *)sender {
    if (_backBlock) {
        _backBlock();
    }
}

#pragma mark - Getter
- (UILabel *)titleLab {
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.text = @"未知";
        _titleLab.font = [UIFont systemFontOfSize:17.0];
        _titleLab.textColor = [UIColor whiteColor];
        _titleLab.backgroundColor = [UIColor clearColor];
        _titleLab.textAlignment = NSTextAlignmentCenter;
        [_titleLab sizeToFit];
    }
    return _titleLab;
}

- (UIButton *)backBtn {
    if (!_backBtn) {
        _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _backBtn.titleLabel.font = [UIFont systemFontOfSize:15.0];
        [_backBtn setTitle:@"取消" forState:UIControlStateNormal];
        [_backBtn addTarget:self action:@selector(backAction:)
           forControlEvents:UIControlEventTouchUpInside];
    }
    return _backBtn;
}

@end
