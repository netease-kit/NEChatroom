//
//  NELPLogMappingFile.h
//  Pods
//
//  Created by amao on 2017/9/5.
//
//

#import <Foundation/Foundation.h>

@interface NELPLogMappingFile : NSObject
@property (nonatomic,assign,readonly)    BOOL        isValid;
- (instancetype)initWitPath:(NSString *)path;
- (void)appendData:(NSData *)data;
- (BOOL)shouldFlush;
- (NSData *)flushData;
- (void)flush;
@end
