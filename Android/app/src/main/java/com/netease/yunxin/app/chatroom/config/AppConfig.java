// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.app.chatroom.config;

import android.annotation.SuppressLint;
import android.content.Context;
import android.content.SharedPreferences;

public class AppConfig {
  // 请填写您的appKey,如果您的APP是国内环境，请填写APP_KEY_MAINLAND，如果是海外环境，请填写APP_KEY_OVERSEA
  private static final String APP_KEY_MAINLAND = "your mainland appKey"; // 国内用户填写
  private static final String APP_KEY_OVERSEA = "your oversea appKey";// 海外用户填写

  private static final int ONLINE_CONFIG_ID = 569;
  private static final int OVERSEA_CONFIG_ID = 75;

  private static final int LISTEN_TOGETHER_ONLINE_CONFIG_ID = 570;
  private static final int LISTEN_TOGETHER_OVERSEA_CONFIG_ID = 76;

  private static final int PARENT_SCOPE = 5; //roomkit
  private static final int CHILD_SCOPE = 4; //voiceroom

  private static final String KEY_DATA_CENTER = "DATA_CENTER";



  @SuppressLint("StaticFieldLeak")
  private static Context sContext;

  private static SharedPreferences sp;
  private static DataCenter sDataCenter;

  public static void init(Context context) {
    if (sContext == null) {
      sContext = context.getApplicationContext();
      sp = sContext.getSharedPreferences("app_config", Context.MODE_PRIVATE);
    }
  }

  public static String getAppKey() {
    if (getDataCenter() == DataCenter.Oversea) {
      return APP_KEY_OVERSEA;
    }
    return APP_KEY_MAINLAND;
  }

  public static int getParentScope() {
    return PARENT_SCOPE;
  }

  public static int getScope() {
    return CHILD_SCOPE;
  }

  public static boolean isOversea() {
    return AppConfig.getDataCenter() == AppConfig.DataCenter.Oversea;
  }

  /// 获取模版id
  public static int getConfigId() {
    if (getDataCenter() == DataCenter.Oversea) {
      return OVERSEA_CONFIG_ID;
    }
    return ONLINE_CONFIG_ID;
  }

  /// 获取模版id
  public static int getListenTogetherConfigId() {
    if (getDataCenter() == DataCenter.Oversea) {
      return LISTEN_TOGETHER_OVERSEA_CONFIG_ID;
    }
    return LISTEN_TOGETHER_ONLINE_CONFIG_ID;
  }

  public static DataCenter getDataCenter() {
    if (sDataCenter == null) {
      int index = sp.getInt(KEY_DATA_CENTER, DataCenter.MainLand.ordinal());
      sDataCenter = DataCenter.values()[index];
    }
    return sDataCenter;
  }

  public static void setDataCenter(DataCenter dataCenter) {
    if (sDataCenter != dataCenter) {
      sDataCenter = dataCenter;
      sp.edit().putInt(KEY_DATA_CENTER, dataCenter.ordinal()).commit();
    }
  }

  public enum DataCenter {
    MainLand,
    Oversea,
  }
}
