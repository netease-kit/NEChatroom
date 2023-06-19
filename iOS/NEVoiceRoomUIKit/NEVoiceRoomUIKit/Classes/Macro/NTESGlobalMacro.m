// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NTESGlobalMacro.h"

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
