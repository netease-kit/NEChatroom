// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.voiceroomkit.ui.base.service;

import android.text.TextUtils;
import com.netease.yunxin.kit.alog.ALog;
import com.netease.yunxin.kit.voiceroomkit.api.NEVoiceRoomKit;
import com.netease.yunxin.kit.voiceroomkit.api.NEVoiceRoomListenerAdapter;
import com.netease.yunxin.kit.voiceroomkit.api.model.NEVoiceRoomCreateAudioEffectOption;
import com.netease.yunxin.kit.voiceroomkit.api.model.NEVoiceRoomRtcAudioStreamType;

/** 音乐播放控制管理类 */
public class SongPlayManager {
  public static final int EFFECT_ID = 1000;
  private static final String TAG = "SongPlayManager";
  private int volume = 100;
  private boolean isPlaying = true;
  private String playingFilePath;

  private final NEVoiceRoomListenerAdapter roomListener =
      new NEVoiceRoomListenerAdapter() {

        @Override
        public void onAudioEffectFinished(int effectId) {
          ALog.i(TAG, "onAudioEffectFinished effectId = " + effectId);
          if (effectId == EFFECT_ID) {
            isPlaying = false;
          }
        }
      };

  private SongPlayManager() {
    NEVoiceRoomKit.getInstance().addVoiceRoomListener(roomListener);
  }

  private static class Inner {
    private static final SongPlayManager sInstance = new SongPlayManager();
  }

  public static SongPlayManager getInstance() {
    return Inner.sInstance;
  }

  public void start(String filePath, long position) {
    ALog.i(TAG, "start,filePath:" + filePath + ",position:" + position);

    if (isPlaying && TextUtils.equals(playingFilePath, filePath)) {
      ALog.i(TAG, "the song is playing filePath = " + filePath);
      return;
    }

    NEVoiceRoomCreateAudioEffectOption option =
        new NEVoiceRoomCreateAudioEffectOption(
            filePath,
            1,
            true,
            volume,
            true,
            volume,
            0,
            100,
            NEVoiceRoomRtcAudioStreamType.NERtcAudioStreamTypeMain);
    NEVoiceRoomKit.getInstance().playEffect(EFFECT_ID, option);
    isPlaying = true;
    playingFilePath = filePath;
  }

  public void pause() {
    ALog.i(TAG, "pause");
    NEVoiceRoomKit.getInstance().pauseEffect(EFFECT_ID);
    isPlaying = false;
  }

  public void resume() {
    ALog.i(TAG, "resume");
    NEVoiceRoomKit.getInstance().resumeEffect(EFFECT_ID);
    isPlaying = true;
  }

  public void stop() {
    ALog.i(TAG, "stop");
    NEVoiceRoomKit.getInstance().stopEffect(EFFECT_ID);
    isPlaying = false;
    playingFilePath = null;
  }

  public boolean isPlaying() {
    return isPlaying;
  }

  public void setVolume(int volume) {
    ALog.i(TAG, "setVolume,volume:" + volume);
    this.volume = volume;
    NEVoiceRoomKit.getInstance().setEffectVolume(EFFECT_ID, volume);
  }

  public int getVolume() {
    return volume;
  }
}
