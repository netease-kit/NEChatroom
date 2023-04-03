// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of netease_voiceroomkit;

/// 房间信息
/// @property anchor 主播信息
/// @property liveModel 直播模式
/// @constructor
class NEVoiceRoomInfo {
  NEVoiceRoomAnchor? anchor;
  NEVoiceRoomLiveModel? liveModel;

  NEVoiceRoomInfo(this.anchor, this.liveModel);

  NEVoiceRoomInfo.fromJson(Map? json) {
    anchor = NEVoiceRoomAnchor.fromJson(json?['anchor'] as Map?);
    liveModel = NEVoiceRoomLiveModel.fromJson(json?['live'] as Map?);
  }

  Map<String, dynamic> toJson() => {
        'anchor': anchor?.toJson(),
        'liveModel': liveModel?.toJson(),
      };

  @override
  String toString() {
    return 'NEVoiceRoomInfo{anchor: $anchor, liveModel: $liveModel}';
  }
}
