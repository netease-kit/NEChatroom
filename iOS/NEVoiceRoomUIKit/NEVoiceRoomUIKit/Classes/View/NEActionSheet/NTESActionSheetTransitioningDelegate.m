// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NTESActionSheetTransitioningDelegate.h"
#import "NTESActionSheetDismissalController.h"
#import "NTESActionSheetPresentationController.h"

@interface NTESActionSheetTransitioningDelegate ()

// present动画
@property(nonatomic, strong) NTESActionSheetPresentationController *presentationController;

// dismiss动画
@property(nonatomic, strong) NTESActionSheetDismissalController *dismissalController;

@end

@implementation NTESActionSheetTransitioningDelegate

@dynamic dismissOnTouchOutside;

+ (instancetype)defaultInstance {
  static dispatch_once_t onceToken;
  static NTESActionSheetTransitioningDelegate *instance;
  dispatch_once(&onceToken, ^{
    instance = [[NTESActionSheetTransitioningDelegate alloc] init];
  });
  return instance;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    self.presentationController = [[NTESActionSheetPresentationController alloc] init];
    self.dismissalController = [[NTESActionSheetDismissalController alloc] init];
  }
  return self;
}

- (id<UIViewControllerAnimatedTransitioning>)
    animationControllerForPresentedController:(UIViewController *)presented
                         presentingController:(UIViewController *)presenting
                             sourceController:(UIViewController *)source {
  return self.presentationController;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:
    (UIViewController *)dismissed {
  return self.dismissalController;
}

- (id<UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:
    (id<UIViewControllerAnimatedTransitioning>)animator {
  return self.presentationController.dismissAnimator;
}

- (BOOL)respondsToSelector:(SEL)aSelector {
  return [super respondsToSelector:aSelector] ||
         [self.presentationController respondsToSelector:aSelector];
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
  if ([self.presentationController respondsToSelector:aSelector]) {
    return self.presentationController;
  }
  return [super forwardingTargetForSelector:aSelector];
}

@end
