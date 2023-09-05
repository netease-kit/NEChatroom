// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Foundation

@objc public class NemoAccount: NSObject, Codable {
  // 用户信息
  public var userUuid: String = ""
  // 手机
  public var mobile: String = ""
  // 昵称
  public var userName: String = ""
  // 头像
  public var icon: String?
  // rtcUid
  public var rtcUid: UInt64?
  // userToken
  public var userToken: String = ""
  // imToken
  public var imToken: String = ""
  // sex
  public var sex: Int = 0
}

///  质量探测结果的状态。
@objc
public enum NemoSceneType: Int {
  /// 1v1
  case oneOnOne = 1
  /// 语聊房
  case voiceRoom
}
