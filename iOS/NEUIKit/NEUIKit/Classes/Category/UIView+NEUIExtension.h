// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (NEUIExtension)

/**
 * Shortcut for frame.origin.x
 *
 * Sets frame.origin.x = left
 */
@property(nonatomic) CGFloat left;

/**
 * Shortcut for frame.origin.y
 *
 * Sets frame.origin.y = top
 */
@property(nonatomic) CGFloat top;

/**
 * Shortcut for frame.origin.x + frame.size.width
 *
 * Sets frame.origin.x = right - frame.size.width
 */
@property(nonatomic) CGFloat right;

/**
 * Shortcut for frame.origin.y + frame.size.height
 *
 * Sets frame.origin.y = bottom - frame.size.height
 */
@property(nonatomic) CGFloat bottom;

/**
 * Shortcut for frame.size.width
 *
 * Sets frame.size.width = width
 */
@property(nonatomic) CGFloat width;

/**
 * Shortcut for frame.size.height
 *
 * Sets frame.size.height = height
 */
@property(nonatomic) CGFloat height;

/**
 * Shortcut for center.x
 *
 * Sets center.x = centerX
 */
@property(nonatomic) CGFloat centerX;

/**
 * Shortcut for center.y
 *
 * Sets center.y = centerY
 */
@property(nonatomic) CGFloat centerY;
/**
 * Shortcut for frame.origin
 */
@property(nonatomic) CGPoint origin;

/**
 * Shortcut for frame.size
 */
@property(nonatomic) CGSize size;

/// 为视图添加圆角
///
/// 调用此方法一般放在 视图展示的末尾
/// @param cornerRadii 圆角size
/// @param rectCorner 圆角方位
- (void)ne_cornerRadii:(CGSize)cornerRadii addRectCorners:(UIRectCorner)rectCorner;

@end

NS_ASSUME_NONNULL_END
