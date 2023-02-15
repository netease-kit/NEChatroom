// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (NEListenTogetherString)

- (BOOL)isChinese;

- (nullable id)jsonObject;

// 数字处理
+ (NSString *)praiseStrFormat:(NSUInteger)number;

/**
 获取文字排列大小宽度

 @param font 字体大小
 @param maxH 高度
 @return 计算大小
 */
- (CGSize)sizeWithFont:(UIFont *)font maxH:(CGFloat)maxH;

/**
 获取文字排列大小高度

 @param font 字体大小
 @param maxW 宽度
 @return 计算大小
 */
- (CGSize)sizeWithFont:(UIFont *)font maxW:(CGFloat)maxW;
@end

NS_ASSUME_NONNULL_END
