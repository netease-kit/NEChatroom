// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.
package com.netease.yunxin.app.chatroom.activity;

import android.os.Bundle;
import androidx.annotation.Nullable;
import com.netease.yunxin.app.chatroom.config.AppConfig;
import com.netease.yunxin.app.chatroom.databinding.ActivityCreatRoomBinding;
import com.netease.yunxin.app.chatroom.utils.NavUtils;
import com.netease.yunxin.kit.alog.ALog;
import com.netease.yunxin.kit.login.AuthorManager;
import com.netease.yunxin.kit.voiceroomkit.api.NECreateVoiceRoomOptions;
import com.netease.yunxin.kit.voiceroomkit.api.NECreateVoiceRoomParams;
import com.netease.yunxin.kit.voiceroomkit.api.NEVoiceRoomCallback;
import com.netease.yunxin.kit.voiceroomkit.api.NEVoiceRoomKit;
import com.netease.yunxin.kit.voiceroomkit.api.model.NEVoiceCreateRoomDefaultInfo;
import com.netease.yunxin.kit.voiceroomkit.api.model.NEVoiceRoomInfo;
import com.netease.yunxin.kit.voiceroomkit.ui.activity.base.BaseActivity;

public class CreateRoomActivity extends BaseActivity {

  private static final String TAG = "CreateRoomActivity";
  private ActivityCreatRoomBinding binding;
  private static final int COUNT_SEAT = 9;
  private String cover = "";

  @Override
  protected void onCreate(@Nullable Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    binding = ActivityCreatRoomBinding.inflate(getLayoutInflater());
    setContentView(binding.getRoot());
    paddingStatusBarHeight(binding.getRoot());
    getRoomDefault();
    setEvent();
  }

  @Override
  protected boolean needTransparentStatusBar() {
    return true;
  }

  private void getRoomDefault() {
    NEVoiceRoomKit.getInstance()
        .getCreateRoomDefaultInfo(
            new NEVoiceRoomCallback<NEVoiceCreateRoomDefaultInfo>() {
              @Override
              public void onSuccess(
                  @Nullable NEVoiceCreateRoomDefaultInfo neVoiceCreateRoomDefaultInfo) {
                binding.etRoomName.setText(neVoiceCreateRoomDefaultInfo.getTopic());
                cover = neVoiceCreateRoomDefaultInfo.getLivePicture();
              }

              @Override
              public void onFailure(int code, @Nullable String msg) {
                ALog.e(TAG, "getRoomDefault code:" + code);
              }
            });
  }

  private void setEvent() {
    binding.ivBack.setOnClickListener(v -> finish());
    binding.tvCreateRoom.setOnClickListener(
        v -> {
          NECreateVoiceRoomParams createVoiceRoomParams =
              new NECreateVoiceRoomParams(
                  binding.etRoomName.getText().toString(),
                  getDefaultUserName(),
                  COUNT_SEAT,
                  AppConfig.getConfigId(),
                  cover,
                  null);
          NEVoiceRoomKit.getInstance()
              .createRoom(
                  createVoiceRoomParams,
                  new NECreateVoiceRoomOptions(),
                  new NEVoiceRoomCallback<NEVoiceRoomInfo>() {
                    @Override
                    public void onSuccess(@Nullable NEVoiceRoomInfo roomInfo) {
                      NavUtils.toVoiceRoomPage(CreateRoomActivity.this, roomInfo);
                      finish();
                    }

                    @Override
                    public void onFailure(int code, @Nullable String msg) {}
                  });
        });

    binding.ivRandom.setOnClickListener(v -> getRoomDefault());
  }

  private String getDefaultUserName() {
    if (AuthorManager.INSTANCE.getUserInfo() == null) {
      return "";
    }
    return AuthorManager.INSTANCE.getUserInfo().getNickname();
  }
}
