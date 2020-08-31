//
//  NELPLogMessage.m
//  Pods
//
//  Created by amao on 2017/9/5.
//
//

#import "NELPLogMessage.h"
#import "NELPLogUtil.h"

@implementation NELPLogMessage

- (instancetype)initWithMessage:(NSString *)message
                          level:(NELPLogLevel)level
                       filename:(NSString *)filename
                       function:(NSString *)function
                           line:(NSInteger)line
{
    if (self = [super init])
    {
        _message    = [message copy];
        _level      = level;
        _filename   = [filename lastPathComponent];
        _function   = [function copy];
        _line       = line;
        _date       = [NSDate date];
    }
    return self;
}

- (NSString *)logMessage
{
    return [NSString stringWithFormat:@"[%@] file:%@ line:%d)<<<<%@\n",
            [[NELPLogUtil logDateFormatter] stringFromDate:_date],_filename,(int)_line,_message];

}

@end
