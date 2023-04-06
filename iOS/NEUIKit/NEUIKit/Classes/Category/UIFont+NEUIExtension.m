// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "UIFont+NEUIExtension.h"

@implementation UIFont (NEUIExtension)
+ (UIFont *)ne_font:(CGFloat)fontSize {
  return [self ne_font:fontSize weight:NEUIFontWeightRegular];
}
+ (UIFont *)ne_font:(CGFloat)fontSize weight:(NEUIFontWeight)weight {
  if (weight < NEUIFontWeightThin || weight > NEUIFontWeightLight) weight = NEUIFontWeightRegular;
  NSString *fontName;
  switch (weight) {
    case NEUIFontWeightThin:
      fontName = @"PingFangSC-Thin";
      break;
    case NEUIFontWeightMedium:
      fontName = @"PingFangSC-Medium";
      break;
    case NEUIFontWeightSemibold:
      fontName = @"PingFangSC-Semibold";
      break;
    case NEUIFontWeightLight:
      fontName = @"PingFangSC-Light";
      break;
    case NEUIFontWeightRegular:
      fontName = @"PingFangSC-Regular";
      break;
    default:
      fontName = @"PingFangSC-Regular";
  }
  UIFont *font = [UIFont fontWithName:fontName size:fontSize];
  return font ?: [UIFont systemFontOfSize:fontSize];
}
@end
