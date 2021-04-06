//
//  NTESApiOptions.m
//  NLiteAVDemo
//
//  Created by Ease on 2020/12/1.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NTESApiOptions.h"
#import "AppKey.h"

@implementation NTESApiOptions

- (instancetype)init
{
    self = [super init];
    if (self) {
        _host = kApiHost;
        _timeoutInterval = 10;
    }
    return self;
}

- (NSString *)contentTypeValue
{
    switch (_contentType) {
        case NTESRequestContentForm:
            return @"application/x-www-form-urlencoded";
        case NTESRequestContentJson:
            return @"";
            
        default:
            break;
    }
}

- (nullable NSData *)paramsData
{
    NSData *data = nil;
    switch (_contentType) {
        case NTESRequestContentForm:
        {
            NSString *paramStr = [self paramsString];
            data = [paramStr dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        }
            break;
        case NTESRequestContentJson:
        {
            NSDictionary *paramsDic = [self paramsDict];
            NSError *error;
            data = [NSJSONSerialization dataWithJSONObject:paramsDic options:NSJSONWritingPrettyPrinted error:&error];
            if (error) {
                YXAlogInfo(@"参数数据错误, error: %@, paramsDic: %@", error, paramsDic ?: @"nil");
            }
        }
            break;
            
        default:
            break;
    }
    return data;
}

- (NSDictionary *)paramsDict
{
    NSMutableDictionary *res = [NSMutableDictionary dictionaryWithDictionary:_params];
    NSDictionary *commonParams = [NTESApiOptions commonParams];
    for (NSString *key in commonParams.allKeys) {
        [res setValue:commonParams[key] forKey:key];
    }
    return  [res copy];
}

- (NSString *)paramsString
{
    NSString *res = @"";
    NSDictionary *params = [self paramsDict];
    for (NSString *key in params.allKeys) {
        NSString *valStr = [[params[key] description] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        if ([res length] == 0) {
            res = [NSString stringWithFormat:@"%@=%@", key, valStr];
        } else {
            res = [NSString stringWithFormat:@"%@&%@=%@", res, key, valStr];
        }
    }
    return res;
}

+ (NSDictionary <NSString *, NSString *> *)commonParams
{
    return @{};
}

@end
