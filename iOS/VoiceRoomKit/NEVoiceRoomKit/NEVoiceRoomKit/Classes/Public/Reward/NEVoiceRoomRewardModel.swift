// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Foundation

@objcMembers
/// 礼物模型
public class NEVoiceRoomBatchGiftModel: NSObject {
  /// 发送者账号
  public var sendAccout: String = ""
  /// 礼物编号
  public var giftId: Int = 0
  /// 礼物个数
  public var giftCount: Int = 0

  public var rewarderUserUuid: String = ""
//  // 打赏者昵称
  public var rewarderUserName: String = ""
//  public var rewardeeUserUuid: String = ""
//  // 被打赏者昵称
//  public var rewardeeUserName: String = ""

  /// 麦上主播或者观众打赏信息
  public var seatUserReward: [NEVoiceRoomBatchSeatUserReward]
  ///
  public var rewardeeUsers: [NEVoiceRoomBatchSeatUserRewardee]

  init(_ rewardMsg: _NEVoiceRoomBatchRewardMessage) {
    sendAccout = rewardMsg.senderUserUuid ?? ""
    giftId = rewardMsg.giftId ?? 0
    giftCount = rewardMsg.giftCount ?? 0
    rewarderUserName = rewardMsg.userName ?? ""
    rewarderUserUuid = rewardMsg.userUuid ?? ""
    seatUserReward = rewardMsg.seatUserReward.map { NEVoiceRoomBatchSeatUserReward($0) }
    rewardeeUsers = rewardMsg.targets.map { NEVoiceRoomBatchSeatUserRewardee($0) }
  }
}

@objcMembers
public class NEVoiceRoomBatchSeatUserReward: NSObject {
  public var seatIndex: Int = 0
  public var userUuid: String?
  public var userName: String?
  public var rewardTotal: Int = 0
  public var icon: String?

  init(_ batchSeatUserReward: _NEVoiceRoomBatchSeatUserReward?) {
    if let batchSeatUserReward = batchSeatUserReward {
      seatIndex = batchSeatUserReward.seatIndex
      userUuid = batchSeatUserReward.userUuid
      userName = batchSeatUserReward.userName
      rewardTotal = batchSeatUserReward.rewardTotal
      icon = batchSeatUserReward.icon
    }
  }
}

@objcMembers
public class NEVoiceRoomBatchSeatUserRewardee: NSObject {
  public var userUuid: String?
  public var userName: String?
  public var icon: String?

  init(_ batchSeatUserReward: _NEVoiceRoomBatchSeatUserRewardee?) {
    if let batchSeatUserRewardee = batchSeatUserReward {
      userUuid = batchSeatUserRewardee.userUuid
      userName = batchSeatUserRewardee.userName
      icon = batchSeatUserRewardee.icon
    }
  }
}
