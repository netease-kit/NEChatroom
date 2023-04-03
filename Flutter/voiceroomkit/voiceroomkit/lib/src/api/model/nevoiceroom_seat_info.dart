// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of netease_voiceroomkit;

/// 麦位信息。
/// @property creator 麦位创建者。
/// @property managers 管理员列表。
/// @property seatItems 麦位列表信息。
class NEVoiceRoomSeatInfo {
  final String creator;
  final List<String> managers;
  final List<NEVoiceRoomSeatItem> seatItems;

  NEVoiceRoomSeatInfo(this.creator, this.managers, this.seatItems);

  Map<String, dynamic> toJson() => {
        'creator': creator,
        'managers': managers,
        'seatItems': seatItems,
      };

  @override
  String toString() {
    return 'NEVoiceRoomSeatInfo{creator: $creator, managers: $managers, seatItems: $seatItems}';
  }
}
