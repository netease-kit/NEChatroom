//
//  NELPLogger.m
//  Pods
//
//  Created by amao on 2017/9/5.
//
//

#import "NELPLogger.h"
#import "NELPLogAppender.h"

static const void * const NELPLogQueueSpecificKey = &NELPLogQueueSpecificKey;


@interface NELPLogger ()
@property (nonatomic,strong)    NELPLogInfoender *logAppender;
@end

@implementation NELPLogger
+ (instancetype)shared
{
    static NELPLogger *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NELPLogger alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    if (self = [super init])
    {
        _logQueue = dispatch_queue_create("com.netease.log", 0);
        dispatch_queue_set_specific(_logQueue, NELPLogQueueSpecificKey, (void *)NELPLogQueueSpecificKey, NULL);
        _logAppender = [[NELPLogInfoender alloc] init];
        
        NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        NSString *dir = [docDir stringByAppendingPathComponent:@"ntes_demo_logs"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:dir])
        {
            [[NSFileManager defaultManager] createDirectoryAtPath:dir
                                      withIntermediateDirectories:YES
                                                       attributes:nil
                                                            error:nil];
        }
        _logDir = dir;
        
    }
    return self;
}

- (void)log:(NELPLogMessage *)message
{
    dispatch_async(_logQueue, ^{
        @autoreleasepool
        {
            [self doLog:message];
        }

    });
}


- (void)flush
{
    dispatch_block_t block = ^() {
        [[self logAppender] flush];
    };
    
    if (dispatch_get_specific(NELPLogQueueSpecificKey))
    {
        block();
    }
    else
    {
        dispatch_sync(_logQueue, block);
    }
}


#pragma mark - misc
- (void)doLog:(NELPLogMessage *)message
{
    NSString *log = [message logMessage];

#if defined(DEBUG) || defined(_DEBUG)
    printf("%s",[log UTF8String]);
#endif
    NSData *logData = [log dataUsingEncoding:NSUTF8StringEncoding];
    [[self logAppender] appendData:logData];

}
@end

void NELPLOG(NELPLogLevel level, const char *file, const char *function,NSInteger line, NSString *format, ...)
{
    @autoreleasepool
    {
        if (level < [[NELPLogger shared] level])
        {
            return;
        }
        
        if (format)
        {
            va_list args;
            va_start(args, format);
            NSString *message = [[NSString alloc] initWithFormat:format
                                                       arguments:args];
            va_end(args);
            
            NELPLogMessage *logMessage = [[NELPLogMessage alloc] initWithMessage:message
                                                                           level:level
                                                                        filename:[NSString stringWithFormat:@"%s",file]
                                                                        function:[NSString stringWithFormat:@"%s",function]
                                                                            line:line];
            [[NELPLogger shared] log:logMessage];
            
        }
        
    }
}

