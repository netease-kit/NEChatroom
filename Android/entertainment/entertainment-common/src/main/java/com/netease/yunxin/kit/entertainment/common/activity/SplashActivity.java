// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.entertainment.common.activity;

import android.annotation.SuppressLint;
import android.content.Intent;
import android.os.Bundle;
import android.text.Spannable;
import android.text.SpannableStringBuilder;
import android.text.style.ClickableSpan;
import android.view.View;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import com.netease.yunxin.kit.alog.ALog;
import com.netease.yunxin.kit.entertainment.common.AppStatusConstant;
import com.netease.yunxin.kit.entertainment.common.AppStatusManager;
import com.netease.yunxin.kit.entertainment.common.Constants;
import com.netease.yunxin.kit.entertainment.common.R;
import com.netease.yunxin.kit.entertainment.common.databinding.ActivitySplashBinding;
import com.netease.yunxin.kit.entertainment.common.statusbar.StatusBarConfig;
import com.netease.yunxin.kit.entertainment.common.utils.NavUtils;
import com.netease.yunxin.kit.entertainment.common.utils.SpUtils;
import com.netease.yunxin.kit.login.AuthorManager;
import com.netease.yunxin.kit.login.model.EventType;
import com.netease.yunxin.kit.login.model.LoginEvent;
import com.netease.yunxin.kit.login.model.LoginObserver;
import com.netease.yunxin.kit.login.utils.ConfirmDialog;
import com.netease.yunxin.kit.login.utils.HelperUtils;

@SuppressLint("CustomSplashScreen")
public class SplashActivity extends BaseActivity {
  private static final String TAG = "SplashActivity";
  private ActivitySplashBinding binding;
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
              gotoHomePage();
            }
          };

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
    AuthorManager.INSTANCE.registerLoginObserver(loginObserver);
    if (SpUtils.isAgreePrivate()) {
      gotoHomePage();
    } else {
      ConfirmDialog.Companion.show(
          this,
          getString(R.string.app_dialog_protocol_tips_title),
          getDialogContent(),
          getString(R.string.app_dialog_protocol_agree),
          true,
          false,
          aBoolean -> {
            if (aBoolean != null && aBoolean) {
              SpUtils.setAgreePrivate(true);
              gotoHomePage();
            } else {
              System.exit(0);
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

  private void gotoHomePage() {
    Intent intent = new Intent();
    intent.setPackage(getPackageName());
    intent.setAction(Constants.MAIN_PAGE_ACTION);
    startActivity(intent);
    AuthorManager.INSTANCE.unregisterLoginObserver(loginObserver);
    finish();
  }

  private void gotoLoginPage() {
    AuthorManager.INSTANCE.launchLogin(SplashActivity.this, Constants.MAIN_PAGE_ACTION, false);
    finish();
  }

  private SpannableStringBuilder getDialogContent() {
    SpannableStringBuilder spannedString =
        new SpannableStringBuilder(getString(R.string.app_dialog_protocol_content_text));
    int privacyStart = 61;
    int privacyEnd = 67;
    if (!HelperUtils.INSTANCE.isChineseLang()) {
      privacyStart = 139;
      privacyEnd = 158;
    }

    spannedString.setSpan(
        new ClickableSpan() {

          @Override
          public void onClick(@NonNull View widget) {
            NavUtils.toPrivacyPolicyPage(SplashActivity.this);
          }
        },
        privacyStart,
        privacyEnd,
        Spannable.SPAN_EXCLUSIVE_EXCLUSIVE);

    int userPoliceStart = 68;
    int userPoliceEnd = 74;
    if (!HelperUtils.INSTANCE.isChineseLang()) {
      userPoliceStart = 163;
      userPoliceEnd = 179;
    }
    spannedString.setSpan(
        new ClickableSpan() {

          @Override
          public void onClick(@NonNull View widget) {
            NavUtils.toUserPolicePage(SplashActivity.this);
          }
        },
        userPoliceStart,
        userPoliceEnd,
        Spannable.SPAN_EXCLUSIVE_EXCLUSIVE);

    return spannedString;
  }
}
