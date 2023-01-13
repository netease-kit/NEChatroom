// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.
package com.netease.yunxin.app.chatroom.activity;

import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.recyclerview.widget.RecyclerView;
import com.netease.yunxin.app.chatroom.R;
import com.netease.yunxin.app.chatroom.config.AppConfig;
import com.netease.yunxin.app.chatroom.databinding.ActivityCreatRoomBinding;
import com.netease.yunxin.app.chatroom.utils.NavUtils;
import com.netease.yunxin.app.listentogether.Constants;
import com.netease.yunxin.kit.common.ui.utils.ToastUtils;
import com.netease.yunxin.kit.common.utils.NetworkUtils;
import com.netease.yunxin.kit.listentogetherkit.api.NECreateListenTogetherRoomOptions;
import com.netease.yunxin.kit.listentogetherkit.api.NECreateListenTogetherRoomParams;
import com.netease.yunxin.kit.listentogetherkit.api.NEListenTogetherCallback;
import com.netease.yunxin.kit.listentogetherkit.api.NEListenTogetherKit;
import com.netease.yunxin.kit.listentogetherkit.api.model.NEListenTogetherCreateRoomDefaultInfo;
import com.netease.yunxin.kit.listentogetherkit.api.model.NEListenTogetherRoomInfo;
import com.netease.yunxin.kit.login.AuthorManager;
import com.netease.yunxin.kit.voiceroomkit.api.NECreateVoiceRoomOptions;
import com.netease.yunxin.kit.voiceroomkit.api.NECreateVoiceRoomParams;
import com.netease.yunxin.kit.voiceroomkit.api.NELiveType;
import com.netease.yunxin.kit.voiceroomkit.api.NEVoiceRoomCallback;
import com.netease.yunxin.kit.voiceroomkit.api.NEVoiceRoomKit;
import com.netease.yunxin.kit.voiceroomkit.api.model.NEVoiceRoomInfo;
import com.netease.yunxin.kit.voiceroomkit.ui.activity.base.BaseActivity;

public class CreateRoomActivity extends BaseActivity {

  private static final String TAG = "CreateRoomActivity";
  private ActivityCreatRoomBinding binding;
  private static final int COUNT_SEAT = 9;
  private static final int LISTEN_TOGETHER_COUNT_SEAT = 2;
  private String cover = "";
  private int liveType;

  @Override
  protected void onCreate(@Nullable Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    binding = ActivityCreatRoomBinding.inflate(getLayoutInflater());
    setContentView(binding.getRoot());
    paddingStatusBarHeight(binding.getRoot());
    liveType = getIntent().getIntExtra(Constants.INTENT_LIVE_TYPE, NELiveType.LIVE_TYPE_VOICE);
    if (liveType == NELiveType.LIVE_TYPE_VOICE) {
      binding.tvChatRoom.setText(getString(R.string.app_voice_chat));
    } else if (liveType == NELiveType.LIVE_TYPE_TOGETHER_LISTEN) {
      binding.tvChatRoom.setText(getString(R.string.app_listen_together));
    }
    getRoomDefault();
    setEvent();
  }

  @Override
  protected boolean needTransparentStatusBar() {
    return true;
  }

  private void getRoomDefault() {
    NEListenTogetherKit.getInstance()
        .getCreateRoomDefaultInfo(
            new NEListenTogetherCallback<NEListenTogetherCreateRoomDefaultInfo>() {
              @Override
              public void onSuccess(
                  @Nullable NEListenTogetherCreateRoomDefaultInfo neVoiceCreateRoomDefaultInfo) {
                binding.etRoomName.setText(neVoiceCreateRoomDefaultInfo.getTopic());
                cover = neVoiceCreateRoomDefaultInfo.getLivePicture();
              }

              @Override
              public void onFailure(int code, @Nullable String msg) {}
            });
  }

  private void setEvent() {
    binding.ivBack.setOnClickListener(v -> finish());
    binding.tvCreateRoom.setOnClickListener(
        v -> {
          if (!NetworkUtils.isConnected()) {
            ToastUtils.INSTANCE.showShortToast(this, getString(R.string.common_network_error));
            return;
          }
          if (TextUtils.isEmpty(binding.etRoomName.getText().toString())) {
            ToastUtils.INSTANCE.showShortToast(
                CreateRoomActivity.this, getString(R.string.app_empty_roomname_tips));
            return;
          }
          if (liveType == NELiveType.LIVE_TYPE_TOGETHER_LISTEN) {
            NECreateListenTogetherRoomParams createVoiceRoomParams =
                new NECreateListenTogetherRoomParams(
                    binding.etRoomName.getText().toString(),
                    getDefaultUserName(),
                    LISTEN_TOGETHER_COUNT_SEAT,
                    AppConfig.getListenTogetherConfigId(),
                    cover,
                    NELiveType.LIVE_TYPE_TOGETHER_LISTEN,
                    null);
            NEListenTogetherKit.getInstance()
                .createRoom(
                    createVoiceRoomParams,
                    new NECreateListenTogetherRoomOptions(),
                    new NEListenTogetherCallback<NEListenTogetherRoomInfo>() {
                      @Override
                      public void onSuccess(@Nullable NEListenTogetherRoomInfo roomInfo) {
                        NavUtils.toListenTogetherRoomPage(CreateRoomActivity.this, roomInfo);
                        finish();
                      }

                      @Override
                      public void onFailure(int code, @Nullable String msg) {}
                    });
          } else {
            NECreateVoiceRoomParams createVoiceRoomParams =
                new NECreateVoiceRoomParams(
                    binding.etRoomName.getText().toString(),
                    getDefaultUserName(),
                    COUNT_SEAT,
                    AppConfig.getConfigId(),
                    cover,
                    NELiveType.LIVE_TYPE_VOICE,
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
          }
        });

    binding.ivRandom.setOnClickListener(v -> getRoomDefault());
  }

  private String getDefaultUserName() {
    if (AuthorManager.INSTANCE.getUserInfo() == null) {
      return "";
    }
    return AuthorManager.INSTANCE.getUserInfo().getNickname();
  }

  public static class RoomViewHolder extends RecyclerView.ViewHolder {
    ImageView iv;
    TextView tv;

    public RoomViewHolder(@NonNull View itemView) {
      super(itemView);
      iv = itemView.findViewById(R.id.iv);
      tv = itemView.findViewById(R.id.tv);
    }
  }

  public static class Room {
    public String name;
    public boolean selected;

    public Room(String name, boolean selected) {
      this.name = name;
      this.selected = selected;
    }
  }
}
