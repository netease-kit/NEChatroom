// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

library netease_voiceroomkit;

import 'package:netease_roomkit/netease_roomkit.dart';
import 'package:netease_roomkit_interface/netease_roomkit_interface.dart';
import 'package:netease_voiceroomkit/netease_voiceroomkit.dart';

class VoiceRoomMemberImpl extends NEVoiceRoomMember {
  final NERoomMember roomMember;

  VoiceRoomMemberImpl(this.roomMember)
      : super(roomMember.uuid, roomMember.name, roomMember.role.name, false,
            false, roomMember.avatar);
  @override
  bool get isAudioOn =>
      roomMember.isAudioOn &&
      MemberPropertyConstants.MUTE_VOICE_VALUE_ON ==
          roomMember.properties[MemberPropertyConstants.MUTE_VOICE_KEY];

  @override
  bool get isAudioBanned =>
      roomMember.properties[MemberPropertyConstants.CAN_OPEN_MIC_KEY] ==
      MemberPropertyConstants.CAN_OPEN_MIC_VALUE_NO;

  @override
  Map<String, String>? get properties => roomMember.properties;

  @override
  String toString() {
    return 'VoiceRoomMemberImpl{roomMember: $roomMember}';
  }
}
