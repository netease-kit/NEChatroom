//
//  NTESLiveRoomFooterView.m
//  NEChatroom-iOS-ObjC
//
//  Created by vvj on 2021/2/4.
//  Copyright © 2021 netease. All rights reserved.
//

#import "NTESLiveRoomFooterView.h"
#import "UIImage+NTES.h"
#import "NTESPickMusicService.h"
#import "NTESRtcConfig.h"

static void *KVOContext = &KVOContext;

#define kBtnWidth 36
@interface NTESLiveRoomFooterView ()<UITextFieldDelegate>
@property (nonatomic, strong) UIView *searchBarBgView;
@property (nonatomic, strong) UIImageView *searchImageView;
@property (nonatomic, strong) UITextField *inputTextField;
@property (nonatomic, strong) UIButton *requestSongButton;
@property (nonatomic, strong) UIButton *microphoneButton;
@property (nonatomic, strong) UIButton *bannedSpeakButton;
@property (nonatomic, strong) UIButton *menuButton;
@property (nonatomic, strong) NSArray *buttonsArray;
@property (nonatomic, strong) UILabel *markLable;

@property (nonatomic, strong) NTESChatroomDataSource *context;

@end

@implementation NTESLiveRoomFooterView

- (instancetype)initWithContext:(NTESChatroomDataSource *)context {
    self = [super init];
    if (self) {
        self.context = context;

        [self.context.rtcConfig addObserver:self forKeyPath:@"micOn" options:NSKeyValueObservingOptionNew context:KVOContext];
    }
    return self;
}

- (void)ntes_bindViewModel {
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(musicQueueDidChange:) name:kChatroomKtvMusicQueueChanged object:nil]; // 顶部歌曲变化通知
}

- (void)ntes_setupViews {
    self.backgroundColor = UIColor.clearColor;
    [self addSubview:self.searchBarBgView];
    [self.searchBarBgView addSubview:self.searchImageView];
    [self.searchBarBgView addSubview:self.inputTextField];
    
    CGSize searchViewSize = CGSizeZero;
    if (IS_IPAD) {
        searchViewSize = CGSizeMake(UIWidthAdapter(140), 36);
    }else {
        searchViewSize = CGSizeMake(UIWidthAdapter(140), UIWidthAdapter(36));
    }
    [self.searchBarBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(searchViewSize);
        make.left.top.equalTo(self);
    }];
    
    [self.searchImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.searchBarBgView).offset(12);
        make.centerY.equalTo(self.searchBarBgView);
        make.size.mas_equalTo(CGSizeMake(14, 14));
    }];
    
    [self.inputTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.searchBarBgView);
        make.left.equalTo(self.searchImageView.mas_right).offset(4);
        make.right.equalTo(self.searchBarBgView);
    }];
}

- (void)dealloc {
    [self.context.rtcConfig removeObserver:self forKeyPath:@"micOn"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (context != KVOContext) {
        return [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
    if ([keyPath isEqualToString:@"micOn"]) {
        self.microphoneButton.selected = !self.context.rtcConfig.micOn;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [_searchBarBgView cutViewRounded:UIRectCornerAllCorners cornerRadii:CGSizeMake(18, 18)];
       if (self.width != 0 && self.height != 0) {
            [self doLayoutButtons];
       }
}

- (void)musicQueueDidChange:(NSNotification *)notification {
    NSDictionary *musicInfo = notification.userInfo;
    NSArray *musicArray = musicInfo[kChatroomKtvMusicQueueKey];
    self.markLable.text = [NSString stringWithFormat:@"%zd",musicArray.count];
    self.markLable.hidden = musicArray.count == 0 ?YES:NO;
}

- (void)doLayoutButtons {
    if (self.width != 0 && self.height != 0) {
        __weak typeof(self)weakSelf = self;
        [self.buttonsArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            UIButton *btn = (UIButton *)obj;
            btn.frame = CGRectMake(weakSelf.width-kBtnWidth*(idx+1) - 8.0*idx,
                                   0,
                                   kBtnWidth,
                                   kBtnWidth);
        }];
    }
}

- (void)setUserMode:(NTESUserMode)userMode {
    _userMode = userMode;
    [self.buttonsArray makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self selectSubviewsWithUserMode:userMode];
    for (UIButton *btn in self.buttonsArray) {
        [self addSubview:btn];
    }
    [self doLayoutButtons];
}

- (void)selectSubviewsWithUserMode:(NTESUserMode)userMode {

    if (self.roomType == NTESCreateRoomTypeKTV) {
        switch (userMode) {
             case NTESUserModeAnchor:
                 self.buttonsArray = @[self.menuButton,self.bannedSpeakButton,self.microphoneButton,self.requestSongButton];
                 break;
             case NTESUserModeAudience:
//                 self.buttonsArray = @[self.menuButton,self.requestSongButton];
                self.buttonsArray = @[self.requestSongButton];
                 break;
             case NTESUserModeConnector:
                 self.buttonsArray = @[self.menuButton,self.microphoneButton,self.requestSongButton];
                 break;
             default:
                 break;
         }
    }else if (self.roomType == NTESCreateRoomTypeChatRoom){
        switch (userMode) {
              case NTESUserModeAnchor:
                  self.buttonsArray = @[self.menuButton,self.bannedSpeakButton,self.microphoneButton];
                  break;
              case NTESUserModeAudience:
//                  self.buttonsArray = @[self.menuButton];
                self.buttonsArray = @[];
                  break;
              case NTESUserModeConnector:
                  self.buttonsArray = @[self.menuButton,self.microphoneButton];
                  break;
              default:
                  break;
          }
    }
}

- (void)footerButtonClickAction:(UIButton *)sender {
    
    switch (sender.tag) {
        case NTESFunctionAreaRequestSong: {
            if (_delegate && [_delegate respondsToSelector:@selector(footerDidReceiveRequestSongAciton)]) {
                [_delegate footerDidReceiveRequestSongAciton];
            }
        }
            break;
        case NTESFunctionAreaMicrophone: {
            if (_delegate && [_delegate respondsToSelector:@selector(footerDidReceiveMicMuteAction:)]) {
                [_delegate footerDidReceiveMicMuteAction:!sender.selected];
            }
        }
            break;
        case NTESFunctionAreaBanned: {
            if (_delegate && [_delegate respondsToSelector:@selector(footerDidReceiveNoSpeekingAciton)]) {
                [_delegate footerDidReceiveNoSpeekingAciton];
            }
        }
            break;
        case NTESFunctionAreaMore: {
            if (_delegate && [_delegate respondsToSelector:@selector(footerDidReceiveMenuClickAciton)]) {
                [_delegate footerDidReceiveMenuClickAciton];
            }
        }
            break;
            
        default:
            break;
    }
}

- (void)setMuteWithType:(NTESMuteType)type {
    NSString *msg = @"";
    if (type == NTESMuteTypeSelf) {
        msg = @"您已被禁言";
    } else if (type == NTESMuteTypeAll){
//        msg = @"主播已开启\"全部禁言\"";
        msg = @"聊天室被禁言";
    }
    self.inputTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:msg attributes:@{NSForegroundColorAttributeName:UIColorFromRGB(0x4b6677)}];
    self.searchBarBgView.userInteractionEnabled = NO;
}

- (void)cancelMute {
    self.searchBarBgView.userInteractionEnabled = YES;
    self.inputTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"一起聊聊吧~" attributes:@{NSForegroundColorAttributeName:UIColorFromRGB(0xAAACB7)}];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(footerInputViewDidClickAction)]) {
        [self.delegate footerInputViewDidClickAction];
    }
    return NO;
}


#pragma mark - lazyMethod

- (UIView *)searchBarBgView {
    if (!_searchBarBgView) {
        _searchBarBgView = [NTESViewFactory createViewFrame:CGRectZero BackgroundColor:UIColorFromRGBA(0x000000, 0.5)];
    }
    return _searchBarBgView;
}

- (UIImageView *)searchImageView {
    if (!_searchImageView) {
        _searchImageView = [NTESViewFactory createImageViewFrame:CGRectZero imageName:@""];
        _searchImageView.image = [[UIImage imageNamed:@"chatroom_titleIcon"] ne_imageWithTintColor:UIColorFromRGB(0xAAACB7)];
    }
    return _searchImageView;
}

- (UITextField *)inputTextField {
    if (!_inputTextField) {
        _inputTextField = [NTESViewFactory createTextfieldFrame:CGRectZero placeHolder:@""];
        _inputTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"一起聊聊吧~" attributes:@{NSForegroundColorAttributeName:UIColorFromRGB(0xAAACB7)}];
        _inputTextField.font = TextFont_13;
        _inputTextField.delegate = self;
        _inputTextField.textColor = UIColor.whiteColor;
    }
    return _inputTextField;
}

- (UIButton *)requestSongButton {
    if (!_requestSongButton) {
        _requestSongButton = [NTESViewFactory createBtnFrame:CGRectZero title:@"点歌" bgImage:@"" selectBgImage:@"" image:@"" target:self action:@selector(footerButtonClickAction:)];
        [_requestSongButton setBackgroundColor:UIColorFromRGBA(0x000000, 0.5)];
        [_requestSongButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        _requestSongButton.titleLabel.font = Font_Default(12);
        _requestSongButton.tag = NTESFunctionAreaRequestSong;
        _requestSongButton.layer.cornerRadius = kBtnWidth/2;
        [_requestSongButton addSubview:self.markLable];
    }
    return _requestSongButton;
}

- (UIButton *)microphoneButton {
    if (!_microphoneButton) {
        _microphoneButton = [NTESViewFactory createBtnFrame:CGRectZero title:@"" bgImage:@"" selectBgImage:@"" image:@"icon_mic_on_n" target:self action:@selector(footerButtonClickAction:)];
        [_microphoneButton setImage:[UIImage imageNamed:@"icon_mic_off_n"] forState:UIControlStateSelected];
        [_microphoneButton setBackgroundColor:UIColorFromRGBA(0x000000, 0.5)];
        _microphoneButton.tag = NTESFunctionAreaMicrophone;
        _microphoneButton.selected = !self.context.rtcConfig.micOn;
        _microphoneButton.layer.cornerRadius = kBtnWidth/2;
    }
    return _microphoneButton;
}

- (UIButton *)bannedSpeakButton {
    if (!_bannedSpeakButton) {
        _bannedSpeakButton = [NTESViewFactory createBtnFrame:CGRectZero title:@"" bgImage:@"" selectBgImage:@"" image:@"banned_speak" target:self action:@selector(footerButtonClickAction:)];
        [_bannedSpeakButton setBackgroundColor:UIColorFromRGBA(0x000000, 0.5)];
        _bannedSpeakButton.tag = NTESFunctionAreaBanned;
        _bannedSpeakButton.layer.cornerRadius = kBtnWidth/2;

    }
    return _bannedSpeakButton;
}

- (UIButton *)menuButton {
    if (!_menuButton) {
        _menuButton = [NTESViewFactory createBtnFrame:CGRectZero title:@"" bgImage:@"" selectBgImage:@"" image:@"moreContent_icon" target:self action:@selector(footerButtonClickAction:)];
        [_menuButton setBackgroundColor:UIColorFromRGBA(0x000000, 0.5)];
        _menuButton.tag = NTESFunctionAreaMore;
        _menuButton.layer.cornerRadius = kBtnWidth/2;
    }
    return _menuButton;
}

- (UILabel *)markLable {
    if (!_markLable) {
        _markLable = [[UILabel alloc]initWithFrame:CGRectMake(kBtnWidth-16, 0, 20, 12)];
        _markLable.textColor = UIColorFromRGB(0x222222);
        _markLable.font = Font_Default(10);
        _markLable.backgroundColor = UIColor.whiteColor;
        _markLable.text = @"0";
        _markLable.textAlignment = NSTextAlignmentCenter;
        _markLable.layer.cornerRadius = 5;
        _markLable.layer.masksToBounds = YES;
    }
    return _markLable;
}
@end
