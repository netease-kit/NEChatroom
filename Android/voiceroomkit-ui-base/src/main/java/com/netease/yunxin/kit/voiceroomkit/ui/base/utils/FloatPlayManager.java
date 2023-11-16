// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.voiceroomkit.ui.base.utils;

import android.content.Context;
import android.content.Intent;
import android.widget.FrameLayout;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import com.netease.yunxin.kit.alog.ALog;
import com.netease.yunxin.kit.common.ui.utils.ToastUtils;
import com.netease.yunxin.kit.common.utils.NetworkUtils;
import com.netease.yunxin.kit.common.utils.ScreenUtils;
import com.netease.yunxin.kit.common.utils.SizeUtils;
import com.netease.yunxin.kit.entertainment.common.R;
import com.netease.yunxin.kit.entertainment.common.floatplay.FloatPlayLayout;
import com.netease.yunxin.kit.entertainment.common.floatplay.FloatView;
import com.netease.yunxin.kit.entertainment.common.model.RoomModel;
import com.netease.yunxin.kit.entertainment.common.utils.Utils;
import com.netease.yunxin.kit.entertainment.common.utils.VoiceRoomUtils;
import com.netease.yunxin.kit.voiceroomkit.api.NEVoiceRoomCallback;
import com.netease.yunxin.kit.voiceroomkit.api.NEVoiceRoomEndReason;
import com.netease.yunxin.kit.voiceroomkit.api.NEVoiceRoomKit;
import com.netease.yunxin.kit.voiceroomkit.api.NEVoiceRoomListenerAdapter;
import com.netease.yunxin.kit.voiceroomkit.ui.base.activity.VoiceRoomBaseActivity;
import com.netease.yunxin.kit.voiceroomkit.ui.base.service.SongPlayManager;
import kotlin.Unit;

public class FloatPlayManager {
  private static final String TAG = "FloatPlayManager";
  private boolean mIsShowing = false;
  private FloatPlayLayout floatPlayLayout;
  private FloatView floatView;
  private static final int WIDTH = SizeUtils.dp2px(98);
  private static final int HEIGHT = SizeUtils.dp2px(132);
  private RoomModel voiceRoomInfo;
  private final NEVoiceRoomListenerAdapter roomListener =
      new NEVoiceRoomListenerAdapter() {
        @Override
        public void onRoomEnded(@NonNull NEVoiceRoomEndReason endReason) {
          if (endReason == NEVoiceRoomEndReason.CLOSE_BY_MEMBER) {
            if (!VoiceRoomUtils.isLocalAnchor()) {
              ToastUtils.INSTANCE.showShortToast(
                  Utils.getApp(), Utils.getApp().getString(R.string.voiceroom_is_closed));
            }
            stopFloatPlay();
          } else if (endReason == NEVoiceRoomEndReason.END_OF_RTC) {
            release();
          } else {
            stopFloatPlay();
            VoiceRoomBaseActivity.charSequenceList.clear();
          }
        }
      };

  private static class Inner {
    private static final FloatPlayManager sInstance = new FloatPlayManager();
  }

  public static FloatPlayManager getInstance() {
    return Inner.sInstance;
  }

  public void startFloatPlay(Context context, RoomModel voiceRoomInfo, Intent intent) {
    this.voiceRoomInfo = voiceRoomInfo;
    Context appContext = context.getApplicationContext();
    floatPlayLayout = new FloatPlayLayout(appContext);
    floatPlayLayout.setAvatar(voiceRoomInfo.getAnchorAvatar());
    floatPlayLayout.setCloseCallback(
        () -> {
          release();
        });
    floatView = new FloatView(context.getApplicationContext());
    floatView.setLayoutParams(new FrameLayout.LayoutParams(WIDTH, HEIGHT));
    floatView.addView(floatPlayLayout);
    floatView.addToWindow();
    floatView.setOnFloatViewClickListener(
        () -> {
          if (!NetworkUtils.isConnected()) {
            ToastUtils.INSTANCE.showShortToast(
                context, context.getString(R.string.common_network_error));
            return;
          }
          stopFloatPlay();
          context.startActivity(intent);
        });
    floatView.update(
        WIDTH,
        HEIGHT,
        ScreenUtils.getDisplayWidth() - WIDTH,
        ScreenUtils.getDisplayHeight() - SizeUtils.dp2px(240) - HEIGHT);
    mIsShowing = true;
    NEVoiceRoomKit.getInstance().addVoiceRoomListener(roomListener);
  }

  public void stopFloatPlay() {
    if (floatView != null) {
      floatView.removeFromWindow();
    }
    mIsShowing = false;
    floatView = null;
    floatPlayLayout = null;
    voiceRoomInfo = null;
    NEVoiceRoomKit.getInstance().removeVoiceRoomListener(roomListener);
  }

  public void release() {
    if (VoiceRoomUtils.isLocalAnchor()) {
      NEVoiceRoomKit.getInstance()
          .endRoom(
              new NEVoiceRoomCallback<Unit>() {
                @Override
                public void onSuccess(@Nullable Unit unit) {
                  ToastUtils.INSTANCE.showShortToast(
                      Utils.getApp(),
                      Utils.getApp().getString(R.string.voiceroom_host_close_room_success));
                }

                @Override
                public void onFailure(int code, @Nullable String msg) {
                  ALog.e(TAG, "endRoom failed code:" + code + ",msg:" + msg);
                }
              });
    } else {
      NEVoiceRoomKit.getInstance()
          .leaveRoom(
              new NEVoiceRoomCallback<Unit>() {
                @Override
                public void onSuccess(@Nullable Unit unit) {}

                @Override
                public void onFailure(int code, @Nullable String msg) {
                  ALog.e(TAG, "leaveRoom failed code:" + code + ",msg:" + msg);
                }
              });
    }

    stopFloatPlay();
    SongPlayManager.getInstance().stop();
    VoiceRoomBaseActivity.charSequenceList.clear();
  }

  public boolean isShowFloatView() {
    return mIsShowing;
  }

  public RoomModel getVoiceRoomInfo() {
    return voiceRoomInfo;
  }
}
