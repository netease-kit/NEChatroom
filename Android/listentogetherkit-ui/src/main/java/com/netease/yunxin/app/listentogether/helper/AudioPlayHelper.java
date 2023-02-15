// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

package com.netease.yunxin.app.listentogether.helper;

import static com.netease.yunxin.app.listentogether.helper.AudioPlayHelper.AudioMixingPlayState.STATE_PAUSED;
import static com.netease.yunxin.app.listentogether.helper.AudioPlayHelper.AudioMixingPlayState.STATE_PLAYING;
import static com.netease.yunxin.app.listentogether.helper.AudioPlayHelper.AudioMixingPlayState.STATE_STOPPED;

import android.content.Context;
import android.media.MediaMetadataRetriever;
import android.text.TextUtils;
import androidx.annotation.NonNull;
import com.netease.yunxin.app.listentogether.dialog.ChatRoomAudioDialog;
import com.netease.yunxin.app.listentogether.utils.CommonUtil;
import com.netease.yunxin.kit.alog.ALog;
import com.netease.yunxin.kit.listentogetherkit.api.NEListenTogetherKit;
import com.netease.yunxin.kit.listentogetherkit.api.NEListenTogetherRoomListenerAdapter;
import com.netease.yunxin.kit.listentogetherkit.api.model.NEListenTogetherRoomCreateAudioEffectOption;
import com.netease.yunxin.kit.listentogetherkit.api.model.NEListenTogetherRoomCreateAudioMixingOption;
import com.netease.yunxin.kit.listentogetherkit.api.model.NEListenTogetherRoomRtcAudioStreamType;
import java.io.File;
import java.util.ArrayList;
import java.util.List;

public class AudioPlayHelper extends NEListenTogetherRoomListenerAdapter {

  public static final String TAG = "AudioPlayHelper";

  /** 音效文件 */
  private String[] effectPaths;

  /** 混音文件 */
  private String[] audioMixingFilePaths;
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
  private static final String MUSIC1 = "music1.mp3";
  private static final String MUSIC2 = "music2.mp3";
  private static final String MUSIC3 = "music3.mp3";
  private static final String EFFECT1 = "effect1.wav";
  private static final String EFFECT2 = "effect2.wav";
  private List<ChatRoomAudioDialog.MusicItem> audioMixingMusicInfos;

  public AudioPlayHelper(Context context) {
    this.context = context;
    NEListenTogetherKit.getInstance().addRoomListener(this);
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

              String[] musicPaths = new String[4];
              musicPaths[0] = extractMusicFile(root, MUSIC1);
              musicPaths[1] = extractMusicFile(root, MUSIC2);
              musicPaths[2] = extractMusicFile(root, MUSIC3);

              setAudioMixingFilePaths(musicPaths);
              if (audioMixingMusicInfos == null) {
                audioMixingMusicInfos = new ArrayList<>();
              }
              audioMixingMusicInfos.clear();
              for (int i = 0; i < musicPaths.length - 1; i++) {
                String path = musicPaths[i];
                audioMixingMusicInfos.add(getMusicInfo("0" + (i + 1), path));
              }
            })
        .start();
  }

  /**
   * 获取音乐文件信息
   *
   * @param mediaUri 文件路径
   */
  private ChatRoomAudioDialog.MusicItem getMusicInfo(String order, String mediaUri) {
    MediaMetadataRetriever mediaMetadataRetriever = new MediaMetadataRetriever();
    mediaMetadataRetriever.setDataSource(mediaUri);
    String name = mediaMetadataRetriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_TITLE);
    String author =
        mediaMetadataRetriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_ARTIST);
    return new ChatRoomAudioDialog.MusicItem(order, name, author);
  }

  public List<ChatRoomAudioDialog.MusicItem> getAudioMixingMusicInfos() {
    return audioMixingMusicInfos;
  }

  public void setCallBack(IPlayCallback callBack) {
    this.callBack = callBack;
  }

  public void setEffectPaths(String[] effectPaths) {
    this.effectPaths = effectPaths;
  }

  public void setAudioMixingFilePaths(String[] audioMixingFilePaths) {
    this.audioMixingFilePaths = audioMixingFilePaths;
  }

  public void setEffectVolume(int effectVolume) {
    this.effectVolume = effectVolume;
    for (int index = 0; index < effectPaths.length; index++) {
      int effectId = effectIndexToEffectId(index);
      NEListenTogetherKit.getInstance().setEffectVolume(effectId, effectVolume);
    }
  }

  public void setAudioMixingVolume(int audioMixingVolume) {
    this.audioMixingVolume = audioMixingVolume;
    for (int index = 0; index < audioMixingFilePaths.length; index++) {
      NEListenTogetherKit.getInstance().setAudioMixingVolume(audioMixingVolume);
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
    NEListenTogetherKit.getInstance().adjustRecordingSignalVolume(volume);
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
      NEListenTogetherRoomCreateAudioEffectOption option =
          new NEListenTogetherRoomCreateAudioEffectOption(
              path,
              1,
              true,
              effectVolume,
              true,
              effectVolume,
              0,
              100,
              NEListenTogetherRoomRtcAudioStreamType.NERtcAudioStreamTypeMain);
      NEListenTogetherKit.getInstance().stopEffect(effectId);
      NEListenTogetherKit.getInstance().playEffect(effectId, option);
    }
  }

  public void stopAllEffect() {
    NEListenTogetherKit.getInstance().stopAllEffect();
  }

  // 播放伴音
  public boolean playAudioMixing(int index) {
    if (isAudioMixingIndexInvalid(index, audioMixingFilePaths)) {
      return false;
    }
    stopAudioMixing();
    audioMixingIndex = index;
    return shiftPlayState();
  }

  public boolean playNextMixing() {
    stopAudioMixing();
    audioMixingIndex = getNextAudioMixingIndex(audioMixingIndex, audioMixingFilePaths);
    return shiftPlayState();
  }

  private int getNextAudioMixingIndex(int index, @NonNull String[] paths) {
    do {
      index = (index + 1) % paths.length;
    } while (isAudioMixingIndexInvalid(index, paths));
    return index;
  }

  public boolean playOrPauseMixing() {
    return shiftPlayState();
  }

  private boolean isAudioMixingIndexInvalid(int index, @NonNull String[] paths) {
    return index < 0 || index >= paths.length || TextUtils.isEmpty(paths[index]);
  }

  // 暂停伴音
  public int pauseAudioMixing() {
    return NEListenTogetherKit.getInstance().pauseAudioMixing();
  }

  public void stopAudioMixing() {
    NEListenTogetherKit.getInstance().stopAudioMixing();
    audioMixingState = STATE_STOPPED;
    notifyAudioMixingState();
  }

  private void notifyAudioMixingState() {
    if (callBack != null) {
      callBack.onAudioMixingPlayState(audioMixingState, audioMixingIndex);
    }
  }

  // 恢复伴音
  public int resumeAudioMixing() {
    return NEListenTogetherKit.getInstance().resumeAudioMixing();
  }

  /** STATE_PLAYING -> STATE_PAUSED STATE_PAUSED -> STATE_PLAYING STATE_STOPPED -> STATE_PLAYING */
  private boolean shiftPlayState() {
    int stateOld = audioMixingState;
    int stateNew;
    int result;
    if (stateOld == STATE_PLAYING) {
      stateNew = STATE_PAUSED;
      result = pauseAudioMixing();
    } else if (stateOld == STATE_PAUSED) {
      stateNew = STATE_PLAYING;
      result = resumeAudioMixing();
    } else {
      stateNew = STATE_PLAYING;
      String path = audioMixingFilePaths[audioMixingIndex];
      NEListenTogetherRoomCreateAudioMixingOption option =
          new NEListenTogetherRoomCreateAudioMixingOption(
              path, 1, true, audioMixingVolume, true, audioMixingVolume);
      result = NEListenTogetherKit.getInstance().startAudioMixing(option);
    }
    if (result == 0) {
      audioMixingState = stateNew;
      notifyAudioMixingState();
    }
    return result == 0;
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
    stopAllEffect();
    stopAudioMixing();
    NEListenTogetherKit.getInstance().removeRoomListener(this);
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
}
