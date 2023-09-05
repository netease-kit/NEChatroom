// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
/// buttomItem 扩展
@interface UIBarButtonItem (NEUIKit)
/// 默认返回
+ (UIBarButtonItem *)ne_backItemWithTarget:(id)target action:(SEL)action;
/// 自定义返回item
/// @param image 返回图片
/// @param target 目标
/// @param action 方法选择器
+ (UIBarButtonItem *)ne_customBackItemWithImage:(UIImage *)image
                                         target:(id)target
                                         action:(SEL)action;

/// 自定义返回item
/// @param image 返回图片
/// @param highlightedImage 高亮图片
/// @param target 目标
/// @param action 方法选择器
+ (UIBarButtonItem *)ne_customBackItemWithImage:(UIImage *)image
                               highlightedImage:(UIImage *)highlightedImage
                                         target:(id)target
                                         action:(SEL)action;
@end

NS_ASSUME_NONNULL_END
