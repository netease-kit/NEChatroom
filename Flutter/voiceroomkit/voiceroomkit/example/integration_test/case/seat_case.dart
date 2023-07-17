// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:hawk/hawk.dart';

import 'voice_room_base_case.dart';

///case模板，模板代码的class需要在 [nim_core_test.dart] 中注册。
class HandleSeatCase extends HandleVoiceRoomBaseCase {
  HandleSeatCase();

  @override
  Future<ResultBean?> handle(event) async {
    super.handle(event);

    if (className == "NEVoiceRoomKit" && methodName == "openSeats") {
      ret = await voiceRoomKit.openSeats(params?[0]["seatIndices"].cast<int>());
    } else if (className == "NEVoiceRoomKit" && methodName == "closeSeats") {
      ret =
          await voiceRoomKit.closeSeats(params?[0]["seatIndices"].cast<int>());
    } else if (className == "NEVoiceRoomKit" && methodName == "getSeatInfo") {
      ret = await voiceRoomKit.getSeatInfo();
    } else if (className == "NEVoiceRoomKit" &&
        methodName == "getSeatRequestList") {
      ret = await voiceRoomKit.getSeatRequestList();
    }

    if (className == "NEVoiceRoomKit" && methodName == "submitSeatRequest") {
      ret = await voiceRoomKit.submitSeatRequest(
          params?[0]["seatIndex"], params?[1]["exclusive"]);
    }

    if (className == "NEVoiceRoomKit" && methodName == "cancelSeatRequest") {
      ret = await voiceRoomKit.cancelSeatRequest();
    }

    if (className == "NEVoiceRoomKit" && methodName == "approveSeatRequest") {
      ret = await voiceRoomKit.approveSeatRequest(params?[0]["account"]);
    }

    if (className == "NEVoiceRoomKit" && methodName == "rejectSeatRequest") {
      ret = await voiceRoomKit.rejectSeatRequest(params?[0]["account"]);
    }

    if (className == "NEVoiceRoomKit" && methodName == "kickSeat") {
      ret = await voiceRoomKit.kickSeat(params?[0]["account"]);
    }

    if (className == "NEVoiceRoomKit" && methodName == "leaveSeat") {
      ret = await voiceRoomKit.leaveSeat();
    }

    if (className == "NEVoiceRoomKit" && methodName == "banRemoteAudio") {
      ret = await voiceRoomKit.banRemoteAudio(params?[0]["account"]);
    }

    if (className == "NEVoiceRoomKit" && methodName == "unbanRemoteAudio") {
      ret = await voiceRoomKit.unbanRemoteAudio(params?[0]["account"]);
    }

    return reportCaseResult();
  }
}
