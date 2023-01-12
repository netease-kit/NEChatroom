// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>

@protocol NEListenTogetherUIBaseModelProtocol <NSObject>

@optional

/**
 初始化配置方法
 */
- (void)fb_initialize;

/**
 数据解析

 @param data 源数据
 */
- (void)dataParsing:(id)data;

@end
