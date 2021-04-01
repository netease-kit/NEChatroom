//
//  NTESTestViewController.m
//  NEChatroom-iOS-ObjC
//
//  Created by Wenchao Ding on 2021/1/27.
//  Copyright © 2021 netease. All rights reserved.
//

#import "NTESTestViewController.h"
#import "NTESMusicPanelViewController.h"

@interface NTESTestViewController ()

@end

@implementation NTESTestViewController

- (void)loadView {
    UIView *view = [[UIView alloc] initWithFrame:UIScreen.mainScreen.bounds];
    view.backgroundColor = UIColor.blackColor;
    self.view = view;
    
    NTESMusicPanelViewController *panel = [[NTESMusicPanelViewController alloc] initWithContext:nil];
    panel.view.frame = CGRectMake(10, 100, self.view.frame.size.width-20, 220);
    [self.view addSubview:panel.view];
    [self addChildViewController:panel];
    
}

@end
