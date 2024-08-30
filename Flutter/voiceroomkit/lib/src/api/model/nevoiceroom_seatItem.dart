// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of netease_voiceroomkit;

/// 单个麦位信息。
/// @property index 麦位位置。
/// @property status 麦位状态，参考[NEVoiceRoomSeatItemStatus]。
/// @property onSeatType 上麦类型，参考[NEVoiceRoomOnSeatType]。
/// @property user 当前状态关联的用户。
/// @property updated 更新时间戳，单位ms。
class NEVoiceRoomSeatItem {
  final int index;
  final int status;
  final String user;
  final String? userName;
  final String? icon;
  final int onSeatType;
  final int updated;

  NEVoiceRoomSeatItem(this.index, this.status, this.user, this.userName,
      this.icon, this.onSeatType, this.updated);

  @override
  String toString() {
    return 'NEVoiceRoomSeatItem{index: $index, status: $status, user: $user, userName: $userName, icon: $icon, onSeatType: $onSeatType, updated: $updated}';
  }

  Map<String, dynamic> toJson() => {
        'index': index,
        'status': status,
        'user': user,
        'userName': userName,
        'icon': icon,
        'onSeatType': onSeatType,
        'updated': updated,
      };
}
