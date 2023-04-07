// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.app.chatroom.utils;

import com.netease.yunxin.app.chatroom.config.AppConfig;

import java.util.Locale;

public class AppUtils {

  // 当前系统是否是中文简体
  public static boolean isMainLand() {
    return Locale.getDefault().getLanguage().equals(new Locale("zh").getLanguage());
  }

  public static String getUserName() {
    return AppConfig.ACCOUNT;
  }

  public static String getAvatar() {
    return "";
  }
}
