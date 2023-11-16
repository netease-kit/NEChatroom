// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.kit.voiceroomkit.ui.base.helper;

import static com.netease.yunxin.kit.voiceroomkit.ui.base.helper.EffectPlayHelper.AudioMixingPlayState.STATE_STOPPED;

import android.content.Context;
import android.media.MediaMetadataRetriever;
import android.text.TextUtils;
import androidx.annotation.NonNull;
import com.netease.yunxin.kit.alog.ALog;
import com.netease.yunxin.kit.entertainment.common.utils.CommonUtil;
import com.netease.yunxin.kit.voiceroomkit.api.NEVoiceRoomKit;
import com.netease.yunxin.kit.voiceroomkit.api.NEVoiceRoomListenerAdapter;
import com.netease.yunxin.kit.voiceroomkit.api.model.NEVoiceRoomCreateAudioEffectOption;
import com.netease.yunxin.kit.voiceroomkit.api.model.NEVoiceRoomRtcAudioStreamType;
import java.io.File;

public class EffectPlayHelper extends NEVoiceRoomListenerAdapter {

  public static final String TAG = "AudioPlayHelper";

  /** 音效文件 */
  private String[] effectPaths;

  /** 音效音量 */
  private int effectVolume = 100;

  /** 混音音量 */
  private int audioMixingVolume = 50;

  /** 当前混音 */
  private int audioMixingIndex = 0;

  /** 混音播放状态 */
  private int audioMixingState = STATE_STOPPED;

  /** 采集音量，默认100 */
  private int audioCaptureVolume = 100;

  private IPlayCallback callBack;

  private Context context;

  private static final String MUSIC_DIR = "music";
  private static final String EFFECT1 = "effect1.wav";
  private static final String EFFECT2 = "effect2.wav";

  public EffectPlayHelper(Context context) {
    this.context = context;
    NEVoiceRoomKit.getInstance().addVoiceRoomListener(this);
  }

  private String extractMusicFile(String path, String name) {
    CommonUtil.copyAssetToFile(context, MUSIC_DIR + "/" + name, path, name);
    return new File(path, name).getAbsolutePath();
  }

  private String ensureMusicDirectory() {
    File dir = context.getExternalFilesDir(MUSIC_DIR);
    if (dir == null) {
      dir = context.getDir(MUSIC_DIR, 0);
    }
    if (dir != null) {
      dir.mkdirs();
      return dir.getAbsolutePath();
    }
    return "";
  }

  public void checkMusicFiles() {
    new Thread(
            () -> {
              String root = ensureMusicDirectory();

              String[] effectPaths = new String[2];
              effectPaths[0] = extractMusicFile(root, EFFECT1);
              effectPaths[1] = extractMusicFile(root, EFFECT2);
              setEffectPaths(effectPaths);
            })
        .start();
  }

  /**
   * 获取音乐文件信息
   *
   * @param mediaUri 文件路径
   */
  private MusicItem getMusicInfo(String order, String mediaUri) {
    MediaMetadataRetriever mediaMetadataRetriever = new MediaMetadataRetriever();
    mediaMetadataRetriever.setDataSource(mediaUri);
    String name = mediaMetadataRetriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_TITLE);
    String author =
        mediaMetadataRetriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_ARTIST);
    return new MusicItem(order, name, author);
  }

  public void setCallBack(IPlayCallback callBack) {
    this.callBack = callBack;
  }

  public void setEffectPaths(String[] effectPaths) {
    this.effectPaths = effectPaths;
  }

  public void setEffectVolume(int effectVolume) {
    this.effectVolume = effectVolume;
    for (int index = 0; index < effectPaths.length; index++) {
      int effectId = effectIndexToEffectId(index);
      NEVoiceRoomKit.getInstance().setEffectVolume(effectId, effectVolume);
    }
  }

  public int getEffectVolume() {
    return effectVolume;
  }

  public int getAudioMixingVolume() {
    return audioMixingVolume;
  }

  public int getCurrentState() {
    return audioMixingState;
  }

  public int getPlayingMixIndex() {
    return audioMixingIndex;
  }

  public void setAudioCaptureVolume(int volume) {
    audioCaptureVolume = volume;
    NEVoiceRoomKit.getInstance().adjustRecordingSignalVolume(volume);
  }

  public int getAudioCaptureVolume() {
    return audioCaptureVolume;
  }

  // 播放音效
  public void playEffect(int index) {
    if (effectPaths == null) {
      ALog.e(TAG, "effectPaths is null");
      return;
    }
    if (index < effectPaths.length && index >= 0) {
      String path = effectPaths[index];
      int effectId = effectIndexToEffectId(index);
      NEVoiceRoomCreateAudioEffectOption option =
          new NEVoiceRoomCreateAudioEffectOption(
              path,
              1,
              true,
              effectVolume,
              true,
              effectVolume,
              0,
              100,
              NEVoiceRoomRtcAudioStreamType.NERtcAudioStreamTypeMain);
      NEVoiceRoomKit.getInstance().stopEffect(effectId);
      NEVoiceRoomKit.getInstance().playEffect(effectId, option);
    }
  }

  private int getNextAudioMixingIndex(int index, @NonNull String[] paths) {
    do {
      index = (index + 1) % paths.length;
    } while (isAudioMixingIndexInvalid(index, paths));
    return index;
  }

  private boolean isAudioMixingIndexInvalid(int index, @NonNull String[] paths) {
    return index < 0 || index >= paths.length || TextUtils.isEmpty(paths[index]);
  }

  // 暂停伴音
  public int pauseAudioMixing() {
    return NEVoiceRoomKit.getInstance().pauseAudioMixing();
  }

  public void stopAudioMixing() {
    NEVoiceRoomKit.getInstance().stopAudioMixing();
    audioMixingState = STATE_STOPPED;
    notifyAudioMixingState();
  }

  private void notifyAudioMixingState() {
    if (callBack != null) {
      callBack.onAudioMixingPlayState(audioMixingState, audioMixingIndex);
    }
  }

  @Override
  public void onAudioMixingStateChanged(int reason) {
    if (reason == 0) {
      audioMixingState = STATE_STOPPED;
      callBack.onAudioMixingPlayFinish();
    } else {
      callBack.onAudioMixingPlayError();
    }
  }

  public void destroy() {
    stopAudioMixing();
    NEVoiceRoomKit.getInstance().removeVoiceRoomListener(this);
  }

  private int effectIndexToEffectId(int index) {
    return index + 1; // effect id starts from one
  }

  /** 伴音播放状态 */
  public interface AudioMixingPlayState {
    /** 停止，未播放 */
    int STATE_STOPPED = 0;

    /** 播放中 */
    int STATE_PLAYING = 1;

    /** 暂停 */
    int STATE_PAUSED = 2;
  }

  public interface IPlayCallback {
    /** 伴音播放错误 */
    void onAudioMixingPlayError();

    /**
     * 伴音播放状态
     *
     * @param state {@link AudioMixingPlayState}
     * @param index 伴音文件索引
     */
    void onAudioMixingPlayState(int state, int index);

    /** 伴音播放完成 */
    void onAudioMixingPlayFinish();
  }

  public static class MusicItem {
    private final String order;
    private final String name;
    private final String singer;

    public MusicItem(String order, String name, String singer) {
      this.order = order;
      this.name = name;
      this.singer = singer;
    }

    @Override
    public boolean equals(Object o) {
      if (this == o) return true;
      if (o == null || getClass() != o.getClass()) return false;

      MusicItem musicItem = (MusicItem) o;

      if (!order.equals(musicItem.order)) return false;
      if (!name.equals(musicItem.name)) return false;
      return singer.equals(musicItem.singer);
    }

    @Override
    public int hashCode() {
      int result = order.hashCode();
      result = 31 * result + name.hashCode();
      result = 31 * result + singer.hashCode();
      return result;
    }
  }
}
