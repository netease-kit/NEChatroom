// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.app.chatroom.activity;

import android.content.Context;
import android.os.Bundle;
import android.view.View;
import androidx.annotation.Nullable;
import com.netease.yunxin.app.chatroom.R;
import com.netease.yunxin.app.chatroom.config.AppConfig;
import com.netease.yunxin.kit.alog.ALog;
import com.netease.yunxin.kit.voiceroomkit.api.NECreateVoiceRoomOptions;
import com.netease.yunxin.kit.voiceroomkit.api.NECreateVoiceRoomParams;
import com.netease.yunxin.kit.voiceroomkit.api.NEJoinVoiceRoomOptions;
import com.netease.yunxin.kit.voiceroomkit.api.NEJoinVoiceRoomParams;
import com.netease.yunxin.kit.voiceroomkit.api.NEVoiceRoomCallback;
import com.netease.yunxin.kit.voiceroomkit.api.NEVoiceRoomKit;
import com.netease.yunxin.kit.voiceroomkit.api.NEVoiceRoomLiveState;
import com.netease.yunxin.kit.voiceroomkit.api.NEVoiceRoomRole;
import com.netease.yunxin.kit.voiceroomkit.api.model.NEVoiceRoomInfo;
import com.netease.yunxin.kit.voiceroomkit.api.model.NEVoiceRoomList;
import com.netease.yunxin.kit.voiceroomkit.ui.activity.base.BaseActivity;
import kotlin.Unit;

/** 用于接口调试 */
public class VoiceRoomKitTestActivity extends BaseActivity {
  Context context;
  private static final String TAG = "TestActivity";
  private String roomId = "";
  private long liveRecordId;

  @Override
  protected void onCreate(@Nullable Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    setContentView(R.layout.activity_test);
    context = this;
    findViewById(R.id.createRoom)
        .setOnClickListener(
            new View.OnClickListener() {
              @Override
              public void onClick(View v) {
                createRoom();
              }
            });
    findViewById(R.id.endRoom)
        .setOnClickListener(
            new View.OnClickListener() {
              @Override
              public void onClick(View v) {
                endRoom();
              }
            });
    findViewById(R.id.joinRoom)
        .setOnClickListener(
            new View.OnClickListener() {
              @Override
              public void onClick(View v) {
                joinRoom();
              }
            });
    findViewById(R.id.leaveRoom)
        .setOnClickListener(
            new View.OnClickListener() {
              @Override
              public void onClick(View v) {
                leaveRoom();
              }
            });
    findViewById(R.id.getRoomList)
        .setOnClickListener(
            new View.OnClickListener() {
              @Override
              public void onClick(View v) {
                getRoomList();
              }
            });
  }

  private void getRoomList() {
    NEVoiceRoomKit.getInstance()
        .getVoiceRoomList(
            NEVoiceRoomLiveState.Live,
            1,
            20,
            new NEVoiceRoomCallback<NEVoiceRoomList>() {
              @Override
              public void onSuccess(@Nullable NEVoiceRoomList neVoiceRoomList) {
                ALog.d(TAG, "getVoiceRoomRoomList onSuccess:" + neVoiceRoomList);
              }

              @Override
              public void onFailure(int code, @Nullable String msg) {
                ALog.d(TAG, "getVoiceRoomRoomList onFailure:" + code);
              }
            });
  }

  private void createRoom() {
    NECreateVoiceRoomParams params =
        new NECreateVoiceRoomParams(
            "test roomName", "test nick", 8, AppConfig.getConfigId(), "", null);
    NECreateVoiceRoomOptions options = new NECreateVoiceRoomOptions();
    NEVoiceRoomKit.getInstance()
        .createRoom(
            params,
            options,
            new NEVoiceRoomCallback<NEVoiceRoomInfo>() {
              @Override
              public void onSuccess(@Nullable NEVoiceRoomInfo neVoiceRoomInfo) {
                if (neVoiceRoomInfo != null && neVoiceRoomInfo.getLiveModel() != null) {
                  liveRecordId = neVoiceRoomInfo.getLiveModel().getLiveRecordId();
                  roomId = neVoiceRoomInfo.getLiveModel().getRoomUuid();
                  ALog.d(TAG, "createRoom onSuccess:" + neVoiceRoomInfo);
                  ALog.d(TAG, "createRoom roomId:" + roomId);
                  ALog.d(TAG, "createRoom liveRecordId:" + liveRecordId);
                }
              }

              @Override
              public void onFailure(int code, @Nullable String msg) {
                ALog.d(TAG, "createRoom onFailure:" + code);
              }
            });
  }

  private void endRoom() {
    NEVoiceRoomKit.getInstance()
        .endRoom(
            new NEVoiceRoomCallback<Unit>() {
              @Override
              public void onSuccess(@Nullable Unit unit) {
                ALog.d(TAG, "endRoom onSuccess");
              }

              @Override
              public void onFailure(int code, @Nullable String msg) {
                ALog.d(TAG, "endRoom onFailure:" + code);
              }
            });
  }

  private void joinRoom() {
    NEJoinVoiceRoomParams joinVoiceRoomParams =
        new NEJoinVoiceRoomParams(roomId, "nick", null, NEVoiceRoomRole.HOST, liveRecordId, null);
    NEVoiceRoomKit.getInstance()
        .joinRoom(
            joinVoiceRoomParams,
            new NEJoinVoiceRoomOptions(),
            new NEVoiceRoomCallback<NEVoiceRoomInfo>() {
              @Override
              public void onSuccess(@Nullable NEVoiceRoomInfo neVoiceRoomInfo) {
                ALog.d(TAG, "joinRoom onSuccess:" + neVoiceRoomInfo);
              }

              @Override
              public void onFailure(int code, @Nullable String msg) {
                ALog.d(TAG, "joinRoom onFailure:" + code);
              }
            });
  }

  private void leaveRoom() {
    NEVoiceRoomKit.getInstance()
        .leaveRoom(
            new NEVoiceRoomCallback<Unit>() {
              @Override
              public void onSuccess(@Nullable Unit unit) {
                ALog.d(TAG, "leaveRoom onSuccess");
              }

              @Override
              public void onFailure(int code, @Nullable String msg) {
                ALog.d(TAG, "leaveRoom onFailure:" + code);
              }
            });
  }
}
