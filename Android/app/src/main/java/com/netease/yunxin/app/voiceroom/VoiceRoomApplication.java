// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.app.voiceroom;

import android.app.Application;
import android.content.Context;
import androidx.annotation.Nullable;
import com.netease.yunxin.app.voiceroom.config.AppConfig;
import com.netease.yunxin.app.voiceroom.utils.AppUtils;
import com.netease.yunxin.kit.alog.ALog;
import com.netease.yunxin.kit.login.AuthorManager;
import com.netease.yunxin.kit.login.model.AuthorConfig;
import com.netease.yunxin.kit.login.model.EventType;
import com.netease.yunxin.kit.login.model.LoginEvent;
import com.netease.yunxin.kit.login.model.LoginObserver;
import com.netease.yunxin.kit.login.model.LoginType;
import com.netease.yunxin.kit.voiceroomkit.api.NEVoiceRoomCallback;
import com.netease.yunxin.kit.voiceroomkit.api.NEVoiceRoomKit;
import com.netease.yunxin.kit.voiceroomkit.api.NEVoiceRoomKitConfig;
import com.netease.yunxin.kit.voiceroomkit.ui.NEVoiceRoomUI;
import com.netease.yunxin.kit.voiceroomkit.ui.utils.IconFontUtil;
import java.util.HashMap;
import java.util.Map;
import kotlin.Unit;

public class VoiceRoomApplication extends Application {

    private static final String TAG = "VoiceRoomApplication";
    private static Application application;

    @Override
    public void onCreate() {
        super.onCreate();
        ALog.init(this, ALog.LEVEL_ALL);
        application = this;
        AppConfig.init(this);
        initAuth();
        initVoiceRoomUI();
        initVoiceRoomKit(application, AppConfig.getAppKey());
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
                            NEVoiceRoomKit.getInstance().logout(null);
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
    }
}
