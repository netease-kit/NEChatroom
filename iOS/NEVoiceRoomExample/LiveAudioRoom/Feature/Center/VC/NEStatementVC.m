// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEStatementVC.h"
#import <NEUIKit/UIColor+NEUIExtension.h>
@interface NEStatementVC ()

@end

@implementation NEStatementVC

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view from its nib.
}

- (void)ntes_initializeConfig {
  self.view.backgroundColor = [UIColor ne_colorWithHex:0x1A1A24];
}
@end
