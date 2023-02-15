// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Foundation
import NERoomKit

extension NEOrderSongAudioPlayService: NERoomListener {
//  func onRoomEnded(reason _: NERoomEndReason) {
//    NEVoiceRoomKit.getInstance().leaveRoom()
//  }
}

extension NEOrderSongAudioPlayService: NEMessageChannelListener {
  /// 接收自定义消息
  func onReceiveCustomMessage(message: NECustomMessage) {
    guard let dic = message.data.toDictionary() else { return }
    if message.commandId == 10001 {
      NEOrderSongLog.infoLog(kitTag, desc: "Receive audience get position message.")
      if callback != nil {
        callback!.onReceiveSongPosition(NEOrderSongCustomAction.getPosition, data: dic)
      }
    } else if message.commandId == 10002 {
      NEOrderSongLog.infoLog(kitTag, desc: "Receive anchor send position message.")
      if callback != nil {
        callback!.onReceiveSongPosition(NEOrderSongCustomAction.sendPosition, data: dic)
      }
    } else if message.commandId == 10003 {
      NEOrderSongLog.infoLog(kitTag, desc: "Receive downloadProcess message.")
      if callback != nil {
        callback!.onReceiveSongPosition(NEOrderSongCustomAction.downloadProcess, data: dic)
      }
    }
  }
}
