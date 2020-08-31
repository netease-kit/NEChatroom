//
//  NTESLiveChatTextCell.m
//  NIMLiveDemo
//
//  Created by chris on 16/3/28.
//  Copyright © 2016年 Netease. All rights reserved.
//

#import "NTESLiveChatTextCell.h"
#import "M80AttributedLabel.h"
#import "UIView+NTES.h"

@interface NTESLiveChatTextCell()
{
    CGRect _preRect;
}
@property (nonatomic, strong) NTESMessageModel *model;
@property (nonatomic,strong) M80AttributedLabel *attributedLabel;

@end

@implementation NTESLiveChatTextCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.contentView.layer.cornerRadius = 12.0;
        [self.contentView addSubview:self.attributedLabel];
    }
    return self;
}

- (void)refresh:(NTESMessageModel *)model
{
    [self.attributedLabel setAttributedText:model.formatMessage];
    _model = model;
    
    switch (model.type) {
        case NTESMessageNormal:
        {
            self.contentView.backgroundColor = UIColorFromRGBA(0xffffff, 0.1);
            break;
        }
        case NTESMessageNotication:
        {
            self.contentView.backgroundColor = [UIColor clearColor];
            break;
        }
        default:
            break;
    }
    
    
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.contentView.frame = CGRectMake(0, 0, _model.size.width + 8*2, _model.size.height + 4.0);
    self.contentView.centerY = self.height/2;
    _attributedLabel.frame = CGRectMake(8, 0, _model.size.width, _model.size.height);
    _attributedLabel.bottom = self.contentView.height;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{

}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    
}

#pragma mark - Get
- (M80AttributedLabel *)attributedLabel
{
    if (!_attributedLabel) {
        _attributedLabel = [[M80AttributedLabel alloc] init];
        _attributedLabel.numberOfLines = 0;
        _attributedLabel.font = Chatroom_Message_Font;
        _attributedLabel.backgroundColor = [UIColor clearColor];//UIColorFromRGBA(0xffffff, 0.1);
        _attributedLabel.lineBreakMode = kCTLineBreakByCharWrapping;
    }
    return _attributedLabel;
}

@end
