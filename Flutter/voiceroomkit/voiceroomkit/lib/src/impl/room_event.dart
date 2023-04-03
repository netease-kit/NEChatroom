// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of netease_voiceroomkit;

class _NEVoiceRoomEvent extends NERoomEventCallback with _AloggerMixin {
  late NERoomEventCallback _roomEvent;
  final _VoiceRoomKitImpl _voiceRoomKit =
      NEVoiceRoomKit.instance as _VoiceRoomKitImpl;
  _NEVoiceRoomEvent() {
    _roomEvent = NERoomEventCallback(
        memberJoinRoom: _memberJoinRoom,
        memberLeaveRoom: _memberLeaveRoom,
        roomEnd: _roomEnd);
  }

  _memberLeaveRoom(List<NERoomMember> members) {
    _voiceRoomKit._notifyMembersLeave(members);
  }

  void _memberJoinRoom(List<NERoomMember> members) {
    _voiceRoomKit._notifyMembersJoin(members);
  }

  void _roomEnd(NERoomEndReason reason) {
    _voiceRoomKit._notifyRoomEnd(reason);
  }
}
