// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.



/// 用户信息管理类
class UserInfoManager {
  static bool useUnifiedLogin = false;
  static String account = '';
  static String nickname = '';
  static String avatar = '';
  static String token = '';

  static String getAccount() {
    return account;
  }

  static String getAvatar() {
    return avatar;
  }

  static String getNickname() {
    return nickname;
  }

  static void setUserInfo(
      String account, String token, String nickname, String avatar) {
    UserInfoManager.account = account;
    UserInfoManager.token = token;
    UserInfoManager.nickname = nickname;
    UserInfoManager.avatar = avatar;
  }
}
