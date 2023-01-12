// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NSString+NEListenTogetherString.h"

@implementation NSString (NEListenTogetherString)

- (nullable id)jsonObject {
  NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
  if (data) {
    id object = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    return object;
  }
  return nil;
}

- (BOOL)isChinese {
  NSString *match = @"(^[\u4e00-\u9fa5]+$)";
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF matches %@", match];
  return [predicate evaluateWithObject:self];
}

+ (NSString *)praiseStrFormat:(NSUInteger)number {
  NSString *str;
  if (number == 0) {
    str = @"0";
  } else if (number > 0 && number <= 10000) {
    str = @(number).stringValue;
  } else {
    //        保留两位小数 不四舍五入
    str = [NSString stringWithFormat:@"%.2f", floor((number / 10000.0) * 100) / 100];
    //        保留两位小数 四舍五入
    str = [NSString stringWithFormat:@"%.1fw", (number / 10000.0)];
    ////        去除末尾0
    //        str = [NSString stringWithFormat:@"%@w",@(str.floatValue)];
  }
  return str;
}

- (CGSize)sizeWithFont:(UIFont *)font maxH:(CGFloat)maxH {
  NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
  attrs[NSFontAttributeName] = font;
  CGSize maxSize = CGSizeMake(MAXFLOAT, maxH);
  return [self boundingRectWithSize:maxSize
                            options:NSStringDrawingUsesLineFragmentOrigin
                         attributes:attrs
                            context:nil]
      .size;
}

- (CGSize)sizeWithFont:(UIFont *)font maxW:(CGFloat)maxW {
  NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
  attrs[NSFontAttributeName] = font;
  CGSize maxSize = CGSizeMake(maxW, MAXFLOAT);
  return [self boundingRectWithSize:maxSize
                            options:NSStringDrawingUsesLineFragmentOrigin
                         attributes:attrs
                            context:nil]
      .size;
}

@end
