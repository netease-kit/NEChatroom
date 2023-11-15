// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Foundation

@objc
/// 房间类型
public enum NEVoiceRoomLiveRoomType: Int {
  /// 语聊房
  case multiAudio = 2
  /// 一起听
  case listenTogether = 5
  /// 游戏房
  case game = 6
}

@objc
/// 直播状态
public enum NEVoiceRoomLiveStatus: Int {
  /// 未直播
  case idle = 0
  /// 直播中
  case living = 1
  /// PK中
  case pking = 2
  /// PK惩罚中
  case punishing = 3
  /// 连麦中
  case connected = 4
  /// PK邀请中
  case inviting = 5
  /// 直播结束
  case end = -1
}
