// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.app.chatroom.utils;

import android.content.Context;
import androidx.annotation.Nullable;
import com.netease.yunxin.app.chatroom.config.AppConfig;
import com.netease.yunxin.kit.alog.ALog;
import com.netease.yunxin.kit.entertainment.common.model.NemoAccount;
import com.netease.yunxin.kit.entertainment.common.utils.UserInfoManager;
import com.netease.yunxin.kit.ordersong.core.NEOrderSongService;
import com.netease.yunxin.kit.voiceroomkit.api.NEVoiceRoomCallback;
import com.netease.yunxin.kit.voiceroomkit.api.NEVoiceRoomKit;
import com.netease.yunxin.kit.voiceroomkit.api.NEVoiceRoomKitConfig;
import java.util.HashMap;
import java.util.Map;
import kotlin.Unit;

public class LoginUtil {
  private static final String TAG = "LoginUtil";

  public static void loginVoiceRoom(
      Context context, NemoAccount nemoAccount, LoginVoiceRoomCallback callback) {
    ALog.i(TAG, "initVoiceRoomKit");
    Map<String, String> extras = new HashMap<>();
    extras.put("serverUrl", AppConfig.getNERoomServerUrl());
    extras.put("baseUrl", AppConfig.getBaseUrl());
    NEVoiceRoomKit.getInstance()
        .initialize(
            context,
            new NEVoiceRoomKitConfig(AppConfig.getAppKey(), extras),
            new NEVoiceRoomCallback<Unit>() {
              @Override
              public void onSuccess(@Nullable Unit unit) {
                ALog.d(TAG, "NEVoiceRoomKit init success");
                loginVoiceRoomInner(context, nemoAccount, callback);
              }

              @Override
              public void onFailure(int code, @Nullable String msg) {
                if (callback != null) {
                  callback.onError(
                      code, "NEVoiceRoomKit initialize failed,code:" + code + "，msg:" + msg);
                }
              }
            });
  }

  private static void loginVoiceRoomInner(
      Context context, NemoAccount nemoAccount, LoginVoiceRoomCallback callback) {
    NEVoiceRoomKit.getInstance()
        .login(
            nemoAccount.userUuid,
            nemoAccount.userToken,
            new NEVoiceRoomCallback<Unit>() {

              @Override
              public void onSuccess(@Nullable Unit unit) {
                ALog.d(TAG, "NEVoiceRoomKit login success");
                UserInfoManager.setUserInfo(
                    nemoAccount.userUuid,
                    nemoAccount.userToken,
                    nemoAccount.imToken,
                    nemoAccount.userName,
                    nemoAccount.icon,
                    nemoAccount.mobile);
                UserInfoManager.saveUserInfoToSp(nemoAccount);
                NEOrderSongService.INSTANCE.initialize(
                    context.getApplicationContext(),
                    AppConfig.getAppKey(),
                    AppConfig.getBaseUrl(),
                    AppConfig.getNERoomServerUrl(),
                    nemoAccount.userUuid);
                NEOrderSongService.INSTANCE.addHeader("user", nemoAccount.userUuid);
                NEOrderSongService.INSTANCE.addHeader("token", nemoAccount.userToken);
                if (callback != null) {
                  callback.onSuccess();
                }
              }

              @Override
              public void onFailure(int code, @Nullable String msg) {
                ALog.e(TAG, "NEVoiceRoomKit login failed code = " + code + ", msg = " + msg);
                UserInfoManager.clearUserInfo();
                if (callback != null) {
                  callback.onError(
                      code, "NEVoiceRoomKit login failed code = " + code + ", msg = " + msg);
                }
              }
            });
  }

  public interface LoginVoiceRoomCallback {
    void onSuccess();

    void onError(int errorCode, String errorMsg);
  }
}
