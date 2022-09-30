// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.app.voiceroom.utils;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import com.netease.yunxin.app.voiceroom.Constants;
import com.netease.yunxin.app.voiceroom.main.MainActivity;
import com.netease.yunxin.app.voiceroom.main.SplashActivity;
import com.netease.yunxin.app.voiceroom.main.WebViewActivity;
import com.netease.yunxin.app.voiceroom.user.AppAboutActivity;
import com.netease.yunxin.app.voiceroom.user.EditUserInfoActivity;
import com.netease.yunxin.app.voiceroom.user.UserInfoActivity;
import com.netease.yunxin.kit.login.AuthorManager;
import com.netease.yunxin.kit.voiceroomkit.api.model.NEVoiceRoomInfo;
import com.netease.yunxin.kit.voiceroomkit.ui.NEVoiceRoomUIConstants;
import com.netease.yunxin.kit.voiceroomkit.ui.activity.AnchorActivity;
import com.netease.yunxin.kit.voiceroomkit.ui.activity.AudienceActivity;
import com.netease.yunxin.kit.voiceroomkit.ui.model.VoiceRoomModel;

public class NavUtils {

  private static final String TAG = "NavUtil";

  public static void toSplash(Context context) {
    Intent intent = new Intent(context, SplashActivity.class);
    context.startActivity(intent);
  }

  public static void toMainPage(Context context) {
    Intent intent = new Intent(context, MainActivity.class);
    context.startActivity(intent);
  }

  public static void toBrowsePage(Context context, String title, String url) {
    Intent intent = new Intent(context, WebViewActivity.class);
    if (!(context instanceof Activity)) {
      intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
    }
    intent.putExtra(Constants.INTENT_KEY_TITLE, title);
    intent.putExtra(Constants.INTENT_KEY_URL, url);
    context.startActivity(intent);
  }

  public static void toUserInfoPage(Context context) {
    Intent intent = new Intent(context, UserInfoActivity.class);
    context.startActivity(intent);
  }

  public static void toAppAboutPage(Context context) {
    Intent intent = new Intent(context, AppAboutActivity.class);
    context.startActivity(intent);
  }

  public static void toEditUserInfoPage(Context context) {
    Intent intent = new Intent(context, EditUserInfoActivity.class);
    context.startActivity(intent);
  }

  public static void toVoiceRoomPage(Context context, NEVoiceRoomInfo roomInfo) {
    VoiceRoomModel roomModel = new VoiceRoomModel();
    roomModel.setLiveRecordId(roomInfo.getLiveModel().getLiveRecordId());
    roomModel.setRoomUuid(roomInfo.getLiveModel().getRoomUuid());
    roomModel.setRole(NEVoiceRoomUIConstants.ROLE_HOST);
    roomModel.setRoomName(roomInfo.getLiveModel().getLiveTopic());
    roomModel.setNick(AuthorManager.INSTANCE.getUserInfo().getNickname());
    roomModel.setAvatar(AuthorManager.INSTANCE.getUserInfo().getAvatar());
    Intent intent = new Intent(context, AnchorActivity.class);
    intent.putExtra(NEVoiceRoomUIConstants.INTENT_ROOM_MODEL, roomModel);
    context.startActivity(intent);
  }

  public static void toVoiceRoomAudiencePage(Context context, NEVoiceRoomInfo roomInfo) {
    VoiceRoomModel roomModel = new VoiceRoomModel();
    roomModel.setLiveRecordId(roomInfo.getLiveModel().getLiveRecordId());
    roomModel.setRoomUuid(roomInfo.getLiveModel().getRoomUuid());
    roomModel.setRole(NEVoiceRoomUIConstants.ROLE_AUDIENCE);
    roomModel.setRoomName(roomInfo.getLiveModel().getLiveTopic());
    roomModel.setNick(AuthorManager.INSTANCE.getUserInfo().getNickname());
    roomModel.setAvatar(AuthorManager.INSTANCE.getUserInfo().getAvatar());
    Intent intent = new Intent(context, AudienceActivity.class);
    intent.putExtra(NEVoiceRoomUIConstants.INTENT_ROOM_MODEL, roomModel);
    context.startActivity(intent);
  }
}