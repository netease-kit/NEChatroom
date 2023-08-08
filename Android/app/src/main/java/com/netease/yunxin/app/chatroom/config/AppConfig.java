// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.app.chatroom.config;

import android.annotation.SuppressLint;
import android.content.Context;

public class AppConfig {
  // 请填写您的AppKey和AppSecret
  private static final String APP_KEY = "your AppKey"; // 填入您的AppKey,可在云信控制台AppKey管理处获取
  public static final String APP_SECRET = "your AppSecret"; // 填入您的AppSecret,可在云信控制台AppKey管理处获取
  public static final boolean IS_OVERSEA = false; // 如果您的AppKey为海外，填ture；如果您的AppKey为国内，填false
  /**
   * BASE_URL为服务端地址,请在跑通Server Demo(https://github.com/netease-kit/nemo)后，替换为您自己实际的服务端地址
   * "http://yiyong.netease.im/"(国内)或者"http://yiyong-sg.netease.im"(海外)仅用于跑通体验Demo,请勿用于正式产品上线
   */
  public static final String BASE_URL = "http://yiyong.netease.im/";//如果您的AppKey为海外，填http://yiyong.netease.im/；如果您的AppKey为国内，填http://yiyong-sg.netease.im/

  // 说明： 云信IM账号（userUuid）和 用户Token（userToken） 默认为空，如果未填写或者只填写了个别数据， 则自动生成一个账号。如果填写完整则会使用填写的账号。
  // 注意： 通过ECServerApi.createAccount可以生成账号，必须在成功生成账号后才可填入您对应账号的userUuid、userToken、imToken、userName、icon，随意填入无效。
  /**
   * 云信IM账号，说明：账号信息为空，则默认自动生成一个账号
   */
  public static String userUuid = "";
  /**
   * 用户Token，说明：账号信息为空，则默认自动生成一个账号
   */
  public static String userToken = "";

  /**
   * 云信IM账号 token，说明：账号信息为空，则默认自动生成一个账号
   */
  public  static String imToken = "";

  // 以下内容选填
  /**
   * 用户名
   */
  public static String userName = "";
  /**
   * 头像
   */
  public static String icon = "";

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
    return BASE_URL;
  }

  public static String getNERoomServerUrl() {
    if (isOversea()) {
      return "oversea";
    }
    return "online";
  }
}
