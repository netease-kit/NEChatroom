// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <NEUIKit/NEUIBackNavigationController.h>
#import "AppDelegate+UIWindow.h"
#import "NEMenuViewController.h"
#import "NEPersonVC.h"

@implementation AppDelegate (UIWindow)
- (void)vr_initWindow {
  self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
  self.window.backgroundColor = UIColor.whiteColor;

  NEMenuViewController *vc = [[NEMenuViewController alloc] init];
  NEUIBackNavigationController *appNav =
      [[NEUIBackNavigationController alloc] initWithRootViewController:vc];
  appNav.tabBarItem.title = NSLocalizedString(@"应用", nil);
  appNav.tabBarItem.image = [UIImage imageNamed:@"application"];
  appNav.tabBarItem.selectedImage = [UIImage imageNamed:@"application_select"];

  NEPersonVC *personVC = [[NEPersonVC alloc] init];
  NEUIBackNavigationController *personNav =
      [[NEUIBackNavigationController alloc] initWithRootViewController:personVC];
  personNav.backImage = [UIImage imageNamed:@"menu_arrow_left"];
  personNav.tabBarItem.title = NSLocalizedString(@"个人中心", nil);
  personNav.tabBarItem.image = [UIImage imageNamed:@"mine"];
  personNav.tabBarItem.selectedImage = [UIImage imageNamed:@"mine_select"];

  self.tab = [[UITabBarController alloc] init];
  self.tab.tabBar.tintColor = [UIColor whiteColor];
  self.tab.tabBar.barStyle = UIBarStyleBlack;
  self.tab.viewControllers = @[ appNav, personNav ];

  self.window.rootViewController = self.tab;
  [self.window makeKeyAndVisible];

  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(login)
                                               name:@"Login"
                                             object:nil];
}

- (void)login {
  dispatch_async(dispatch_get_main_queue(), ^{
    self.tab.selectedIndex = 0;
  });
}

@end
