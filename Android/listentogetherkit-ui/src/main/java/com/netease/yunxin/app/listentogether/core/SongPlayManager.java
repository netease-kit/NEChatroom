// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.app.listentogether.core;

import com.netease.yunxin.app.listentogether.core.constant.ListenTogetherConstant;
import com.netease.yunxin.kit.alog.ALog;
import com.netease.yunxin.kit.listentogetherkit.api.NEListenTogetherKit;
import com.netease.yunxin.kit.listentogetherkit.api.model.NEListenTogetherRoomCreateAudioEffectOption;
import com.netease.yunxin.kit.listentogetherkit.api.model.NEListenTogetherRoomRtcAudioStreamType;

/** 音乐播放控制管理类 */
public class SongPlayManager {
  private static final int EFFECT_ID = ListenTogetherConstant.EFFECT_ID;
  private static final String TAG = "SongPlayManager";
  private boolean isPlaying = true;

  private static class Inner {
    private static final SongPlayManager sInstance = new SongPlayManager();
  }

  public static SongPlayManager getInstance() {
    return Inner.sInstance;
  }

  public void start(String filePath, long position) {
    ALog.i(TAG, "start,filePath:" + filePath + ",position:" + position);
    NEListenTogetherRoomCreateAudioEffectOption option =
        new NEListenTogetherRoomCreateAudioEffectOption(
            filePath,
            1,
            false,
            0,
            true,
            100,
            position,
            ListenTogetherConstant.PROGRESS_INTERVAL,
            NEListenTogetherRoomRtcAudioStreamType.NERtcAudioStreamTypeSub);
    NEListenTogetherKit.getInstance().playEffect(EFFECT_ID, option);
    isPlaying = true;
  }

  public void pause() {
    ALog.i(TAG, "pause");
    NEListenTogetherKit.getInstance().pauseEffect(EFFECT_ID);
    isPlaying = false;
  }

  public void resume() {
    ALog.i(TAG, "resume");
    NEListenTogetherKit.getInstance().resumeEffect(EFFECT_ID);
    isPlaying = true;
  }

  public void stop() {
    ALog.i(TAG, "stop");
    NEListenTogetherKit.getInstance().stopEffect(EFFECT_ID);
    isPlaying = false;
  }

  public boolean isPlaying() {
    return isPlaying;
  }

  public void setVolume(int volume) {
    ALog.i(TAG, "setVolume,volume:" + volume);
    NEListenTogetherKit.getInstance().setEffectVolume(EFFECT_ID, volume);
  }
}
