// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Foundation

@objc
/// 本地音频输出设备
public enum NEVoiceRoomAudioOutputDevice: UInt {
  /// 扬声器
  case speakerPhone = 0
  /// 有线耳机
  case wiredHeadset
  /// 听筒
  case earpiece
  /// 无线耳机
  case bluetoothHeadset
}
