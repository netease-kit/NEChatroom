// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (NEUIExtension)

+ (UIColor *)ne_colorWithHex:(NSInteger)rgbValue alpha:(float)alpha;

+ (UIColor *)ne_colorWithHex:(NSInteger)rgbValue
                       alpha:(float)alpha
                     darkHex:(NSInteger)darkRgbValue
                       alpha:(float)darkAlpha;

+ (UIColor *)ne_colorWithHex:(NSInteger)rgbValue;

+ (UIColor *)ne_colorWithHex:(NSInteger)rgbValue darkHex:(NSInteger)darkRgbValue;

@end

NS_ASSUME_NONNULL_END
