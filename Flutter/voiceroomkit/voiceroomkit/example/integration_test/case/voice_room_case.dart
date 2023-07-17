// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:hawk/hawk.dart';
import 'package:netease_voiceroomkit/netease_voiceroomkit.dart';

import 'voice_room_base_case.dart';

///case模板，模板代码的class需要在 [main_test.dart] 中注册。
class HandleVoiceRoomCase extends HandleVoiceRoomBaseCase {
  HandleVoiceRoomCase();

  @override
  Future<ResultBean?> handle(event) async {
    super.handle(event);
    if (className == "NEVoiceRoomKit" && methodName == "createRoom") {
      ret = await voiceRoomKit.createRoom(
          NECreateVoiceRoomParams(
            title: params?[0]["params"]["title"],
            nick: params?[0]["params"]["nick"],
            seatCount: params?[0]["params"]["seatCount"],
            configId: params?[0]["params"]["configId"],
            cover: params?[0]["params"]["cover"],
            extraData: params?[0]["params"]["extraData"],
          ),
          NECreateVoiceRoomOptions());
    } else if (className == "NEVoiceRoomKit" && methodName == "joinRoom") {
      ret = await voiceRoomKit.joinRoom(
          NEJoinVoiceRoomParams(
            roomUuid: params?[0]["params"]["roomUuid"],
            nick: params?[0]["params"]["nick"],
            avatar: params?[0]["params"]["avatar"],
            role: params?[0]["params"]["role"] == "HOST"
                ? NEVoiceRoomRole.host
                : NEVoiceRoomRole.audience,
            liveRecordId: params?[0]["params"]["liveRecordId"],
            extraData:
                Map<String, String>.from(params?[0]["params"]["extraData"]),
          ),
          NEJoinVoiceRoomOptions());
    } else if (className == "NEVoiceRoomKit" && methodName == "leaveRoom") {
      ret = await voiceRoomKit.leaveRoom();
    } else if (className == "NEVoiceRoomKit" && methodName == "endRoom") {
      ret = await voiceRoomKit.endRoom();
    } else if (className == "NEVoiceRoomKit" &&
        methodName == "sendTextMessage") {
      ret = await voiceRoomKit.sendTextMessage(params?[0]["content"]);
    } else if (className == "NEVoiceRoomKit" &&
        methodName == "addVoiceRoomListener") {
      var listener = getVoiceRoomListener();
      listenerMap.putIfAbsent(
          params?[0]['listener']?.toString() ?? 'voiceRoomListener',
          () => listener);
      voiceRoomKit.addVoiceRoomListener(listener);
      ret = "addVoiceRoomListener";
    } else if (className == "NEVoiceRoomKit" &&
        methodName == "removeVoiceRoomListener") {
      voiceRoomKit.removeVoiceRoomListener(listenerMap[
          params?[0]['listener']?.toString() ?? 'voiceRoomListener']);
      ret = "removeVoiceRoomListener";
    } else if (className == "NEVoiceRoomKit" && methodName == "getRoomList") {
      ret = await voiceRoomKit.getRoomList(
        getLiveStatus(params?[0]["liveState"]),
        params?[1]["pageNum"],
        params?[2]["pageSize"],
      );
    } else if (className == "NEVoiceRoomKit" &&
        methodName == "getCreateRoomDefaultInfo") {
      ret = await voiceRoomKit.getCreateRoomDefaultInfo();
    } else if (className == "NEVoiceRoomKit" &&
        methodName == "sendSeatInvitation") {
      ret = await voiceRoomKit.sendSeatInvitation(
        params?[0]["seatIndex"],
        params?[1]["account"],
      );
    }

    return reportCaseResult();
  }

  NEVoiceRoomLiveState getLiveStatus(String status) {
    switch (status) {
      case "NotStart":
        return NEVoiceRoomLiveState.notStart;
      case "Live":
        return NEVoiceRoomLiveState.live;
      case "LiveClose":
        return NEVoiceRoomLiveState.liveClose;
      default:
        return NEVoiceRoomLiveState.notStart;
    }
  }

  NEVoiceRoomEventCallback getVoiceRoomListener() {
    return NEVoiceRoomEventCallback(memberJoinRoomCallback: ((members) {
      reportInListener("addVoiceRoomListener",
          message: 'memberJoinRoomCallback', data: members);
    }), memberLeaveRoomCallback: ((members) {
      reportInListener("addVoiceRoomListener",
          message: 'memberLeaveRoomCallback', data: members);
    }), roomEndedCallback: ((reason) {
      reportInListener("addVoiceRoomListener",
          message: 'roomEndedCallback', data: reason);
    }), rtcChannelErrorCallback: ((code) {
      reportInListener("addVoiceRoomListener",
          message: 'rtcChannelErrorCallback', code: code);
    }), memberAudioMuteChangedCallback: ((member, mute, operateBy) {
      reportInListener("addVoiceRoomListener",
          message: 'memberAudioMuteChangedCallback',
          data: {
            'member': member,
            'mute': mute,
            'operateBy': operateBy,
          });
    }), memberAudioBannedCallback: ((member, banned) {
      reportInListener("addVoiceRoomListener",
          message: 'memberAudioBannedCallback',
          data: {
            'member': member,
            'banned': banned,
          });
    }), receiveTextMessageCallback: ((message) {
      reportInListener("addVoiceRoomListener",
          message: 'receiveTextMessageCallback', data: message);
    }), seatRequestSubmittedCallback: ((seatIndex, account) {
      reportInListener("addVoiceRoomListener",
          message: 'seatRequestSubmittedCallback',
          data: {
            'seatIndex': seatIndex,
            'account': account,
          });
    }), seatRequestCancelledCallback: ((seatIndex, account) {
      reportInListener("addVoiceRoomListener",
          message: 'seatRequestCancelledCallback',
          data: {
            'seatIndex': seatIndex,
            'account': account,
          });
    }), seatRequestApprovedCallback:
        ((seatIndex, account, operateBy, isAutoAgree) {
      reportInListener("addVoiceRoomListener",
          message: 'seatRequestApprovedCallback',
          data: {
            'seatIndex': seatIndex,
            'account': account,
            'operateBy': operateBy,
            'isAutoAgree': isAutoAgree,
          });
    }), seatRequestRejectedCallback: ((seatIndex, account, operateBy) {
      reportInListener("addVoiceRoomListener",
          message: 'seatRequestRejectedCallback',
          data: {
            'seatIndex': seatIndex,
            'account': account,
            'operateBy': operateBy,
          });
    }), seatLeaveCallback: ((seatIndex, account) {
      reportInListener("addVoiceRoomListener",
          message: 'seatLeaveCallback',
          data: {
            'seatIndex': seatIndex,
            'account': account,
          });
    }), seatKickedCallback: ((seatIndex, account, operateBy) {
      reportInListener("addVoiceRoomListener",
          message: 'seatKickedCallback',
          data: {
            'seatIndex': seatIndex,
            'account': account,
            'operateBy': operateBy,
          });
    }), seatInvitationAcceptedCallback: ((seatIndex, account, isAutoAgree) {
      reportInListener("addVoiceRoomListener",
          message: 'seatInvitationAcceptedCallback',
          data: {
            'seatIndex': seatIndex,
            'account': account,
            'isAutoAgree': isAutoAgree,
          });
    }), seatListChangedCallback: ((seatItems) {
      reportInListener("addVoiceRoomListener",
          message: 'seatListChangedCallback', data: seatItems);
    }), audioMixingStateChangedCallback: ((reason) {
      reportInListener("addVoiceRoomListener",
          message: 'audioMixingStateChangedCallback', data: reason);
    }), audioOutputDeviceChangedCallback: ((device) {
      reportInListener("addVoiceRoomListener",
          message: 'audioOutputDeviceChangedCallback', data: device);
    }));
  }
}
