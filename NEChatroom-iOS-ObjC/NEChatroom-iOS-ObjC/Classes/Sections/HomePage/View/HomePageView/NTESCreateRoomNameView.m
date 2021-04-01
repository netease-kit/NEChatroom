//
//  NTESSlideView.m
//  NEChatroom-iOS-ObjC
//
//  Created by vvj on 2021/1/28.
//  Copyright © 2021 netease. All rights reserved.
//

#import "NTESCreateRoomNameView.h"
#import "NTESCreateRoomTitleButton.h"

@interface NTESCreateRoomNameView ()<UITextViewDelegate>
@property (nonatomic, strong) NSArray *titleArray;
@property (nonatomic, strong) UIButton *chatRoomButton;
@property (nonatomic, strong) UIButton *ktvButton;
@property (nonatomic, strong) UIView *divideView;
@property (nonatomic, strong) UIView *slideView;
@property (nonatomic, strong) UITextView *contentTextView;
@property (nonatomic, strong) UIButton *randomThemeButton;

@end



@implementation NTESCreateRoomNameView

- (void)ntes_bindViewModel {
    [self createRandomRoomName];
}

- (void)ntes_setupViews {
    self.backgroundColor = UIColorFromRGBA(0x0C0C0D, 0.6);
    [self addSubview:self.chatRoomButton];
    [self addSubview:self.ktvButton];
    [self addSubview:self.divideView];
    [self addSubview:self.slideView];
    [self addSubview:self.contentTextView];
    [self addSubview:self.randomThemeButton];

    [self.chatRoomButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(self);
        make.right.equalTo(self.mas_centerX);
        make.height.mas_equalTo(48);
    }];
    
    [self.ktvButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.equalTo(self);
        make.left.equalTo(self.mas_centerX);
        make.height.mas_equalTo(48);
    }];
    
    [self.divideView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(48);
        make.left.equalTo(self).offset(12);
        make.right.equalTo(self).offset(-12);
        make.height.mas_equalTo(0.5);
    }];
    
    [self.slideView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.divideView.mas_top);
        make.centerX.equalTo(self.chatRoomButton);
        make.size.mas_equalTo(CGSizeMake(20, 3));
        
    }];
    
    [self.randomThemeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(20, 20));
        make.top.equalTo(self.divideView.mas_bottom).offset(12);
        make.right.equalTo(self).offset(-12);
     }];
    
    [self.contentTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(12);
        make.bottom.equalTo(self).offset(-12);
        make.top.equalTo(self.divideView.mas_bottom);
        make.right.equalTo(self.randomThemeButton.mas_left).offset(-12);
    }];
 
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.ktvButton layoutButtonWithEdgeInsetsStyle:QSButtonEdgeInsetsStyleLeft imageTitleSpace:2];
    [self.chatRoomButton layoutButtonWithEdgeInsetsStyle:QSButtonEdgeInsetsStyleLeft imageTitleSpace:2];
}

//点击语聊房
- (void)chatRoomButtonClick {
    self.chatRoomButton.alpha = 1;
    self.ktvButton.alpha = 0.5;
    [self.slideView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.divideView.mas_top);
        make.centerX.equalTo(self.chatRoomButton);
        make.size.mas_equalTo(CGSizeMake(20, 3));
    }];
    if (_delegate && [_delegate respondsToSelector:@selector(createRoomResult:)]) {
        [_delegate createRoomResult:NTESCreateRoomTypeChatRoom];
    }
}

//点击ktv房间
- (void)ktvButtonClick {
    self.chatRoomButton.alpha = 0.5;
    self.ktvButton.alpha = 1;
    [self.slideView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.divideView.mas_top);
        make.centerX.equalTo(self.ktvButton);
        make.size.mas_equalTo(CGSizeMake(20, 3));
    }];
    if (_delegate && [_delegate respondsToSelector:@selector(createRoomResult:)]) {
        [_delegate createRoomResult:NTESCreateRoomTypeKTV];
    }
}

- (NSString *)getRoomName {
    return self.contentTextView.text;
}

- (void)createRandomRoomName {
    [NTESChatroomApi fetchRoomThemeWithSuccessBlock:^(NSDictionary * _Nonnull response) {
        NSDictionary *listDict = response[@"/"];
        if (listDict) {
            self.contentTextView.text = listDict[@"data"];
        }
    } errorBlock:^(NSError * _Nonnull error, NSDictionary * _Nullable response) {
        if (error) {
            YXAlogInfo(@"获取房间随机主题失败");
        }
    }];
}

- (void)setRoomType:(NTESCreateRoomType)roomType {
    _roomType = roomType;
    UIButton *typeButton = roomType == NTESCreateRoomTypeChatRoom ? self.chatRoomButton : self.ktvButton;
    [typeButton sendActionsForControlEvents:UIControlEventTouchUpInside];
}

- (BOOL)textView:(UITextView*)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString*)text {
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    NSString *newString = [textView.text stringByReplacingCharactersInRange:range withString:text];
    return newString.length <= 20; // 限制 20字符
}


#pragma mark - lazyMethod

-(UIButton *)chatRoomButton {
    if (!_chatRoomButton) {
        _chatRoomButton = [[UIButton alloc]init];
        [_chatRoomButton setTitle:@"语音聊天室" forState:UIControlStateNormal];
        [_chatRoomButton setImage:[UIImage imageNamed:@"chatroom_titleIcon"] forState:UIControlStateNormal];
        _chatRoomButton.titleLabel.textColor = UIColor.whiteColor;
        _chatRoomButton.titleLabel.font = TextFont_16;
        [_chatRoomButton addTarget:self action:@selector(chatRoomButtonClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _chatRoomButton;
}

-(UIButton *)ktvButton {
    if (!_ktvButton) {
        _ktvButton = [[UIButton alloc]init];
        [_ktvButton setTitle:@"KTV" forState:UIControlStateNormal];
        [_ktvButton setImage:[UIImage imageNamed:@"ktv_titleIcon"] forState:UIControlStateNormal];
        _ktvButton.titleLabel.textColor = UIColor.whiteColor;
        _ktvButton.titleLabel.font = TextFont_16;
        [_ktvButton addTarget:self action:@selector(ktvButtonClick) forControlEvents:UIControlEventTouchUpInside];
        _ktvButton.alpha = 0.5;
    }
    return _ktvButton;
}


- (UIView *)divideView {
    if (!_divideView) {
        _divideView = [NTESViewFactory createViewFrame:CGRectZero BackgroundColor:UIColorFromRGBA(0xffffff, 0.2)];
    }
    return _divideView;
}

- (UIView *)slideView {
    if (!_slideView) {
        _slideView = [NTESViewFactory createViewFrame:CGRectZero BackgroundColor:UIColorFromRGB(0x337EFF)];
    }
    return _slideView;
}

- (UITextView *)contentTextView {
    if (!_contentTextView) {
        _contentTextView = [[UITextView alloc]init];
        _contentTextView.backgroundColor = UIColor.clearColor;
        _contentTextView.textColor = UIColor.whiteColor;
        _contentTextView.font = TextFont_14;
        _contentTextView.delegate = self;
    }
    return _contentTextView;
}

- (UIButton *)randomThemeButton {
    if (!_randomThemeButton) {
        _randomThemeButton = [[UIButton alloc]init];
        [_randomThemeButton setBackgroundImage:[UIImage imageNamed:@"createRoom_randomIcon"] forState:UIControlStateNormal];
        [_randomThemeButton addTarget:self action:@selector(createRandomRoomName) forControlEvents:UIControlEventTouchUpInside];
    }
    return _randomThemeButton;
}
@end
