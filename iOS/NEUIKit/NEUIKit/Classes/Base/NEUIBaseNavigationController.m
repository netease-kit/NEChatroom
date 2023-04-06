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
- (void)setNavigationBarHidden:(BOOL)navigationBarHidden {
  [self setNavigationBarHidden:navigationBarHidden animated:NO];
}
- (void)setNavigationBarHidden:(BOOL)navigationBarHidden animated:(BOOL)animated {
  _navigationBarHidden = navigationBarHidden;
  [self updateNavigationBarHiddenAnimated:animated];
}
- (void)updateNavigationBarHiddenAnimated:(BOOL)animated {
  if (self.navigationController &&
      self.navigationController.navigationBarHidden != _navigationBarHidden) {
    [self.navigationController setNavigationBarHidden:_navigationBarHidden animated:animated];
  }
}
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
+ (void)load {
  NEUIKitSwizzling(self, @selector(viewWillAppear:), @selector(ne_viewWillAppear:));
  NEUIKitSwizzling(self, @selector(viewDidAppear:), @selector(ne_viewDidAppear:));
  NEUIKitSwizzling(self, @selector(viewWillDisappear:), @selector(ne_viewWillDisappear:));
  NEUIKitSwizzling(self, @selector(viewDidDisappear:), @selector(ne_viewDidDisappear:));
}
- (void)ne_viewWillAppear:(BOOL)animated {
  self.ne_UINavigationItem.isViewAppearing = YES;
  [self ne_viewWillAppear:animated];
}
- (void)ne_viewDidAppear:(BOOL)animated {
  if (self.ne_UINavigationItem) {
    self.ne_UINavigationItem.isViewAppearing = NO;
    // 正在消失
    if (self.ne_UINavigationItem.isViewDisappearing) {
      dispatch_async(dispatch_get_main_queue(), ^{
        [self.ne_UINavigationItem updateNavigationBarHiddenAnimated:NO];
      });
    }
  }
  [self ne_viewDidAppear:animated];
}
- (void)ne_viewWillDisappear:(BOOL)animated {
  self.ne_UINavigationItem.isViewDisappearing = YES;
  [self ne_viewWillDisappear:animated];
}
- (void)ne_viewDidDisappear:(BOOL)animated {
  self.ne_UINavigationItem.isViewDisappearing = NO;
  [self ne_viewDidDisappear:animated];
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
      willShowViewController:(nonnull UIViewController *)viewController
                    animated:(BOOL)animated {
  viewController.ne_UINavigationItem.navigationController = self;
  [viewController.ne_UINavigationItem updateNavigationBarHiddenAnimated:animated];
}
- (void)navigationController:(UINavigationController *)navigationController
       didShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated {
  if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
    self.interactivePopGestureRecognizer.enabled =
        !viewController.ne_UINavigationItem.disableInteractivePopGestureRecognizer;
  }
}
@end
