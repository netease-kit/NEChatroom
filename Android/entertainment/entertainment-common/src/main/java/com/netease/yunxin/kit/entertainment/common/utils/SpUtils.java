// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.entertainment.common.utils;

import com.netease.yunxin.kit.common.utils.SPUtils;

public class SpUtils {

  private static final String KEY_HIGH_KEEP_ALIVE = "key_high_keep_alive";
  private static final String KEY_AGREE_PRIVATE = "key_agree_private";

  public static void setHighKeepAliveOpen(Boolean isOpen) {
    SPUtils.getInstance().put(KEY_HIGH_KEEP_ALIVE, isOpen);
  }

  public static boolean isHighKeepAliveOpen() {
    return SPUtils.getInstance().getBoolean(KEY_HIGH_KEEP_ALIVE, false);
  }

  public static void setAgreePrivate(Boolean isOpen) {
    SPUtils.getInstance().put(KEY_AGREE_PRIVATE, isOpen);
  }

  public static boolean isAgreePrivate() {
    return SPUtils.getInstance().getBoolean(KEY_AGREE_PRIVATE, false);
  }
}
