//
//  NTESApiOptions.h
//  NLiteAVDemo
//
//  Created by Ease on 2020/12/1.
//  Copyright © 2020 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NTESApiModelMapping.h"

NS_ASSUME_NONNULL_BEGIN

/**
 请求工具配置项
 */

/// 请求方式
typedef NS_ENUM(NSUInteger, NTESRequestMethod) {
    NTESRequestMethodGET = 0,
    NTESRequestMethodPOST
};

/// 解析类型
typedef NS_ENUM(NSUInteger, NTESRequestContentType) {
    NTESRequestContentForm= 0,
    NTESRequestContentJson,
};

@interface NTESApiOptions : NSObject

// host
@property (nonatomic, copy, nonnull)     NSString    *host;
// 接口
@property (nonatomic, copy, nonnull)     NSString    *baseUrl;
// 请求参数
@property (nonatomic, strong, nonnull)  NSDictionary<NSString *, NSString *>    *params;
// 返回数据映射
@property (nonatomic, strong, nonnull)  NSArray<NTESApiModelMapping *>          *modelMapping;
// 请求方式
@property (nonatomic, assign)           NTESRequestMethod                       apiMethod;
// 超时时间(默认10)
@property (nonatomic, assign)           int32_t                                 timeoutInterval;
/// 请求头
@property (nonatomic, strong, nullable) NSDictionary                            *headerValues;
/// 请求体类型(默认 application/x-www-form-urlencoded)
@property (nonatomic, assign)           NTESRequestContentType                  contentType;

/**
 请求内容类型数据
 */
- (NSString *)contentTypeValue;

/**
 请求参数data数据
 */
- (nullable NSData *)paramsData;

/**
 请求参数字符串数据
 */
- (NSString *)paramsString;

/**
 请求参数字典
 */
- (NSDictionary *)paramsDict;

/**
 通用参数(扩展)
 */
+ (NSDictionary <NSString *, NSString *> *)commonParams;

@end

NS_ASSUME_NONNULL_END
