// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Foundation

@objc
/// 角色
public enum NEVoiceRoomRole: Int {
  /// 房主
  case host = 0
  /// 听众
  case audience

  func toString() -> String {
    switch self {
    case .host: return "host"
    default: return "audience"
    }
  }
}

@objcMembers
/// 加入房间参数
public class NEJoinVoiceRoomParams: NSObject {
  /// 房间uid
  public var roomUuid: String = ""
  /// 房间内昵称
  public var nick: String = ""
  /// 直播id
  public var liveRecordId: Int = 0
  /// 角色
  public var role: NEVoiceRoomRole = .host
  /// 扩展参数
  public var extraData: String?
}
