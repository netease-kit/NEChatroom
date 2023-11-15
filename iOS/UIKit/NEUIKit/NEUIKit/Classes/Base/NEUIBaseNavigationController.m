// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEUIBaseNavigationController.h"
#import <objc/runtime.h>
#import "NEUIMethodSwizzling.h"

@interface NEUINavigationItem ()
@property(nonatomic, weak) UINavigationController *navigationController;
@property(nonatomic, assign, readwrite) BOOL isViewAppearing;
@property(nonatomic, assign, readwrite) BOOL isViewDisappearing;
/// 更新 navigationbar的显隐
- (void)updateNavigationBarHiddenAnimated:(BOOL)animated;
@end

@implementation NEUINavigationItem

@end

static char kNEUINavigationItemKey;
@implementation UIViewController (NEUINavigationItem)
@dynamic ne_UINavigationItem;
- (NEUINavigationItem *)ne_UINavigationItem {
  NEUINavigationItem *item = objc_getAssociatedObject(self, &kNEUINavigationItemKey);
  if (!item) {
    item = [NEUINavigationItem new];
    objc_setAssociatedObject(self, &kNEUINavigationItemKey, item,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  }
  return item;
}
@end

@interface NEUIBaseNavigationController () <UIGestureRecognizerDelegate>

@end

@implementation NEUIBaseNavigationController
- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  self.interactivePopGestureRecognizer.delegate = self;
  [super setDelegate:self];
}
// 支持旋转
- (BOOL)shouldAutorotate {
  return [self.topViewController shouldAutorotate];
}
// 支持的方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
  return [self.topViewController supportedInterfaceOrientations];
}
// 默认的方向
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
  return [self.topViewController preferredInterfaceOrientationForPresentation];
}
#pragma mark ==================  UIGestureRecognizerDelegate   ==================
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
  if (gestureRecognizer == self.interactivePopGestureRecognizer) {
    if (self.viewControllers.count < 2 ||
        self.visibleViewController == [self.viewControllers objectAtIndex:0]) {
      return NO;
    }
    UIViewController *topVC = [self topViewController];
    if (topVC.ne_UINavigationItem.disableInteractivePopGestureRecognizer) {
      return NO;
    }
  }
  return YES;
}
#pragma mark ==================  UINavigationControllerDelegate   ==================
- (void)navigationController:(UINavigationController *)navigationController
       didShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated {
  if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
    self.interactivePopGestureRecognizer.enabled =
        !viewController.ne_UINavigationItem.disableInteractivePopGestureRecognizer;
  }
}
@end
