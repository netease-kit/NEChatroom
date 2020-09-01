//
//  NELPLogUtil.h
//  Pods
//
//  Created by amao on 2017/9/5.
//
//

#import <Foundation/Foundation.h>

@interface NELPLogUtil : NSObject
+ (NSString *)mmapLogFilename;

+ (NSString *)currentLogFilename;

+ (NSDateFormatter *)logDateFormatter;
@end
