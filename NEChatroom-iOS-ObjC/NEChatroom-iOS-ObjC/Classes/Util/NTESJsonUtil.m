//
//  NTESJsonUtil.m
//  NERtcAudioChatroom
//
//  Created by Simon Blue on 2019/1/24.
//  Copyright © 2019年 netease. All rights reserved.
//

#import "NTESJsonUtil.h"

@implementation NTESJsonUtil
+ (nullable NSDictionary *)dictByJsonData:(NSData *)data
{
    NSDictionary *dict = nil;
    if ([data isKindOfClass:[NSData class]])
    {
        NSError *error = nil;
        dict = [NSJSONSerialization JSONObjectWithData:data
                                               options:0
                                                 error:&error];
    }
    return [dict isKindOfClass:[NSDictionary class]] ? dict : nil;
}


+ (nullable NSDictionary *)dictByJsonString:(NSString *)jsonString
{
    if (!jsonString.length) {
        return nil;
    }
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    return [NTESJsonUtil dictByJsonData:data];
}

+ (NSString *)jsonString:(NSString *)destinationJsonString addJsonString:(NSString *)jsonString
{
    if (!jsonString.length) {
        return destinationJsonString;
    }
    
    NSDictionary *sourceDict = [self dictByJsonString:jsonString];
    
    NSDictionary *destinationDict = [self dictByJsonString:destinationJsonString];
    
    if (destinationDict && sourceDict) {
        NSMutableDictionary * destinationMutableDict = [destinationDict mutableCopy];
        [destinationMutableDict addEntriesFromDictionary:sourceDict];
        destinationJsonString = [self dataTojsonString:destinationMutableDict];
        return destinationJsonString;
    } else if (sourceDict && !destinationDict) {
        return jsonString;
    } else if (!sourceDict && destinationDict) {
        return destinationJsonString;
    } else {
        return nil;
    }
}

+ (NSString *)dataTojsonString:(id)object
{
    NSString *jsonString = nil;
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return jsonString;
}


@end
