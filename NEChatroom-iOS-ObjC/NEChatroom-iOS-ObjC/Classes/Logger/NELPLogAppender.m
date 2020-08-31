//
//  NELPLogInfoender.m
//  Pods
//
//  Created by amao on 2017/9/5.
//
//

#import "NELPLogAppender.h"
#import "NELPLogMappingFile.h"
#import "NELPLogUtil.h"
#import "NELPLogger.h"
#import "NELPFoundationLogger.h"

#define NELPLogMaxSize      (1024 * 1024 * 163)
#define NELPLogCheckSize    (1024 * 1024 * 10)

@interface NELPLogInfoender ()
@property (nonatomic,strong)    NELPLogMappingFile   *file;
@property (nonatomic,assign)    NSInteger            bytesWritten;
@end

@implementation NELPLogInfoender

- (void)appendData:(NSData *)data
{
    if ([[self file] isValid])
    {
        [self appendDataByMappingFile:data];
    }
    else
    {
        [self appendDataByFD:data];
    }
    
    
}

- (void)appendDataByFD:(NSData *)data
{
    NSInteger dataLength = [data length];
    if (dataLength)
    {
        NSInteger fileSize = 0;
        NSString *logFilepath = [self logFilepath];
        int fd = open([logFilepath UTF8String], O_CREAT|O_RDWR|O_APPEND, 0660);
        if (fd)
        {
            const void *buffer = [data bytes];
            int32_t size = (int32_t)dataLength;
            int32_t savedSize = 0;
            while (savedSize < size)
            {
                size_t n = write(fd, buffer + savedSize, size - savedSize);
                
                if (n > 0)
                {
                    savedSize += (int32_t)n;
                }
                else
                {
                    break;
                }
            }
            _bytesWritten += dataLength;
            if (_bytesWritten >= NELPLogCheckSize)
            {
                _bytesWritten = 0;
                fileSize = (NSInteger)lseek(fd, 0, SEEK_END);
            }
            close(fd);
            
            if (fileSize >= NELPLogMaxSize)
            {
                NSError *error = nil;
                [[NSFileManager defaultManager] removeItemAtPath:logFilepath
                                                           error:&error];
                NELPLogWarn(@"log path %@ reach size %d remove error %@",logFilepath,(int)fileSize,error);
            }
        }
        
    }
}

- (void)appendDataByMappingFile:(NSData *)data
{
    NELPLogMappingFile *file = [self file];
    if ([file isValid])
    {
        [file appendData:data];
        if ([file shouldFlush])
        {
            NSData *fileData = [file flushData];
            [self appendDataByFD:fileData];
            [file flush];
        }
    }
}

- (void)flush
{
    NELPLogMappingFile *file = [self file];
    if ([file isValid])
    {
        NSData *data = [file flushData];
        [self appendDataByFD:data];
        [file flush];
    }
}

- (NELPLogMappingFile *)file
{
    if (_file == nil)
    {
        NSString *dir = [[NELPLogger shared] logDir];
        NSString *filename = [NELPLogUtil mmapLogFilename];
        NSString *path = [dir stringByAppendingPathComponent:filename];
        _file = [[NELPLogMappingFile alloc] initWitPath:path];
    }
    return _file;
}


- (NSString *)logFilepath
{
    NSString *filename = [NELPLogUtil currentLogFilename];
    NSString *dir = [[NELPLogger shared] logDir];
    return [dir stringByAppendingPathComponent:filename];
}

@end
