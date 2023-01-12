// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (ListenTogether)

// 从当前bundle加载图片
/// @param name 图片名
+ (UIImage *)voiceRoom_imageNamed:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
