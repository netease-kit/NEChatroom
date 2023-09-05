// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Foundation

let kitTag = "NELoginSample"
@objcMembers public class NELoginSample {
  /// 单例初始化
  /// - Returns: 单例对象
  public static func getInstance() -> NELoginSample {
    instance
  }

  /// NELoginSample 初始化
  /// - Parameters:
  ///   - config: 初始化配置
  ///   - callback: 回调
  public func initialize(_ config: NELoginSampleConfig,
                         callback: NELoginSampleCallback<AnyObject>? = nil) {
    NELoginSampleLog.setUp(config.appKey)
    NELoginSampleLog.apiLog(kitTag, desc: "Initialize")
    if let baseUrl = config.extras["baseUrl"] {
      NE.config.customUrl = baseUrl
    }
    if let serverUrl = config.extras["serverUrl"] {
      isDebug = serverUrl == "test"
      isOversea = serverUrl == "oversea"
      if !serverUrl.contains("http"), isOversea {
        config.extras["serverUrl"] = "https://roomkit-sg.netease.im"
      }
    }
    self.config = config
    NE.config.isDebug = isDebug
    NE.config.isOverSea = isOversea

    NE.addHeader([
      "appSecret": self.config?.appSecret ?? "",
      "appKey": self.config?.appKey ?? "",
    ])

    isInitialized = true
    NELoginSampleLog.successLog(kitTag, desc: "Successfully initialize.")

    callback?(NELoginSampleErrorCode.success, nil, nil)
  }

  private static let instance = NELoginSample()

  var config: NELoginSampleConfig?
  var isDebug: Bool = false
  /// 初始化状态
  public var isInitialized: Bool = false
  /// 是否出海
  public var isOversea: Bool = false
}
