//
//  NTESRequest.h
//  NLiteAVDemo
//
//  Created by Ease on 2020/12/1.
//  Copyright © 2020 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NTESApiOptions.h"

NS_ASSUME_NONNULL_BEGIN

/**
 请求错误domain
 */
#define NTESRequestErrorParseDomain @"NTESRequestErrorParseDomain"
#define NTESRequestErrorCodeDomain @"NTESRequestErrorCodeDomain"
#define NTESRequestErrorParamDomain @"NTESRequestErrorParamDomain"

/**
 请求错误码
 */
typedef NS_ENUM(NSUInteger, NTESRequestErrorCode) {
    NTESRequestErrorUnknown         = 0,
    NTESRequestErrorSerialization   = 1001,
    NTESRequestErrorAuthorization   = 1002,
    NTESRequestErrorMapping         = 1003
};

typedef void(^NTESRequestCompletion)(NSDictionary * _Nonnull response);
typedef void(^NTESRequestError)(NSError * _Nonnull error, NSDictionary * _Nullable response);

@interface NTESRequest : NSObject

// 请求配置项
@property (nonatomic, strong, nullable)   NTESApiOptions  *options;
// 请求返回数据
@property (nonatomic, strong, nullable, readonly)   NSURLResponse   *response;
// 请求完成闭包
@property (nonatomic, copy, nullable)   NTESRequestCompletion   completionBlock;
// 请求失败闭包
@property (nonatomic, copy, nullable)   NTESRequestError        errorBlock;

/**
 实例化请求
 @param options - 请求配置参数
 */
- (instancetype)initWithOptions:(NTESApiOptions *)options;

/**
 异步请求
 */
- (void)asyncRequest;

@end

NS_ASSUME_NONNULL_END
