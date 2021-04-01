//
//  NTESApiModelMapping.m
//  NLiteAVDemo
//
//  Created by Ease on 2020/12/1.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NTESApiModelMapping.h"

@implementation NTESApiModelMapping

+ (instancetype)mappingWith:(NSString *)keyPath mappingClass:(Class)mappingClass isArray:(BOOL)isArray
{
    NSAssert([keyPath length] > 0, @"keyPath 为空");
    NSAssert(mappingClass, @"mappingClass 为空");
    NTESApiModelMapping *mapping = [[NTESApiModelMapping alloc] init];
    mapping.keyPath = keyPath;
    mapping.mappingClass = mappingClass;
    mapping.isArray = isArray;
    
    return mapping;
}

@end
