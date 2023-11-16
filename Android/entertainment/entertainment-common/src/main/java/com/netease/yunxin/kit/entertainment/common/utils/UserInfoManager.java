// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.entertainment.common.utils;

import android.text.TextUtils;
import com.google.gson.Gson;
import com.google.gson.JsonSyntaxException;
import com.netease.yunxin.kit.alog.ALog;
import com.netease.yunxin.kit.common.utils.SPUtils;
import com.netease.yunxin.kit.entertainment.common.model.NemoAccount;

public class UserInfoManager {
  private static final String TAG = "UserInfoManager";
  private static String selfUserUuid = "";
  private static String selfImToken = "";
  private static String selfImNickname = "";
  private static String selfImAvatar = "";
  private static String selfPhoneNumber = "";
  private static String selfUserToken = "";
  private static final String USER_INFO_SP_KEY = "user_info_sp_key";

  public static String getSelfImAvatar() {
    return selfImAvatar;
  }

  public static String getSelfPhoneNumber() {
    return selfPhoneNumber;
  }

  public static String getSelfUserUuid() {
    return selfUserUuid;
  }

  public static String getSelfNickname() {
    return selfImNickname;
  }

  public static void setSelfNickname(String nickname) {
    selfImNickname = nickname;
  }

  public static String getSelfUserToken() {
    return selfUserToken;
  }

  // 设置用户信息
  public static void setUserInfo(
      String userUuid,
      String userToken,
      String imToken,
      String userName,
      String icon,
      String mobile) {
    ALog.i(
        TAG,
        "setIMUserInfo: userUuid:"
            + userUuid
            + " userToken:"
            + userToken
            + " imToken:"
            + imToken
            + " userName:"
            + userName
            + " icon:"
            + icon
            + " mobile:"
            + mobile);
    selfUserUuid = userUuid;
    selfUserToken = userToken;
    selfImToken = imToken;
    selfImNickname = userName;
    selfImAvatar = icon;
    selfPhoneNumber = mobile;
  }

  public static void saveUserInfoToSp(NemoAccount nemoAccount) {
    if (nemoAccount != null) {
      SPUtils.getInstance().put(USER_INFO_SP_KEY, new Gson().toJson(nemoAccount));
    } else {
      SPUtils.getInstance().put(USER_INFO_SP_KEY, "");
    }
  }

  public static NemoAccount getUserInfoFromSp() {
    String nemoAccountStr = SPUtils.getInstance().getString(USER_INFO_SP_KEY);
    if (!TextUtils.isEmpty(nemoAccountStr)) {
      try {
        return new Gson().fromJson(nemoAccountStr, NemoAccount.class);
      } catch (JsonSyntaxException e) {
        ALog.e(TAG, "getNemoAccountFromSp error" + e.getMessage());
        return null;
      }
    }
    return null;
  }

  public static void clearUserInfo() {
    selfUserUuid = "";
    selfImToken = "";
    selfImNickname = "";
    selfImAvatar = "";
    selfPhoneNumber = "";
    selfUserToken = "";
    saveUserInfoToSp(null);
  }
}
