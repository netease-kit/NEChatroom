//
//  NTESService.m
//  NLiteAVDemo
//
//  Created by Ease on 2020/12/1.
//  Copyright © 2020 Netease. All rights reserved.
//

#import "NTESService.h"

@implementation NTESService

+ (instancetype)shared
{
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[[self class] alloc] init];
    });
    return instance;
}

- (void)runRequest:(NSURLRequest *)request completion:(void(^)(NSData * _Nullable data, NSError * _Nullable error))completion
{
    NSURLSessionTask *sessionTask =
    [[NSURLSession sharedSession] dataTaskWithRequest:request
                                    completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable connectionError) {
                                        id jsonData = nil;
                                        NSError *error = nil;
        
                                        if (connectionError == nil && [response isKindOfClass:[NSHTTPURLResponse class]]) {
                                            NSInteger status = [(NSHTTPURLResponse *)response statusCode];
                                            if (status == 200 && data) {
                                                jsonData = [NSJSONSerialization JSONObjectWithData:data
                                                                                           options:0
                                                                                             error:nil];
                                                if ([jsonData isKindOfClass:[NSDictionary class]]) {
                                                    NSDictionary *dict = jsonData;
                                                    if ([dict objectForKey:@"code"]) {
                                                        long code = [[dict objectForKey:@"code"] longValue];
                                                        NSString *msg = [dict objectForKey:@"msg"]?:@"";
                                                        if (code != 200) {
                                                            error = [NSError errorWithDomain:@"NTESErrorBusinessDomain"
                                                                                        code:code
                                                                                    userInfo:@{NSLocalizedDescriptionKey:msg}];
                                                        }
                                                    }
                                                }
                                            } else {
                                                error = connectionError;
                                            }
                                        } else {
                                            if (connectionError.code == -1009 && [connectionError.domain isEqualToString:@"NSURLErrorDomain"]) {
                                                error = [NSError errorWithDomain:connectionError.domain
                                                                            code:connectionError.code
                                                                        userInfo:@{NSLocalizedDescriptionKey: @"网络似乎断开了"}];
                                            } else {
                                                error = connectionError;
                                            }
                                        }
                                        ntes_main_async_safe(^{
                                            if (completion) {
                                                completion(data, error);
                                            }
                                        });
                                    }];
    [sessionTask resume];
}

@end
