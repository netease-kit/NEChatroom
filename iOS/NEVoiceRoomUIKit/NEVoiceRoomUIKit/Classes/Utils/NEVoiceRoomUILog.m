// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEVoiceRoomUILog.h"
#import <YXAlog_iOS/YXAlog.h>
@implementation NEVoiceRoomUILog
+ (void)setup {
  YXAlogOptions *opt = [[YXAlogOptions alloc] init];
  opt.path = [self getDirectoryForDocuments:@"NIMSDK/Logs/extra_log/NEVoiceRoomUIKit"];
  opt.level = YXAlogLevelInfo;
  opt.filePrefix = @"NEVoiceRoomUIKit";
  opt.moduleName = @"NEVoiceRoomUIKit";
  [[YXAlog shared] setupWithOptions:opt];
}
+ (void)infoLog:(NSString *)className desc:(NSString *)desc {
  [YXAlog.shared logWithLevel:YXAlogLevelInfo
                          tag:className
                         type:YXAlogTypeNormal
                         line:0
                         desc:@"⚠️ %@", desc];
}
+ (void)successLog:(NSString *)className desc:(NSString *)desc {
  [YXAlog.shared logWithLevel:YXAlogLevelInfo
                          tag:className
                         type:YXAlogTypeNormal
                         line:0
                         desc:@"✅ %@", desc];
}
/// error类型 log
+ (void)errorLog:(NSString *)className desc:(NSString *)desc {
  [YXAlog.shared logWithLevel:YXAlogLevelError
                          tag:className
                         type:YXAlogTypeNormal
                         line:0
                         desc:@"❌%@", desc];
}
+ (void)messageLog:(NSString *)className desc:(NSString *)desc {
  [YXAlog.shared logWithLevel:YXAlogLevelInfo
                          tag:className
                         type:YXAlogTypeNormal
                         line:0
                         desc:@"✉️ %@", desc];
}

+ (NSString *)getDocumentPath {
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *documentsDirectory = [paths objectAtIndex:0];
  return documentsDirectory;
}

+ (NSString *)getDirectoryForDocuments:(NSString *)dir {
  NSString *dirPath = [[self getDocumentPath] stringByAppendingPathComponent:dir];
  BOOL isDir = NO;
  BOOL isCreated = [[NSFileManager defaultManager] fileExistsAtPath:dirPath isDirectory:&isDir];
  if (!isCreated || !isDir) {
    [[NSFileManager defaultManager] createDirectoryAtPath:dirPath
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:nil];
  }
  return dirPath;
}
@end
