//
//  NTESChatroomTableViewCell.m
//  NERtcAudioChatroom
//
//  Created by Simon Blue on 2019/1/17.
//  Copyright © 2019年 netease. All rights reserved.
//

#import "NTESChatroomTableViewCell.h"
#import "NTESChatroomInfo.h"
#import "UIImage+YYWebImage.h"
#import "UIImageView+YYWebImage.h"
#import "UIView+NTES.h"

@interface NTESChatroomTableViewCell()
{
    CGRect _preRect;
}
@property (nonatomic, strong) UILabel *roomNameLabel;
@property (nonatomic, strong) UILabel *onlineCountLabel;
@property (nonatomic, strong) UIImageView *backImgView;
@property (nonatomic, strong) UIImage *placeholder;
@end

@implementation NTESChatroomTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = UIColor.whiteColor;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self addSubview:self.backImgView];
        [self addSubview:self.roomNameLabel];
        [self addSubview:self.onlineCountLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (!CGRectEqualToRect(_preRect, self.bounds)) {
        CGFloat totalHeight = _roomNameLabel.height + 2.0*self.height/100.0 + _onlineCountLabel.height;
        _backImgView.frame = CGRectMake(20.0, 8.0, self.width - 20.0*2, self.height - 8.0*2);
        _roomNameLabel.frame = CGRectMake(40.0,
                                          (self.height-totalHeight)/2,
                                          self.width-40.0*2,
                                          _roomNameLabel.height);
        _onlineCountLabel.frame = CGRectMake(_roomNameLabel.left,
                                             _roomNameLabel.bottom+2.0*self.height/100.0,
                                             _roomNameLabel.width,
                                             _onlineCountLabel.height);
        _preRect = self.bounds;
    }
}

- (void)refresh:(NTESChatroomInfo *)info;
{
    //room name
    _roomNameLabel.text = info.name ?: @"";
    
    //onlineCount
    _onlineCountLabel.text = [@(info.onlineUserCount).stringValue stringByAppendingString:@"人"];
    
    //backImag
    if (info.thumbnail.length != 0) {
        NSURL *url = [NSURL URLWithString:info.thumbnail];
        if (url) {
            __weak typeof(self) weakSelf = self;
            [_backImgView yy_setImageWithURL:url placeholder:_placeholder options:YYWebImageOptionAvoidSetImage completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
                weakSelf.backImgView.image = [image yy_imageByRoundCornerRadius:2.0];
            }];
        }
    }
}

- (UILabel *)roomNameLabel {
    if (!_roomNameLabel) {
        _roomNameLabel = [[UILabel alloc] init];
        [_roomNameLabel setTextColor:[UIColor whiteColor]];
        _roomNameLabel.font = [UIFont systemFontOfSize:20];
        _roomNameLabel.text = @"未知";
        [_roomNameLabel sizeToFit];
    }
    return _roomNameLabel;
}

- (UILabel *)onlineCountLabel
{
    if (!_onlineCountLabel) {
        _onlineCountLabel = [[UILabel alloc] init];
        [_onlineCountLabel setTextColor:[UIColor whiteColor]];
        _onlineCountLabel.font = [UIFont systemFontOfSize:14];
        _onlineCountLabel.text = @"0人";
        [_onlineCountLabel sizeToFit];
    }
    return _onlineCountLabel;
}

- (UIImageView *)backImgView {
    if (!_backImgView) {
        _backImgView = [[UIImageView alloc] init];
        _placeholder = [UIImage imageNamed:@"default_room_background"];
        _backImgView.image = _placeholder;
    }
    return _backImgView;
}

@end
