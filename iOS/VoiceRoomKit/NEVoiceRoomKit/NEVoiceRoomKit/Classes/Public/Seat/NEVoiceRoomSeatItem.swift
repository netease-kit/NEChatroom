// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Foundation
import NERoomKit

@objc
/// 麦位状态
public enum NEVoiceRoomSeatItemStatus: Int {
  /// 麦位初始化 (无人，可上麦)
  case initial = 0
  /// 该麦位正在等待管理员通过申请或等待成员接受邀请后上麦
  case waiting = 1
  /// 当前麦位已被占用
  case taken = 2
  /// 当前麦位已关闭, 不能操作上麦
  case closed = -1
}

@objcMembers
/// 单个麦位信息
public class NEVoiceRoomSeatItem: NSObject {
  /// 麦位位置
  public var index: Int = 0
  /// 麦位状态, 参考[NESeatItemStatus]
  public var status: NEVoiceRoomSeatItemStatus = .initial
  /// 当前状态关联的用户
  public var user: String?
  /// 用户名
  public var userName: String?
  /// 用户头像
  public var icon: String?
  /// 时间戳
  public var updated: Int64 = 0

  override public init() {
    super.init()
  }

  convenience init(_ item: NESeatItem) {
    self.init()
    index = item.index
    status = NEVoiceRoomSeatItemStatus(rawValue: item.status.rawValue) ?? .initial
    user = item.user
    updated = item.updated
    userName = item.userName
    icon = item.icon
  }
}
