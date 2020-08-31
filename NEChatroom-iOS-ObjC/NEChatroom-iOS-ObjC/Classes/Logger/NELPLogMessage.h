//
//  NELPLogMessage.h
//  Pods
//
//  Created by amao on 2017/9/5.
//
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    NELPLogLevelDebug,
    NELPLogLevelInfo,
    NELPLogLevelWarning,
    NELPLogLevelError,
} NELPLogLevel;


@interface NELPLogMessage : NSObject
@property (nonatomic,copy)      NSString        *message;
@property (nonatomic,assign)    NELPLogLevel    level;
@property (nonatomic,copy)      NSString        *filename;
@property (nonatomic,copy)      NSString        *function;
@property (nonatomic,assign)    NSInteger       line;
@property (nonatomic,strong)    NSDate          *date;

- (instancetype)initWithMessage:(NSString *)message
                          level:(NELPLogLevel)level
                       filename:(NSString *)filename
                       function:(NSString *)function
                           line:(NSInteger)line;

- (NSString *)logMessage;


@end
