//
//  NTESActionSheetTransitioningDelegate.m
//  NEChatroom-iOS-ObjC
//
//  Created by Wenchao Ding on 2021/1/26.
//  Copyright © 2021 netease. All rights reserved.
//

#import "NTESActionSheetPresentationController.h"

@interface NTESActionSheetPresentationController () <UIGestureRecognizerDelegate>

// 点击消失的手势
@property (nonatomic, strong) UITapGestureRecognizer *dismissGesture;

// 驱动消失手势
@property (nonatomic, strong) UIPanGestureRecognizer *dismissDrivenGesture;

// 保存负责动画的父视图
@property (nonatomic, weak) UIView *containerView;

// 已弹出的控制器
@property (nonatomic, weak) UIViewController *toViewController;

// 手势驱动消失
@property (nonatomic, strong) UIPercentDrivenInteractiveTransition *dismissAnimator;

// 处理点击消失
- (void)handleDismissTap:(UITapGestureRecognizer *)sender;

// 处理百分比消失
- (void)handleDismissDrive:(UIPanGestureRecognizer *)sender;

@end

@implementation NTESActionSheetPresentationController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.interactiveDismissalDistance = 30;
    }
    return self;
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.3;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    CGSize preferedSize = toViewController.preferredContentSize;
    UIView *containerView = transitionContext.containerView;
    CGFloat duration = [self transitionDuration:transitionContext];
    toViewController.view.frame = CGRectMake(0, transitionContext.containerView.bounds.size.height-preferedSize.height, preferedSize.width, preferedSize.height);
    toViewController.view.transform = CGAffineTransformMakeTranslation(0, preferedSize.height);
    [containerView addSubview:toViewController.view];
    self.containerView = containerView;
    self.toViewController = toViewController;
    
    [UIView animateWithDuration:duration
                          delay:0
                        options:7 << 16
                     animations:^{
        toViewController.view.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        if (self.dismissOnTouchOutside) {
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDismissTap:)];
            tapGesture.delegate = self;
            tapGesture.numberOfTouchesRequired = 1;
            tapGesture.numberOfTapsRequired = 1;
            [containerView addGestureRecognizer:tapGesture];
            self.dismissGesture = tapGesture;
        }
        if (self.interactiveDismissalDistance > 0) {
            UIPanGestureRecognizer *dismissDrivenGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleDismissDrive:)];
            dismissDrivenGesture.delegate = self;
            dismissDrivenGesture.minimumNumberOfTouches = 1;
            [containerView addGestureRecognizer:dismissDrivenGesture];
            self.dismissDrivenGesture = dismissDrivenGesture;
        }
        [transitionContext completeTransition:finished];
    }];
}

- (void)handleDismissTap:(UITapGestureRecognizer *)sender {
    [self.toViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)handleDismissDrive:(UIPanGestureRecognizer *)sender {
    switch (sender.state) {
        case UIGestureRecognizerStateBegan: {
            [self.toViewController dismissViewControllerAnimated:YES completion:nil];
            break;
        }
        case UIGestureRecognizerStateChanged: {
            if (self.toViewController.view.frame.size.height > 0) {
                CGFloat translateY = [sender translationInView:self.containerView].y;
                CGFloat progress = translateY/self.toViewController.view.frame.size.height;
                [self.dismissAnimator updateInteractiveTransition:progress];
                NSLog(@"%f",progress);
            }
            break;
        }
        case UIGestureRecognizerStateEnded: {
            CGFloat maxPercent = self.toViewController.view.frame.size.height/self.containerView.frame.size.height;
            if (self.dismissAnimator.percentComplete/maxPercent > 0.3) {
                [self.dismissAnimator finishInteractiveTransition];
            } else {
                [self.dismissAnimator cancelInteractiveTransition];
            }
            self.dismissAnimator = nil;
            break;
        }
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed: {
            [self.dismissAnimator cancelInteractiveTransition];
            self.dismissAnimator = nil;
            break;
        }
        default:
            break;
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == self.dismissGesture) {
        BOOL shouldStart = !CGRectContainsPoint(self.toViewController.view.bounds, [gestureRecognizer locationInView:self.toViewController.view]);
        return shouldStart;
    }
    if (gestureRecognizer == self.dismissDrivenGesture) {
        CGPoint locationInContent = [gestureRecognizer locationInView:self.toViewController.view];
        BOOL shouldStart = locationInContent.y >= 0 && locationInContent.y <= self.interactiveDismissalDistance;
        if (shouldStart) {
            self.dismissAnimator = [[UIPercentDrivenInteractiveTransition alloc] init];
        }
        return shouldStart;
    }
    return NO;
}

@end
