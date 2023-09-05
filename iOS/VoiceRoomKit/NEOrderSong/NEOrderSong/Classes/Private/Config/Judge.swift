// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Foundation

struct Judge {
  /// 前置条件判断
  static func preCondition<T: Any>(_ success: @escaping () -> Void,
                                   failure: NEOrderSongCallback<T>? = nil) {
    guard NEOrderSong.getInstance().musicService != nil else {
      NEOrderSongLog.errorLog(kitTag, desc: "MusicService is nil")
      failure?(NEOrderSongErrorCode.failed, "MusicService is nil", nil)
      return
    }
    success()
  }

  /// 初始化判断条件
  static func initCondition<T: Any>(_ success: @escaping () -> Void,
                                    failure: NEOrderSongCallback<T>? = nil) {
    guard NEOrderSong.getInstance().isInitialized else {
      NEOrderSongLog.errorLog(kitTag, desc: "Uninitialized.")
      failure?(NEOrderSongErrorCode.failed, "Uninitialized.", nil)
      return
    }
    success()
  }

  @discardableResult

  /// 同步返回
  static func syncCondition(_ success: @escaping () -> Int) -> Int {
    guard NEOrderSong.getInstance().isInitialized else {
      NEOrderSongLog.errorLog(kitTag, desc: "Uninitialized.")
      return NEOrderSongErrorCode.failed
    }
    guard let _ = NEOrderSong.getInstance().roomContext else {
      NEOrderSongLog.errorLog(kitTag, desc: "RoomContext is nil.")
      return NEOrderSongErrorCode.failed
    }
    return success()
  }

  static func condition(_ success: @escaping () -> Void) {
    guard NEOrderSong.getInstance().isInitialized else {
      NEOrderSongLog.errorLog(kitTag, desc: "Uninitialized.")
      return
    }
    guard let _ = NEOrderSong.getInstance().roomContext else {
      NEOrderSongLog.errorLog(kitTag, desc: "RoomContext is nil.")
      return
    }
    success()
  }

  static func syncResult<T: Any>(_ success: @escaping () -> T) -> T? {
    guard NEOrderSong.getInstance().isInitialized else {
      NEOrderSongLog.errorLog(kitTag, desc: "Uninitialized.")
      return nil
    }
    guard let _ = NEOrderSong.getInstance().roomContext else {
      NEOrderSongLog.errorLog(kitTag, desc: "RoomContext is nil.")
      return nil
    }
    return success()
  }
}
