// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>

/**
 交换类的实例方法
 @param originClass 需要交换的类
 @param originSelector 交换前的实例方法
 @param swizzledSelector 交换后的实例方法
 */
void NEUIKitSwizzling(Class originClass, SEL originSelector,
                      SEL swizzledSelector);
