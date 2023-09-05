// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Foundation
import NERoomKit

@objcMembers
/// 麦位请求模型
public class NEVoiceRoomSeatRequestItem: NSObject {
  /// 麦位位置，如果为-1，表示未指定位置。
  public var index: Int = -1
  /// 申请人
  public var user: String = ""
  /// 麦序状态 0 麦上无人 1 麦被占 2 已上麦 -1 麦位关闭
  var status: Int = 0
  /// 用户名
  public var userName: String?
  /// 用户头像
  public var icon: String?
  /// 房间号
  var roomUuid: String = ""
  override public init() {
    super.init()
  }

  convenience init(_ item: NESeatRequestItem) {
    self.init()
    index = item.index
    user = item.user
    status = item.status
    userName = item.userName
    icon = item.icon
    roomUuid = item.roomUuid
  }
}
