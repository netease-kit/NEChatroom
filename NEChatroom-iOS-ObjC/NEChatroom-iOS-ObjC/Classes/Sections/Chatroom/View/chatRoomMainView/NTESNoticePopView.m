//
//  NTESNoticePopView.h
//  NEChatroom-iOS-ObjC
//
//  Created by vvj on 2021/2/4.
//  Copyright © 2021 netease. All rights reserved.
//

#import "NTESNoticePopView.h"
#import "UILabel+ChangeSpace.h"

@interface NTESNoticePopView ()
@property (nonatomic,strong) UIView *containerView;
@property (nonatomic,strong) UILabel *titleLable;
@property (nonatomic,strong) UILabel *contentLabel;
@property (nonatomic,strong) UIButton *closeButton;

@end

@implementation NTESNoticePopView



- (void)ntes_setupViews {
    self.backgroundColor = UIColorFromRGBA(0x00000, 0.5);
    [self addSubview:self.containerView];
    [self.containerView addSubview:self.titleLable];
    [self.containerView addSubview:self.contentLabel];
    [self.containerView addSubview:self.closeButton];
    [self buildViewconstraint];
}

- (void)buildViewconstraint {
    
    [self.containerView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(280, 256));
        make.center.equalTo(self);
    }];
    
    [self.titleLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.containerView).offset(20);
        make.left.equalTo(self.containerView).offset(20);
    }];

    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLable.mas_bottom).offset(16);
        make.left.equalTo(self.titleLable);
        make.right.equalTo(self.containerView).offset(-20);
    }];
    
    [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.containerView).offset(12);
        make.right.equalTo(self.containerView).offset(-12);
        make.size.mas_equalTo(CGSizeMake(16, 16));
    }];
}

- (void)closeButtonClick {
    [self removeFromSuperview];
}

#pragma mark === lazyMethod
- (UIView *)containerView {
    if (!_containerView) {
        _containerView = [[UIView alloc]init];
        _containerView.layer.cornerRadius = 8;
        _containerView.backgroundColor = UIColor.whiteColor;
    }
    return _containerView;
}

- (UILabel *)titleLable {
    if (!_titleLable) {
        _titleLable = [NTESViewFactory createLabelFrame:CGRectZero title:@"公告" textColor:UIColorFromRGB(0x222222) textAlignment:NSTextAlignmentLeft font:TextFont_16];
    }
    return _titleLable;
}

- (UILabel *)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [NTESViewFactory createLabelFrame:CGRectZero title:@"本应用为示例产品，请勿商用，单场直播最长10分钟，最多10人次。\n感谢网易MMORPG游戏《新倩女幽魂》提供伴奏歌曲。" textColor:UIColorFromRGB(0x222222) textAlignment:NSTextAlignmentLeft font:TextFont_14];
        [UILabel  changeLineSpaceForLabel:_contentLabel WithSpace:5];
        _contentLabel.numberOfLines = 0;
    }
    return _contentLabel;
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [NTESViewFactory createBtnFrame:CGRectZero title:@"" bgImage:@"" selectBgImage:@"" image:@"notice_close" target:self action:@selector(closeButtonClick)];
    }
    return _closeButton ;
}


@end
