//
//  NTESLiveRoomHeaderView.m
//  NEChatroom-iOS-ObjC
//
//  Created by vvj on 2021/2/4.
//  Copyright © 2021 netease. All rights reserved.
//

#import "NTESLiveRoomHeaderView.h"
#import "NTESCreateRoomTitleButton.h"
#import "NTESNoticePopView.h"
#import "NTESChatroomInfo.h"
#import "NTESAccountInfo.h"
#import "NSString+NTES.h"


@interface NTESLiveRoomHeaderView ()
@property (nonatomic, strong) UILabel *roomNameLabel;
@property (nonatomic, strong) UILabel *onlinePersonLabel;
@property (nonatomic, strong) UIButton *closeRoomButton;
@property (nonatomic, strong) NTESCreateRoomTitleButton *noticeButton;

@end

@implementation NTESLiveRoomHeaderView

- (void)ntes_setupViews {
    [self addSubview:self.roomNameLabel];
    [self addSubview:self.onlinePersonLabel];
    [self addSubview:self.closeRoomButton];
    [self addSubview:self.noticeButton];

    [self.roomNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(self);
        make.right.equalTo(self.closeRoomButton.mas_left);
    }];
    
    [self.onlinePersonLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.right.equalTo(self);
        make.height.mas_equalTo(20);
    }];
    [self.closeRoomButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(24, 24));
    }];
    
    [self.noticeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(54, 20));
    }];
    
}


- (void)closeRoomButtonClickAction {
    if (_delegate && [_delegate respondsToSelector:@selector(liveRoomHeaderDidReceiveExitAction)]) {
      [self.delegate liveRoomHeaderDidReceiveExitAction];
    }
}

- (void)noticeButtonClickAction {
//    if (_delegate && [_delegate respondsToSelector:@selector(liveRoomHeaderClickNoticeAction)]) {
//      [self.delegate liveRoomHeaderClickNoticeAction];
//    }
//
    NTESNoticePopView* noticePopView = [[NTESNoticePopView alloc]initWithFrame:CGRectMake(0, 0, UIScreenWidth, UIScreenHeight)];
    [[UIApplication sharedApplication].keyWindow addSubview:noticePopView];
    
}
-(void)layoutSubviews {
    [super layoutSubviews];
    [self.noticeButton cutViewRounded:UIRectCornerAllCorners cornerRadii:CGSizeMake(20, 20)];
    [self.onlinePersonLabel cutViewRounded:UIRectCornerAllCorners cornerRadii:CGSizeMake(20, 20)];
    [self.closeRoomButton cutViewRounded:UIRectCornerAllCorners cornerRadii:CGSizeMake(12, 12)];

}



- (void)setChatroomInfo:(NTESChatroomInfo *)chatroomInfo {
    if (!chatroomInfo) {
        return;
    }
    self.roomNameLabel.text = chatroomInfo.name;
    NSString *onLineNumberString = [NSString stringWithFormat:@"在线%@人",@(chatroomInfo.onlineUserCount)];
    self.onlinePersonLabel.text  = onLineNumberString;
    [self.onlinePersonLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo([onLineNumberString sizeWithFont:Font_Default(12) maxH:20].width + 10);
    }];
}


#pragma mark - lazyMethod

- (UILabel *)roomNameLabel {
    if (!_roomNameLabel) {
        _roomNameLabel = [NTESViewFactory createLabelFrame:CGRectZero title:@"房间名称" textColor:UIColor.whiteColor textAlignment:NSTextAlignmentLeft font:TextFont_16];
    }
    return _roomNameLabel;
}

- (UILabel *)onlinePersonLabel {
    if (!_onlinePersonLabel) {
        _onlinePersonLabel = [NTESViewFactory createLabelFrame:CGRectZero title:@"在线0人" textColor:UIColor.whiteColor textAlignment:NSTextAlignmentCenter font:Font_Default(12)];
        [_onlinePersonLabel setBackgroundColor:UIColorFromRGBA(0x000000, 0.5)];
    }
    return _onlinePersonLabel;
}

-(NTESCreateRoomTitleButton *)noticeButton {
    if (!_noticeButton) {
        _noticeButton = [[NTESCreateRoomTitleButton alloc]initWithImage:@"roomNotice_icon" content:@"公告"];
        [_noticeButton addTarget:self action:@selector(noticeButtonClickAction) forControlEvents:UIControlEventTouchUpInside];
        [_noticeButton setLableFont:Font_Default(12)];
        [_noticeButton setLeftMargin:8 imageSize:CGSizeMake(12, 12)];
        _noticeButton.backgroundColor = UIColorFromRGBA(0x000000, 0.5);
    }
    return _noticeButton;
}

- (UIButton *)closeRoomButton {
    if (!_closeRoomButton) {
        _closeRoomButton = [[UIButton alloc]init];
        [_closeRoomButton setImage:[UIImage imageNamed:@"closeroom_icon"] forState:UIControlStateNormal];
        [_closeRoomButton addTarget:self action:@selector(closeRoomButtonClickAction) forControlEvents:UIControlEventTouchUpInside];
        [_closeRoomButton setBackgroundColor:UIColorFromRGBA(0x000000, 0.5)];
    }
    return _closeRoomButton;
}
@end
