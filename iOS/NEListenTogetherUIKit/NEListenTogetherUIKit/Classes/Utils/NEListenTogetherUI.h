// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN

/// 通用类
@interface NEListenTogetherUI : NSObject

/// 图片
/// @param imageName 图片名称
+ (UIImage *_Nullable)ne_listen_imageName:(NSString *)imageName;
/// bundle
+ (NSBundle *_Nullable)ne_listen_sourceBundle;

/// 边距
+ (CGFloat)margin;
/// 麦位水平间距
+ (CGFloat)seatItemSpace;
/// 麦位垂直间距
+ (CGFloat)seatLineSpace;
@end

NS_ASSUME_NONNULL_END
