//
//  NTESApiModelMapping.h
//  NLiteAVDemo
//
//  Created by Ease on 2020/12/1.
//  Copyright © 2020 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 请求工具映射类
 */

@interface NTESApiModelMapping : NSObject

// 对象在数据中层级
@property (nonatomic, copy)     NSString    *keyPath;
// 对象是否为数组
@property (nonatomic, assign)   BOOL        isArray;
// 解析类
@property (nonatomic, strong)   Class       mappingClass;

+ (instancetype)mappingWith:(NSString *)keyPath mappingClass:(Class)mappingClass isArray:(BOOL)isArray;

@end

NS_ASSUME_NONNULL_END
