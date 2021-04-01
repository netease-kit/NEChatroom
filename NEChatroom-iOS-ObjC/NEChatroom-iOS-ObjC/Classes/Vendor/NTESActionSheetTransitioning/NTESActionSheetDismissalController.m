//
//  NTESActionSheetDismissalController.m
//  NEChatroom-iOS-ObjC
//
//  Created by Wenchao Ding on 2021/1/27.
//  Copyright © 2021 netease. All rights reserved.
//

#import "NTESActionSheetDismissalController.h"

@implementation NTESActionSheetDismissalController

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return transitionContext.isInteractive ? 0.6 : 0.2;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    CGFloat duration = [self transitionDuration:transitionContext];

    UIViewAnimationOptions curve = transitionContext.isInteractive ? UIViewAnimationOptionCurveLinear : 7 << 16;
    [UIView animateWithDuration:duration
                          delay:0
                        options:curve
                     animations:^{
        fromViewController.view.transform = CGAffineTransformMakeTranslation(0, fromViewController.view.frame.size.height);
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
    }];
}

@end
