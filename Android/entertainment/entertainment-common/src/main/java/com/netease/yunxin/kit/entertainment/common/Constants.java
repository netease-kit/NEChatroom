// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.entertainment.common;

import java.util.Locale;

public class Constants {

  private static final String ZH = "zh";

  public static final String INTENT_KEY_APP_KEY = "intent_key_app_key";
  public static final String INTENT_KEY_TITLE = "intent_key_title";

  public static final String INTENT_KEY_URL = "intent_key_url";
  public static final String INTENT_KEY_NICK = "intent_key_nick";
  public static final String PAGE_ACTION_HOME = "https://netease.yunxin.party.home";
  public static final String PAGE_ACTION_AUTH = "https://netease.yunxin.party.auth";
  public static final String PRIVACY_POLICY_ZH =
      "https://yx-web-nosdn.netease.im/quickhtml/assets/yunxin/protocol/clauses.html";
  public static final String USER_AGREEMENT_ZH = "https://yunxin.163.com/m/clauses/user";
  public static final String PRIVACY_POLICY_EN =
      "https://yx-web-nosdn.netease.im/quickhtml/assets/yunxin/protocol/policy.html";
  public static final String USER_AGREEMENT_EN = "https://commsease.com/en/m/clauses/user";

  public static boolean isChineseLanguage() {
    return Locale.getDefault().getLanguage().contains(ZH);
  }

  public static String getPrivacyPolicyUrl() {
    if (isChineseLanguage()) {
      return PRIVACY_POLICY_ZH;
    } else {
      return PRIVACY_POLICY_EN;
    }
  }

  public static String getUserAgreementUrl() {
    if (isChineseLanguage()) {
      return USER_AGREEMENT_ZH;
    } else {
      return USER_AGREEMENT_EN;
    }
  }
}
