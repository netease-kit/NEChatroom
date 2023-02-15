// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEUIBaseNavigationController.h"
NS_ASSUME_NONNULL_BEGIN

/// 带返回按钮的 导航控制器
@interface NEUIBackNavigationController : NEUIBaseNavigationController
@property(nonatomic, strong, nullable) UIImage *backImage;
@end

@interface UIViewController (NEUIBackNavigationController)
/// 返回响应
- (void)ne_backAction:(id)sender;
@end

@interface UINavigationBar (NEUIBackNavigationController)
@end

NS_ASSUME_NONNULL_END
