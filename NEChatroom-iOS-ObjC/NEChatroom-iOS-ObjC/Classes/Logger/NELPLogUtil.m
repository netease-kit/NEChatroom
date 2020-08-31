//
//  NELPLogUtil.m
//  Pods
//
//  Created by amao on 2017/9/5.
//
//

#import "NELPLogUtil.h"

@implementation NELPLogUtil
+ (NSString *)mmapLogFilename
{
    return @"NELP.log.mmap";
}

+ (NSString *)currentLogFilename
{
    NSDate *date = [NSDate date];
    return [NSString stringWithFormat:@"NELP_%@.log",[[NELPLogUtil fileDateFormatter] stringFromDate:date]];
}

+ (NSDateFormatter *)logDateFormatter
{
    static NSDateFormatter *logDateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        logDateFormatter = [[NSDateFormatter alloc] init];
        logDateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss:SSS";
    });
    return logDateFormatter;
}

+ (NSDateFormatter *)fileDateFormatter
{
    static NSDateFormatter *fileDateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        fileDateFormatter = [[NSDateFormatter alloc] init];
        fileDateFormatter.dateFormat = @"yyyyMMdd";
    });
    return fileDateFormatter;
}
@end
