// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of netease_voiceroomkit;

class NEVoiceRoomSeatItemStatus {
  /// 麦位初始化（无人，可以上麦）
  static const initial = NESeatItemStatus.INITIAL;

  /// 该麦位正在等待管理员通过申请或等待成员接受邀请后上麦。
  static const waiting = NESeatItemStatus.WAITING;

  /// 当前麦位已被占用
  static const taken = NESeatItemStatus.TAKEN;

  /// 当前麦位已关闭，不能操作上麦
  static const closed = NESeatItemStatus.CLOSED;
}

/// 成员上麦方式
class NEVoiceRoomOnSeatType {
  /// 无效
  static const invalid = NESeatOnSeatType.INVALID;

  /// 用户通过申请上麦
  static const request = NESeatOnSeatType.REQUEST;

  /// 管理员抱成员上麦
  static const invitation = NESeatOnSeatType.INVITATION;
}
