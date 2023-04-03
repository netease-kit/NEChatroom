// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of netease_voiceroomkit;

class MemberPropertyConstants {
  // 根据该成员属性 变更mic声音采集
  static const String MUTE_VOICE_KEY = "recordDevice";
  static const String MUTE_VOICE_VALUE_ON = "on";
  static const String MUTE_VOICE_VALUE_OFF = "off";

  // 成员是否可以开启麦克风。如果值为 [CAN_OPEN_MIC_VALUE_NO]，表示不能开启麦克风。
  static const String CAN_OPEN_MIC_KEY = "canOpenMic";
  static const String CAN_OPEN_MIC_VALUE_NO = "0";
  static const String CAN_OPEN_MIC_VALUE_YES = "1";
}
