// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.app.chatroom.main;

import android.content.Intent;
import android.os.Bundle;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import com.netease.yunxin.app.chatroom.Constants;
import com.netease.yunxin.app.chatroom.R;
import com.netease.yunxin.app.chatroom.activity.BaseActivity;
import com.netease.yunxin.app.chatroom.utils.NavUtils;
import com.netease.yunxin.kit.alog.ALog;
import com.netease.yunxin.kit.login.AuthorManager;
import com.netease.yunxin.kit.login.model.EventType;
import com.netease.yunxin.kit.login.model.LoginCallback;
import com.netease.yunxin.kit.login.model.LoginEvent;
import com.netease.yunxin.kit.login.model.LoginObserver;
import com.netease.yunxin.kit.login.model.UserInfo;
import com.netease.yunxin.kit.voiceroomkit.ui.activity.AppStatusConstant;
import com.netease.yunxin.kit.voiceroomkit.ui.activity.AppStatusManager;
import com.netease.yunxin.kit.voiceroomkit.ui.statusbar.StatusBarConfig;

public class SplashActivity extends BaseActivity {
  private static final String TAG = "SplashActivity";
  private LoginObserver loginObserver =
      (LoginObserver<LoginEvent>)
          loginEvent -> {
            ALog.d(
                TAG,
                "LoginObserver loginEvent = "
                    + loginEvent.getEventType()
                    + " userInfo = "
                    + (loginEvent.getUserInfo() == null ? "" : loginEvent.getUserInfo().toJson()));
            if (loginEvent.getEventType() == EventType.TYPE_LOGIN) {
              gotoMainPage();
            }
          };

  @Override
  protected void onCreate(@Nullable Bundle savedInstanceState) {
    AppStatusManager.getInstance().setAppStatus(AppStatusConstant.STATUS_NORMAL);
    super.onCreate(savedInstanceState);
    if (!isTaskRoot()) {
      Intent mainIntent = getIntent();
      String action = mainIntent.getAction();
      if (mainIntent.hasCategory(Intent.CATEGORY_LAUNCHER) && Intent.ACTION_MAIN.equals(action)) {
        finish();
        return;
      }
    }

    setContentView(R.layout.activity_splash);

    AuthorManager.INSTANCE.registerLoginObserver(loginObserver);
    if (!AuthorManager.INSTANCE.isLogin()) {
      AuthorManager.INSTANCE.autoLogin(
          false,
          new LoginCallback<UserInfo>() {

            @Override
            public void onSuccess(UserInfo userInfo) {
              ALog.d(TAG, "autoLogin success");
              gotoMainPage();
            }

            @Override
            public void onError(int code, @NonNull String message) {
              ALog.d(TAG, "autoLogin failed code = " + code + " message = " + message);
              gotoLoginPage();
            }
          });
    }
  }

  @Override
  protected void onNewIntent(Intent intent) {
    super.onNewIntent(intent);
    ALog.d(TAG, "onNewIntent: intent -> " + intent.getData());
    setIntent(intent);
  }

  @Override
  protected StatusBarConfig provideStatusBarConfig() {
    return new StatusBarConfig.Builder().statusBarDarkFont(true).fullScreen(true).build();
  }

  private void gotoMainPage() {
    NavUtils.toMainPage(SplashActivity.this);
    AuthorManager.INSTANCE.unregisterLoginObserver(loginObserver);
    finish();
  }

  private void gotoLoginPage() {
    AuthorManager.INSTANCE.launchLogin(SplashActivity.this, Constants.MAIN_PAGE_ACTION, false);
    finish();
  }
}
