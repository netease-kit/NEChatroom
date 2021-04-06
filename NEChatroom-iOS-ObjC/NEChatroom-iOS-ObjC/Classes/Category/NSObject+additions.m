//
//  NSObject+additions.m
//  NEChatroom-iOS-ObjC
//
//  Created by vvj on 2021/2/1.
//  Copyright © 2021 netease. All rights reserved.
//

#import "NSObject+additions.h"

@implementation NSObject (additions)

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
