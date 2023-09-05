// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Foundation
import NERoomKit

@objc

/// 播放状态的相关回调
protocol NEOrderSongPlayStateChangeCallback {
  func onReceiveSongPosition(_ actionType: NEOrderSongCustomAction,
                             data: [String: Any]?)
}

/// 唱歌 相关操作接口
/// 独唱、合唱
class NEOrderSongAudioPlayService: NSObject {
  var callback: NEOrderSongPlayStateChangeCallback?

  var roomUuid: String = ""

  /// 初始化
  /// - Parameter roomUuid: 房间id
  init(roomUuid: String) {
    super.init()
    self.roomUuid = roomUuid
    // 默认配置
    defaultConfig()
  }

  func defaultConfig() {
    NERoomKit.shared().roomService.getRoomContext(roomUuid: roomUuid)?.addRoomListener(listener: self)
    NERoomKit.shared().messageChannelService.addMessageChannelListener(listener: self)
  }

  /// 销毁
  func destroy() {
    NERoomKit.shared().messageChannelService.removeMessageChannelListener(listener: self)
  }
}
