// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Foundation
import NERoomKit

/// 登录模块扩展
public extension NEOrderSong {
  /// 登录成功后调用，主要初始化一些配置，不进行NERoom登录
  /// - Parameters:
  ///   - account: 账号
  ///   - token: 令牌
  ///   - callback: 回调
  func loginInitConfig(_ account: String,
                       token: String,
                       callback: NEOrderSongCallback<AnyObject>? = nil) {
    NEOrderSongLog.apiLog(kitTag, desc: "Login. Account: \(account). Token: \(token)")

    guard NEOrderSong.getInstance().isInitialized else {
      NEOrderSongLog.errorLog(kitTag, desc: "Failed to login. Uninitialized.")
      callback?(NEOrderSongErrorCode.failed, "Failed to login. Uninitialized.", nil)
      return
    }

    NEOrderSongLog.successLog(kitTag, desc: "Successfully login.")
    // 登陆成功后，headers添加属性
    NE.addHeader([
      "user": account,
      "token": token,
    ])
    NEOrderSong.getInstance().copyrightedMediaService?
      .getSongDynamicTokenUntilSuccess(success: { dynamicToken in
        guard let dynamicToken = dynamicToken,
              let accessToken = dynamicToken.accessToken,
              let expiresIn = dynamicToken.expiresIn
        else {
          return
        }
        guard let appkey = NEOrderSong.getInstance().config?.appKey else {
          return
        }
        NEOrderSong.getInstance().initializeCopyrightedMedia(
          appkey,
          token: accessToken,
          userUuid: account,
          extras: NEOrderSong.getInstance().config?.extras,
          success: {
            NEOrderSong.getInstance().copyrightedMediaService?
              .calculateExpiredTime(timeExpired: expiresIn)
          },
          failure: { error in
          }
        )
      })
    callback?(NEOrderSongErrorCode.success, "", nil)
  }
}
