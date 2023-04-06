// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Foundation
import NERoomKit

/// 登录模块扩展
public extension NEListenTogetherKit {
  /// 是否登录
  var isLoggedIn: Bool {
    NERoomKit.shared().authService.isLoggedIn
  }

  /// 添加登录监听
  /// - Parameter listener: 监听器
  func addAuthListener(_ listener: NEListenTogetherAuthListener) {
    NEListenTogetherLog.apiLog(kitTag, desc: "Add auth listener.")
    authListeners.addWeakObject(listener)
  }

  /// 移除登录监听
  /// - Parameter listener: 监听器
  func removeAuthListener(_ listener: NEListenTogetherAuthListener) {
    NEListenTogetherLog.apiLog(kitTag, desc: "Remove auth listener.")
    authListeners.removeWeakObject(listener)
  }

  /// 登录
  /// - Parameters:
  ///   - account: 账号
  ///   - token: 令牌
  ///   - callback: 回调
  func login(_ account: String,
             token: String,
             resumeLogin: Bool = false,
             callback: NEListenTogetherCallback<AnyObject>? = nil) {
    NEListenTogetherLog.apiLog(kitTag, desc: "Login. Account: \(account). Token: \(token)")

    guard NEListenTogetherKit.getInstance().isInitialized else {
      NEListenTogetherLog.errorLog(kitTag, desc: "Failed to login. Uninitialized.")
      callback?(NEListenTogetherErrorCode.failed, "Failed to login. Uninitialized.", nil)
      return
    }
    if resumeLogin {
      NE.addHeader([
        "user": account,
        "token": token,
      ])
      callback?(NEListenTogetherErrorCode.success, nil, nil)
      return
    }
    NERoomKit.shared().authService.login(account: account,
                                         token: token) { code, str, _ in
      if code == 0 {
        NEListenTogetherLog.successLog(kitTag, desc: "Successfully login.")
        // 登陆成功后，headers添加属性
        NE.addHeader([
          "user": account,
          "token": token,
        ])
//        NEListenTogetherKit.getInstance().copyrightedMediaService?
//          .getSongDynamicTokenUntilSuccess(success: { dynamicToken in
//            guard let dynamicToken = dynamicToken,
//                  let accessToken = dynamicToken.accessToken,
//                  let expiresIn = dynamicToken.expiresIn
//            else {
//              return
//            }
//            guard let appkey = NEListenTogetherKit.getInstance().config?.appKey else {
//              return
//            }
//            NEListenTogetherKit.getInstance().initializeCopyrightedMedia(
//              appkey,
//              token: accessToken,
//              userUuid: account,
//              extras: NEListenTogetherKit.getInstance().config?.extras,
//              success: {
//                NEListenTogetherKit.getInstance().copyrightedMediaService?
//                  .calculateExpiredTime(timeExpired: expiresIn)
//              },
//              failure: { error in
//              }
//            )
//          })
      } else {
        NEListenTogetherLog.errorLog(kitTag, desc: "Failed to login. Code: \(code)")
      }
      callback?(code, str, nil)
    }
  }

  /// 退出登录
  /// - Parameter callback: 回调
  func logout(callback: NEListenTogetherCallback<AnyObject>? = nil) {
    NEListenTogetherLog.apiLog(kitTag, desc: "Logout.")

    guard NEListenTogetherKit.getInstance().isInitialized else {
      NEListenTogetherLog.errorLog(kitTag, desc: "Failed to logout. Uninitialized.")
      callback?(NEListenTogetherErrorCode.failed, "Failed to logout. Uninitialized.", nil)
      return
    }

    NERoomKit.shared().authService.logout { code, str, _ in
      if code == 0 {
        NEListenTogetherLog.successLog(kitTag, desc: "Successfully logout.")
      } else {
        NEListenTogetherLog.errorLog(kitTag, desc: "Failed to logout. Code: \(code)")
      }
      callback?(code, str, nil)
    }
  }
}

extension NEListenTogetherKit: NEAuthListener {
  public func onAuthEvent(evt: NEAuthEvent) {
    DispatchQueue.main.async {
      self.reset()
      for pointerListener in self.authListeners.allObjects {
        guard pointerListener is NEListenTogetherAuthListener, let listener = pointerListener as? NEListenTogetherAuthListener else { continue }

        if listener.responds(to: #selector(NEListenTogetherAuthListener.onVoiceRoomAuthEvent(_:))) {
          listener
            .onVoiceRoomAuthEvent?(NEListenTogetherAuthEvent(rawValue: evt.rawValue) ?? .loggedOut)
        }
      }
    }
  }
}
