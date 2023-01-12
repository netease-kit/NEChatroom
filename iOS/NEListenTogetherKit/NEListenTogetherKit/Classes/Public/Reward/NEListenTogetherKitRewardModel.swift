// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Foundation

@objcMembers
/// 礼物模型
public class NEListenTogetherGiftModel: NSObject {
  /// 发送者账号
  public var sendAccout: String = ""
  /// 发送者昵称
  public var sendNick: String = ""
  /// 礼物编号
  public var giftId: Int = 0
  internal init(_ rewardMsg: _NEListenTogetherRewardMessage) {
    sendAccout = rewardMsg.senderUserUuid ?? ""
    sendNick = rewardMsg.rewarderUserName ?? ""
    giftId = rewardMsg.giftId ?? 0
  }
}
