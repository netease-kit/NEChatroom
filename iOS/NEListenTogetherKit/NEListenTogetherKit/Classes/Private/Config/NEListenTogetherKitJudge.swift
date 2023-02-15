// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Foundation

struct Judge {
  /// 前置条件判断
  static func preCondition<T: Any>(_ success: @escaping () -> Void,
                                   failure: NEListenTogetherCallback<T>? = nil) {
    guard NEListenTogetherKit.getInstance().isInitialized else {
      NEListenTogetherLog.errorLog(kitTag, desc: "Uninitialized.")
      failure?(NEListenTogetherErrorCode.failed, "Uninitialized.", nil)
      return
    }
    guard let _ = NEListenTogetherKit.getInstance().roomContext else {
      NEListenTogetherLog.errorLog(kitTag, desc: "RoomContext not exist.")
      failure?(NEListenTogetherErrorCode.failed, "RoomContext not exist.", nil)
      return
    }
    success()
  }

  /// 初始化判断条件
  static func initCondition<T: Any>(_ success: @escaping () -> Void,
                                    failure: NEListenTogetherCallback<T>? = nil) {
    guard NEListenTogetherKit.getInstance().isInitialized else {
      NEListenTogetherLog.errorLog(kitTag, desc: "Uninitialized.")
      failure?(NEListenTogetherErrorCode.failed, "Uninitialized.", nil)
      return
    }
    success()
  }

  @discardableResult

  /// 同步返回
  static func syncCondition(_ success: @escaping () -> Int) -> Int {
    guard NEListenTogetherKit.getInstance().isInitialized else {
      NEListenTogetherLog.errorLog(kitTag, desc: "Uninitialized.")
      return NEListenTogetherErrorCode.failed
    }
    guard let _ = NEListenTogetherKit.getInstance().roomContext else {
      NEListenTogetherLog.errorLog(kitTag, desc: "RoomContext is nil.")
      return NEListenTogetherErrorCode.failed
    }
    return success()
  }

  static func condition(_ success: @escaping () -> Void) {
    guard NEListenTogetherKit.getInstance().isInitialized else {
      NEListenTogetherLog.errorLog(kitTag, desc: "Uninitialized.")
      return
    }
    guard let _ = NEListenTogetherKit.getInstance().roomContext else {
      NEListenTogetherLog.errorLog(kitTag, desc: "RoomContext is nil.")
      return
    }
    success()
  }

  static func syncResult<T: Any>(_ success: @escaping () -> T) -> T? {
    guard NEListenTogetherKit.getInstance().isInitialized else {
      NEListenTogetherLog.errorLog(kitTag, desc: "Uninitialized.")
      return nil
    }
    guard let _ = NEListenTogetherKit.getInstance().roomContext else {
      NEListenTogetherLog.errorLog(kitTag, desc: "RoomContext is nil.")
      return nil
    }
    return success()
  }
}
