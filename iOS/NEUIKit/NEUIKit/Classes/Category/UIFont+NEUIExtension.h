// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, NEUIFontWeight) {
  NEUIFontWeightThin,
  NEUIFontWeightRegular,
  NEUIFontWeightMedium,
  NEUIFontWeightSemibold,
  NEUIFontWeightLight
};

@interface UIFont (NEUIExtension)
+ (UIFont *)ne_font:(CGFloat)fontSize;
/// Font
+ (UIFont *)ne_font:(CGFloat)fontSize weight:(NEUIFontWeight)weight;
@end

NS_ASSUME_NONNULL_END
