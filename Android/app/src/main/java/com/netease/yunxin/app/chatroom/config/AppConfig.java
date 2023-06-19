// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.app.chatroom.config;

import android.annotation.SuppressLint;
import android.content.Context;

public class AppConfig {
  // 请填写您的appKey,如果您的APP是国内环境，请填写APP_KEY_MAINLAND，如果是海外环境，请填写APP_KEY_OVERSEA
  private static final String APP_KEY_MAINLAND = "your mainland appKey"; // 国内用户填写
  private static final String APP_KEY_OVERSEA = "your oversea appKey"; // 海外用户填写

  // 获取userUuid和对应的userToken，请参考https://doc.yunxin.163.com/neroom/docs/TY1NzM5MjQ?platform=server
  public static final String ACCOUNT = "your userUuid";
  public static final String TOKEN = "your userToken";
  // 跑通Server Demo后，替换为实际的host
  public static final String BASE_URL = "";
  private static final int ONLINE_CONFIG_ID = 569;
  private static final int OVERSEA_CONFIG_ID = 75;

  @SuppressLint("StaticFieldLeak")
  private static Context sContext;

  public static void init(Context context) {
    if (sContext == null) {
      sContext = context.getApplicationContext();
    }
  }

  public static String getAppKey() {
    if (isOversea()) {
      return APP_KEY_OVERSEA;
    } else {
      return APP_KEY_MAINLAND;
    }
  }

  public static boolean isOversea() {
    return false;
  }

  public static int getVoiceRoomConfigId() {
    if (isOversea()) {
      return OVERSEA_CONFIG_ID;
    } else {
      return ONLINE_CONFIG_ID;
    }
  }

  public static String getBaseUrl() {
    return BASE_URL;
  }

  public static String getNERoomServerUrl() {
    if (isOversea()) {
      return "oversea";
    }
    return "online";
  }
}
