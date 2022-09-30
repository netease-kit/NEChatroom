// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.app.voiceroom.user;

import android.os.Bundle;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.view.View;
import com.blankj.utilcode.util.ToastUtils;
import com.netease.yunxin.app.voiceroom.R;
import com.netease.yunxin.app.voiceroom.activity.BaseActivity;
import com.netease.yunxin.app.voiceroom.databinding.ActivityEditUserInfoBinding;
import com.netease.yunxin.kit.login.AuthorManager;
import com.netease.yunxin.kit.login.model.LoginCallback;
import com.netease.yunxin.kit.login.model.UserInfo;
import com.netease.yunxin.kit.voiceroomkit.ui.statusbar.StatusBarConfig;
import org.json.JSONException;

public final class EditUserInfoActivity extends BaseActivity {
  private final UserInfo userInfo = AuthorManager.INSTANCE.getUserInfo();
  private String lastNickname;
  private ActivityEditUserInfoBinding binding;

  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    binding = ActivityEditUserInfoBinding.inflate(getLayoutInflater());
    setContentView(binding.getRoot());
    paddingStatusBarHeight(binding.clRoot);
    lastNickname = userInfo.getNickname();
    initViews();
  }

  private void initViews() {
    binding.etNickName.setText(userInfo.getNickname());
    binding.ivBack.setOnClickListener(it -> finish());
    binding.ivClear.setOnClickListener(it -> binding.etNickName.setText(""));
    binding.etNickName.setOnFocusChangeListener(
        (view, hasFocus) -> {
          boolean visible = hasFocus && !TextUtils.isEmpty(binding.etNickName.getText().toString());
          binding.ivClear.setVisibility(visible ? View.VISIBLE : View.INVISIBLE);
        });

    binding.etNickName.addTextChangedListener(
        new TextWatcher() {
          public void beforeTextChanged(CharSequence s, int start, int count, int after) {}

          public void onTextChanged(CharSequence s, int start, int before, int count) {
            binding.ivClear.setVisibility(s.length() > 0 ? View.VISIBLE : View.INVISIBLE);
          }

          public void afterTextChanged(Editable s) {}
        });
  }

  private void doForUpdatingUserModel(String newNickname) {
    if (TextUtils.isEmpty(newNickname)) {
      ToastUtils.showShort(getString(R.string.app_user_info_update_failed));
      return;
    }
    if (newNickname != null && !newNickname.equals(lastNickname)) {
      try {
        UserInfo newUserInfo =
            UserInfo.Companion.fromJson(userInfo.toJson().put("nickname", newNickname));
        AuthorManager.INSTANCE.updateUserInfo(
            newUserInfo,
            new LoginCallback<UserInfo>() {
              @Override
              public void onSuccess(UserInfo userInfo) {
                ToastUtils.showShort(getString(R.string.app_user_info_update_success));
              }

              @Override
              public void onError(int i, String s) {
                ToastUtils.showShort(getString(R.string.app_user_info_update_failed));
              }
            });
      } catch (JSONException e) {
        e.printStackTrace();
      }
    }
  }

  public void finish() {
    // 关闭页面前检查用户昵称决定是否更新
    doForUpdatingUserModel(binding.etNickName.getText().toString());
    super.finish();
  }

  protected StatusBarConfig provideStatusBarConfig() {
    return new StatusBarConfig.Builder().statusBarDarkFont(false).build();
  }
}
