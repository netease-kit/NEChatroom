// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NEListenTogetherToast : NSObject

/**
 展示toast信息
 */
+ (void)showToast:(NSString *)toast;

/**
 展示toast信息
 */
+ (void)showToast:(NSString *)toast pos:(id)pos;

/**
 展示loading图
 */
+ (void)showLoading;

/**
 销毁loading图
 */
+ (void)hideLoading;

@end

NS_ASSUME_NONNULL_END
