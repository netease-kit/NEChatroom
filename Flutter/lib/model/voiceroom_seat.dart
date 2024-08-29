// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:core';

import 'package:netease_voiceroomkit/netease_voiceroomkit.dart';

class VoiceRoomSeat {
  /// 麦位容量
  static const int SEAT_COUNT = 9;

  final int index;
  final int status;
  final int reason;
  final NEVoiceRoomMember? member;

  VoiceRoomSeat(this.index, this.status, this.reason, this.member);

  int getSeatIndex() {
    return index;
  }

  int getStatus() {
    return status;
  }

  int getReason() {
    return reason;
  }

  NEVoiceRoomMember? getMember() {
    return member;
  }

  String? getAccount() {
    if (member != null) {
      return member?.account;
    } else {
      return null;
    }
  }

  bool isOn() {
    return status == Status.ON;
  }

  @override
  String toString() {
    return 'VoiceRoomSeat{index: $index, status: $status, reason: $reason, member: $member}';
  }
}

class Status {
  /// 麦位初始化状态（没人） */
  static const int INIT = 0;

  /// 正在申请（没人） */
  static const APPLY = 1;

  /// 麦位上有人，且能正常发言（有人） */
  static const ON = 2;

  /// 麦位关闭（没人） */
  static const CLOSED = 3;
}

class Reason {
  /// 无
  static const int NONE = 0;

  /// 主播同意上麦
  static const int ANCHOR_APPROVE_APPLY = 1;

  /// 主播抱上麦
  static const int ANCHOR_INVITE_ACCEPT = 2;

  /// 主播踢下麦
  static const int ANCHOR_KICK = 3;

  /// 下麦
  static const int LEAVE = 4;

  /// 主播拒绝申请
  static const int ANCHOR_DENY_APPLY = 6;

  /// 主播抱上麦申请
  static const int ANCHOR_INVITE_APPLY = 7;
}
