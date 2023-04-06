// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEVoiceRoomFloatWindowSingleton.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import "NEVoiceRoomDraggableButton.h"
#import "NEVoiceRoomUI.h"
#import "NSBundle+NELocalized.h"
#import "NTESGlobalMacro.h"
#import "UIView+VoiceRoom.h"

#define floatWindowWidth 100

#define floatWindowHeight 132

@interface NEVoiceRoomFloatWindowSingleton () <UIDragButtonDelegate>

@property(strong, nonatomic) UIWindow *window;
@property(strong, nonatomic) NEVoiceRoomDraggableButton *button;
@property(strong, nonatomic) NEVoiceRoomViewController *target;

@property(strong, nonatomic) UIView *floatingView;

@property(strong, nonatomic) UIButton *closeButton;

@end

@implementation NEVoiceRoomFloatWindowSingleton

+ (instancetype)Ins {
  static id sharedInstance;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedInstance = [[self alloc] init];
    [sharedInstance createButton];
    [[NSNotificationCenter defaultCenter] addObserver:sharedInstance
                                             selector:@selector(orientationChange:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
  });
  return sharedInstance;
}

- (void)addViewControllerTarget:(NEVoiceRoomViewController *)controller {
  @weakify(self) dispatch_async(dispatch_get_main_queue(), ^{
    @strongify(self) self.target = controller;
    self.button.rootView = [UIApplication sharedApplication].keyWindow.rootViewController.view;
  });
}

- (UIViewController *)getViewControllerTarget {
  return self.target;
}

/**
 * create floating window and button
 */
- (void)createButton {
  // 1.floating button
  _button = [NEVoiceRoomDraggableButton buttonWithType:UIButtonTypeCustom];
  //    [self voiceRoom_setBackgroundImage:@"default_normal" forState:UIControlStateNormal];
  [_button setImage:[NEVoiceRoomUI ne_voice_imageName:@"default_normal"]
           forState:UIControlStateNormal];
  //    [self voiceRoom_setBackgroundImage:@"default_selected" forState:UIControlStateSelected];
  _button.imageView.contentMode = UIViewContentModeScaleAspectFill;
  _button.frame = CGRectMake(20, 48, 40, 40);
  _button.buttonDelegate = self;
  _button.initOrientation = [UIApplication sharedApplication].statusBarOrientation;
  _button.originTransform = _button.transform;
  _button.layer.masksToBounds = YES;
  _button.layer.cornerRadius = 20;
  _button.layer.borderWidth = 2;
  _button.layer.borderColor = [UIColor whiteColor].CGColor;

  /// 关闭按钮
  _closeButton = [[UIButton alloc] initWithFrame:CGRectMake(floatWindowWidth - 24, 0, 24, 24)];
  [_closeButton setImage:[NEVoiceRoomUI ne_voice_imageName:@"closeroom_icon"]
                forState:UIControlStateNormal];
  _closeButton.backgroundColor = UIColorFromRGBA(0x000000, 0.6);
  [_closeButton cutViewRounded:UIRectCornerAllCorners cornerRadii:CGSizeMake(12, 12)];
  [_closeButton addTarget:self
                   action:@selector(clickCloseButton)
         forControlEvents:UIControlEventTouchUpInside];

  UIView *subDetailView = [[UIView alloc] initWithFrame:CGRectMake(0, 28, 80, 104)];
  subDetailView.backgroundColor = UIColorFromRGBA(0x000000, 0.6);
  subDetailView.layer.cornerRadius = 6;
  subDetailView.layer.masksToBounds = YES;

  /// 文本
  UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 94, 50, 18)];
  titleLabel.text = NELocalizedString(@"聊天室");
  titleLabel.font = [UIFont systemFontOfSize:14];
  titleLabel.textColor = HEXCOLOR(0xFFFFFF);

  // 2.floating window
  //    _window = [[UIWindow alloc]init];
  //    _window.frame = CGRectMake(0, 100, floatWindowWidth, floatWindowHeight);
  //    _window.windowLevel = UIWindowLevelNormal;
  //    _window.backgroundColor = [UIColor clearColor];

  //    [_window addSubview:subDetailView];
  //    [_window addSubview:_button];
  //    [_window addSubview:_closeButton];
  //    [_window addSubview:titleLabel];
  //    [_window makeKeyAndVisible];
  //    _window.hidden = YES;
  //
  _floatingView = [[UIView alloc] init];
  _floatingView.frame = CGRectMake(0, 100, floatWindowWidth, floatWindowHeight);
  _floatingView.backgroundColor = [UIColor clearColor];

  [_floatingView addSubview:subDetailView];
  [_floatingView addSubview:_button];
  [_floatingView addSubview:_closeButton];
  [_floatingView addSubview:titleLabel];
  //    [_floatingView makeKeyAndVisible];
  [[UIApplication sharedApplication].keyWindow addSubview:_floatingView];
  _floatingView.hidden = YES;
}

- (void)setNetImage:(NSString *)icon title:(NSString *)title {
  [_button setNetImage:icon];
}
/**
 *  floating button clicked
 */
- (void)dragButtonClicked:(UIButton *_Nullable)sender {
  sender.selected = !sender.selected;
  if (sender.selected) {
    //        [sender setBackgroundImage:_imageSelected forState:UIControlStateSelected];
  } else {
    //        [sender setBackgroundImage:_imageNormal forState:UIControlStateNormal];
  }

  // click callback
  //    [NEVoiceRoomFloatWindowSingleton Ins].floatWindowCallBack();
  NSLog(@"Floating button clicked!!!");
  if (!self.hasFloatingView) {
    return;
  }
  if (self.target) {
    NSLog(@"Floating button target start!!!");
    UIViewController *currentViewController = [self findVisibleViewController];
    if (currentViewController.navigationController) {
      [currentViewController.navigationController pushViewController:self.target animated:YES];
    } else {
      [currentViewController presentViewController:self.target animated:YES completion:nil];
    }
    //      self.target
    NSLog(@"Floating button target end!!!");
    //    self.target = nil;
    [self setHideWindow:YES];
  }
  NSLog(@"Floating button clicked end!!!");
}

- (BOOL)hasFloatingView {
  return !self.floatingView.hidden;
}
- (void)setHideWindow:(BOOL)hide {
  _floatingView.hidden = hide;
}
- (NSString *_Nullable)getRoomUuid {
  if (self.floatingView.hidden == NO) {
    return self.target.detail.liveModel.roomUuid;
  }
  return nil;
}
/**
 * notification
 */
- (void)orientationChange:(NSNotification *)notification {
  //    [_button buttonRotate];
}
- (void)clickCloseButton {
  NSLog(@"clickCloseButton");
  [self clickCloseButton:NO callback:nil];
}

- (void)clickCloseButton:(BOOL)pop callback:(void (^)(void))callback {
  _floatingView.hidden = YES;
  [self.target closeRoomWithViewPop:pop callback:callback];
}

- (UIViewController *)findVisibleViewController {
  UIViewController *currentViewController = [self getRootViewController];

  BOOL runLoopFind = YES;
  while (runLoopFind) {
    if (currentViewController.presentedViewController) {
      currentViewController = currentViewController.presentedViewController;
    } else {
      if ([currentViewController isKindOfClass:[UINavigationController class]]) {
        currentViewController =
            ((UINavigationController *)currentViewController).visibleViewController;
      } else if ([currentViewController isKindOfClass:[UITabBarController class]]) {
        currentViewController =
            ((UITabBarController *)currentViewController).selectedViewController;
      } else {
        break;
      }
    }
  }

  return currentViewController;
}

- (UIViewController *)getRootViewController {
  id<UIApplicationDelegate> delegate = [[UIApplication sharedApplication] delegate];
  if (delegate && [delegate respondsToSelector:@selector(window)]) {
    UIWindow *window = [delegate window];
    return window.rootViewController;
  }
  return [UIApplication sharedApplication].keyWindow.rootViewController;
}
@end
