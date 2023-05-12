// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.app.chatroom.activity;

import android.annotation.SuppressLint;
import android.content.Intent;
import android.os.Bundle;
import androidx.annotation.Nullable;
import com.netease.yunxin.kit.alog.ALog;
import com.netease.yunxin.kit.entertainment.common.AppStatusConstant;
import com.netease.yunxin.kit.entertainment.common.AppStatusManager;
import com.netease.yunxin.kit.entertainment.common.Constants;
import com.netease.yunxin.kit.entertainment.common.R;
import com.netease.yunxin.kit.entertainment.common.activity.BaseActivity;
import com.netease.yunxin.kit.entertainment.common.statusbar.StatusBarConfig;

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
    init();
  }

  protected void init() {
    gotoHomePage();
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

  private void gotoHomePage() {
    Intent intent = new Intent();
    intent.setPackage(getPackageName());
    intent.setAction(Constants.PAGE_ACTION_HOME);
    startActivity(intent);
    finish();
  }
}
