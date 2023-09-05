// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Foundation

@objcMembers
class _NECreateLiveResponse: NSObject, Codable {
  var anchor: _NECreateLiveAnchor?
  var live: _NECreateLiveLive?
}

// MARK: 开播

@objcMembers
/// 主播信息
class _NECreateLiveAnchor: NSObject, Codable {
  /// 用户编号
  var userUuid: String?
  /// 房间用户编号
  var rtcUid: Int?
  /// 昵称
  var userName: String?
  /// 头像地址
  var icon: String?
}

@objcMembers
/// 创建房间所需的主题与背景图片
class _NECreateRoomDefaultInfo: NSObject, Codable {
  /// 房间主题
  var topic: String?
  /// 默认背景图
  var livePicture: String?
}

@objcMembers
/// 直播信息
class _NECreateLiveLive: NSObject, Codable {
  /// 应用编号
  var appId: String?
  /// 房间号
  var roomUuid: String?
  /// 创建人账号
  var userUuid: String?
  /// 直播记录编号
  var liveRecordId: Int?
  /// 直播类型
  var liveType: Int?
  /// 直播记录是否有效 1: 有效 -1 无效
  var status: Int?
  /// 直播主题
  var liveTopic: String?
  /// 背景图地址
  var cover: String?
  /// 打赏总额
  var rewardTotal: Int?
  /// 观众人数
  var audienceCount: Int?
  /// 直播状态，0.未开始，1.直播中，2.PK中 3. 惩罚中  4.连麦中  5.等待PK中  6.直播结束
  var live: Int?
  /// 唱歌模式
  var singMode: Int?
  /// 麦位人数
  var onSeatCount: Int?
}

// MARK: 直播列表

@objcMembers
/// 直播信息
class _NEOrderSongListResponse: NSObject, Codable {
  var pageNum: Int?
  var pageSize: Int?
  var size: Int?
  var startRow: Int?
  var endRow: Int?
  var pages: Int?
  var prePage: Int?
  var nextPage: Int?
  var isFirstPage: Bool?
  var isLastPage: Bool?
  var hasPreviousPage: Bool = false
  var hasNextPage: Bool = false
  var navigatePages: Int?
  var navigatepageNums: [Int]?
  var navigateFirstPage: Int?
  var navigateLastPage: Int?
  var total: Int?
  var list: [_NEOrderSongInfoResponse]?
}

// MARK: 直播详情

@objcMembers
/// 直播信息
class _NEOrderSongInfoResponse: NSObject, Codable {
  var anchor: _NECreateLiveAnchor?
  var live: _NECreateLiveLive?
}

/// 设备参数 判断走串行还是实时合唱的参数
class _NEOrderSongDeviceParam: Codable {
  /// 播放延时，单位：ms
  var playDelay: UInt64 = 30
  /// rtt值，单位：ms
  var rtt: UInt64 = 0
  /// 有线耳机，1: 有线耳机，0: 非有线耳机
  var wiredHeadset: Int = 0
  init(_ playDelay: UInt64 = 30,
       rtt: UInt64,
       wiredHeadset: Int) {
    self.playDelay = playDelay
    self.rtt = rtt
    self.wiredHeadset = wiredHeadset
  }
}

enum _NEOrderSongMusicOperationType: Int {
  // 暂停
  case pause = 2
  // 恢复
  case resume = 1
  // 停止
//  case stop
}

// MARK: 打赏

@objcMembers
class _NEOrderSongRewardTop: NSObject, Codable {
  var userUuid: String?
  var userName: String?
  var avatar: String?
  var rewardCoin: Int?
}

@objcMembers
class _NEOrderSongAnchorReward: NSObject, Codable {
  var userUuid: String?
  var pkRewardTotal: Int?
  var rewardTotal: Int?
  var pkRewardTop: [_NEOrderSongRewardTop]?
}

@objcMembers
class _NEOrderSongRewardMessage: NSObject, Codable {
  var subCmd: Int?
  var type: Int?
  var senderUserUuid: String?
  var sendTime: Int?
  var pkStartTime: Int?
  var rewarderUserUuid: String?
  var rewarderUserName: String?
  var giftId: Int?
  var memberTotal: Int?
  var anchorReward: _NEOrderSongAnchorReward?
  var otherAnchorReward: _NEOrderSongAnchorReward?
}
