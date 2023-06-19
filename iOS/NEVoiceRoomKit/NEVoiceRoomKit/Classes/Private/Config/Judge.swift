// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Foundation

struct Judge {
  /// 前置条件判断
  static func preCondition<T: Any>(_ success: @escaping () -> Void,
                                   failure: NEVoiceRoomCallback<T>? = nil) {
    guard NEVoiceRoomKit.getInstance().isInitialized else {
      NEVoiceRoomLog.errorLog(kitTag, desc: "Uninitialized.")
      failure?(NEVoiceRoomErrorCode.failed, "Uninitialized.", nil)
      return
    }
    guard let _ = NEVoiceRoomKit.getInstance().roomContext else {
      NEVoiceRoomLog.errorLog(kitTag, desc: "RoomContext not exist.")
      failure?(NEVoiceRoomErrorCode.failed, "RoomContext not exist.", nil)
      return
    }
    success()
  }

  /// 初始化判断条件
  static func initCondition<T: Any>(_ success: @escaping () -> Void,
                                    failure: NEVoiceRoomCallback<T>? = nil) {
    guard NEVoiceRoomKit.getInstance().isInitialized else {
      NEVoiceRoomLog.errorLog(kitTag, desc: "Uninitialized.")
      failure?(NEVoiceRoomErrorCode.failed, "Uninitialized.", nil)
      return
    }
    success()
  }

  @discardableResult

  /// 同步返回
  static func syncCondition(_ success: @escaping () -> Int) -> Int {
    guard NEVoiceRoomKit.getInstance().isInitialized else {
      NEVoiceRoomLog.errorLog(kitTag, desc: "Uninitialized.")
      return NEVoiceRoomErrorCode.failed
    }
    guard let _ = NEVoiceRoomKit.getInstance().roomContext else {
      NEVoiceRoomLog.errorLog(kitTag, desc: "RoomContext is nil.")
      return NEVoiceRoomErrorCode.failed
    }
    return success()
  }

  static func condition(_ success: @escaping () -> Void) {
    guard NEVoiceRoomKit.getInstance().isInitialized else {
      NEVoiceRoomLog.errorLog(kitTag, desc: "Uninitialized.")
      return
    }
    guard let _ = NEVoiceRoomKit.getInstance().roomContext else {
      NEVoiceRoomLog.errorLog(kitTag, desc: "RoomContext is nil.")
      return
    }
    success()
  }

  static func syncResult<T: Any>(_ success: @escaping () -> T) -> T? {
    guard NEVoiceRoomKit.getInstance().isInitialized else {
      NEVoiceRoomLog.errorLog(kitTag, desc: "Uninitialized.")
      return nil
    }
    guard let _ = NEVoiceRoomKit.getInstance().roomContext else {
      NEVoiceRoomLog.errorLog(kitTag, desc: "RoomContext is nil.")
      return nil
    }
    return success()
  }
}
