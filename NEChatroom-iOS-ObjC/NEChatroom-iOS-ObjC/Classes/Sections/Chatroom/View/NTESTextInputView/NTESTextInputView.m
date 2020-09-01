//
//  NTESTextInputView.m
//  NIMLiveDemo
//
//  Created by chris on 16/3/28.
//  Copyright © 2016年 Netease. All rights reserved.
//

#import "NTESTextInputView.h"
#import "UIView+NTES.h"

@interface NTESTextInputView()<NTESGrowingTextViewDelegate>
{
    CGRect _preRect;
    BOOL _beginEdit;
}
@property (nonatomic,strong) NTESGrowingTextView *textView;
@property (nonatomic,strong) UIButton *sendButton;
@property (nonatomic,strong) UIView *wrapperView;
@property (nonatomic,assign) CGFloat offset;
@property (nonatomic,assign) CGFloat oriTop;
@property (nonatomic,assign) CGFloat lastTop;
@property (nonatomic,strong) UIButton *tapBtn;
@property (nonatomic,assign) CGFloat oriHeight;
@property (nonatomic,assign) CGFloat heightOffset;
@property (nonatomic,assign) BOOL enableMute;
@property (nonatomic, assign) BOOL showSend;
@end

@implementation NTESTextInputView

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.sendButton];
        [self addSubview:self.wrapperView];
        [self.wrapperView addSubview:self.textView];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (!CGRectEqualToRect(self.bounds, _preRect)) {
        _sendButton.frame = CGRectMake(self.width-74.0-10.0, 0, 74.0, 36.0);
        _sendButton.centerY = self.height/2;
        _sendButton.layer.cornerRadius = _sendButton.height/2;
        [self layoutShowSend:_showSend];
        CGFloat textViewWidth = self.width - _sendButton.width - 6.0 - 10.0*2;
        _textView.frame = CGRectMake(8.0, 0, textViewWidth-16.0, _wrapperView.height);
    }
}

- (void)layoutShowSend:(BOOL)showSend {
    if (_showSend) {
        _sendButton.hidden = NO;
        CGFloat textViewWidth = self.width - _sendButton.width - 6.0 - 10.0*2;
        _wrapperView.frame = CGRectMake(10.0, 0, textViewWidth, self.height);
        _wrapperView.layer.cornerRadius = self.height/2;
        
        _beginEdit = YES;
        [self.tapBtn removeFromSuperview];
        _tapBtn.frame = [UIScreen mainScreen].bounds;
        if (self.superview) {
            [self.superview insertSubview:self.tapBtn belowSubview:self];
        }
    } else {
        _sendButton.hidden = YES;
        _wrapperView.frame = CGRectMake(20.0, 0, self.width-2*20.0, self.height);
        _wrapperView.layer.cornerRadius = self.height/2;
        
        _beginEdit = NO;
        [self.tapBtn removeFromSuperview];
        _tapBtn.frame = _wrapperView.frame;
        [self addSubview:_tapBtn];
    }
}

#pragma mark - NTESGrowingTextViewDelegate
- (void)willChangeHeight:(CGFloat)height
{
    CGFloat bottom = self.bottom;
    _lastTop = self.top;
    self.size = [self measureViewSize:height];
    self.bottom = bottom;
    if ([self.delegate respondsToSelector:@selector(willChangeHeight:)]) {
        [self.delegate willChangeHeight:height];
    }
    _heightOffset = (self.height - _oriHeight - (self.top - _lastTop));
    [self.delegate topDidChange:(self.top - _lastTop)];
}

- (void)didChangeHeight:(CGFloat)height
{
    if ([self.delegate respondsToSelector:@selector(didChangeHeight:)]) {
        [self.delegate didChangeHeight:height];
    }
}

- (BOOL)shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)replacementText
{
    if ([replacementText isEqualToString:@"\n"]) {
        [self onSend:self.textView.text];
        [self endEditing:YES];
        return NO;
    }
    return YES;
}

- (void)setShowSend:(BOOL)showSend {
    _showSend = showSend;
    [self layoutShowSend:showSend];
}

- (void)setEnableMuteWithType:(NTESDisableType)type {
    NSString *msg = @"";
    if (type == NTESDisableTypeMute) {
        msg = @"您已被禁言";
    } else if (type == NTESDisableTypeMuteAll){
        msg = @"主播已开启\"全部禁言\"";
    }
    
    //结束输入
    [self resignFirstResponder];
    [self setShowSend:NO];
    _wrapperView.hidden = YES;
    
    //覆盖禁用层
    [_tapBtn setTitle:msg forState:UIControlStateNormal];
    _tapBtn.layer.cornerRadius = _tapBtn.height/2;
    _tapBtn.backgroundColor = UIColorFromRGBA(0xffffff, 0.1);
    _enableMute = YES;
}

- (void)setDisableMute {
    _wrapperView.hidden = NO;
    _tapBtn.layer.cornerRadius = 0;
    _tapBtn.backgroundColor = [UIColor clearColor];
    [_tapBtn setTitle:@"" forState:UIControlStateNormal];
    _enableMute = NO;
}

#pragma mark - Get
- (NTESGrowingTextView *)textView
{
    if (!_textView) {
        _textView = [[NTESGrowingTextView alloc] initWithFrame:CGRectMake(0, 0, 0, 36.f)];
        _textView.textViewDelegate  = self;
        _textView.textColor = [UIColor whiteColor];
        _textView.font = [UIFont systemFontOfSize:13.0];
        _textView.backgroundColor  = [UIColor clearColor];
        NSDictionary *attributes = @{
                                     NSFontAttributeName:_textView.font,
                                     NSForegroundColorAttributeName:UIColorFromRGB(0x525252)
                                     };
        _textView.placeholderAttributedText = [[NSAttributedString alloc] initWithString:@"唠两句~"
                                                                             attributes:attributes];
    }
    return _textView;
}

- (UIButton *)sendButton
{
    if (!_sendButton) {
        _sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_sendButton setBackgroundColor:UIColorFromRGB(0x2294ff)];
        _sendButton.titleLabel.font = [UIFont systemFontOfSize:14.f];
        [_sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_sendButton setTitle:@"发送" forState:UIControlStateNormal];
        [_sendButton addTarget:self action:@selector(onSend:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sendButton;
}

- (UIView *)wrapperView {
    if (!_wrapperView) {
        _wrapperView = [[UIView alloc] init];
        _wrapperView.backgroundColor = UIColorFromRGBA(0xFFFFFF, 0.1);
        _wrapperView.clipsToBounds = YES;
    }
    return _wrapperView;
}

- (void)onSend:(id)sender
{
    NSString *text = self.textView.text;
    if (!text.length) {
        return;
    }
    self.textView.text = @"";
    [self endEditing:YES];
    if ([self.delegate respondsToSelector:@selector(didSendText:)]) {
        [self.delegate didSendText:text];
    }
}

- (void)tapAction:(UIButton *)sender {
    
    if (_enableMute) {
        if (_delegate && [_delegate respondsToSelector:@selector(didSendText:)]) {
            [_delegate didSendText:@""];
        }
    } else {
        if (_beginEdit) {
            [self.textView resignFirstResponder];
        } else {
            [self.textView becomeFirstResponder];
        }
    }
}

- (UIButton *)tapBtn {
    if (!_tapBtn) {
        _tapBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _tapBtn.frame = [UIScreen mainScreen].bounds;
        [_tapBtn setTitleColor:UIColorFromRGBA(0x525252, 1.0) forState:UIControlStateNormal];
        _tapBtn.titleLabel.font = [UIFont systemFontOfSize:13.0];
        [_tapBtn addTarget:self action:@selector(tapAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _tapBtn;
}

#pragma mark - Private
- (CGSize)measureViewSize:(CGFloat)newTextViewHeight {
    CGFloat topSpacing = (self.height - self.textView.height) / 2;
    CGFloat height = topSpacing * 2 + newTextViewHeight;
    return CGSizeMake(self.width, height);
}


#pragma mark - Notification
- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *info = notification.userInfo;
    if (_offset == 0) {
        _oriTop = self.top;
        _lastTop = _oriTop;
        _oriHeight = self.height;
    }
    if (_offset == 0) {
        _offset = -1 * [info[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
        __weak typeof(self) weakSelf = self;
        [UIView animateWithDuration:0.25 animations:^{
            weakSelf.top = weakSelf.oriTop + weakSelf.offset;
        } completion:^(BOOL finished) {
            weakSelf.showSend = YES;
        }];
    } else {
        _offset = -1 * [info[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
        self.top = self.oriTop + self.offset;
        self.showSend = YES;
    }
    if (_delegate && [_delegate respondsToSelector:@selector(topDidChange:)]) {
        [_delegate topDidChange:(self.top - _lastTop)];
    }
    _lastTop = self.top;
}

- (void)keyboardWillHide:(NSNotification *)notification{
    if (_offset != 0) {
        __weak typeof(self) weakSelf = self;
        CGFloat top = weakSelf.top;
        [UIView animateWithDuration:0.25 animations:^{
            weakSelf.top = top - weakSelf.offset;
        }completion:^(BOOL finished) {
            weakSelf.showSend = NO;
        }];
        _offset = 0;
        if (_delegate && [_delegate respondsToSelector:@selector(topDidChange:)]) {
            [_delegate topDidChange:(self.top - (_lastTop - _heightOffset))];
        }
        _heightOffset = 0;
    }
}

@end
