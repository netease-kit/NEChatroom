// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Foundation
import UIKit

enum Configs {
  static var extras: [String: String] {
    IS_OVERSEA ? ["serverUrl": "oversea"] : [String: String]()
  }

  static var AppKey: String {
    APP_KEY
  }

  static var AppSecret: String {
    APP_SECRET
  }

  static var voiceRoomBaseUrl: String {
    IS_OVERSEA ? BASE_URL_OVERSEA : BASE_URL
  }

  static var orderSongBaseUrl: String {
    IS_OVERSEA ? BASE_URL_OVERSEA : BASE_URL
  }

  static var loginSampleBaseUrl: String {
    IS_OVERSEA ? BASE_URL_OVERSEA : BASE_URL
  }

  static var privacyUrl: String {
    UIDevice.isChinese ? "https://yx-web-nosdn.netease.im/quickhtml/assets/yunxin/protocol/clauses.html" : "https://yx-web-nosdn.netease.im/quickhtml/assets/yunxin/protocol/policy.html"
  }

  static var termsUrl: String {
    UIDevice.isChinese ? "https://yunxin.163.com/m/clauses/user" : "https://commsease.com/en/m/clauses/user"
  }
}

// MARK: 全局变量，无需填写

var userUuid: String = ""
var userToken: String = ""
var userName: String = ""
var icon: String = ""
