// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of netease_voiceroomkit;

class ModelConvertUtil {
  static NEVoiceRoomEndReason handleRoomEndReason(NERoomEndReason reason) {
    if (reason == NERoomEndReason.kLeaveBySelf) {
      return NEVoiceRoomEndReason.leaveBySelf;
    } else if (reason == NERoomEndReason.kSyncDataError) {
      return NEVoiceRoomEndReason.syncDataError;
    } else if (reason == NERoomEndReason.kKickBySelf) {
      return NEVoiceRoomEndReason.kickBySelf;
    } else if (reason == NERoomEndReason.kKickOut) {
      return NEVoiceRoomEndReason.kickOut;
    } else if (reason == NERoomEndReason.kCloseByMember) {
      return NEVoiceRoomEndReason.closeByMember;
    } else if (reason == NERoomEndReason.kEndOfLife) {
      return NEVoiceRoomEndReason.endOfLife;
    } else if (reason == NERoomEndReason.kAllMemberOut) {
      return NEVoiceRoomEndReason.allMembersOut;
    } else if (reason == NERoomEndReason.kCloseByBackend) {
      return NEVoiceRoomEndReason.closeByBackend;
    } else if (reason == NERoomEndReason.kLoginStateError) {
      return NEVoiceRoomEndReason.loginStateError;
    } else {
      return NEVoiceRoomEndReason.unknown;
    }
  }

  static NEVoiceRoomAudioOutputDevice handleAudioOutputDevices(
      NEAudioOutputDevice device) {
    if (device == NEAudioOutputDevice.kBluetoothHeadset) {
      return NEVoiceRoomAudioOutputDevice.bluetoothHeadset;
    } else if (device == NEAudioOutputDevice.kEarpiece) {
      return NEVoiceRoomAudioOutputDevice.earPiece;
    } else if (device == NEAudioOutputDevice.kSpeakerPhone) {
      return NEVoiceRoomAudioOutputDevice.speakerPhone;
    } else {
      return NEVoiceRoomAudioOutputDevice.wiredHeadSet;
    }
  }
}
