// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEVoiceRoomLocalized.h"
#import "NEChatRoomListViewController.h"
@implementation NEVoiceRoomLocalized

+ (NSBundle *)ne_localBundle {
  static NSBundle *localBundle = nil;
  if (localBundle == nil) {
    // 这里不使用mainBundle是为了适配pod 1.x和0.x
    localBundle = [NSBundle bundleForClass:[self class]];
  }
  return localBundle;
}

+ (NSString *)ne_localizedStringForKey:(NSString *)key {
  return [self localizedStringForKey:key value:nil];
}

+ (NSString *)localizedStringForKey:(NSString *)key value:(NSString *)value {
  static NSBundle *bundle = nil;
  if (bundle == nil) {
    // （iOS获取的语言字符串比较不稳定）目前框架只处理en、zh-Hans、zh-Hant三种情况，其他按照系统默认处理
    NSString *language = [NSLocale preferredLanguages].firstObject;
    if ([language hasPrefix:@"en"]) {
      language = @"en";
    } else if ([language hasPrefix:@"zh-Hans"]) {
      language = @"zh-Hans";
    } else {
      language = @"en";
    }
    bundle = [NSBundle bundleWithPath:[[self ne_localBundle] pathForResource:language
                                                                      ofType:@"lproj"]];
  }
  value = [bundle localizedStringForKey:key value:value table:nil];
  return value;
}

@end
