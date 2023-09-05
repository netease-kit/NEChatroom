// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Foundation
import NERoomKit
import UIKit

// 加入扩展
public extension NEOrderSong {
  func configRoomSetting(_ roomUuid: String, liveRecordId: UInt64) {
    _audioPlayService = NEOrderSongAudioPlayService(roomUuid: roomUuid)
    _audioPlayService?.callback = self
    musicService = NEOrderSongMusicService(liveRecordId)
    NERoomKit.shared().roomService.getRoomContext(roomUuid: roomUuid)?.addRoomListener(listener: self)
  }

  /// 获取实时Token
  /// - Parameter callback: 回调
  func getSongToken(callback: NEOrderSongCallback<NEOrderSongDynamicToken>? = nil) {
    NEOrderSongLog.apiLog(kitTag, desc: "Get Song Token")
    Judge.initCondition({
      self.roomService.getSongToken { data in
        NEOrderSongLog.successLog(kitTag, desc: "Successfully getSongToken")
        callback?(NEOrderSongErrorCode.success, nil, data)
      } failure: { error in
        NEOrderSongLog.errorLog(
          kitTag,
          desc: "Failed to getSongToken. Code: \(error.code). Msg: \(error.localizedDescription)"
        )
        callback?(error.code, error.localizedDescription, nil)
      }

    }, failure: callback)
  }
}
