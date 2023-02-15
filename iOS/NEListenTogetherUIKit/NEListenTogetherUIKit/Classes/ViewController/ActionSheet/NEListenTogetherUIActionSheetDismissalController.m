// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEListenTogetherUIActionSheetDismissalController.h"

@implementation NEListenTogetherUIActionSheetDismissalController

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
  return transitionContext.isInteractive ? 0.6 : 0.2;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
  UIViewController *fromViewController =
      [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
  CGFloat duration = [self transitionDuration:transitionContext];

  UIViewAnimationOptions curve =
      transitionContext.isInteractive ? UIViewAnimationOptionCurveLinear : 7 << 16;
  [UIView animateWithDuration:duration
      delay:0
      options:curve
      animations:^{
        fromViewController.view.transform =
            CGAffineTransformMakeTranslation(0, fromViewController.view.frame.size.height);
      }
      completion:^(BOOL finished) {
        [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
      }];
}

@end
