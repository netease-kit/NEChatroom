// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.app.chatroom;

import android.app.Application;
import android.content.Context;
import androidx.annotation.Nullable;
import com.blankj.utilcode.util.ToastUtils;
import com.netease.yunxin.app.chatroom.config.AppConfig;
import com.netease.yunxin.kit.alog.ALog;
import com.netease.yunxin.kit.entertainment.common.AppStatusManager;
import com.netease.yunxin.kit.entertainment.common.utils.IconFontUtil;
import com.netease.yunxin.kit.voiceroomkit.api.NEVoiceRoomAuthEvent;
import com.netease.yunxin.kit.voiceroomkit.api.NEVoiceRoomCallback;
import com.netease.yunxin.kit.voiceroomkit.api.NEVoiceRoomKit;
import com.netease.yunxin.kit.voiceroomkit.api.NEVoiceRoomKitConfig;
import com.netease.yunxin.kit.voiceroomkit.ui.NEVoiceRoomUI;
import java.util.HashMap;
import java.util.Map;
import kotlin.Unit;

public class VoiceRoomApplication extends Application {

  private static final String TAG = "VoiceRoomApplication";

  @Override
  public void onCreate() {
    super.onCreate();
    ALog.init(this, ALog.LEVEL_ALL);
    AppConfig.init(this);
    AppStatusManager.init(this);
    initAuth();
    initVoiceRoomUI();
    initVoiceRoomKit(
        this,
        AppConfig.getAppKey(),
        new NEVoiceRoomCallback<Unit>() {

          @Override
          public void onSuccess(@Nullable Unit unit) {
            ALog.i(TAG, "initVoiceRoomKit success");
          }

          @Override
          public void onFailure(int code, @Nullable String msg) {
            ALog.i(TAG, "initVoiceRoomKit failed code = " + code + ", msg = " + msg);
          }
        });

    IconFontUtil.getInstance().init(this);
  }

  private void initAuth() {
    ALog.i(TAG, "initAuth");
  }

  private void initVoiceRoomUI() {
    NEVoiceRoomUI.getInstance().init(this);
  }

  private void initVoiceRoomKit(
      Context context, String appKey, NEVoiceRoomCallback<Unit> callback) {
    ALog.i(TAG, "initVoiceRoomKit");
    Map<String, String> extras = new HashMap<>();
    if (AppConfig.isOversea()) {
      extras.put("serverUrl", "oversea");
    }
    NEVoiceRoomKit.getInstance()
        .initialize(context, new NEVoiceRoomKitConfig(appKey, extras), callback);
    NEVoiceRoomKit.getInstance()
        .addAuthListener(
            evt -> {
              ALog.i(TAG, "onVoiceRoomAuthEvent evt = " + evt);
              if (evt == NEVoiceRoomAuthEvent.KICK_OUT) {
                ToastUtils.showShort(R.string.app_kick_out);
              }
              if (evt != NEVoiceRoomAuthEvent.LOGGED_IN) {}
            });
  }
}
