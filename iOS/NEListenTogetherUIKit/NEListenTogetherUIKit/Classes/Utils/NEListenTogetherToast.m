// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEListenTogetherToast.h"
#import <Toast/UIView+Toast.h>
#import <UIKit/UIKit.h>

@interface NETopmostView : UIView

@property(nonatomic, weak) UIWindow *tv_window;

// Get topmost view for the application window.
// The application window is [UIApplicationDelegate window].
+ (instancetype)viewForApplicationWindow;

// Get topmost view for a new window over status bar.
+ (instancetype)viewForStatusBarWindow;

// Get topmost view for a new window over alert window.
// It is for iOS 7/8, UIAlertView cteate a new window which level =
// UIWindowLevelAlert. For iOS >= 9, UIAlertController does not create a new
// window.
+ (instancetype)viewForAlertWindow;

// Get topmost view for the keyboard window.
+ (instancetype)viewForKeyboardWindow;

// Get topmost view for specified window.
+ (instancetype)viewForWindow:(UIWindow *)window;

@end

@implementation NETopmostView

- (instancetype)initWithWindow:(UIWindow *)window {
  if (self = [super init]) {
    self.tv_window = window;
    self.backgroundColor = [UIColor clearColor];
    self.userInteractionEnabled = NO;
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    [self updateWithOrientation:orientation];
    [[NSNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(changeOrientationHandler:)
               name:UIApplicationWillChangeStatusBarOrientationNotification
             object:nil];
  }
  return self;
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter]
      removeObserver:self
                name:UIApplicationWillChangeStatusBarOrientationNotification
              object:nil];
}

- (void)updateTransformWithOrientation:(UIInterfaceOrientation)orientation {
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

- (void)updateFrameWithOrientation:(UIInterfaceOrientation)orientation {
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

- (void)updateWithOrientation:(UIInterfaceOrientation)orientation {
  [self updateFrameWithOrientation:orientation];
}

- (void)changeOrientationHandler:(NSNotification *)notification {
  if (notification.name == UIApplicationWillChangeStatusBarOrientationNotification) {
    [UIView
        animateWithDuration:[UIApplication sharedApplication].statusBarOrientationAnimationDuration
                 animations:^{
                   UIInterfaceOrientation orientation = (UIInterfaceOrientation)
                       [notification
                            .userInfo[UIApplicationStatusBarOrientationUserInfoKey] integerValue];
                   [self updateWithOrientation:orientation];
                 }];
  }
}

+ (instancetype)viewForApplicationWindow {
  if ([[UIApplication sharedApplication].delegate respondsToSelector:@selector(window)]) {
    return [self viewForWindow:[[UIApplication sharedApplication].delegate window]];
  }
  return nil;
}

+ (instancetype)viewForStatusBarWindow {
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

+ (instancetype)viewForAlertWindow {
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

+ (instancetype)viewForWindow:(UIWindow *)window {
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
  NETopmostView *topmostView = nil;
  for (UIView *subview in window.subviews) {
    if ([subview isKindOfClass:[NETopmostView class]]) {
      topmostView = (NETopmostView *)subview;
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

@implementation NEListenTogetherToast

+ (void)showToast:(NSString *)toast {
  dispatch_async(dispatch_get_main_queue(), ^{
    [[NETopmostView viewForApplicationWindow] makeToast:toast
                                               duration:3.0
                                               position:CSToastPositionCenter];
  });
}

+ (void)showToast:(NSString *)toast pos:(id)pos {
  dispatch_async(dispatch_get_main_queue(), ^{
    [[NETopmostView viewForApplicationWindow] makeToast:toast duration:3.0 position:pos];
  });
}

+ (void)showLoading {
  dispatch_async(dispatch_get_main_queue(), ^{
    [[NETopmostView viewForApplicationWindow] makeToastActivity:CSToastPositionCenter];
  });
}

+ (void)hideLoading {
  dispatch_async(dispatch_get_main_queue(), ^{
    [[NETopmostView viewForApplicationWindow] hideToastActivity];
  });
}

@end
