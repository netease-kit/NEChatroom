// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Foundation
import NERoomKit

@objcMembers
/// 文本聊天消息
public class NEVoiceRoomChatTextMessage: NSObject {
  /// 消息来源
  public var fromUserUuid: String = ""
  /// 发送端昵称
  public var fromNick: String?
  /// 消息接受
  public var toUserUuidList: [String]?
  /// 消息发送时间
  public var time: TimeInterval = 0
  /// 消息文本
  public var text: String?
  override public init() {
    super.init()
  }

  init(_ message: NERoomChatTextMessage) {
    fromUserUuid = message.fromUserUuid
    fromNick = message.fromNick
    toUserUuidList = message.toUserUuidList
    time = message.time ?? 0
    text = message.text
  }
}
