//
//  NTESGrowingTextView.h
//  NIMLiveDemo
//
//  Created by chris on 16/3/27.
//  Copyright © 2016年 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NTESGrowingTextView;

@protocol NTESGrowingTextViewDelegate <NSObject>
@optional

- (BOOL)shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)replacementText;

- (BOOL)shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)range;

- (BOOL)shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment inRange:(NSRange)range;

- (void)textViewDidBeginEditing:(NTESGrowingTextView *)growingTextView;

- (void)textViewDidChangeSelection:(NTESGrowingTextView *)growingTextView;

- (void)textViewDidEndEditing:(NTESGrowingTextView *)growingTextView;

- (BOOL)textViewShouldBeginEditing:(NTESGrowingTextView *)growingTextView;

- (BOOL)textViewShouldEndEditing:(NTESGrowingTextView *)growingTextView;

- (void)textViewDidChange:(NTESGrowingTextView *)growingTextView;

- (void)willChangeHeight:(CGFloat)height;

- (void)didChangeHeight:(CGFloat)height;

@end

@interface NTESGrowingTextView : UIScrollView

@property (nonatomic,weak) id<NTESGrowingTextViewDelegate> textViewDelegate;

@property (nonatomic,assign) NSInteger minNumberOfLines;

@property (nonatomic,assign) NSInteger maxNumberOfLines;

@property (nonatomic,strong) UIView *inputView;

@end

@interface NTESGrowingTextView(TextView)

@property (nonatomic,copy)   NSAttributedString *placeholderAttributedText;

@property (nonatomic,copy)   NSString *text;

@property (nonatomic,strong) UIFont *font;

@property (nonatomic,strong) UIColor *textColor;

@property (nonatomic,assign) NSTextAlignment textAlignment;

@property (nonatomic,assign) NSRange selectedRange;

@property (nonatomic,assign) UIDataDetectorTypes dataDetectorTypes;

@property (nonatomic,assign) BOOL editable;

@property (nonatomic,assign) BOOL selectable;

@property (nonatomic,assign) BOOL allowsEditingTextAttributes;

@property (nonatomic,copy)   NSAttributedString *attributedText;

@property (nonatomic,strong) UIView *textViewInputAccessoryView;

@property (nonatomic,assign) BOOL clearsOnInsertion;

@property (nonatomic,readonly) NSTextContainer *textContainer;

@property (nonatomic,assign)   UIEdgeInsets textContainerInset;

@property (nonatomic,readonly) NSLayoutManager *layoutManger;

@property (nonatomic,readonly) NSTextStorage *textStorage;

@property (nonatomic, copy)    NSDictionary<NSString *, id> *linkTextAttributes;

//@property (nonatomic,assign)  UIReturnKeyType returnKeyType;

- (void)scrollRangeToVisible:(NSRange)range;

@end
