//
//  NTESMessageModel.m
//  NIMLiveDemo
//
//  Created by chris on 16/3/28.
//  Copyright © 2016年 Netease. All rights reserved.
//

#import "NTESMessageModel.h"
#import "M80AttributedLabel.h"
#import "NTESUserUtil.h"

@interface NTESMessageModel ()
@property (nonatomic,assign) NSRange nickRange;
@property (nonatomic,assign) NSRange textRange;
@end

@implementation NTESMessageModel

- (void)caculate:(CGFloat)width
{
    ntes_main_sync_safe(^{
        M80AttributedLabel *label = NTESCaculateLabel();
        [label setAttributedText:self.formatMessage];
        CGSize size = [label sizeThatFits:CGSizeMake(width, CGFLOAT_MAX)];
        _size = size;
    });
}

- (NSAttributedString *)formatMessage
{
    NSString *showMessage = [self showMessage];
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:showMessage];
    switch (_type) {
        case NTESMessageNormal:
            [text setAttributes:@{NSForegroundColorAttributeName:UIColorFromRGB(0xffffff),
                                  NSFontAttributeName:Chatroom_Message_Font}
                          range:_nickRange];
            [text setAttributes:@{NSForegroundColorAttributeName:UIColorFromRGB(0x828282),
                                  NSFontAttributeName:Chatroom_Message_Font}
                          range:_textRange];
            break;
        case NTESMessageNotication:
            [text setAttributes:@{NSForegroundColorAttributeName:UIColorFromRGB(0xffffff),
                                  NSFontAttributeName:Chatroom_Message_Font}
                          range:_textRange];
            break;
        default:
            break;
    }
    return text;
}

- (NSRange)textRange
{
    NSString *showMessage = [self showMessage];
    return NSMakeRange(showMessage.length - self.message.text.length, self.message.text.length);
}

- (NSString *)showMessage
{
    NSString *showMessage = @"";
    switch (_type) {
        case NTESMessageNormal:{
            NSString *nickName = [NTESUserUtil fromNickNameWithMessage:_message];
            showMessage = [NSString stringWithFormat:@"%@：%@", nickName, _message.text];
            _textRange = NSMakeRange(showMessage.length-_message.text.length, _message.text.length);
            _nickRange = NSMakeRange(0, showMessage.length-_message.text.length);
            break;
        }
        case NTESMessageNotication: {
            showMessage = [NSString stringWithFormat:@"%@", _message.text];
            _textRange = NSMakeRange(0, showMessage.length);
            _nickRange = NSMakeRange(0, 0);
            break;
        }
        default:
            break;
    }
    return showMessage;
}

M80AttributedLabel *NTESCaculateLabel()
{
    static M80AttributedLabel *label;
    if (!label) {
        label = [[M80AttributedLabel alloc] init];
        label.font = Chatroom_Message_Font;
        label.numberOfLines = 0;
        label.lineBreakMode = kCTLineBreakByCharWrapping;
    }
    return label;
}

@end
