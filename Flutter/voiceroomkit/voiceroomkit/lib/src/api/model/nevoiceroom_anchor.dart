// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of netease_voiceroomkit;

/// 主播信息
/// @property account 账号
/// @property nick 昵称
/// @property avatar 头像
/// @constructor
class NEVoiceRoomAnchor {
  String? account;
  String? nick;
  String? avatar;

  NEVoiceRoomAnchor(this.account, this.nick, this.avatar);

  NEVoiceRoomAnchor.fromJson(Map? json) {
    account = json?['userUuid'] ?? "";
    nick = json?['userName'];
    avatar = json?['icon'];
  }

  Map<String, dynamic> toJson() =>
      {'account': account, 'nick': nick, 'avatar': avatar};

  @override
  String toString() {
    return 'NEVoiceRoomAnchor{account: $account, nick: $nick, avatar: $avatar}';
  }
}
