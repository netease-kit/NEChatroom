// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.entertainment.common.utils;

import com.netease.yunxin.kit.alog.ALog;

public class ClickUtils {
  private static final String TAG = "ClickUtils";
  private static long lastClickTime = 0;
  private static final int CLICK_TIME = 300; // 快速点击间隔时间
  private static final int SLIGHTLY_CLICK_TIME = 800; // 稍微地快速点击间隔时间

  // 判断按钮是否快速点击
  public static boolean isFastClick() {
    long time = System.currentTimeMillis();
    if (time - lastClickTime < CLICK_TIME) { // 判断系统时间差是否小于点击间隔时间
      ALog.d(TAG, "isFastClick:true");
      return true;
    }
    lastClickTime = time;
    ALog.d(TAG, "isFastClick:false");
    return false;
  }

  public static boolean isSlightlyFastClick() {
    long time = System.currentTimeMillis();
    if (time - lastClickTime < SLIGHTLY_CLICK_TIME) { // 判断系统时间差是否小于点击间隔时间
      ALog.d(TAG, "isSlightlyFastClick:true");
      return true;
    }
    lastClickTime = time;
    ALog.d(TAG, "isSlightlyFastClick:false");
    return false;
  }
}
