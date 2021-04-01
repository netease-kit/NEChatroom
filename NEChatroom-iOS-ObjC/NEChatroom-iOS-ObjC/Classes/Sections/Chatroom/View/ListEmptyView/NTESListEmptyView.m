//
//  NTESListEmptyView.m
//  NLiteAVDemo
//
//  Created by Think on 2020/12/31.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NTESListEmptyView.h"
#import "UIImage+NTES.h"

@interface NTESListEmptyView ()

@property (nonatomic, strong)   UIImageView *imgView;
@property (nonatomic, strong)   UILabel     *tipLabel;

@end

@implementation NTESListEmptyView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self addSubview:self.imgView];
        [self addSubview:self.tipLabel];
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    self.imgView.frame = CGRectMake((frame.size.width - 80) * 0.5, 0, 80, 80);
    self.tipLabel.frame = CGRectMake(0, self.imgView.height + 12, frame.size.width, 22);
}

- (void)setTintColor:(UIColor *)tintColor
{
    if (_tintColor == tintColor) {
        return;
    }
    self.imgView.image = [[UIImage imageNamed:@"empty_ico"] ne_imageWithTintColor:tintColor];
    self.tipLabel.textColor = tintColor;
}

- (void)setMsg:(NSString *)msg
{
    self.tipLabel.text = msg;
}

#pragma mark - lazy load

- (UIImageView *)imgView
{
    if (!_imgView) {
        _imgView = [[UIImageView alloc] init];
        _imgView.image = [UIImage imageNamed:@"empty_ico"];
    }
    return _imgView;
}

- (UILabel *)tipLabel
{
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc] init];
        _tipLabel.font = [UIFont systemFontOfSize:14];
        _tipLabel.textColor = UIColorFromRGB(0xbfbfbf);
        _tipLabel.textAlignment = NSTextAlignmentCenter;
        _tipLabel.text = @"暂无直播哦";
    }
    return _tipLabel;
}

@end
