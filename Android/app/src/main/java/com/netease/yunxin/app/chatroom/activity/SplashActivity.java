// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.app.chatroom.activity;

import android.annotation.SuppressLint;
import android.content.Intent;
import android.os.Bundle;
import androidx.annotation.Nullable;
import com.netease.yunxin.app.chatroom.utils.LoginUtil;
import com.netease.yunxin.kit.alog.ALog;
import com.netease.yunxin.kit.common.ui.utils.ToastX;
import com.netease.yunxin.kit.entertainment.common.AppStatusConstant;
import com.netease.yunxin.kit.entertainment.common.AppStatusManager;
import com.netease.yunxin.kit.entertainment.common.R;
import com.netease.yunxin.kit.entertainment.common.activity.BaseActivity;
import com.netease.yunxin.kit.entertainment.common.model.NemoAccount;
import com.netease.yunxin.kit.entertainment.common.utils.UserInfoManager;

@SuppressLint("CustomSplashScreen")
public class SplashActivity extends BaseActivity {
  private static final String TAG = "SplashActivity";

  @Override
  protected void onCreate(@Nullable Bundle savedInstanceState) {
    AppStatusManager.getInstance().setAppStatus(AppStatusConstant.STATUS_NORMAL);
    super.onCreate(savedInstanceState);
    setContentView(R.layout.activity_splash);
    if (!isTaskRoot()) {
      Intent mainIntent = getIntent();
      String action = mainIntent.getAction();
      if (mainIntent.hasCategory(Intent.CATEGORY_LAUNCHER) && Intent.ACTION_MAIN.equals(action)) {
        finish();
      }
    }
    if (UserInfoManager.getUserInfoFromSp() != null) {
      // sp中有登录信息，执行登录逻辑，成功后跳转到首页
      loginVoiceRoom(UserInfoManager.getUserInfoFromSp());
    } else {
      // 跳转到登录页面
      gotoLoginPage();
    }
  }

  private void loginVoiceRoom(NemoAccount nemoAccount) {
    LoginUtil.loginVoiceRoom(
        this,
        nemoAccount,
        new LoginUtil.LoginVoiceRoomCallback() {
          @Override
          public void onSuccess() {
            gotoHomePage();
          }

          @Override
          public void onError(int errorCode, String errorMsg) {
            ToastX.showShortToast(errorMsg);
          }
        });
  }

  private void gotoLoginPage() {
    SampleLoginActivity.startLoginActivity(this);
    finish();
  }

  @Override
  protected void onNewIntent(Intent intent) {
    super.onNewIntent(intent);
    ALog.d(TAG, "onNewIntent: intent -> " + intent.getData());
    setIntent(intent);
  }

  private void gotoHomePage() {
    Intent intent = new Intent(this, HomeActivity.class);
    startActivity(intent);
    finish();
  }
}
