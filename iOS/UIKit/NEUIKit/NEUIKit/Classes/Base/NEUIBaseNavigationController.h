// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface NEUINavigationItem : NSObject
/// view正在出现中
@property(nonatomic, assign, readonly) BOOL isViewAppearing;
/// view正在消失中
@property(nonatomic, assign, readonly) BOOL isViewDisappearing;
/// 禁用 右滑返回
@property(nonatomic, assign) BOOL disableInteractivePopGestureRecognizer;

@end

@interface UIViewController (NEUINavigationItem)
@property(nonatomic, strong, readonly) NEUINavigationItem *ne_UINavigationItem;
@end

/// 基类 导航控制器
@interface NEUIBaseNavigationController : UINavigationController <UINavigationControllerDelegate>

@end

NS_ASSUME_NONNULL_END
