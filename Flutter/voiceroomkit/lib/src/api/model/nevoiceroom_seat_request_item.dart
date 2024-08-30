// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of netease_voiceroomkit;

/// 成员麦位申请信息。
/// @property index 麦位位置。如果为**-1**，表示未指定位置。
/// @property user 申请人。
/// @property userName 用户名。
/// @property user 用户头像。
class NEVoiceRoomSeatRequestItem {
  final int index;
  final String user;
  final String? userName;
  final String? icon;

  NEVoiceRoomSeatRequestItem(this.index, this.user, this.userName, this.icon);

  Map<String, dynamic> toJson() => {
        'index': index,
        'user': user,
        'userName': userName,
        'icon': icon,
      };
}
