//
//  NTESSettingPanelView.m
//  NERtcAudioChatroom
//
//  Created by Think on 2020/8/19.
//  Copyright © 2020 netease. All rights reserved.
//

#import "NTESSettingPanelView.h"
#import "UIView+NTES.h"
#import <NERtcSDK/NERtcSDK.h>

@interface NTESSettingPanelView ()

@property (nonatomic, weak)     id<NTESSettingPanelDelegate>    delegate;

@property (nonatomic, strong)   UIView      *settingPanel;
@property (nonatomic, strong)   UILabel     *titleLab;
@property (nonatomic, strong)   UIView      *line;
@property (nonatomic, strong)   UILabel     *earbackLab;
@property (nonatomic, strong)   UISwitch    *earbackSwitch;
@property (nonatomic, strong)   UILabel     *volumeLab;
@property (nonatomic, strong)   UIImageView *volumeIco;
@property (nonatomic, strong)   UISlider    *volumeSlider;

@end

@implementation NTESSettingPanelView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.1f];
        self.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
        [self addGestureRecognizer:tap];
        
        [self addSubview:self.settingPanel];
        [self.settingPanel addSubview:self.titleLab];
        [self.settingPanel addSubview:self.line];
        [self.settingPanel addSubview:self.earbackLab];
        [self.settingPanel addSubview:self.earbackSwitch];
        [self.settingPanel addSubview:self.volumeLab];
        [self.settingPanel addSubview:self.volumeIco];
        [self.settingPanel addSubview:self.volumeSlider];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.maskView.frame = self.bounds;
    CGFloat panelH = IPHONE_X ? 258 : 224;
    self.settingPanel.frame = CGRectMake(0, CGRectGetHeight(self.frame) - panelH, CGRectGetWidth(self.frame), panelH);
    self.titleLab.frame = CGRectMake(0, 0, self.settingPanel.width, 44);
    self.line.frame = CGRectMake(0, self.titleLab.bottom, self.titleLab.width, 1);
    self.earbackLab.frame = CGRectMake(20, self.line.bottom + 40, 80, 24);
    self.earbackSwitch.centerY = self.earbackLab.centerY;
    self.earbackSwitch.right = self.settingPanel.right - 20;
    self.volumeLab.frame = CGRectMake(20, self.earbackLab.bottom + 28, 80, 24);
    self.volumeSlider.frame = CGRectMake(50, self.volumeLab.bottom + 14, self.settingPanel.width - 50 - 20, 44);
    [self.volumeIco sizeToFit];
    self.volumeIco.left = 20;
    self.volumeIco.centerY = self.volumeSlider.centerY;
}

+ (void)showWithController:(UIViewController <NTESSettingPanelDelegate> *)controller
             earbackSwifth:(BOOL)earbackSwitch
                    volume:(CGFloat)volume
{
    NTESSettingPanelView *view = [[NTESSettingPanelView alloc] init];
    view.frame = controller.view.bounds;
    [controller.view addSubview:view];
    
    view.delegate = controller;
    [view.earbackSwitch setOn:earbackSwitch];
    [view.volumeSlider setValue:volume];
}

- (void)hide
{
    self.hidden = YES;
    [self removeFromSuperview];
}

- (void)onVolumnAction:(UISlider *)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(setGatherVolume:)]) {
        [self.delegate setGatherVolume:sender.value];
    }
}

- (void)switchChange:(UISwitch *)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(setEarbackEnable:)]) {
        [self.delegate setEarbackEnable:[sender isOn]];
    }
}

#pragma mark - getter

- (UIView *)settingPanel
{
    if (!_settingPanel) {
        _settingPanel = [[UIView alloc] init];
        _settingPanel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.85f];
    }
    return _settingPanel;
}

- (UILabel *)titleLab
{
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.text = @"设置";
        _titleLab.font = [UIFont systemFontOfSize:17];
        _titleLab.textColor = [UIColor whiteColor];
        _titleLab.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLab;
}

- (UIView *)line
{
    if (!_line) {
        _line = [[UIView alloc] init];
        _line.backgroundColor = UIColorFromRGBA(0xffffff, 0.1);
    }
    return _line;
}

- (UILabel *)earbackLab
{
    if (!_earbackLab) {
        _earbackLab = [[UILabel alloc] init];
        _earbackLab.text = @"耳返";
        _earbackLab.font = [UIFont systemFontOfSize:17];
        _earbackLab.textColor = [UIColor whiteColor];
    }
    return _earbackLab;
}

- (UISwitch *)earbackSwitch
{
    if (!_earbackSwitch) {
        _earbackSwitch = [[UISwitch alloc] init];
        _earbackSwitch.onTintColor= UIColorFromRGB(0x3f82ff);
        [_earbackSwitch addTarget:self action:@selector(switchChange:)forControlEvents:UIControlEventValueChanged];
    }
    return _earbackSwitch;
}

- (UILabel *)volumeLab
{
    if (!_volumeLab) {
        _volumeLab = [[UILabel alloc] init];
        _volumeLab.text = @"采集音量";
        _volumeLab.font = [UIFont systemFontOfSize:17];
        _volumeLab.textColor = [UIColor whiteColor];
    }
    return _volumeLab;
}

- (UIImageView *)volumeIco
{
    if (!_volumeIco) {
        UIImage *image = [UIImage imageNamed:@"sound-loud copy"];
        _volumeIco = [[UIImageView alloc] initWithImage:image];
    }
    return _volumeIco;
}

- (UISlider *)volumeSlider {
    if (!_volumeSlider) {
        _volumeSlider = [[UISlider alloc] init];
        _volumeSlider.minimumTrackTintColor = UIColorFromRGB(0x3f82ff);
        _volumeSlider.maximumTrackTintColor = [UIColor grayColor];
        _volumeSlider.minimumValue = 0;
        _volumeSlider.maximumValue = 400;
        _volumeSlider.value = 100;
        [_volumeSlider addTarget:self action:@selector(onVolumnAction:) forControlEvents:UIControlEventValueChanged];
    }
    return _volumeSlider;
}

@end
