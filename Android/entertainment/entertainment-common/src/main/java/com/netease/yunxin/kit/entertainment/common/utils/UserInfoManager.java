// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.entertainment.common.utils;

public class UserInfoManager {
  private static String selfImAccid = "";
  private static String selfImToken = "";
  private static String selfImNickname = "";
  private static String selfImAvatar = "";
  private static String selfPhoneNumber = "";

  public static String getSelfImAvatar() {
    return selfImAvatar;
  }

  public static String getSelfPhoneNumber() {
    return selfPhoneNumber;
  }

  public static String getSelfImAccid() {
    return selfImAccid;
  }

  public static String getSelfAccessToken() {
    return selfImToken;
  }

  public static String getSelfNickname() {
    return selfImNickname;
  }

  public static void setSelfNickname(String nickname) {
    selfImNickname = nickname;
  }

  // 设置云信IM用户信息
  public static void setIMUserInfo(
      String imAccid, String imToken, String imNickname, String imAvatar, String phoneNumber) {
    selfImAccid = imAccid;
    selfImToken = imToken;
    selfImNickname = imNickname;
    selfImAvatar = imAvatar;
    selfPhoneNumber = phoneNumber;
  }
}
