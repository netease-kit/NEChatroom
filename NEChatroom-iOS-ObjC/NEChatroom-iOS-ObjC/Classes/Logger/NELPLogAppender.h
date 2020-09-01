//
//  NELPLogInfoender.h
//  Pods
//
//  Created by amao on 2017/9/5.
//
//

#import <Foundation/Foundation.h>

@interface NELPLogInfoender : NSObject
- (void)appendData:(NSData *)data;
- (void)flush;
@end
