// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

class VoiceRoomSeatEvent {
  final String user;

  final int index;

  final int reason;

  VoiceRoomSeatEvent(this.user, this.index, this.reason);

  @override
  String toString() {
    return 'VoiceRoomSeatEvent{user: $user, index: $index, reason: $reason}';
  }
}
