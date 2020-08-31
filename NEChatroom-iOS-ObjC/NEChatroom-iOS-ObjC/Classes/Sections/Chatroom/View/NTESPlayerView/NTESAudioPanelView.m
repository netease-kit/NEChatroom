//
//  NTESAudioPanelView.m
//  NERtcAudioChatroom
//
//  Created by He on 2019/5/29.
//  Copyright © 2019 netease. All rights reserved.
//

#import "NTESAudioPanelView.h"
#import "UIView+NTES.h"

static const CGFloat kButtonBorderWidth = 1.2f;
static NSString * const kButtonKVOPath = @"selected";

@interface NTESAudioPanelView()
@property(nonatomic,strong) UIColor *basicColor;
@property(nonatomic,strong) UILabel  *musicLabel;
@property(nonatomic,strong) UIButton *musicButton1;
@property(nonatomic,strong) UIButton *musicButton2;
@property(nonatomic,strong) UIImageView *musicSliderImageView;
@property(nonatomic,strong) UISlider *musicVolumnSlider;
@property(nonatomic,strong) UIView *seperator;
@property(nonatomic,strong) UILabel *effectLabel;
@property(nonatomic,strong) UIButton *effectButton1;
@property(nonatomic,strong) UIButton *effectButton2;
@property(nonatomic,strong) UIImageView *effectSliderImageView;
@property(nonatomic,strong) UISlider *effectValueSlider;
@end

@implementation NTESAudioPanelView

- (void)dealloc
{
    [self.effectButton1 removeObserver:self forKeyPath:kButtonKVOPath];
    [self.effectButton2 removeObserver:self forKeyPath:kButtonKVOPath];
    [self.musicButton1 removeObserver:self forKeyPath:kButtonKVOPath];
    [self.musicButton2 removeObserver:self forKeyPath:kButtonKVOPath];

}

- (instancetype)init {
    if (self = [super init]) {
        [self addSubview:self.musicLabel];
        [self addSubview:self.musicButton1];
        [self addSubview:self.musicButton1];
        [self addSubview:self.musicButton2];
        [self addSubview:self.musicSliderImageView];
        [self addSubview:self.musicVolumnSlider];
        [self addSubview:self.seperator];
        [self addSubview:self.effectLabel];
        [self addSubview:self.effectButton1];
        [self addSubview:self.effectButton2];
        [self addSubview:self.effectSliderImageView];
        [self addSubview:self.effectValueSlider];
        self.backgroundColor = [UIColor blackColor];
        self.alpha = .85f;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat width = self.width / 6;
    CGFloat height = self.height / 10;
    CGFloat padding = (self.height - 7 * height - 1) / 8;

    [self.musicLabel sizeToFit];
    self.musicLabel.centerY = self.height / 4.f;
    self.musicLabel.left = padding * 2;
    
    self.musicButton2.frame = CGRectMake(0, 0, width, height);
    self.musicButton2.centerY = self.musicLabel.centerY;
    self.musicButton2.right = self.width - padding * 2;

    self.musicButton1.frame = CGRectMake(0, 0, width, height);
    self.musicButton1.centerY = self.musicLabel.centerY;
    self.musicButton1.right = self.musicButton2.left - padding;
    
    [self.musicSliderImageView sizeToFit];
    self.musicSliderImageView.left = self.musicLabel.left;
    self.musicSliderImageView.top = self.musicButton1.bottom + 2 * padding;
    
    self.musicVolumnSlider.frame = CGRectMake(self.musicSliderImageView.right + padding, 0, self.width - self.musicSliderImageView.right - 2 * padding, height);
    self.musicVolumnSlider.centerY = self.musicSliderImageView.centerY;
    
    self.seperator.frame = CGRectMake(0, self.musicVolumnSlider.bottom + padding, self.width, 1);
    
    [self.effectLabel sizeToFit];
    self.effectLabel.centerY = self.height * 0.75f - 2 * padding;
    self.effectLabel.left = padding * 2;
    
    self.effectButton2.frame = CGRectMake(0, 0, width, height);
    self.effectButton2.centerY = self.effectLabel.centerY;
    self.effectButton2.right = self.width - padding * 2;

    self.effectButton1.frame = CGRectMake(self.effectLabel.left, self.effectLabel.bottom + padding, width, height);
    self.effectButton1.centerY = self.effectLabel.centerY;
    self.effectButton1.right = self.effectButton2.left - padding;
    
    
    [self.effectSliderImageView sizeToFit];
    self.effectSliderImageView.left = self.effectLabel.left;
    self.effectSliderImageView.top = self.effectButton1.bottom + padding;
    
    self.effectValueSlider.frame = CGRectMake(self.effectSliderImageView.right + padding, 0, self.width - self.effectSliderImageView.right - 2 * padding, height);
    self.effectValueSlider.centerY = self.effectSliderImageView.centerY;
}

// 吸收UITableViewCell 选中事件
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
}

#pragma mark - Public

- (void)setMusicButtonSelectedAtIndex:(NSInteger)index
{
    if ( index == 0) {
        self.musicButton1.selected = YES;
        self.musicButton2.selected = NO;
    } else if (index == 1) {
        self.musicButton1.selected = NO;
        self.musicButton2.selected = YES;
    }
}

#pragma mark - Action
- (void)onMusicButton1Action:(UIButton *)sender {
    [self refreshButtonState:sender selected:YES];
    [self refreshButtonState:self.musicButton2 selected:NO];
    if ([self.delegate respondsToSelector:@selector(onButtonSelected:)]) {
        [self.delegate onButtonSelected:NTESButtonTypeMusic1];
    }
}

- (void)onMusicButton2Action:(UIButton *)sender {
    [self refreshButtonState:sender selected:YES];
    [self refreshButtonState:self.musicButton1 selected:NO];
    if ([self.delegate respondsToSelector:@selector(onButtonSelected:)]) {
        [self.delegate onButtonSelected:NTESButtonTypeMusic2];
    }
}

- (void)onMusicVolumnAction:(UISlider *)sender {
    if ([self.delegate respondsToSelector:@selector(onValueChangeOfType:value:)]) {
        [self.delegate onValueChangeOfType:NTESValueChangeTypeMusicVolumn value:sender.value];
    }
}

- (void)onEffectButton1Action:(UIButton *)sender {
    [self refreshButtonState:sender selected:YES];
    [self refreshButtonState:self.effectButton2 selected:NO];
    if ([self.delegate respondsToSelector:@selector(onButtonSelected:)]) {
        [self.delegate onButtonSelected:NTESButtonTypeMusicEffect1];
    }
}

- (void)onEffectButton2Action:(UIButton *)sender {
    [self refreshButtonState:sender selected:YES];
    [self refreshButtonState:self.effectButton1 selected:NO];
    if ([self.delegate respondsToSelector:@selector(onButtonSelected:)]) {
        [self.delegate onButtonSelected:NTESButtonTypeMusicEffect2];
    }
}

- (void)onEffectValueAction:(UISlider *)sender {
    if ([self.delegate respondsToSelector:@selector(onValueChangeOfType:value:)]) {
        [self.delegate onValueChangeOfType:NTESValueChangeTypeMusicEffect value:sender.value];
    }
}

- (void)refreshButtonState:(UIButton *)button selected:(BOOL)select {
    button.selected = select;
}

#pragma mark - Getter
- (UILabel *)musicLabel {
    if (!_musicLabel) {
        _musicLabel = [[UILabel alloc] init];
        _musicLabel.font = [UIFont boldSystemFontOfSize:19.f];
        _musicLabel.text = @"背景音乐";
        _musicLabel.textColor = [UIColor whiteColor];
    }
    return _musicLabel;
}

- (UIButton *)musicButton1 {
    if (!_musicButton1) {
        _musicButton1 = [UIButton buttonWithType:UIButtonTypeCustom];
        [_musicButton1 setTitle:@"音乐1" forState:UIControlStateNormal];
        [_musicButton1 setTitleShadowColor:[UIColor grayColor] forState:UIControlStateNormal];
        [_musicButton1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_musicButton1 setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [_musicButton1 addTarget:self action:@selector(onMusicButton1Action:) forControlEvents:UIControlEventTouchUpInside];
        _musicButton1.layer.masksToBounds = YES;
        [_musicButton1 setBackgroundImage:[self imageWithColor:self.basicColor] forState:UIControlStateSelected];
        _musicButton1.titleLabel.font = [UIFont systemFontOfSize:15.f];
        _musicButton1.layer.borderColor = [UIColor whiteColor].CGColor;
        _musicButton1.layer.borderWidth = kButtonBorderWidth;
        [_musicButton1 addObserver:self forKeyPath:kButtonKVOPath options:NSKeyValueObservingOptionNew context:nil];
    }
    return _musicButton1;
}

- (UIButton *)musicButton2 {
    if (!_musicButton2) {
        _musicButton2 = [UIButton buttonWithType:UIButtonTypeCustom];
        [_musicButton2 setTitle:@"音乐2" forState:UIControlStateNormal];
        [_musicButton2 setTitleShadowColor:[UIColor grayColor] forState:UIControlStateNormal];
        [_musicButton2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_musicButton2 setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        _musicButton2.titleLabel.font = [UIFont systemFontOfSize:15.f];
        _musicButton2.layer.borderColor = [UIColor whiteColor].CGColor;
        _musicButton2.layer.borderWidth = kButtonBorderWidth;
        _musicButton2.layer.masksToBounds = YES;
        [_musicButton2 setBackgroundImage:[self imageWithColor:self.basicColor] forState:UIControlStateSelected];
        [_musicButton2 addTarget:self action:@selector(onMusicButton2Action:) forControlEvents:UIControlEventTouchUpInside];
        [_musicButton2 addObserver:self forKeyPath:kButtonKVOPath options:NSKeyValueObservingOptionNew context:nil];


    }
    return _musicButton2;
}

- (UIImageView *)musicSliderImageView {
    if (!_musicSliderImageView) {
        _musicSliderImageView = [[UIImageView alloc] init];
        _musicSliderImageView.image = [UIImage imageNamed:@"sound-loud copy"];
    }
    return _musicSliderImageView;
}

- (UISlider *)musicVolumnSlider {
    if (!_musicVolumnSlider) {
        _musicVolumnSlider = [[UISlider alloc] init];
        _musicVolumnSlider.minimumTrackTintColor = self.basicColor;
        _musicVolumnSlider.maximumTrackTintColor = [UIColor grayColor];
        _musicVolumnSlider.minimumValue = 0;
        _musicVolumnSlider.maximumValue = 100;
        _musicVolumnSlider.value = 50;
        [_musicVolumnSlider addTarget:self action:@selector(onMusicVolumnAction:) forControlEvents:UIControlEventValueChanged];
    }
    return _musicVolumnSlider;
}

- (UIView *)seperator {
    if (!_seperator) {
        _seperator = [[UIView alloc] init];
        _seperator.backgroundColor = [UIColor blackColor];
    }
    return _seperator;
}


- (UILabel *)effectLabel {
    if (!_effectLabel) {
        _effectLabel = [[UILabel alloc] init];
        _effectLabel.font = [UIFont boldSystemFontOfSize:19.f];
        _effectLabel.text = @"音效";
        _effectLabel.textColor = [UIColor whiteColor];
    }
    return _effectLabel;
}

- (UIButton *)effectButton1 {
    if (!_effectButton1) {
        _effectButton1 = [UIButton buttonWithType:UIButtonTypeCustom];
        [_effectButton1 setTitle:@"音效1" forState:UIControlStateNormal];
        [_effectButton1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_effectButton1 setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        _effectButton1.layer.masksToBounds = YES;
        [_effectButton1 setBackgroundImage:[self imageWithColor:self.basicColor] forState:UIControlStateSelected];
        _effectButton1.titleLabel.font = [UIFont systemFontOfSize:15.f];
        _effectButton1.layer.borderColor = [UIColor whiteColor].CGColor;
        _effectButton1.layer.borderWidth = kButtonBorderWidth;
        [_effectButton1 addTarget:self action:@selector(onEffectButton1Action:) forControlEvents:UIControlEventTouchUpInside];
        [_effectButton1 addObserver:self forKeyPath:kButtonKVOPath options:NSKeyValueObservingOptionNew context:nil];


        
    }
    return _effectButton1;
}

- (UIButton *)effectButton2 {
    if (!_effectButton2) {
        _effectButton2 = [UIButton buttonWithType:UIButtonTypeCustom];
        [_effectButton2 setTitle:@"音效2" forState:UIControlStateNormal];
        [_effectButton2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_effectButton2 setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        _effectButton2.layer.masksToBounds = YES;
        [_effectButton2 setBackgroundImage:[self imageWithColor:self.basicColor] forState:UIControlStateSelected];
        _effectButton2.titleLabel.font = [UIFont systemFontOfSize:15.f];
        _effectButton2.layer.borderColor = [UIColor whiteColor].CGColor;
        _effectButton2.layer.borderWidth = kButtonBorderWidth;
        [_effectButton2 addTarget:self action:@selector(onEffectButton2Action:) forControlEvents:UIControlEventTouchUpInside];
        [_effectButton2 addObserver:self forKeyPath:kButtonKVOPath options:NSKeyValueObservingOptionNew context:nil];


    }
    return _effectButton2;
}

- (UIImageView *)effectSliderImageView {
    if (!_effectSliderImageView) {
        _effectSliderImageView = [[UIImageView alloc] init];
        _effectSliderImageView.image = [UIImage imageNamed:@"sound-loud copy"];
    }
    return _effectSliderImageView;
}

- (UISlider *)effectValueSlider {
    if (!_effectValueSlider) {
        _effectValueSlider = [[UISlider alloc] init];
        _effectValueSlider.minimumTrackTintColor = self.basicColor;
        _effectValueSlider.maximumTrackTintColor = [UIColor grayColor];
        _effectValueSlider.minimumValue = 0;
        _effectValueSlider.maximumValue = 100;
        _effectValueSlider.value = 50;
        [_effectValueSlider addTarget:self action:@selector(onEffectValueAction:) forControlEvents:UIControlEventValueChanged];

    }
    return _effectValueSlider;
}

- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 100.0f, 1000.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIColor *)basicColor {
    if (!_basicColor) {
        _basicColor = UIColorFromRGB(0x3f82ff);
    }
    return _basicColor;
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:kButtonKVOPath] &&
        [object isKindOfClass:[UIButton class]])
    {
        UIButton *button = (UIButton *)object;
        button.layer.borderWidth = button.isSelected ? 0 : kButtonBorderWidth;
    }
}

@end
