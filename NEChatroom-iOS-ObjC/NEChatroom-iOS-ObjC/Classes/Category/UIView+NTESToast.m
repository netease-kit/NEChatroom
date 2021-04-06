//
//  UIView+NTESToast.m
//  NERtcAudioChatroom
//
//  Created by Netease on 2019/3/8.
//  Copyright © 2019年 netease. All rights reserved.
//

#import "UIView+NTESToast.h"
#import "UIView+NTES.h"

#define NTES_TOAST_MIN_WIDTH (120)
#define NTES_TOAST_BAR_TAG (111)

@interface NTESToastBar : UIView

@property (nonatomic, assign) NTESToastState state;
@property (nonatomic, strong) UILabel *infoLab;
@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, strong) UIButton *cancelBtn;
@property (nonatomic, strong) dispatch_block_t cancel;

- (instancetype)initWithState:(NTESToastState)state;
- (CGFloat)setInfo:(NSString *)info;

@end

@implementation UIView (NTESToast)

- (void)showToastWithMessage:(NSString *)message
                       state:(NTESToastState)state {
    
    [self showToastWithMessage:message
                         state:state
                   autoDismiss:YES];
}

- (void)showToastWithMessage:(NSString *)message
                       state:(NTESToastState)state
                 autoDismiss:(BOOL)autoDismiss {
    
    [self showToastWithMessage:message
                         state:state
                        cancel:nil];
    
    if (autoDismiss) {
        [self performSelector:@selector(dismissToast) withObject:nil afterDelay:1];
    }
}

- (void)showToastWithMessage:(NSString *)message
                       state:(NTESToastState)state
                      cancel:(nullable dispatch_block_t)cancel {
    
    [self dismissToast];
    
    NTESToastBar *bar = [[NTESToastBar alloc] initWithState:state];
    bar.cancel = cancel;
    bar.tag = NTES_TOAST_BAR_TAG;
    CGFloat width = [bar setInfo:message];
    width = MIN(width, self.bounds.size.width);
    CGFloat offset = 38.0;
    bar.frame = CGRectMake(0, -offset, width, offset);
    bar.centerX = self.bounds.size.width/2;
    
    [self addSubview:bar];
    [UIView animateWithDuration:0.25 animations:^{
        bar.top = (IPHONE_X ? IPHONE_X_HairHeight : 20);
    }];
}

- (void)dismissToast {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    UIView *bar = [self viewWithTag:NTES_TOAST_BAR_TAG];
    CGFloat offset = bar.height;
    
    bar.top = -offset;
    [bar removeFromSuperview];
}
@end

@implementation NTESToastBar

- (instancetype)initWithState:(NTESToastState)state {
    if (self = [super init]) {
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 19;
        
        switch (state) {
            case NTESToastStateSuccess:
                [self addSubview:self.imgView];
                [self addSubview:self.infoLab];
                _imgView.image = [UIImage imageNamed:@"state_success"];
                break;
            case NTESToastStateFail:
                [self addSubview:self.imgView];
                [self addSubview:self.infoLab];
                _imgView.image = [UIImage imageNamed:@"state_fail"];
                break;
            case NTESToastCancel:
                [self addSubview:self.infoLab];
                [self addSubview:self.cancelBtn];
                break;
            default:
                break;
        }
        _state = state;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    switch (_state) {
        case NTESToastStateSuccess:
        case NTESToastStateFail: {
            _imgView.frame = CGRectMake(20.0, 0, 18.0, 18.0);
            _imgView.centerY = self.height/2;
            _infoLab.frame = CGRectMake(_imgView.right + 5.0, 0, self.width-_imgView.right-5.0-20.0, self.height);
            break;
        }
        case NTESToastCancel: {
            _infoLab.frame = CGRectMake(20.0, 0, self.width-56.0-20.0, self.height);
            _cancelBtn.frame = CGRectMake(_infoLab.right, 0, self.width-_infoLab.right, self.height);
            break;
        }
        default:
            break;
    }
    
}

- (CGFloat)setInfo:(NSString *)info {
    _infoLab.text = info ?: @"";
    [_infoLab sizeToFit];
    
    
    CGFloat width = NTES_TOAST_MIN_WIDTH;
    if (_state != NTESToastCancel) {
        width = _infoLab.width + 20.0 + 18.0 + 5.0 + 20.0;
    } else {
        width = _infoLab.width + 20.0 + 56.0;
    }
    return MAX(width, NTES_TOAST_MIN_WIDTH);
}

#pragma mark - Action
- (void)cancelAction:(UIButton *)sender {
    if (_cancel) {
        _cancel();
    }
}

#pragma mark - Getter

- (UIImageView *)imgView {
    if (!_imgView) {
        _imgView = [[UIImageView alloc] init];
        _imgView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _imgView;
}

- (UILabel *)infoLab {
    if (!_infoLab) {
        _infoLab = [[UILabel alloc] init];
        _infoLab.font = [UIFont systemFontOfSize:14.0];
        _infoLab.textColor = UIColorFromRGBA(0x222222, 1.0);
    }
    return _infoLab;
}

- (UIButton *)cancelBtn {
    if (!_cancelBtn) {
        _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelBtn setTitleColor:UIColorFromRGBA(0x35a4ff, 1.0) forState:UIControlStateNormal];
        _cancelBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
        _cancelBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
        [_cancelBtn addTarget:self
                       action:@selector(cancelAction:)
             forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelBtn;
}

@end
