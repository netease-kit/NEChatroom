// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Foundation
import NERoomKit

@objcMembers
/// 麦位信息
public class NEListenTogetherSeatInfo: NSObject {
  /// 唯一ID
  internal var uuid: String = ""
  /// 麦位创建者
  public var creator: String = ""
  /// 麦位管理员列表
  public var managers: [String] = []
  /// 麦位列表信息
  public var seatItems: [NEListenTogetherSeatItem] = []
  override public init() {
    super.init()
  }

  convenience init(_ info: NESeatInfo) {
    self.init()
    uuid = info.uuid
    creator = info.creator
    managers = info.managers
    var items = [NEListenTogetherSeatItem]()
    info.seatItems.forEach { items.append(NEListenTogetherSeatItem($0)) }
    seatItems = items
  }
}
