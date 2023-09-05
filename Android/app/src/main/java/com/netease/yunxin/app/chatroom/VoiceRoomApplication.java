// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.app.chatroom;

import android.app.Application;
import com.netease.yunxin.app.chatroom.config.AppConfig;
import com.netease.yunxin.kit.alog.ALog;
import com.netease.yunxin.kit.entertainment.common.AppStatusManager;
import com.netease.yunxin.kit.entertainment.common.utils.IconFontUtil;
import com.netease.yunxin.kit.voiceroomkit.ui.NEVoiceRoomUI;

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
    IconFontUtil.getInstance().init(this);
  }

  private void initAuth() {
    ALog.i(TAG, "initAuth");
  }

  private void initVoiceRoomUI() {
    NEVoiceRoomUI.getInstance().init(this);
  }
}
