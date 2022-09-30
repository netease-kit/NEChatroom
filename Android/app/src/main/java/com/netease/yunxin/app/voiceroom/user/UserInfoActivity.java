// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.app.voiceroom.user;

import static com.netease.yunxin.app.voiceroom.utils.NavUtils.toEditUserInfoPage;

import android.os.Bundle;
import com.netease.yunxin.app.voiceroom.activity.BaseActivity;
import com.netease.yunxin.app.voiceroom.databinding.ActivityUserInfoBinding;
import com.netease.yunxin.kit.common.image.ImageLoader;
import com.netease.yunxin.kit.login.AuthorManager;
import com.netease.yunxin.kit.login.model.LoginCallback;
import com.netease.yunxin.kit.login.model.LoginEvent;
import com.netease.yunxin.kit.login.model.LoginObserver;
import com.netease.yunxin.kit.login.model.UserInfo;
import com.netease.yunxin.kit.voiceroomkit.ui.statusbar.StatusBarConfig;

public final class UserInfoActivity extends BaseActivity {

  private UserInfo userInfo = AuthorManager.INSTANCE.getUserInfo();
  private final LoginObserver<LoginEvent> loginObserver =
      loginEvent -> {
        if (loginEvent.getUserInfo() != null) {
          userInfo = loginEvent.getUserInfo();
          initUser();
        }
      };
  private ActivityUserInfoBinding binding;

  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    AuthorManager.INSTANCE.registerLoginObserver(loginObserver);
    binding = ActivityUserInfoBinding.inflate(getLayoutInflater());
    setContentView(binding.getRoot());
    initViews();
    paddingStatusBarHeight(binding.clRoot);
  }

  protected void onDestroy() {
    super.onDestroy();
    AuthorManager.INSTANCE.unregisterLoginObserver(loginObserver);
  }

  private void initViews() {
    binding.tvLogout.setOnClickListener(
        v ->
            AuthorManager.INSTANCE.logout(
                new LoginCallback<Void>() {
                  @Override
                  public void onSuccess(Void unused) {
                    finish();
                  }

                  @Override
                  public void onError(int i, String s) {}
                }));
    binding.ivClose.setOnClickListener(v -> finish());
    initUser();
  }

  private void initUser() {
    ImageLoader.with(this).circleLoad(userInfo.getAvatar(), binding.ivUserPortrait);
    binding.tvNickName.setOnClickListener(v -> toEditUserInfoPage(this));
    binding.tvNickName.setText(userInfo.getNickname());
  }

  protected StatusBarConfig provideStatusBarConfig() {
    return new StatusBarConfig.Builder().statusBarDarkFont(false).build();
  }
}
