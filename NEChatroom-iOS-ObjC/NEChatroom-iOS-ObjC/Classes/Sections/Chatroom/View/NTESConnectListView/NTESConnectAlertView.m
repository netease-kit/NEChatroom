//
//  NTESConnectAlertView.m
//  NERtcAudioChatroom
//
//  Created by Simon Blue on 2019/1/31.
//  Copyright © 2019年 netease. All rights reserved.
//

#import "NTESConnectAlertView.h"

@interface NTESConnectAlertView ()

@property (nonatomic,assign)NSUInteger connectCount;
@property (nonatomic,strong)UILabel *connectCountLabel;
@property (nonatomic,strong)UIButton *showConnectListBtn;


@end

@implementation NTESConnectAlertView

- (void)layoutSubviews
{
    self.showConnectListBtn.frame = self.bounds;
    self.connectCountLabel.frame = self.bounds;
}

- (void)onShowConnectListBtnPressed:(UIButton *)button
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(onShowConnectListBtnPressed:)]) {
        [self.delegate onShowConnectListBtnPressed:button];
    }
}

- (void)updateConnectCount:(NSUInteger)connectCount
{
    [self.connectCountLabel setText:[NSString stringWithFormat:@"%zd",connectCount]];
}

- (void)refreshAlertView:(BOOL)listViewPushed
{
    if (!listViewPushed) {
        [self.showConnectListBtn setImage:[UIImage imageNamed:@"icon_connect_alert"] forState:UIControlStateNormal];
        self.connectCountLabel.hidden = NO;
    }
    else
    {
        [self.showConnectListBtn setImage:[UIImage imageNamed:@"icon_connectList_close"] forState:UIControlStateNormal];
        self.connectCountLabel.hidden = YES;
    }
}

- (void)drawBtnCorner
{
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.showConnectListBtn.bounds      byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight    cornerRadii:CGSizeMake(10, 10)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.showConnectListBtn.bounds;
    maskLayer.path = maskPath.CGPath;
    self.showConnectListBtn.layer.mask = maskLayer;
}

- (UILabel *)connectCountLabel
{
    if (!_connectCountLabel)
    {
        UILabel *connectCountLabel = [[UILabel alloc] init];
        [connectCountLabel setTextAlignment:NSTextAlignmentCenter];
        connectCountLabel.font = [UIFont systemFontOfSize:15];
        [connectCountLabel setText:@"1"];
        [connectCountLabel setTextColor:[UIColor whiteColor]];
        [connectCountLabel sizeToFit];
        _connectCountLabel = connectCountLabel;
        [self.showConnectListBtn addSubview:_connectCountLabel];
    }
    return _connectCountLabel;
}

- (UIButton *)showConnectListBtn
{
    if (!_showConnectListBtn) {
        UIButton *showConnectListBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [showConnectListBtn addTarget:self action:@selector(onShowConnectListBtnPressed:)  forControlEvents:UIControlEventTouchUpInside];
        [showConnectListBtn setImage:[UIImage imageNamed:@"icon_connect_alert"] forState:UIControlStateNormal];
        _showConnectListBtn = showConnectListBtn;
        [self addSubview:_showConnectListBtn];
    }
    return _showConnectListBtn;
}



@end
