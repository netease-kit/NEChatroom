//
//  NSString+NTES.m
//  NIMAudioChatroom
//
//  Created by Simon Blue on 2019/1/25.
//  Copyright © 2019年 netease. All rights reserved.
//

#import "NSString+NTES.h"

@implementation NSString (NTESJson)

- (id)jsonObject
{
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    if (data) {
        id object = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        return object;
    }
    return nil;
}

- (BOOL)isChinese
{
    NSString *match = @"(^[\u4e00-\u9fa5]+$)";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF matches %@", match];
    return [predicate evaluateWithObject:self];
}

@end
