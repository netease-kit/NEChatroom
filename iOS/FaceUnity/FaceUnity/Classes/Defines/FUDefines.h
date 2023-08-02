// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <CoreGraphics/CoreGraphics.h>

#pragma mark - 宏

static NSString * FaceUnityLocalizedString(NSString *key) {
  static NSBundle *bundle = nil;
  if (bundle == nil) {
    NSString *language = [NSLocale preferredLanguages].firstObject;
    if ([language hasPrefix:@"en"]) {
      language = @"en";
    } else if ([language hasPrefix:@"zh-Hans"]) {
      language = @"zh-Hans";
    } else {
      language = @"en";
    }
    bundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:NSClassFromString(@"FUDemoManager")] pathForResource:language
                                                                                                              ofType:@"lproj"]];
  }
  return [bundle localizedStringForKey:key value:nil table:@"FaceUnity"];
}

#pragma mark - 枚举

/// 功能模块
typedef NS_ENUM(NSInteger, FUModuleType) {
  FUModuleTypeBeautySkin,             // 美肤
  FUModuleTypeBeautyShape,            // 美型
  FUModuleTypeFilter,                 // 滤镜
};

/// 美肤模块子功能
typedef NS_ENUM(NSUInteger, FUBeautySkinItem) {
  FUBeautySkinItemFineSmooth,         // 精细磨皮
  FUBeautySkinItemWhiten,             // 美白
  FUBeautySkinItemRuddy,              // 红润
  FUBeautySkinItemSharpen,            // 锐化
  FUBeautySkinItemEyeBrighten,        // 亮眼
  FUBeautySkinItemToothWhiten,        // 美牙
  FUBeautySkinItemCircles,            // 去黑眼圈
  FUBeautySkinItemWrinkles,           // 去法令纹
  FUBeautySkinItemMax
};

/// 美型模块子功能
typedef NS_ENUM(NSUInteger, FUBeautyShapeItem) {
  FUBeautyShapeItemCheekThinning,         // 瘦脸
  FUBeautyShapeItemCheekV,                // V脸
  FUBeautyShapeItemCheekNarrow,           // 窄脸
  FUBeautyShapeItemCheekShort,            // 短脸
  FUBeautyShapeItemCheekSmall,            // 小脸
  FUBeautyShapeItemCheekBones,            // 瘦颧骨
  FUBeautyShapeItemLowerJaw,              // 瘦下颌骨
  FUBeautyShapeItemEyeEnlarging,          // 大眼
  FUBeautyShapeItemEyeCircle,             // 圆眼
  FUBeautyShapeItemChin,                  // 下巴
  FUBeautyShapeItemForehead,              // 额头
  FUBeautyShapeItemNose,                  // 瘦鼻
  FUBeautyShapeItemMouth,                 // 嘴型
  FUBeautyShapeItemCanthus,               // 开眼角
  FUBeautyShapeItemEyeSpace,              // 眼距
  FUBeautyShapeItemEyeRotate,             // 眼睛角度
  FUBeautyShapeItemLongNose,              // 长鼻
  FUBeautyShapeItemPhiltrum,              // 缩人中
  FUBeautyShapeItemSmile,                 // 微笑嘴角
  FUBeautyShapeItemBrowHeight,            // 眉毛上下
  FUBeautyShapeItemBrowSpace,             // 眉间距
  FUBeautyShapeItemMax
};

/// 滤镜模块子功能
typedef NS_ENUM(NSUInteger, FUBeautyFilterItem) {
  /// 原图
  FUBeautyFilterItemNone,
  /// 自然
  FUBeautyFilterItemNatural1,
  FUBeautyFilterItemNatural2,
  /// 质感灰
  FUBeautyFilterItemTextureGrey1,
  FUBeautyFilterItemTextureGrey2,
  /// 蜜桃
  FUBeautyFilterItemNectarina1,
  FUBeautyFilterItemNectarina2,
  /// 白亮
  FUBeautyFilterItemBright1,
  FUBeautyFilterItemBright2,
  /// 粉嫩
  FUBeautyFilterItemPink1,
  FUBeautyFilterItemPink2,
  /// 冷色调
  FUBeautyFilterItemColdTone1,
  FUBeautyFilterItemColdTone2,
  /// 暖色调
  FUBeautyFilterItemWarmTone1,
  FUBeautyFilterItemWarmTone2,
  /// 个性
  FUBeautyFilterItemPersonal1,
  FUBeautyFilterItemPersonal2,
  /// 小清新
  FUBeautyFilterItemFresh1,
  FUBeautyFilterItemFresh2,
  /// 黑白
  FUBeautyFilterItemblackAndWhite1,
  FUBeautyFilterItemblackAndWhite2,
  
  FUBeautyFilterItemMax,
};

#pragma mark - 常量

static CGFloat const FUBottomBarHeight = 49.f;

static CGFloat const FUFunctionViewHeight = 118.f;

static CGFloat const FUFunctionSliderHeight = 30.f;


