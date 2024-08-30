// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of netease_voiceroomkit;

/// @property topic 随机直播主题
/// @property livePicture 直播房间背景
class NEVoiceCreateRoomDefaultInfo {
  String? topic;
  String? livePicture;

  NEVoiceCreateRoomDefaultInfo(this.topic, this.livePicture);
  NEVoiceCreateRoomDefaultInfo.fromJson(Map? json) {
    topic = json?['topic'] as String?;
    livePicture = json?['livePicture'] as String?;
  }

  @override
  String toString() {
    return 'NEVoiceCreateRoomDefaultInfo{topic: $topic, livePicture: $livePicture}';
  }
}
