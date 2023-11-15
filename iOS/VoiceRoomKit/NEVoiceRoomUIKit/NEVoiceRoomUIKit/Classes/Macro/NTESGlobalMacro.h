// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>

#ifndef NTESGlobalMacro_h
#define NTESGlobalMacro_h

#define UIScreenWidth ([UIScreen mainScreen].bounds.size.width)
#define UIScreenHeight ([UIScreen mainScreen].bounds.size.height)
#define UIWidthAdapter(x) ((x) * UIScreenWidth / 375.0)
#define UIHeightAdapter(x) ((x) * UIScreenHeight / 667.0)

#pragma mark - UIColor宏定义
#define UIColorFromRGBA(rgbValue, alphaValue)                          \
  [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0 \
                  green:((float)((rgbValue & 0x00FF00) >> 8)) / 255.0  \
                   blue:((float)(rgbValue & 0x0000FF)) / 255.0         \
                  alpha:alphaValue]

#define HEXCOLOR(rgbValue) UIColorFromRGBA(rgbValue, 1.0)

#define PlayComplete @"playComplete"

// 线程
void ntes_main_sync_safe(dispatch_block_t block);
void ntes_main_async_safe(dispatch_block_t block);

#endif /* NTESGlobalMacro_h */
