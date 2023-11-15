// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEUIBackNavigationController.h"
#import "UIBarButtonItem+NEUIKit.h"
@implementation UIBarButtonItem (NEUIKit)
+ (UIBarButtonItem *)ne_backItemWithTarget:(id)target action:(SEL)action {
  UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
  UIImage *image;
  NSBundle *bundle = [NSBundle bundleForClass:[NEUIBackNavigationController class]];
  if (@available(iOS 13.0, *)) {
    image = [UIImage imageNamed:@"NEUI_Common_BlackBack" inBundle:bundle withConfiguration:nil];
  }
  image = [UIImage imageNamed:@"NEUI_Common_BlackBack"
                           inBundle:bundle
      compatibleWithTraitCollection:nil];

  [btn setImage:image forState:UIControlStateNormal];
  btn.frame = CGRectMake(0, 0, 30, 30);
  btn.contentEdgeInsets = UIEdgeInsetsMake(0, -15, 0, 0);
  [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
  btn.userInteractionEnabled = YES;
  return [[UIBarButtonItem alloc] initWithCustomView:btn];
}

+ (UIBarButtonItem *)ne_customBackItemWithImage:(UIImage *)image
                                         target:(id)target
                                         action:(SEL)action {
  return [self ne_customBackItemWithImage:image highlightedImage:image target:target action:action];
}
+ (UIBarButtonItem *)ne_customBackItemWithImage:(UIImage *)image
                               highlightedImage:(UIImage *)highlightedImage
                                         target:(id)target
                                         action:(SEL)action {
  UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
  [btn setImage:image forState:UIControlStateNormal];
  [btn setImage:highlightedImage forState:UIControlStateHighlighted];
  btn.frame = CGRectMake(0, 0, 30, 30);
  [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
  btn.userInteractionEnabled = YES;
  return [[UIBarButtonItem alloc] initWithCustomView:btn];
}
@end
