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
@property (nonatomic, strong) UIButton *arrowButton;
@property (nonatomic, strong) UIView *bottomLineView;
@end

@implementation NTESNavBar

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.titleLab];
        [self addSubview:self.backBtn];
        [self addSubview:self.arrowButton];
        [self addSubview:self.bottomLineView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _backBtn.frame = CGRectMake(0, 0, 60, 40);
    _backBtn.centerY = self.height/2;
    _arrowButton.frame = _backBtn.frame;
    _titleLab.frame = CGRectMake(_backBtn.right,
                                 0,
                                 self.width-_backBtn.width*2,
                                 _titleLab.height);
    _titleLab.centerY = self.height/2;
    _bottomLineView.frame = CGRectMake(0, self.height-0.5, self.width, 0.5);
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

- (void)arrowBackAction:(UIButton *)sender {
    if (self.arrowBackBlock) {
        self.arrowBackBlock();
    }
}

- (void)setNavType:(NTESBanSpeakNavType)navType {
    _navType = navType;
    if (navType == NTESBanSpeakNavTypeCancel) {
        self.backBtn.hidden = NO;
        self.arrowButton.hidden = YES;
    }else if (navType == NTESBanSpeakNavTypeArrow){
        self.backBtn.hidden = YES;
        self.arrowButton.hidden = NO;
    }
}
#pragma mark - Getter
- (UILabel *)titleLab {
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.text = @"未知";
        _titleLab.font = Font_Size(@"PingFangSC-Medium", 16);
        _titleLab.textColor = UIColorFromRGB(0x222222);
        _titleLab.textAlignment = NSTextAlignmentCenter;
        [_titleLab sizeToFit];
    }
    return _titleLab;
}

- (UIButton *)backBtn {
    if (!_backBtn) {
        _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _backBtn.titleLabel.font = TextFont_14;
        [_backBtn setTitle:@"取消" forState:UIControlStateNormal];
        [_backBtn addTarget:self action:@selector(backAction:)
           forControlEvents:UIControlEventTouchUpInside];
        [_backBtn setTitleColor:UIColorFromRGB(0x222222) forState:UIControlStateNormal];
    }
    return _backBtn;
}


- (UIButton *)arrowButton {
    if (!_arrowButton) {
//        _arrowButton = [NTESViewFactory createBtnFrame:CGRectZero title:nil bgImage:nil selectBgImage:nil image:@"nav_back_icon" target:nil action:nil];
        _arrowButton = [[UIButton alloc]init];
        [_arrowButton addTarget:self action:@selector(arrowBackAction:) forControlEvents:UIControlEventTouchUpInside];
        [_arrowButton setImage:[UIImage imageNamed:@"nav_back_icon"] forState:UIControlStateNormal];
        [_arrowButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 32)];
    }
    return _arrowButton;
}

- (UIView *)bottomLineView {
    if (!_bottomLineView) {
        _bottomLineView = [[UIView alloc]init];
        _bottomLineView.backgroundColor = UIColorFromRGB(0xE6E7EB);
    }
    return _bottomLineView;
}

@end
