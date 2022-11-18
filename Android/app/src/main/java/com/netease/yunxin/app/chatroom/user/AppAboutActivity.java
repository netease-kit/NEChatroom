// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.app.chatroom.user;

import static com.netease.yunxin.app.chatroom.utils.NavUtils.toBrowsePage;

import android.os.Bundle;
import com.netease.yunxin.app.chatroom.BuildConfig;
import com.netease.yunxin.app.chatroom.Constants;
import com.netease.yunxin.app.chatroom.R;
import com.netease.yunxin.app.chatroom.activity.BaseActivity;
import com.netease.yunxin.app.chatroom.databinding.ActivityAppAboutBinding;
import com.netease.yunxin.app.chatroom.utils.AppUtils;
import com.netease.yunxin.kit.voiceroomkit.ui.statusbar.StatusBarConfig;

public final class AppAboutActivity extends BaseActivity {

  private ActivityAppAboutBinding binding;

  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    binding = ActivityAppAboutBinding.inflate(getLayoutInflater());
    setContentView(binding.getRoot());
    paddingStatusBarHeight(binding.clRoot);
    initViews();
  }

  private void initViews() {
    binding.ivClose.setOnClickListener(v -> finish());
    binding.tvAppVersion.setText("v" + BuildConfig.VERSION_NAME);
    binding.tvPrivacy.setOnClickListener(
        v ->
            toBrowsePage(
                this,
                getString(R.string.app_privacy_policy),
                AppUtils.isMainLand() ? Constants.URL_PRIVACY_ZH : Constants.URL_PRIVACY_EN));
    binding.tvUserPolice.setOnClickListener(
        v ->
            toBrowsePage(
                this,
                getString(R.string.app_user_agreement),
                AppUtils.isMainLand()
                    ? Constants.URL_USER_POLICE_ZH
                    : Constants.URL_USER_POLICE_EN));
    binding.tvDisclaimer.setOnClickListener(
        v ->
            toBrowsePage(
                this,
                getString(R.string.app_disclaimer),
                AppUtils.isMainLand() ? Constants.URL_DISCLAIMER_ZH : Constants.URL_DISCLAIMER_EN));
  }

  protected StatusBarConfig provideStatusBarConfig() {
    return new StatusBarConfig.Builder().statusBarDarkFont(false).build();
  }
}
