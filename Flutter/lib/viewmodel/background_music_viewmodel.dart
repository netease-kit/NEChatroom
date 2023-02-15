// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:netease_voiceroomkit/netease_voiceroomkit.dart';
import 'package:voiceroomkit_ui/utils/audio_helper.dart';
import 'package:voiceroomkit_ui/utils/voiceroomkit_log.dart';

/// 背景音乐数据
class BackgroundMusicViewModel extends ChangeNotifier {
  final tag = "BackgroundMusicViewModel";
  final musicItem = <_MusicItem>[];
  final effectItem = <String>[];
  AudioMaxing audioMaxing = AudioMaxing();
  late NEVoiceRoomEventCallback _musicListener;

  BackgroundMusicViewModel() {
    _init();
    _addMusicListener();
  }

  void _init() {
    audioMaxing.volume = NEVoiceRoomKit.instance.getAudioMixingVolume();
    effectItem.add(AudioHelper().effectPath1);
    effectItem.add(AudioHelper().effectPath2);
    musicItem.add(_MusicItem(
        name: "name1", singer: "singer1", path: AudioHelper().musicPath1));
    musicItem.add(_MusicItem(
        name: "name2", singer: "singer2", path: AudioHelper().musicPath2));
    musicItem.add(_MusicItem(
        name: "name3", singer: "singer3", path: AudioHelper().musicPath3));
    _musicListener = NEVoiceRoomEventCallback(
      audioMixingStateChangedCallback: (int reason) {
        if (reason == 0) {
          nextSong();
        }
      },
    );
  }

  bool isMusicPaused() {
    return audioMaxing.state == AudioMixingPlayState.paused;
  }

  bool isMusicPlaying() {
    return audioMaxing.state == AudioMixingPlayState.playing;
  }

  /// 播放音效
  playEffect(int index) async {
    var stopEffectRet =
        await NEVoiceRoomKit.instance.stopEffect(_effectIndexToEffectId(index));
    VoiceRoomKitLog.i(tag,
        "stopEffect, code:${stopEffectRet.code}, message:${stopEffectRet.msg}");
    var playEffectRet = await NEVoiceRoomKit.instance.playEffect(
        _effectIndexToEffectId(index),
        NEVoiceRoomCreateAudioEffectOption(
          effectItem[index],
          1,
          true,
          audioMaxing.volume,
          true,
          audioMaxing.volume,
        ));
    VoiceRoomKitLog.i(tag,
        "playEffect, code:${playEffectRet.code}, message:${playEffectRet.msg}");
  }

  /// 播放歌曲
  playAudioMixing(int index) async {
    if (audioMaxing.musicSelectedIndex != -1) {
      await stopAudioMixing();
    }
    audioMaxing.musicSelectedIndex = index;
    await _playSong();
    _notifyMusicUIChanged();
  }

  /// 暂停音乐
  pauseAudioMixing() async {
    audioMaxing.state = AudioMixingPlayState.paused;
    var ret = await NEVoiceRoomKit.instance.pauseAudioMixing();
    VoiceRoomKitLog.i(
        tag, "pauseAudioMixing, code:${ret.code}, message:${ret.msg}");
    _notifyMusicUIChanged();
  }

  /// 恢复播放音乐
  resumeAudioMixing() async {
    audioMaxing.state = AudioMixingPlayState.playing;
    var ret = await NEVoiceRoomKit.instance.resumeAudioMixing();
    VoiceRoomKitLog.i(
        tag, "resumeAudioMixing, code:${ret.code}, message:${ret.msg}");
    _notifyMusicUIChanged();
  }

  /// 停止音乐
  stopAudioMixing() async {
    audioMaxing.state = AudioMixingPlayState.none;
    var ret = await NEVoiceRoomKit.instance.stopAudioMixing();
    VoiceRoomKitLog.i(
        tag, "stopAudioMixing, code:${ret.code}, message:${ret.msg}");
    _notifyMusicUIChanged();
  }

  /// 设置音量
  setVolume(int value) async {
    audioMaxing.volume = value;
    for (var index = 0; index < effectItem.length; index++) {
      var ret = await NEVoiceRoomKit.instance
          .setEffectVolume(_effectIndexToEffectId(index), value);
      VoiceRoomKitLog.i(
          tag, "setEffectVolume, code:${ret.code}, message:${ret.msg}");
    }
    var ret = await NEVoiceRoomKit.instance.setAudioMixingVolume(value);
    VoiceRoomKitLog.i(
        tag, "setAudioMixingVolume, code:${ret.code}, message:${ret.msg}");
    _notifyMusicUIChanged();
  }

  int _effectIndexToEffectId(int index) {
    return index + 1; // effect id starts from one
  }

  void _addMusicListener() {
    VoiceRoomKitLog.i(tag, "addVoiceRoomListener");
    NEVoiceRoomKit.instance.addVoiceRoomListener(_musicListener);
  }

  /// 播放下一首背景音乐
  nextSong() async {
    VoiceRoomKitLog.i(tag, "nextSong");
    await stopAudioMixing();
    audioMaxing.musicSelectedIndex++;
    audioMaxing.musicSelectedIndex %= musicItem.length;
    await _playSong();
    _notifyMusicUIChanged();
  }

  /// 播放背景音乐
  _playSong() async {
    audioMaxing.state = AudioMixingPlayState.playing;
    var ret = await NEVoiceRoomKit.instance
        .startAudioMixing(NEVoiceRoomCreateAudioMixingOption(
      musicItem[audioMaxing.musicSelectedIndex].path,
      1,
      true,
      audioMaxing.volume,
      true,
      audioMaxing.volume,
    ));
    VoiceRoomKitLog.i(
        tag, "startAudioMixing, code:${ret.code}, message:${ret.msg}");
  }

  /// 通知刷新界面
  void _notifyMusicUIChanged() {
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
    NEVoiceRoomKit.instance.removeVoiceRoomListener(_musicListener);
  }
}

class _MusicItem {
  final String name;
  final String singer;
  final String path;

  _MusicItem({required this.name, required this.singer, required this.path});
}

class AudioMaxing {
  int musicSelectedIndex = -1;
  int volume = 100;
  AudioMixingPlayState state = AudioMixingPlayState.none;
}

enum AudioMixingPlayState {
  /// 停止，未播放
  none,

  /// 播放中
  playing,

  /// 暂停
  paused,
}
