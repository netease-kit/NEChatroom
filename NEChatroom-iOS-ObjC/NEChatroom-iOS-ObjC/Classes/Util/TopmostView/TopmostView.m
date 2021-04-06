//
//  TopmostView.m
//  TopmostView
//
//  Created by HarrisonXi on 16/2/19.
//  Copyright (c) 2016-2017 http://harrisonxi.com/. All rights reserved.
//

#import "TopmostView.h"

@interface TopmostView ()

@property (nonatomic, weak) UIWindow *tv_window;

@end

@implementation TopmostView

- (instancetype)initWithWindow:(UIWindow *)window
{
    if (self = [super init]) {
        self.tv_window = window;
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = NO;
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        [self updateWithOrientation:orientation];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeOrientationHandler:) name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
}

- (void)updateTransformWithOrientation:(UIInterfaceOrientation)orientation
{
    CGFloat width = CGRectGetWidth(self.tv_window.bounds);
    CGFloat height = CGRectGetHeight(self.tv_window.bounds);
    if (width > height) {
        CGFloat temp = width;
        width = height;
        height = temp;
    }
    CGAffineTransform transform;
    switch (orientation) {
        case UIInterfaceOrientationLandscapeLeft:
            transform = CGAffineTransformMakeRotation(-M_PI_2);
            break;
        case UIInterfaceOrientationLandscapeRight:
            transform = CGAffineTransformMakeRotation(M_PI_2);
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            transform = CGAffineTransformMakeRotation(-M_PI);
            break;
        default:
            transform = CGAffineTransformIdentity;
            break;
    }
    self.transform = transform;
    self.frame = CGRectMake(0, 0, width, height);
}

- (void)updateFrameWithOrientation:(UIInterfaceOrientation)orientation
{
    CGFloat width = CGRectGetWidth(self.tv_window.bounds);
    CGFloat height = CGRectGetHeight(self.tv_window.bounds);
    if (width > height) {
        CGFloat temp = width;
        width = height;
        height = temp;
    }
    switch (orientation) {
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            self.frame = CGRectMake(0, 0, height, width);
            break;
        default:
            self.frame = CGRectMake(0, 0, width, height);
            break;
    }
}

- (void)updateWithOrientation:(UIInterfaceOrientation)orientation
{
    BOOL isIos7 = [[UIDevice currentDevice].systemVersion floatValue] < 8.0;
    BOOL isKeyboardWindow = [self.tv_window isKindOfClass:NSClassFromString(@"UITextEffectsWindow")];
    if (isIos7 == YES && isKeyboardWindow == NO) {
        [self updateTransformWithOrientation:orientation];
    } else {
        [self updateFrameWithOrientation:orientation];
    }
}

- (void)changeOrientationHandler:(NSNotification *)notification
{
    if (notification.name == UIApplicationWillChangeStatusBarOrientationNotification) {
        [UIView animateWithDuration:[UIApplication sharedApplication].statusBarOrientationAnimationDuration animations:^{
            UIInterfaceOrientation orientation = (UIInterfaceOrientation)[notification.userInfo[UIApplicationStatusBarOrientationUserInfoKey] integerValue];
            [self updateWithOrientation:orientation];
        }];
    }
}

+ (instancetype)viewForApplicationWindow
{
    return [self viewForWindow:[[UIApplication sharedApplication].delegate window]];
}

+ (instancetype)viewForStatusBarWindow
{
    static dispatch_once_t once;
    static UIWindow *statusBarWindow_;
    dispatch_once(&once, ^{
        statusBarWindow_ = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        statusBarWindow_.rootViewController = [UIViewController new];
        statusBarWindow_.backgroundColor = [UIColor clearColor];
        statusBarWindow_.windowLevel = UIWindowLevelStatusBar + 50;
        statusBarWindow_.userInteractionEnabled = NO;
        statusBarWindow_.hidden = NO;
    });
    return [self viewForWindow:statusBarWindow_];
}

+ (instancetype)viewForAlertWindow
{
    static dispatch_once_t once;
    static UIWindow *alertWindow_;
    dispatch_once(&once, ^{
        alertWindow_ = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        alertWindow_.rootViewController = [UIViewController new];
        alertWindow_.backgroundColor = [UIColor clearColor];
        alertWindow_.windowLevel = UIWindowLevelAlert + 50;
        alertWindow_.userInteractionEnabled = NO;
        alertWindow_.hidden = NO;
    });
    return [self viewForWindow:alertWindow_];
}

+ (instancetype)viewForKeyboardWindow
{
    for (UIWindow *window in [[UIApplication sharedApplication].windows reverseObjectEnumerator]) {
        if ([window isKindOfClass:NSClassFromString(@"UITextEffectsWindow")] && window.hidden == NO && window.alpha > 0) {
            return [self viewForWindow:window];
        }
    }
    return nil;
}

+ (instancetype)viewForWindow:(UIWindow *)window
{
#ifdef TV_DEMO
    for (UIWindow *win in [UIApplication sharedApplication].windows) {
        NSLog(@"window class: %@, window level: %.0f", NSStringFromClass([win class]), win.windowLevel);
        if (![win isMemberOfClass:[UIWindow class]]) {
            for (UIView *subview in win.subviews) {
                NSLog(@"    subview class: %@", NSStringFromClass([subview class]));
            }
        }
    }
#endif
    TopmostView *topmostView = nil;
    for (UIView *subview in window.subviews) {
        if ([subview isKindOfClass:[TopmostView class]]) {
            topmostView = (TopmostView *)subview;
            break;
        }
    }
    if (!topmostView) {
        topmostView = [[self alloc] initWithWindow:window];
        [window addSubview:topmostView];
    }
    [topmostView.tv_window bringSubviewToFront:topmostView];
    return topmostView;
}

@end
