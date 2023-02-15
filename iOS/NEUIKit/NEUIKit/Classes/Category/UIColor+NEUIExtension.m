// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "UIColor+NEUIExtension.h"

@implementation UIColor (NEUIExtension)
+ (UIColor *)ne_randomColor {
  return [self ne_r:arc4random_uniform(255) g:arc4random_uniform(255) b:arc4random_uniform(255)];
}
/// RGB
+ (UIColor *)ne_r:(CGFloat)red g:(CGFloat)green b:(CGFloat)blue {
  return [self ne_r:red g:green b:blue a:1.0];
}
/// RGBA
+ (UIColor *)ne_r:(CGFloat)red g:(CGFloat)green b:(CGFloat)blue a:(CGFloat)alpha {
  return [UIColor colorWithRed:(red) / 255.0 green:(green) / 255.0 blue:(blue) / 255.0 alpha:alpha];
}
+ (UIColor *)ne_t:(CGFloat)t {
  return [self ne_r:t g:t b:t];
}
+ (UIColor *)ne_t:(CGFloat)t alpha:(CGFloat)alpha {
  return [self ne_r:t g:t b:t a:alpha];
}

+ (UIColor *)ne_colorWithHex:(NSInteger)rgbValue alpha:(float)alpha {
  return [UIColor ne_colorWithHex:rgbValue alpha:alpha darkHex:rgbValue alpha:alpha];
}

+ (UIColor *)ne_colorWithHex:(NSInteger)rgbValue {
  return [self ne_colorWithHex:rgbValue alpha:1];
}

+ (UIColor *)ne_colorWithHex:(NSInteger)rgbValue
                       alpha:(float)alpha
                     darkHex:(NSInteger)darkRgbValue
                       alpha:(float)darkAlpha {
  if (@available(iOS 13.0, *)) {
    return [UIColor
        colorWithDynamicProvider:^UIColor *_Nonnull(UITraitCollection *_Nonnull traitCollection) {
          if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
            return [UIColor colorWithRed:((float)((darkRgbValue & 0xFF0000) >> 16)) / 255.0
                                   green:((float)((darkRgbValue & 0x00FF00) >> 8)) / 255.0
                                    blue:((float)(darkRgbValue & 0x0000FF)) / 255.0
                                   alpha:darkAlpha];
          } else {
            return [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0
                                   green:((float)((rgbValue & 0x00FF00) >> 8)) / 255.0
                                    blue:((float)(rgbValue & 0x0000FF)) / 255.0
                                   alpha:alpha];
          }
        }];
  } else {
    return [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0
                           green:((float)((rgbValue & 0x00FF00) >> 8)) / 255.0
                            blue:((float)(rgbValue & 0x0000FF)) / 255.0
                           alpha:alpha];
  }
}

+ (UIColor *)ne_colorWithHex:(NSInteger)rgbValue darkHex:(NSInteger)darkRgbValue {
  return [UIColor ne_colorWithHex:rgbValue alpha:1 darkHex:darkRgbValue alpha:1];
}

@end
