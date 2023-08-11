// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.app.chatroom.config;

import android.annotation.SuppressLint;
import android.content.Context;

public class AppConfig {
  private static final String APP_KEY = "your AppKey"; // 请填写应用对应的AppKey，可在云信控制台的”AppKey管理“页面获取
  public static final String APP_SECRET = "your AppSecret"; // 请填写应用对应的AppSecret，可在云信控制台的”AppKey管理“页面获取
  public static final boolean IS_OVERSEA = false; // 如果您的AppKey为海外，填ture；如果您的AppKey为中国国内，填false
  /**
   * 默认的BASE_URL地址仅用于跑通体验Demo，请勿用于正式产品上线。在产品上线前，请换为您自己实际的服务端地址
   */
  public static final String BASE_URL = "https://yiyong.netease.im/";   //云信派对服务端国内的体验地址
  public static final String BASE_URL_OVERSEA = "https://yiyong-sg.netease.im/";   //云信派对服务端海外的体验地址


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
    return APP_KEY;
  }

  public static boolean isOversea() {
    return IS_OVERSEA;
  }

  public static int getVoiceRoomConfigId() {
    if (isOversea()) {
      return OVERSEA_CONFIG_ID;
    } else {
      return ONLINE_CONFIG_ID;
    }
  }

  public static String getBaseUrl() {
    if (isOversea()){
      return BASE_URL_OVERSEA;
    }
    return BASE_URL;
  }

  public static String getNERoomServerUrl() {
    if (isOversea()) {
      return "oversea";
    }
    return "online";
  }
}
