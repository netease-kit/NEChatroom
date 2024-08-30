// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:netease_voiceroomkit/netease_voiceroomkit.dart';
import 'package:voiceroomkit_ui/service/auth/auth_manager.dart';
import 'package:voiceroomkit_ui/utils/voiceroomkit_log.dart';

/// 房间数据
class RoomInfoViewModel extends ChangeNotifier {
  final tag = "RoomInfoViewModel";

  late NEVoiceRoomInfo roomInfo;
  late bool isAnchor;

  initData(Map<String, dynamic> arguments) {
    ///原始数据传入，需要解析
    isAnchor = arguments['isAnchor'] as bool;
    roomInfo = arguments['roomInfo'] as NEVoiceRoomInfo;
  }

  void joinRoom(void Function(int) callback) {
    NEJoinVoiceRoomParams params = NEJoinVoiceRoomParams(
        roomUuid: roomInfo.liveModel?.roomUuid ?? '',
        avatar: AuthManager().avatar ?? '',
        role: isAnchor ? NEVoiceRoomRole.host : NEVoiceRoomRole.audience,
        liveRecordId: roomInfo.liveModel?.liveRecordId as int,
        nick: AuthManager().nickName ?? '',
        extraData: null);

    NEJoinVoiceRoomOptions options = NEJoinVoiceRoomOptions();
    NEVoiceRoomKit.instance.joinRoom(params, options).then((value) {
      VoiceRoomKitLog.i(tag, "joinRoom: $value");
      if (value.isSuccess()) {
        if (isAnchor) {
          NEVoiceRoomKit.instance.submitSeatRequest(1, true).then((value) {
            VoiceRoomKitLog.i(tag, "submitSeatRequest: ${value.code}");
            if (value.isSuccess()) {
              NEVoiceRoomKit.instance.unmuteMyAudio().then((value) {
                VoiceRoomKitLog.i(tag, "unmuteMyAudio: ${value.code}");
              });
            }
          });
        }
        callback(NEVoiceRoomErrorCode.success);
      } else {
        NEVoiceRoomKit.instance.endRoom();
        callback(NEVoiceRoomErrorCode.failure);
      }
    });
  }
}
