// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of netease_voiceroomkit;

/// 语聊房成员对象
class NEVoiceRoomMember {
  /// 用户id
  final String account;

  /// 用户名
  final String name;

  /// 用户角色
  final String role;

  /// 音频是否打开
  final bool isAudioOn;

  /// 音频是否被禁用
  final bool isAudioBanned;

  /// 头像
  final String? avatar;

  NEVoiceRoomMember(this.account, this.name, this.role, this.isAudioOn,
      this.isAudioBanned, this.avatar);

  @override
  String toString() {
    return 'NEVoiceRoomMember{account: $account, name: $name, role: $role, isAudioOn: $isAudioOn, isAudioBanned: $isAudioBanned, avatar: $avatar}';
  }
}
