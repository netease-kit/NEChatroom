// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.app.chatroom;

import android.app.Application;
import android.content.Context;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import com.netease.yunxin.app.chatroom.config.AppConfig;
import com.netease.yunxin.app.chatroom.utils.AppUtils;
import com.netease.yunxin.kit.alog.ALog;
import com.netease.yunxin.kit.listentogetherkit.api.NEListenTogetherCallback;
import com.netease.yunxin.kit.listentogetherkit.api.NEListenTogetherKit;
import com.netease.yunxin.kit.listentogetherkit.api.NEListenTogetherKitConfig;
import com.netease.yunxin.kit.login.AuthorManager;
import com.netease.yunxin.kit.login.model.AuthorConfig;
import com.netease.yunxin.kit.login.model.EventType;
import com.netease.yunxin.kit.login.model.LoginCallback;
import com.netease.yunxin.kit.login.model.LoginEvent;
import com.netease.yunxin.kit.login.model.LoginObserver;
import com.netease.yunxin.kit.login.model.LoginType;
import com.netease.yunxin.kit.voiceroomkit.api.NEVoiceRoomAuthEvent;
import com.netease.yunxin.kit.voiceroomkit.api.NEVoiceRoomCallback;
import com.netease.yunxin.kit.voiceroomkit.api.NEVoiceRoomKit;
import com.netease.yunxin.kit.voiceroomkit.api.NEVoiceRoomKitConfig;
import com.netease.yunxin.kit.voiceroomkit.ui.NEVoiceRoomUI;
import com.netease.yunxin.kit.voiceroomkit.ui.floatplay.FloatPlayManager;
import com.netease.yunxin.kit.voiceroomkit.ui.utils.IconFontUtil;
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
    initAuth();
    initVoiceRoomUI();
    initVoiceRoomKit(this, AppConfig.getAppKey());
    initListenTogetherKit(this, AppConfig.getAppKey());
    IconFontUtil.getInstance().init(this);
  }

  private void initVoiceRoomUI() {
    NEVoiceRoomUI.getInstance().init(this);
  }

  private void initAuth() {
    ALog.i(TAG, "initAuth");
    AuthorConfig authorConfig =
        new AuthorConfig(
            AppConfig.getAppKey(),
            AppConfig.getParentScope(),
            AppConfig.getScope(),
            false);
    authorConfig.setLoginType(AppUtils.isMainLand() ? LoginType.PHONE : LoginType.EMAIL);
    AuthorManager.INSTANCE.initAuthor(getApplicationContext(), authorConfig);
    AuthorManager.INSTANCE.registerLoginObserver(
        new LoginObserver<LoginEvent>() {
          @Override
          public void onEvent(LoginEvent loginEvent) {
            if (loginEvent.getEventType() == EventType.TYPE_LOGOUT) {
              ALog.d(TAG, "loginEvent:" + loginEvent.getEventType());
              if (FloatPlayManager.getInstance().isShowFloatView()) {
                FloatPlayManager.getInstance().release();
              }
              NEVoiceRoomKit.getInstance().logout(null);
              NEListenTogetherKit.getInstance().logout(null);
            }
          }
        });
  }

  private void initVoiceRoomKit(Context context, String appKey) {
    ALog.i(TAG, "initVoiceRoomKit");
    Map<String, String> extras = new HashMap<>();
    if (AppConfig.isOversea()) {
      extras.put("serverUrl", "oversea");
    }
    NEVoiceRoomKit.getInstance()
        .initialize(
            context,
            new NEVoiceRoomKitConfig(appKey, extras),
            new NEVoiceRoomCallback<Unit>() {
              @Override
              public void onSuccess(@Nullable Unit unit) {
                ALog.i(TAG, "initVoiceRoomKit success");
              }

              @Override
              public void onFailure(int code, @Nullable String msg) {
                ALog.i(TAG, "initVoiceRoomKit failed");
              }
            });
    NEVoiceRoomKit.getInstance()
        .addAuthListener(
            evt -> {
              ALog.i(TAG, "onVoiceRoomAuthEvent evt = " + evt);
              if (evt != NEVoiceRoomAuthEvent.LOGGED_IN) {
                AuthorManager.INSTANCE.logout(
                    new LoginCallback<Void>() {
                      @Override
                      public void onSuccess(@Nullable Void unused) {
                        ALog.i(TAG, "logout success");
                      }

                      @Override
                      public void onError(int code, @NonNull String msg) {
                        ALog.i(TAG, "logout failed code = " + code + " msg = " + msg);
                      }
                    });
              }
            });
  }

  private void initListenTogetherKit(Context context, String appKey) {
    ALog.i(TAG, "initListenTogetherKit");
    Map<String, String> extras = new HashMap<>();
    if (AppConfig.isOversea()) {
      extras.put("serverUrl", "oversea");
    }
    NEListenTogetherKit.getInstance()
        .initialize(
            context,
            new NEListenTogetherKitConfig(appKey, extras),
            new NEListenTogetherCallback<Unit>() {
              @Override
              public void onSuccess(@Nullable Unit unit) {
                ALog.i(TAG, "initListenTogetherKit success");
              }

              @Override
              public void onFailure(int code, @Nullable String msg) {
                ALog.i(TAG, "initListenTogetherKit failed");
              }
            });
  }
}
