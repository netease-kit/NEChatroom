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

@end

@implementation NTESConnectAlertView

- (void)layoutSubviews
{
    self.showConnectListBtn.frame = self.bounds;
}

- (void)onShowConnectListBtnPressed:(UIButton *)button
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(onShowConnectListBtnPressed:)]) {
        [self.delegate onShowConnectListBtnPressed:button];
    }
    self.showConnectListBtn.hidden = YES;
}

- (void)updateConnectCount:(NSUInteger)connectCount
{
    NSString *msg = [NSString stringWithFormat:@"申请上麦(%zd)",connectCount];
    [self.showConnectListBtn setTitle:msg forState:UIControlStateNormal];
}

- (void)refreshAlertView:(BOOL)listViewPushed
{
    if (!listViewPushed) {
        self.showConnectListBtn.hidden = NO;
    } else {
        self.showConnectListBtn.hidden = YES;
    }
}

- (UIButton *)showConnectListBtn
{
    if (!_showConnectListBtn) {
        _showConnectListBtn = [NTESViewFactory createSystemBtnFrame:CGRectZero title:@"" titleColor:UIColor.whiteColor backgroundColor:nil target:self action:@selector(onShowConnectListBtnPressed:)];
        [_showConnectListBtn setGradientBackgroundWithColors:@[UIColorFromRGB(0xdc5aaa),UIColorFromRGB(0xfc8567)] locations:nil startPoint:CGPointMake(0, 0) endPoint:CGPointMake(0, 1)];
        [_showConnectListBtn setTitle:@"申请上麦(1)" forState:UIControlStateNormal];
        [_showConnectListBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _showConnectListBtn.layer.cornerRadius = 19.0;
        _showConnectListBtn.layer.masksToBounds = YES;
        [self addSubview:_showConnectListBtn];
    }
    return _showConnectListBtn;
}

@end
