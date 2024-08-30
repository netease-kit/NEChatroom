// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of netease_voiceroomkit;

/// @property path 路径地址
/// @property loopCount 播放次数
/// @property sendEnabled 是否发送
/// @property sendVolume 发送音量
/// @property playbackEnabled 是否本地播放
/// @property playbackVolume 本地播放音量
///
class NEVoiceRoomCreateAudioMixingOption {
  final String path;
  final int loopCount;
  final bool sendEnabled;
  final int sendVolume;
  final bool playbackEnabled;
  final int playbackVolume;

  NEVoiceRoomCreateAudioMixingOption(
      this.path,
      this.loopCount,
      this.sendEnabled,
      this.sendVolume,
      this.playbackEnabled,
      this.playbackVolume);
}
