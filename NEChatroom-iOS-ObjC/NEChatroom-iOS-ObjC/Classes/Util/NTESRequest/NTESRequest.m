//
//  NTESRequest.m
//  NLiteAVDemo
//
//  Created by Ease on 2020/12/1.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NTESRequest.h"
#import "NTESService.h"
#import "SKVObject.h"
#import "AppKey.h"

@implementation NTESRequest

- (instancetype)initWithOptions:(NTESApiOptions *)options
{
    self = [super init];
    if (self) {
        self.options = options;
    }
    return self;
}

- (void)asyncRequest
{
    [[NTESService shared] runRequest:[self _getURLRequest] completion:^(NSData * _Nullable data, NSError * _Nullable error) {
        if (error) {
            if (self.errorBlock) {
                NSDictionary *response = nil;
                if (data) {
                    response = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                }
                self.errorBlock(error, response);
            }
        } else {
            NSError *err = nil;
            SKVObject *obj = [self _serializationFromData:data errorPtr:&err];
            if (err && !obj) {
                if (self.errorBlock) { self.errorBlock(err, nil); }
            } else {
                NSDictionary *mappingResponse = [self _ormResponse:obj errorPtr:&err];
                if (err) {
                    if (self.errorBlock) { self.errorBlock(err, mappingResponse); }
                } else {
                    if (self.completionBlock) { self.completionBlock(mappingResponse); }
                }
            }
        }
    }];
}

- (nullable SKVObject *)_serializationFromData:(NSData *)data errorPtr:(NSError * __autoreleasing _Nonnull * _Nullable)errorPtr
{
    if (!data) {
        return nil;
    }
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSString * str2 = [str stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    str2 = [str2 stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    str2 = [str2 stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    
    id tmp = [NSJSONSerialization JSONObjectWithData:[str2 dataUsingEncoding:NSUTF8StringEncoding] options:0 error:errorPtr];
    if (errorPtr != NULL && *errorPtr) {
        *errorPtr = [NSError errorWithDomain:NTESRequestErrorParseDomain code:NTESRequestErrorSerialization userInfo:@{
            NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:@"request date: %@", [NSDate date]],
            NSLocalizedDescriptionKey: [NSString stringWithFormat:@"error api: %@", self.options.baseUrl]
        }];
        return nil;
    }
    SKVObject *obj = [SKVObject of:tmp];
    NSInteger code = [obj[@"code"] integerValue];
    if (code != 200) {
        if (errorPtr != NULL) {
            *errorPtr = [NSError errorWithDomain:NTESRequestErrorCodeDomain code:code userInfo:@{
                NSLocalizedDescriptionKey: ([obj[@"message"] stringValue] ?: @"")
            }];
        }
        return nil;
    }
    return obj;
}

- (nullable NSDictionary *)_ormResponse:(SKVObject * _Nullable)response errorPtr:(NSError * __autoreleasing _Nonnull * _Nullable)errorPtr
{
    if (!response || ![self.options.modelMapping count]) {
        return nil;
    }
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:[self.options.modelMapping count]];
    for (NTESApiModelMapping *mapping in self.options.modelMapping) {
        NSAssert([mapping isKindOfClass:[NTESApiModelMapping class]], @"error class in options modelMapping array");
        id object = [self _ormResponse:response mapping:mapping errorPtr:errorPtr];
        if (object && mapping.keyPath.length) {
            [dict setObject:object forKey:mapping.keyPath];
        }
        if (errorPtr != NULL && *errorPtr) {
            return nil;
        }
    }
    return [dict copy];
}

- (nullable id)_ormResponse:(SKVObject * _Nullable)response mapping:(NTESApiModelMapping * _Nonnull)mapping errorPtr:(NSError * __autoreleasing _Nonnull * _Nullable)errorPtr
{
    NSMutableArray *responseArray = [NSMutableArray arrayWithCapacity:8];
    if (mapping.isArray) {
        NSArray *x1 = [mapping.keyPath length] ? [[self _findObjByPath:mapping.keyPath obj:response] arrayValue] : [response arrayValue];
        if (!x1) {
            if (errorPtr != NULL) {
                *errorPtr = [NSError errorWithDomain:NTESRequestErrorParseDomain code:NTESRequestErrorMapping userInfo:@{
                    NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:@"date=%@, miss path=%@", [NSDate date], mapping.keyPath],
                    NSLocalizedDescriptionKey: [NSString stringWithFormat:@"error path=%@, error url=%@", mapping.keyPath , self.options.baseUrl]
                }];
            }
            return nil;
        }
        for (id obj in x1) {
            id x = nil;
            if ([mapping.mappingClass isSubclassOfClass:[NSDictionary class]]) {
                if ([obj isKindOfClass:[NSDictionary class]]) {
                    NSMutableDictionary *multDict = [NSMutableDictionary dictionaryWithDictionary:obj];
                    [obj enumerateKeysAndObjectsUsingBlock:^(id _Nonnull key, id  _Nonnull val, BOOL * _Nonnull sstop) {
                        if ([[val class] isSubclassOfClass:[NSNull class]]) {
                            [multDict removeObjectForKey:key];
                        }
                    }];
                    x = [multDict copy];
                }
            } else if ([mapping.mappingClass isSubclassOfClass:[SKVObject class]]) {
                x = [SKVObject of:obj];
            } else if ([mapping.mappingClass isSubclassOfClass:[NSNumber class]]) {
                if ([obj isKindOfClass:[NSNumber class]]) {
                    x = obj;
                } else if ([obj isKindOfClass:[NSString class]]) {
                    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
                    f.numberStyle = NSNumberFormatterDecimalStyle;
                    x = [f numberFromString:obj];
                }
            } else if ([mapping.mappingClass isSubclassOfClass:[NSString class]]) {
                x = [obj isKindOfClass:[NSString class]] ? obj : [obj description];
            } else {
                x = [mapping.mappingClass yy_modelWithDictionary:obj];
            }
            if (x) {
                [responseArray addObject:x];
            } else if (errorPtr != NULL) {
                *errorPtr = [NSError errorWithDomain:NTESRequestErrorParseDomain code:NTESRequestErrorMapping userInfo:@{
                    NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:@"date=%@, miss path=%@", [NSDate date], mapping.keyPath],
                    NSLocalizedDescriptionKey: [NSString stringWithFormat:@"error path=%@, error url=%@", mapping.keyPath , self.options.baseUrl]
                }];
                break;
            }
        }
        if (errorPtr != NULL && !*errorPtr) {
            return responseArray;
        } else {
            return nil;
        }
    } else {
        SKVObject *obj =([mapping.keyPath length] ? [self _findObjByPath:mapping.keyPath obj:response] : response);
        if (!obj) {
            if (errorPtr != NULL) {
                *errorPtr = [NSError errorWithDomain:NTESRequestErrorParseDomain code:NTESRequestErrorMapping userInfo:@{
                    NSLocalizedFailureReasonErrorKey: [NSString stringWithFormat:@"date=%@, miss path=%@", [NSDate date], mapping.keyPath],
                    NSLocalizedDescriptionKey: [NSString stringWithFormat:@"error path=%@, error url=%@", mapping.keyPath , self.options.baseUrl]
                }];
            }
            return nil;
        }
        id responseObject = nil;
        if ([mapping.mappingClass isSubclassOfClass:[NSDictionary class]]) {
            NSMutableDictionary *multDict = [NSMutableDictionary dictionaryWithDictionary:[obj dictionaryValue]];
            /// 根据需求, 如果json解析后的结果中存在key值为NSNull就删除它
            [[obj dictionaryValue] enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull val, BOOL * _Nonnull sstop) {
                if ([[val class] isSubclassOfClass:[NSNull class]]) {
                    [multDict removeObjectForKey:key];
                }
            }];
            responseObject = [multDict copy];
        } else if ([mapping.mappingClass isSubclassOfClass:[SKVObject class]] ) {
            responseObject = obj;
        } else if ([mapping.mappingClass isSubclassOfClass:[NSNumber class]]) {
            responseObject = [obj numberValue];
        } else if ([mapping.mappingClass isSubclassOfClass:[NSString class]]) {
            responseObject = [obj isKindOfClass:[NSString class]] ? obj : [obj description];
        } else {
            responseObject = [mapping.mappingClass yy_modelWithDictionary:[obj dictionaryValue]];
        }
        return responseObject;
    }
}

- (SKVObject *)_findObjByPath:(NSString * _Nonnull)path obj:(SKVObject *)obj
{
    if ([path isEqualToString:@"/"]) {
        return obj;
    }
    
    NSArray *arr = [path componentsSeparatedByString:@"/"];
    NSMutableArray<NSString *> *pathKeyArr = [NSMutableArray array];
    [arr enumerateObjectsUsingBlock:^(NSString *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length) {
            [pathKeyArr addObject:obj];
        }
    }];
    
    NSString *key = [pathKeyArr firstObject];
    if (pathKeyArr.count == 1) {
        return obj[key];
    }
    
    SKVObject *skvObj = obj[key];
    
    NSArray *tailPathKeyArr = [pathKeyArr subarrayWithRange:NSMakeRange(1, pathKeyArr.count - 1)];
    return [self _fetchValueInDict:skvObj pathKeyArr:tailPathKeyArr];
}

- (SKVObject *)_fetchValueInDict:(SKVObject *)skvObj pathKeyArr:(NSArray<NSString *> * _Nonnull)pathKeyArr
{
    NSString *key = [pathKeyArr firstObject];
    if (pathKeyArr.count == 1) {
        return skvObj[key];
    }
    NSArray *tailPathKeyArr = [pathKeyArr subarrayWithRange:NSMakeRange(1, pathKeyArr.count - 1)];
    
    return [self _fetchValueInDict:skvObj[key] pathKeyArr:tailPathKeyArr];
}

- (NSURLRequest *)_getURLRequest
{
    if (_options.apiMethod == NTESRequestMethodPOST) {
        return [self _postRequest];
    }
    return [self _getRequest];
}

- (NSURLRequest *)_postRequest
{
    NSString *urlStr = [NSString stringWithFormat:@"%@%@", _options.host, _options.baseUrl];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlStr]
                                                                cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                            timeoutInterval:_options.timeoutInterval];
    [request addValue:@"" forHTTPHeaderField:@"accessToken"];
    [request addValue:kAppKey forHTTPHeaderField:@"appKey"];
    [request setHTTPMethod:@"Post"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request addValue:[_options contentTypeValue] forHTTPHeaderField:@"Content-Type"];
    if (_options.headerValues != nil) {
        for (NSString *key in _options.headerValues.allKeys) {
            [request setValue:_options.headerValues[key] forHTTPHeaderField:key];
        }
    }
    
    NSData *paramData = [_options paramsData];
    if (paramData) {
        [request setHTTPBody:paramData];
    }
    return [request copy];
}

- (NSURLRequest *)_getRequest
{
    NSDictionary *paramsDic = [_options paramsDict];
    NSString *paramStr = [self _paramsStr:paramsDic];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:paramStr]
                                                                cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                            timeoutInterval:_options.timeoutInterval];
    [request addValue:@"" forHTTPHeaderField:@"accessToken"];
    [request setHTTPMethod:@"Get"];
    [request addValue:kAppKey forHTTPHeaderField:@"appKey"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
//    [request setValue:[NEAccount shared].accessToken forHTTPHeaderField:@"accessToken"];
//    YXAlogInfo(@"accessToken:%@", [NEAccount shared].accessToken);
    
    return [request copy];
}

- (NSString *)_paramsStr:(NSDictionary *)params
{
    NSString *res = @"";
    for (NSString *key in params.allKeys) {
        NSString *valStr = [[params[key] stringValue] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        if ([res length] == 0) {
            res = [NSString stringWithFormat:@"?%@=%@", key, valStr];
        } else {
            res = [NSString stringWithFormat:@"%@&%@=%@", res, key, valStr];
        }
    }
    return res;
}

@end
