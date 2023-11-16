// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.voiceroomkit.ui.base.utils;

import com.netease.yunxin.kit.corekit.XKitLog;

public class VoiceRoomUILog {
  private static final String MODULE = "VoiceRoomUI";

  public static void i(String tag, String log) {
    XKitLog.INSTANCE.i(tag, log, MODULE);
  }

  public static void w(String tag, String log) {
    XKitLog.INSTANCE.w(tag, log, MODULE);
  }

  public static void d(String tag, String log) {
    XKitLog.INSTANCE.d(tag, log, MODULE);
  }

  public static void e(String tag, String log) {
    XKitLog.INSTANCE.e(tag, log, MODULE);
  }
}
