// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.entertainment.common.activity;

import android.content.Intent;
import android.graphics.Color;
import android.os.Bundle;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import androidx.annotation.IdRes;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import com.gyf.immersionbar.ImmersionBar;
import com.netease.yunxin.kit.entertainment.common.AppStates;
import com.netease.yunxin.kit.entertainment.common.AppStatusConstant;
import com.netease.yunxin.kit.entertainment.common.AppStatusManager;
import com.netease.yunxin.kit.entertainment.common.statusbar.StatusBarConfig;
import com.netease.yunxin.kit.login.AuthorManager;
import com.netease.yunxin.kit.login.model.EventType;
import com.netease.yunxin.kit.login.model.LoginEvent;
import com.netease.yunxin.kit.login.model.LoginObserver;

public abstract class BasePartyActivity extends AppCompatActivity {

  private final LoginObserver<LoginEvent> loginObserver =
      event -> {
        if (event.getEventType() == EventType.TYPE_LOGOUT && !ignoredLoginEvent()) {
          finish();
          onKickOut();
        } else if (event.getEventType() == EventType.TYPE_LOGIN) {
          onLogin();
        }
      };

  @Override
  protected void onCreate(@Nullable Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    //校验APP状态
    if (validateAppStatus()) {
      setContentView(getRootView());
      AuthorManager.INSTANCE.registerLoginObserver(loginObserver);
      if (needTransparentStatusBar()) {
        adapterStatusBar();
      } else {
        StatusBarConfig config = provideStatusBarConfig();
        if (config != null) {
          ImmersionBar bar =
              ImmersionBar.with(this)
                  .statusBarDarkFont(config.isDarkFont())
                  .statusBarColor(config.getBarColor());
          if (config.isFits()) {
            bar.fitsSystemWindows(true);
          }
          if (config.isFullScreen()) {
            bar.fullScreen(true);
          }
          bar.init();
        }
      }
      init();
    } else {
      //异常退出
      Intent intent = new Intent(BasePartyActivity.this, SplashActivity.class);
      startActivity(intent);
      finish();
    }
  }

  protected abstract View getRootView();

  protected void init() {}

  private boolean validateAppStatus() {
    return AppStatusManager.getInstance().getAppStatus() == AppStatusConstant.STATUS_NORMAL;
  }

  protected boolean needTransparentStatusBar() {
    return false;
  }

  private void adapterStatusBar() {
    // 5.0以上系统状态栏透明
    Window window = getWindow();
    window.clearFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS);
    //会让应用的主体内容占用系统状态栏的空间
    window
        .getDecorView()
        .setSystemUiVisibility(
            View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN | View.SYSTEM_UI_FLAG_LAYOUT_STABLE);
    window.addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS);
    //将状态栏设置成透明色
    window.setStatusBarColor(Color.TRANSPARENT);
  }

  @Override
  protected void onDestroy() {
    AuthorManager.INSTANCE.unregisterLoginObserver(loginObserver);
    super.onDestroy();
  }

  protected StatusBarConfig provideStatusBarConfig() {
    return new StatusBarConfig.Builder().statusBarDarkFont(true).build();
  }

  protected boolean ignoredLoginEvent() {
    return AppStates.get().isAppRestartInFlight();
  }

  protected void paddingStatusBarHeight(View view) {
    StatusBarConfig.paddingStatusBarHeight(this, view);
  }

  protected void paddingStatusBarHeight(@IdRes int rootViewId) {
    paddingStatusBarHeight(findViewById(rootViewId));
  }

  protected void onKickOut() {}

  protected void onLogin() {}

  protected void showNetError() {}
}
