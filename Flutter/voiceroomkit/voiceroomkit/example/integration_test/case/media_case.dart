// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:hawk/hawk.dart';
import 'package:netease_voiceroomkit/netease_voiceroomkit.dart';

import 'voice_room_base_case.dart';

///case模板，模板代码的class需要在 [nim_core_test.dart] 中注册。
class HandleMediaCase extends HandleVoiceRoomBaseCase {
  HandleMediaCase();

  @override
  Future<ResultBean?> handle(event) async {
    super.handle(event);

    if (className == "NEVoiceRoomKit" && methodName == "muteMyAudio") {
      ret = await voiceRoomKit.muteMyAudio();
    }

    if (className == "NEVoiceRoomKit" && methodName == "unmuteMyAudio") {
      ret = await voiceRoomKit.unmuteMyAudio();
    }
    if (className == "NEVoiceRoomKit" && methodName == "enableEarBack") {
      ret = await voiceRoomKit.enableEarback(params?[0]["volume"]);
    }
    if (className == "NEVoiceRoomKit" && methodName == "disableEarBack") {
      ret = await voiceRoomKit.disableEarback();
    }
    if (className == "NEVoiceRoomKit" && methodName == "isEarBackEnable") {
      ret = voiceRoomKit.isEarbackEnable();
    }

    if (className == "NEVoiceRoomKit" &&
        methodName == "adjustRecordingSignalVolume") {
      ret =
          await voiceRoomKit.adjustRecordingSignalVolume(params?[0]["volume"]);
    }
    if (className == "NEVoiceRoomKit" &&
        methodName == "getRecordingSignalVolume") {
      ret = voiceRoomKit.getRecordingSignalVolume();
    }
    if (className == "NEVoiceRoomKit" && methodName == "startAudioMixing") {
      ret = await voiceRoomKit
          .startAudioMixing(NEVoiceRoomCreateAudioMixingOption(
        params?[0]['option']['path'],
        params?[0]['option']['loopCount'],
        params?[0]['option']['sendEnabled'],
        params?[0]['option']['sendVolume'],
        params?[0]['option']['playbackEnabled'],
        params?[0]['option']['playbackVolume'],
      ));
    }
    if (className == "NEVoiceRoomKit" && methodName == "pauseAudioMixing") {
      ret = await voiceRoomKit.pauseAudioMixing();
    }
    if (className == "NEVoiceRoomKit" && methodName == "resumeAudioMixing") {
      ret = await voiceRoomKit.resumeAudioMixing();
    }
    if (className == "NEVoiceRoomKit" && methodName == "stopAudioMixing") {
      ret = await voiceRoomKit.stopAudioMixing();
    }
    if (className == "NEVoiceRoomKit" && methodName == "setAudioMixingVolume") {
      ret = await voiceRoomKit.setAudioMixingVolume(
        params?[0]['volume'],
      );
    }
    if (className == "NEVoiceRoomKit" && methodName == "getAudioMixingVolume") {
      ret = voiceRoomKit.getAudioMixingVolume();
    }
    if (className == "NEVoiceRoomKit" && methodName == "playEffect") {
      ret = await voiceRoomKit.playEffect(
          params?[0]['effectId'],
          NEVoiceRoomCreateAudioEffectOption(
            params?[1]['option']['path'],
            params?[1]['option']['loopCount'],
            params?[1]['option']['sendEnabled'],
            params?[1]['option']['sendVolume'],
            params?[1]['option']['playbackEnabled'],
            params?[1]['option']['playbackVolume'],
          ));
    }
    if (className == "NEVoiceRoomKit" && methodName == "setEffectVolume") {
      ret = await voiceRoomKit.setEffectVolume(
        params?[0]['effectId'],
        params?[1]['volume'],
      );
    }
    if (className == "NEVoiceRoomKit" && methodName == "getEffectVolume") {
      ret = voiceRoomKit.getEffectVolume();
    }
    if (className == "NEVoiceRoomKit" && methodName == "stopAllEffect") {
      ret = await voiceRoomKit.stopAllEffect();
    }
    if (className == "NEVoiceRoomKit" && methodName == "stopEffect") {
      ret = await voiceRoomKit.stopEffect(params?[0]['effectId']);
    }
    return reportCaseResult();
  }
}
