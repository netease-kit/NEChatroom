// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define ListenTogetherUILog @"NEListenTogetherUILog"

@interface NEListenTogetherUILog : NSObject
/// 初始化
+ (void)setUp:(NSString *)appkey;
/// info类型 log
+ (void)infoLog:(NSString *)className desc:(NSString *)desc;
/// success类型 log
+ (void)successLog:(NSString *)className desc:(NSString *)desc;
/// error类型 log
+ (void)errorLog:(NSString *)className desc:(NSString *)desc;
/// 自定义信息日志
+ (void)messageLog:(NSString *)className desc:(NSString *)desc;
@end

NS_ASSUME_NONNULL_END
