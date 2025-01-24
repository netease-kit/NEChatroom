// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.app.chatroom.activity;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import com.netease.yunxin.app.chatroom.R;
import com.netease.yunxin.app.chatroom.config.AppConfig;
import com.netease.yunxin.app.chatroom.utils.LoginUtil;
import com.netease.yunxin.kit.common.ui.utils.ToastX;
import com.netease.yunxin.kit.entertainment.common.activity.BaseSampleLoginActivity;
import com.netease.yunxin.kit.entertainment.common.model.NemoAccount;

/** 登录页面 */
public class SampleLoginActivity extends BaseSampleLoginActivity {
  private static final String TAG = "SampleLoginActivity";

  public static void startLoginActivity(Context context) {
    hasStart = true;
    Intent intent = new Intent(context, SampleLoginActivity.class);
    if (!(context instanceof Activity)) {
      intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
    }
    context.startActivity(intent);
  }

  @Override
  public void login(NemoAccount nemoAccount) {
    LoginUtil.loginVoiceRoom(
        this,
        nemoAccount,
        new LoginUtil.LoginVoiceRoomCallback() {
          @Override
          public void onSuccess() {
            loadingDialog.dismiss();
            gotoHomePage();
          }

          @Override
          public void onError(int errorCode, String errorMsg) {
            ToastX.showShortToast(errorMsg);
          }
        });
  }

  @Override
  public String getBaseUrl() {
    return AppConfig.getBaseUrl();
  }

  @Override
  public String getAppKey() {
    return AppConfig.getAppKey();
  }

  @Override
  public String getAppSecret() {
    return AppConfig.APP_SECRET;
  }

  @Override
  public int getIconResId() {
    return R.drawable.ic_logo;
  }

  @Override
  public int getContentResId() {
    return R.string.sample_login_desc;
  }

  @Override
  public int getSceneType() {
    return 2;
  }

  private void gotoHomePage() {
    Intent intent = new Intent(this, HomeActivity.class);
    startActivity(intent);
    finish();
  }
}
