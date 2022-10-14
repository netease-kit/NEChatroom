// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEUIMethodSwizzling.h"
#import <objc/runtime.h>

void NEUIKitSwizzling(Class originClass, SEL originSelector, SEL swizzledSelector) {
  Method originMethod = class_getInstanceMethod(originClass, originSelector);
  Method swizzledMethod = class_getInstanceMethod(originClass, swizzledSelector);
  if (class_addMethod(originClass, originSelector, method_getImplementation(swizzledMethod),
                      method_getTypeEncoding(swizzledMethod))) {
    class_replaceMethod(originClass, swizzledSelector, method_getImplementation(originMethod),
                        method_getTypeEncoding(originMethod));
  } else {
    method_exchangeImplementations(originMethod, swizzledMethod);
  }
}
