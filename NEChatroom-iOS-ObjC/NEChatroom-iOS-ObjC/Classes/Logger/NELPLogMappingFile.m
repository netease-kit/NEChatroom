//
//  NELPLogMappingFile.m
//  Pods
//
//  Created by amao on 2017/9/5.
//
//

#import "NELPLogMappingFile.h"
#import <sys/mman.h>

@interface NELPLogMappingFile ()
@property (nonatomic,assign)    NSInteger   offset;
@property (nonatomic,assign)    NSInteger   length;
@property (nonatomic,assign)    void        *dataPtr;
@property (nonatomic,copy)      NSString    *filepath;
@property (nonatomic,assign)    int32_t     intSize;

@end

@implementation NELPLogMappingFile

- (instancetype)initWitPath:(NSString *)path
{
    if (self = [super init])
    {
        _filepath   = [path copy];
        _length     = 163 * 1024;
        _intSize    = sizeof(int32_t);
        _offset     = (NSInteger)_intSize;
        
        [self mappingFile];
    }
    return self;
}

- (void)dealloc
{
    if (_dataPtr && _isValid)
    {
        munmap(_dataPtr, _length);
    }
}

- (void)mappingFile
{
    if ([self markSureFileExists])
    {
        int fd = open([_filepath UTF8String], O_CREAT|O_RDWR, 0660);
        if (fd)
        {
            _dataPtr = mmap(0, _length, PROT_READ |PROT_WRITE,MAP_SHARED,fd,0);
            if (_dataPtr && _dataPtr != MAP_FAILED)
            {
                _isValid = YES;
                
                
                //读取已写入log大小
                int32_t offset = 0;
                memcpy(&offset, _dataPtr, sizeof(offset));
                if (offset > _intSize && offset < _length)
                {
                    _offset = offset;
                }
                
            }
        }
    }
}


- (void)appendData:(NSData *)data
{
    if (_dataPtr && _isValid)
    {
        NSInteger dataLength = (NSInteger)[data length];
        if (_offset + dataLength < _length)
        {
            memcpy(_dataPtr + _offset, [data bytes], dataLength);
            _offset += dataLength;
            
            int32_t length = (int32_t)_offset;
            memcpy(_dataPtr, &length, sizeof(length));
        }
    }
}

- (BOOL)shouldFlush
{
    if (_dataPtr && _isValid)
    {
        return _offset >= _length / 2;
    }
    else
    {
        return NO;
    }
    
}

- (NSData *)flushData
{
    if (_offset > _intSize && _dataPtr && _isValid)
    {
        return [NSData dataWithBytes:_dataPtr + _intSize length:_offset - _intSize];
    }
    else
    {
        return nil;
    }
}

- (void)flush
{
    if (_dataPtr && _isValid)
    {
        memset(_dataPtr, 0, sizeof(char) * _length);
        _offset = (NSInteger)_intSize;
    }
}


#pragma mark - misc
- (BOOL)markSureFileExists
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    unsigned long long fileSize = [self fileSize];
    BOOL valid = fileSize == (unsigned long long)_length;
    if (!valid)
    {
        [fileManager removeItemAtPath:_filepath
                                error:nil];
        
        char *buffer = malloc(sizeof(char) * _length);
        memset(buffer, 0, sizeof(char) * _length);
        NSData *data = [NSData dataWithBytes:buffer
                                      length:_length];
        free(buffer);
        
        [data writeToFile:_filepath
               atomically:YES];
        
        unsigned long long dataFileSize = [self fileSize];
        valid = dataFileSize == (unsigned long long)_length;
        
    }
    return valid;
}

- (unsigned long long)fileSize
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    unsigned long long fileSize = 0;
    if ([_filepath length]  && [fileManager fileExistsAtPath:_filepath])
    {
        NSDictionary *attributes = [fileManager attributesOfItemAtPath:_filepath
                                                          error:nil];
        id item = [attributes objectForKey:NSFileSize];
        fileSize = [item isKindOfClass:[NSNumber class]] ? [item unsignedLongLongValue] : 0;
    }
    return fileSize;

}

@end
