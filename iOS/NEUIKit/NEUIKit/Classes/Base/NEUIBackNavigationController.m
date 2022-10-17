// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEUIBackNavigationController.h"
#import "UIBarButtonItem+NEUIKit.h"
@interface NEUIBackNavigationController ()

@end

@implementation NEUIBackNavigationController
- (instancetype)initWithRootViewController:(UIViewController *)rootViewController {
  self = [super initWithRootViewController:rootViewController];
  if (self) {
    rootViewController.hidesBottomBarWhenPushed = NO;
  }
  return self;
}
- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  self.navigationBar.translucent = YES;
  self.navigationBar.barStyle = UIBarStyleDefault;
  self.navigationBar.barTintColor = [UIColor whiteColor];
  self.navigationBar.tintColor = [UIColor whiteColor];
}
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
  if (self.childViewControllers.count > 0) {
    if (self.viewControllers.count == 1) {
      viewController.hidesBottomBarWhenPushed = YES;
    }
    if (self.backImage) {
      viewController.navigationItem.leftBarButtonItem =
          [UIBarButtonItem ne_customBackItemWithImage:self.backImage
                                               target:viewController
                                               action:@selector(ne_backAction:)];
    } else {
      viewController.navigationItem.leftBarButtonItem =
          [UIBarButtonItem ne_backItemWithTarget:viewController action:@selector(ne_backAction:)];
    }
  } else {
    viewController.hidesBottomBarWhenPushed = NO;
  }
  [super pushViewController:viewController animated:animated];
}
@end

@implementation UIViewController (TPUIBackNavigationController)
- (void)ne_backAction:(id)sender {
  [self.navigationController popViewControllerAnimated:YES];
}
@end

@implementation UINavigationBar (XTBackNavigationController)
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
  if ([self pointInside:point withEvent:event]) {
    self.userInteractionEnabled = YES;
  } else {
    self.userInteractionEnabled = NO;
  }
  return [super hitTest:point withEvent:event];
}
@end
