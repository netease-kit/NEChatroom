// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:hawk/hawk.dart';
import 'package:netease_voiceroomkit/netease_voiceroomkit.dart';

import 'voice_room_base_case.dart';

///case模板，模板代码的class需要在 [nim_core_test.dart] 中注册。
class HandleLoginCase extends HandleVoiceRoomBaseCase {
  HandleLoginCase();

  @override
  Future<ResultBean?> handle(event) async {
    super.handle(event);
    if (className == "NEVoiceRoomKit" && methodName == "initialize") {
      var extras = <String, String>{};
      params?[1]["options"]["extras"].forEach(
          (key, value) => extras.putIfAbsent(key, () => value.toString()));
      ret = await voiceRoomKit.initialize(NEVoiceRoomKitOptions(
        appKey: params?[1]["options"]["appKey"],
        extras: extras,
      ));
    } else if (className == "NEVoiceRoomKit" && methodName == "login") {
      ret = await voiceRoomKit.login(
        params?[0]["account"],
        params?[1]["token"],
      );
    } else if (className == "NEVoiceRoomKit" && methodName == "logout") {
      ret = await voiceRoomKit.logout();
    } else if (className == "NEVoiceRoomKit" &&
        methodName == "addAuthListener") {
      var listener = NEVoiceRoomAuthEventCallback((evt) {
        reportInListener("addAuthListener", data: evt.name);
      });
      listenerMap.putIfAbsent(
          params?[0]['listener']?.toString() ?? 'authListener', () => listener);
      voiceRoomKit.addAuthListener(listener);
      ret = "addAuthListener";
    } else if (className == "NEVoiceRoomKit" &&
        methodName == "removeAuthListener") {
      voiceRoomKit.removeAuthListener(
          listenerMap[params?[0]['listener']?.toString() ?? 'authListener']);
      ret = "removeAuthListener";
    }
    return reportCaseResult();
  }
}
