// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Foundation
import UIKit

enum NPTConfig {
  case online
  case worldwide
}

enum Configs {
  static var config: NPTConfig {
    get {
      if let config = UserDefaults.standard.string(forKey: "NPTConfig") {
        switch config {
        case "online":
            return .online
        case "worldwide":
            return .worldwide
        default:
            return .online
        }
      } else {
        UserDefaults.standard.setValue("online", forKey: "NPTConfig")
        UserDefaults.standard.synchronize()
      }
        return .online
    }
    set {
      switch newValue {
      case .online:
        UserDefaults.standard.setValue("online", forKey: "NPTConfig")
        UserDefaults.standard.synchronize()
      case .worldwide:
        UserDefaults.standard.setValue("worldwide", forKey: "NPTConfig")
        UserDefaults.standard.synchronize()
      }
    }
  }

  static var extras: [String: String] {
    switch config {
    case .online:
      return [String: String]()
    case .worldwide:
      return ["serverUrl": "oversea"]
    }
  }

  static var AppKey: String {
    switch config {
    case .online:
      return APP_KEY_MAINLAND
    case .worldwide:
      return APP_KEY_OVERSEA
    }
  }

  static var AppSecret: String {
    switch config {
    case .online:
      return APP_SECRET_MAINLAND
    case .worldwide:
      return APP_SECRET_OVERSEA
    }
  }

  static var voiceRoomBaseUrl: String {
    switch config {
    case .online:
      return kApiHost
    case .worldwide:
      return kOverSeaApiHost
    }
  }

  static var orderSongBaseUrl: String {
    switch config {
    case .online:
      return kApiHost
    case .worldwide:
      return kOverSeaApiHost
    }
  }

  static var loginSampleBaseUrl: String {
    switch config {
    case .online:
      return kApiHost
    case .worldwide:
      return kOverSeaApiHost
    }
  }

  static var privacyUrl: String {
    UIDevice.isChinese ? "https://yx-web-nosdn.netease.im/quickhtml/assets/yunxin/protocol/clauses.html" : "https://yx-web-nosdn.netease.im/quickhtml/assets/yunxin/protocol/policy.html"
  }

  static var termsUrl: String {
    UIDevice.isChinese ? "https://yunxin.163.com/m/clauses/user" : "https://commsease.com/en/m/clauses/user"
  }

  static var isSupportAIGC: Bool {
    get {
      // bool没有空值，无法区分未设值与设值为NO的情况，所以用string
      if let isSupport = UserDefaults.standard.string(forKey: "NPTSupportAIGC"),
         isSupport == "NO" {
        return false
      } else {
        return true
      }
    }
    set {
      UserDefaults.standard.setValue(newValue ? "YES" : "NO", forKey: "NPTSupportAIGC")
      UserDefaults.standard.synchronize()
    }
  }
}
