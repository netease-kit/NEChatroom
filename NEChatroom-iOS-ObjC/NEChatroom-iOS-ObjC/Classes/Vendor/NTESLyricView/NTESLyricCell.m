//
//  NTESLyricCell.m
//  NEChatroom-iOS-ObjC
//
//  Created by Wenchao Ding on 2021/1/25.
//  Copyright © 2021 netease. All rights reserved.
//

#import "NTESLyricCell.h"

@implementation NTESLyricCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textLabel.textAlignment = NSTextAlignmentCenter;
        self.textLabel.font = [UIFont systemFontOfSize:18];
        self.backgroundColor = UIColor.clearColor;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.textLabel.frame = self.contentView.bounds;
}

- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    [self updateUIProgress:(CGFloat)progress];
}

- (void)updateUIProgress:(CGFloat)progress {
//    CGFloat fromR = 255.0/255.0;
//    CGFloat fromG = 0;
//    CGFloat fromB = 85.0/255.0;
//    CGFloat fromA = 1.0;
//    CGFloat fromS = 18.0;
    
    CGFloat fromR = 255.0/255.0;
    CGFloat fromG = 255.0/255.0;
    CGFloat fromB = 255.0/255.0;
    CGFloat fromA = 1.0;
    CGFloat fromS = 18.0;
    
    CGFloat toR = 1.0;
    CGFloat toG = 1.0;
    CGFloat toB = 1.0;
    CGFloat toA = 0.6;
    CGFloat toS = 15.0;
    
    CGFloat currR = fromR + (toR-fromR) * progress;
    CGFloat currG = fromG + (toG-fromG) * progress;
    CGFloat currB = fromB + (toB-fromB) * progress;
    CGFloat currA = fromA + (toA-fromA) * progress;
    CGFloat currS = fromS + (toS-fromS) * progress;
    self.textLabel.textColor = [UIColor colorWithRed:currR green:currG blue:currB alpha:currA];
    self.textLabel.font = [UIFont systemFontOfSize:currS];
}

@end
