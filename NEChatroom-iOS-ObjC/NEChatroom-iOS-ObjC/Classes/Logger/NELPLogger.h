//
//  NELPLogger.h
//  Pods
//
//  Created by amao on 2017/9/5.
//
//

#import <Foundation/Foundation.h>
#import "NELPLogMessage.h"



@interface NELPLogger : NSObject
@property (nonatomic,assign)    NELPLogLevel        level;
@property (nonatomic,copy)      NSString            *logDir;
@property (nonatomic,strong)    dispatch_queue_t    logQueue;

+ (instancetype)shared;
- (void)log:(NELPLogMessage *)message;
- (void)flush;
@end
