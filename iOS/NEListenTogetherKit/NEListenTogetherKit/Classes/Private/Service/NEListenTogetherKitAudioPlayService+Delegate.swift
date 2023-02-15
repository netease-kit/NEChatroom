// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Foundation
import NERoomKit

extension NEListenTogetherAudioPlayService: NERoomListener {
  func onRoomEnded(reason _: NERoomEndReason) {
    NEListenTogetherKit.getInstance().leaveRoom()
  }
}

extension NEListenTogetherAudioPlayService: NEMessageChannelListener {
  @objc
  func playTimerBlock() {
    guard let roomContext = roomContext else { return }
    // 进度
    let position = roomContext.rtcController
      .getEffectCurrentPosition(effectId: currentEffectId)
    if callback != nil {
      callback!.onSongPlayPosition(position)
    }
  }

  /// 接收自定义消息
  func onReceiveCustomMessage(message: NECustomMessage) {
    guard let dic = message.data.toDictionary() else { return }
    guard roomContext != nil else { return }
    if message.commandId == 10001 {
      NEListenTogetherLog.infoLog(kitTag, desc: "Receive audience get position message.")
      if callback != nil {
        callback!.onReceiveSongPosition(NEListenTogetherCustomAction.getPosition, data: dic)
      }
    } else if message.commandId == 10002 {
      NEListenTogetherLog.infoLog(kitTag, desc: "Receive anchor send position message.")
      if callback != nil {
        callback!.onReceiveSongPosition(NEListenTogetherCustomAction.sendPosition, data: dic)
      }
    } else if message.commandId == 10003 {
      NEListenTogetherLog.infoLog(kitTag, desc: "Receive downloadProcess message.")
      if callback != nil {
        callback!.onReceiveSongPosition(NEListenTogetherCustomAction.downloadProcess, data: dic)
      }
    }
  }
}

extension NEListenTogetherAudioPlayService {
  func isAudience(_ songModel: NEListenTogetherSongModel) -> Bool {
    let userUuid = NEListenTogetherKit.getInstance().localMember?.account
    guard userUuid == songModel.actionOperator?.account else {
      return true
    }
    return false
  }
}
