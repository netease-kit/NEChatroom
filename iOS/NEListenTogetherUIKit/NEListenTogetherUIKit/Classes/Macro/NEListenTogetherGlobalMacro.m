// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEListenTogetherGlobalMacro.h"
#import <NERtcSDK/NERtcSDK.h>
#import <NIMSDK/NIMSDK.h>
#import <YXAlog_iOS/YXAlog.h>
#import <YYModel/YYModel.h>
#import <sys/utsname.h>

void ntes_main_sync_safe(dispatch_block_t block) {
  if ([NSThread isMainThread]) {
    if (block) {
      block();
    }
  } else {
    if (block) {
      dispatch_sync(dispatch_get_main_queue(), block);
    }
  }
}

void ntes_main_async_safe(dispatch_block_t block) {
  if ([NSThread isMainThread]) {
    if (block) {
      block();
    }
  } else {
    if (block) {
      dispatch_async(dispatch_get_main_queue(), block);
    }
  }
}

bool isEmptyString(NSString *string) {
  if (string && [string length] > 0) {
    return false;
  }
  return true;
}

/**
 iPhone设备平台判断
 资料来源: https://www.theiphonewiki.com/wiki/Models
 */
NSString *_platformString() {
  struct utsname systemInfo;
  uname(&systemInfo);
  NSString *platform = [NSString stringWithCString:systemInfo.machine
                                          encoding:NSUTF8StringEncoding];
  if (isEmptyString(platform)) {
    return [UIDevice currentDevice].model ?: @"";
  }

  // iPhone
  if ([platform isEqualToString:@"iPhone13,4"]) return @"iPhone 12 Pro Max";
  if ([platform isEqualToString:@"iPhone13,3"]) return @"iPhone 12 Pro";
  if ([platform isEqualToString:@"iPhone13,2"]) return @"iPhone 12";
  if ([platform isEqualToString:@"iPhone13,1"]) return @"iPhone 12 mini";
  if ([platform isEqualToString:@"iPhone12,8"]) return @"iPhone SE (2nd generation)";
  if ([platform isEqualToString:@"iPhone12,5"]) return @"iPhone 11 Pro Max";
  if ([platform isEqualToString:@"iPhone12,3"]) return @"iPhone 11 Pro";
  if ([platform isEqualToString:@"iPhone12,1"]) return @"iPhone 11";
  if ([platform isEqualToString:@"iPhone11,8"]) return @"iPhone XR";
  if ([platform isEqualToString:@"iPhone11,6"]) return @"iPhone XS Max";
  if ([platform isEqualToString:@"iPhone11,4"]) return @"iPhone XS Max";
  if ([platform isEqualToString:@"iPhone11,2"]) return @"iPhone XS";
  if ([platform isEqualToString:@"iPhone10,6"]) return @"iPhone X";
  if ([platform isEqualToString:@"iPhone10,5"]) return @"iPhone 8 Plus";
  if ([platform isEqualToString:@"iPhone10,4"]) return @"iPhone 8";
  if ([platform isEqualToString:@"iPhone10,3"]) return @"iPhone X";
  if ([platform isEqualToString:@"iPhone10,2"]) return @"iPhone 8 Plus";
  if ([platform isEqualToString:@"iPhone10,1"]) return @"iPhone 8";
  if ([platform isEqualToString:@"iPhone9,4"]) return @"iPhone 7 Plus";
  if ([platform isEqualToString:@"iPhone9,3"]) return @"iPhone 7";
  if ([platform isEqualToString:@"iPhone9,2"]) return @"iPhone 7 Plus";
  if ([platform isEqualToString:@"iPhone9,1"]) return @"iPhone 7";
  if ([platform isEqualToString:@"iPhone8,4"]) return @"iPhone SE";
  if ([platform isEqualToString:@"iPhone8,2"]) return @"iPhone 6s Plus";
  if ([platform isEqualToString:@"iPhone8,1"]) return @"iPhone 6s";
  if ([platform isEqualToString:@"iPhone7,2"]) return @"iPhone 6";
  if ([platform isEqualToString:@"iPhone7,1"]) return @"iPhone 6 Plus";
  if ([platform isEqualToString:@"iPhone6,2"]) return @"iPhone 5s";
  if ([platform isEqualToString:@"iPhone6,1"]) return @"iPhone 5s";
  if ([platform isEqualToString:@"iPhone5,4"]) return @"iPhone 5c";
  if ([platform isEqualToString:@"iPhone5,3"]) return @"iPhone 5c";
  if ([platform isEqualToString:@"iPhone5,2"]) return @"iPhone 5 (CDMA)";
  if ([platform isEqualToString:@"iPhone5,1"]) return @"iPhone 5 (GSM)";
  if ([platform isEqualToString:@"iPhone4,1"]) return @"iPhone 4s";
  if ([platform isEqualToString:@"iPhone3,3"]) return @"iPhone 4 (CDMA)";
  if ([platform isEqualToString:@"iPhone3,2"]) return @"iPhone 4 (GSM Rev A)";
  if ([platform isEqualToString:@"iPhone3,1"]) return @"iPhone 4 (GSM)";
  if ([platform isEqualToString:@"iPhone2,1"]) return @"iPhone 3GS";
  if ([platform isEqualToString:@"iPhone1,2"]) return @"iPhone 3G";
  if ([platform isEqualToString:@"iPhone1,1"]) return @"iPhone 1G";

  // Simulator
  if ([platform isEqualToString:@"i386"]) return @"iPhone Simulator";
  if ([platform isEqualToString:@"x86_64"]) return @"iPhone Simulator";

  return platform;
}

/// 基础日志信息
NSString *_logBaseInfo(NSString *moduleName) {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

  // 获取uuid
  NSString *kRecordUuid = [defaults objectForKey:@"kRecordUuid"];
  if (isEmptyString(kRecordUuid)) {
    kRecordUuid = [[UIDevice currentDevice] identifierForVendor].UUIDString;
    [defaults setObject:kRecordUuid forKey:@"kRecordUuid"];
    [defaults synchronize];
  }

  // 获取platform
  NSString *kRecordPlatform = [defaults objectForKey:@"kRecordPlatform"];
  if (isEmptyString(kRecordPlatform)) {
    kRecordPlatform = _platformString();
    [defaults setObject:kRecordPlatform forKey:@"kRecordPlatform"];
    [defaults synchronize];
  }

  NSDictionary *dict = [[NSBundle mainBundle] infoDictionary];
  NSString *processId =
      [NSString stringWithFormat:@"%d", [NSProcessInfo processInfo].processIdentifier];
  NSString *nertcVersion =
      [NSBundle bundleForClass:[NERtcEngine class]].infoDictionary[@"CFBundleShortVersionString"]
          ?: @"";
  //  NSDictionary *serviceInfo = @{@"baseUrl" : kApiHost ?: @""};
  NSDictionary *deviceInfo = @{
    @"deviceId" : kRecordUuid ?: @"",
    @"model" : kRecordPlatform,
    @"manufacturer" : @"apple",
    @"sysVersion" : [[UIDevice currentDevice] systemVersion] ?: @""
  };

  NSDictionary *info = @{
    @"moduleName" : moduleName ?: @"",
    @"moduleVersion" : [dict objectForKey:@"CFBundleShortVersionString"] ?: @"",
    @"processId" : processId ?: @"",
    //        @"gitHashCode"  : [dict objectForKey:@"kGitHashCode"] ?: @"",
    @"packageName" : [dict objectForKey:@"CFBundleIdentifier"] ?: @"",
    @"nertcVersion" : nertcVersion,
    @"imVersion" : [NIMSDK sharedSDK].sdkVersion ?: @"",
    //    @"serviceInfo" : serviceInfo,
    @"deviceInfo" : deviceInfo
  };

  return [info yy_modelToJSONString];
}

void setupLogger(void) {
  YXAlogOptions *opts = [[YXAlogOptions alloc] init];
#if DEBUG
  opts.level = YXAlogLevelDebug;
#else
  opts.level = YXAlogLevelInfo;
#endif
  opts.filePrefix = @"log";
  opts.moduleName = @"chatroom";
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  opts.path = [paths.firstObject stringByAppendingPathComponent:@"/chatroom"];

  [[YXAlog shared] setupWithOptions:opts];

  // 打印基础日志信息
  NSString *info = _logBaseInfo(opts.moduleName);
  YXAlogInfo(info);
}
