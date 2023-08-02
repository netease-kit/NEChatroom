// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Foundation
import NERoomKit

/// 登录模块扩展
public extension NEVoiceRoomKit {
  /// 是否登录
  var isLoggedIn: Bool {
    NERoomKit.shared().authService.isLoggedIn
  }

  /// 添加登录监听
  /// - Parameter listener: 监听器
  func addAuthListener(_ listener: NEVoiceRoomAuthListener) {
    NEVoiceRoomLog.apiLog(kitTag, desc: "Add auth listener.")
    authListeners.addWeakObject(listener)
  }

  /// 移除登录监听
  /// - Parameter listener: 监听器
  func removeAuthListener(_ listener: NEVoiceRoomAuthListener) {
    NEVoiceRoomLog.apiLog(kitTag, desc: "Remove auth listener.")
    authListeners.removeWeakObject(listener)
  }

  /// 登录
  /// - Parameters:
  ///   - account: 账号
  ///   - token: 令牌
  ///   - callback: 回调
  func login(_ account: String,
             token: String,
             callback: NEVoiceRoomCallback<AnyObject>? = nil) {
    NEVoiceRoomLog.apiLog(kitTag, desc: "Login. Account: \(account). Token: \(token)")

    guard NEVoiceRoomKit.getInstance().isInitialized else {
      NEVoiceRoomLog.errorLog(kitTag, desc: "Failed to login. Uninitialized.")
      callback?(NEVoiceRoomErrorCode.failed, "Failed to login. Uninitialized.", nil)
      return
    }

    NERoomKit.shared().authService.login(account: account,
                                         token: token) { code, str, _ in
      if code == 0 {
        NEVoiceRoomLog.successLog(kitTag, desc: "Successfully login.")
        // 登陆成功后，headers添加属性
        NE.addHeader([
          "user": account,
          "token": token,
          "appkey": self.config?.appKey ?? "",
        ])
      } else {
        NEVoiceRoomLog.errorLog(kitTag, desc: "Failed to login. Code: \(code)")
      }
      callback?(code, str, nil)
    }
  }

  /// 退出登录
  /// - Parameter callback: 回调
  func logout(callback: NEVoiceRoomCallback<AnyObject>? = nil) {
    NEVoiceRoomLog.apiLog(kitTag, desc: "Logout.")

    guard NEVoiceRoomKit.getInstance().isInitialized else {
      NEVoiceRoomLog.errorLog(kitTag, desc: "Failed to logout. Uninitialized.")
      callback?(NEVoiceRoomErrorCode.failed, "Failed to logout. Uninitialized.", nil)
      return
    }

    NERoomKit.shared().authService.logout { code, str, _ in
      if code == 0 {
        NEVoiceRoomLog.successLog(kitTag, desc: "Successfully logout.")
      } else {
        NEVoiceRoomLog.errorLog(kitTag, desc: "Failed to logout. Code: \(code)")
      }
      callback?(code, str, nil)
    }
  }
}

extension NEVoiceRoomKit: NEAuthListener {
  public func onAuthEvent(evt: NEAuthEvent) {
    for pointerListener in authListeners.allObjects {
      guard let listener = pointerListener as? NEVoiceRoomAuthListener else { continue }
      if listener.responds(to: #selector(NEVoiceRoomAuthListener.onVoiceRoomAuthEvent(_:))) {
        listener
          .onVoiceRoomAuthEvent?(NEVoiceRoomAuthEvent(rawValue: evt.rawValue) ?? .loggedOut)
      }
    }
  }
}
