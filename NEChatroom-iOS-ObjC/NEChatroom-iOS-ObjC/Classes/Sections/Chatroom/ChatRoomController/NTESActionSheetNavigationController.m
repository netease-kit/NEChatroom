//
//  NTESActionSheetNavigationController.m
//  NEChatroom-iOS-ObjC
//
//  Created by Wenchao Ding on 2021/1/27.
//  Copyright © 2021 netease. All rights reserved.
//

#import "NTESActionSheetNavigationController.h"
#import "NTESActionSheetTransitioningDelegate.h"
#import "UIImage+NTES.h"

@interface NTESActionSheetNavigationController ()

// 圆角遮罩
@property (nonatomic, strong) CAShapeLayer *navigationBarMask;

// 转场动画代理
@property (nonatomic, strong) NTESActionSheetTransitioningDelegate *transitioning;

@end

@implementation NTESActionSheetNavigationController

@dynamic dismissOnTouchOutside;

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController {
    self = [super initWithRootViewController:rootViewController];
    if (self) {
        self.navigationBar.tintColor = UIColor.blackColor;
        self.navigationBar.clipsToBounds = YES;
        self.navigationBar.translucent = NO;
        self.navigationBar.shadowImage = [UIImage ne_imageWithColor:[UIColor colorWithRed:242/255.0 green:243/255.0 blue:245/255.0 alpha:1.0]];
        [self.navigationBar setTitleTextAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16]}];
        self.navigationBarMask = [[CAShapeLayer alloc] init];
        self.transitioning = [[NTESActionSheetTransitioningDelegate alloc] init];
        self.modalPresentationStyle = UIModalPresentationCustom;
        self.transitioningDelegate = self.transitioning;
    }
    return self;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.navigationBar.frame = CGRectMake(0, 0, self.view.frame.size.width, 48); // 按照设计图高度是48
    self.navigationBarMask.frame = self.navigationBar.bounds;
    UIBezierPath *maskCornor = [UIBezierPath bezierPathWithRoundedRect:self.navigationBar.bounds byRoundingCorners:UIRectCornerTopLeft|UIRectCornerTopRight cornerRadii:CGSizeMake(12, 12)];
    self.navigationBarMask.path = maskCornor.CGPath;
    self.navigationBar.layer.mask = self.navigationBarMask;
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    if ([self.transitioning respondsToSelector:aSelector]) {
        return self.transitioning;
    }
    return [super forwardingTargetForSelector:aSelector];
}

@end
