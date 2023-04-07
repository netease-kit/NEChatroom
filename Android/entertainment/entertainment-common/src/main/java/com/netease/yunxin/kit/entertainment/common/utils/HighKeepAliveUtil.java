// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.entertainment.common.utils;

import android.content.Context;
import com.netease.lava.nertc.foreground.ForegroundKit;
import com.netease.yunxin.kit.entertainment.common.ErrorCode;

public class HighKeepAliveUtil {
  private static final int BACKGROUND_TIME = 10000;

  public static boolean isHighKeepAliveOpen() {
    return SpUtils.isHighKeepAliveOpen();
  }

  public static int openHighKeepAlive(Context context, String appKey) {
    Context appContext = context.getApplicationContext();
    if (ForegroundKit.getInstance(appContext).checkNotifySetting()) {
      ForegroundKit instance = ForegroundKit.getInstance(appContext);
      int result = instance.init(appKey, BACKGROUND_TIME);
      if (result == ErrorCode.SUCCESS) {
        SpUtils.setHighKeepAliveOpen(true);
      }
      return result;
    }
    return ErrorCode.ERROR;
  }

  public static void closeHighKeepAlive(Context context) {
    SpUtils.setHighKeepAliveOpen(false);
    ForegroundKit.getInstance(context.getApplicationContext()).release();
  }

  public static void requestNotifyPermission(Context context) {
    ForegroundKit.getInstance(context.getApplicationContext()).requestNotifyPermission();
  }
}
