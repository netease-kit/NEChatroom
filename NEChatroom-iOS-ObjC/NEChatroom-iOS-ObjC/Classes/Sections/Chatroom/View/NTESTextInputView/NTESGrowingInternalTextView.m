//
//  NTESGrowingInternalTextView.m
//  NIMLiveDemo
//
//  Created by chris on 16/3/27.
//  Copyright © 2016年 Netease. All rights reserved.
//

#import "NTESGrowingInternalTextView.h"

@interface NTESGrowingInternalTextView()

@property (nonatomic,assign) BOOL displayPlaceholder;

@end

@implementation NTESGrowingInternalTextView

- (instancetype)initWithFrame:(CGRect)frame textContainer:(NSTextContainer *)textContainer
{
    self = [super initWithFrame:frame textContainer:textContainer];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChangeNotification:) name:UITextViewTextDidChangeNotification object:self];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setText:(NSString *)text
{
    [super setText:text];
    [self updatePlaceholder];
}

- (void)setPlaceholderAttributedText:(NSAttributedString *)placeholderAttributedText
{
    _placeholderAttributedText = placeholderAttributedText;
    [self setNeedsDisplay];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self setNeedsDisplay];
}



#pragma mark - Private

- (void)setDisplayPlaceholder:(BOOL)displayPlaceholder
{
    BOOL oldValue = _displayPlaceholder;
    _displayPlaceholder = displayPlaceholder;
    if (oldValue != self.displayPlaceholder) {
        [self setNeedsDisplay];
    }
}

- (void)updatePlaceholder
{
    self.displayPlaceholder = self.text.length == 0;
}

- (void)textDidChangeNotification:(NSNotification *)notification
{
    [self updatePlaceholder];
}


- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    if (!self.displayPlaceholder) {
        return;
    }
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = self.textAlignment;
    
    CGRect targetRect = CGRectMake(5, 8 + self.contentInset.top, self.frame.size.width - self.contentInset.left, self.frame.size.height - self.contentInset.top);
    
    NSAttributedString *attributedString = self.placeholderAttributedText;
    [attributedString drawInRect:targetRect];
}


@end
