// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NSObject+NEListenTogetherAdditions.h"

@implementation NSObject (NEListenTogetherAdditions)

+ (BOOL)isNullOrNilWithObject:(id)object {
  if (object == nil || [object isEqual:[NSNull null]]) {
    return YES;
  } else if ([object isKindOfClass:[NSString class]]) {
    NSString *str = [object stringByReplacingOccurrencesOfString:@" " withString:@""];
    if ([str isEqualToString:@""]) {
      return YES;
    } else {
      return NO;
    }
  } else if ([object isKindOfClass:[NSNumber class]]) {
    if ([object isEqualToNumber:@0]) {
      return NO;
    } else {
      return NO;
    }
  }
  return NO;
}

@end
