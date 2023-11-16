// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Foundation
import NERoomKit

@objcMembers
public class NEVoiceRoomInfo: NSObject {
  /// 主播信息
  public var anchor: NEVoiceRoomAnchor?
  /// 直播信息
  public var liveModel: NEVoiceRoomLiveModel?

  init(create: _NECreateLiveResponse?) {
    if let create = create {
      anchor = NEVoiceRoomAnchor(create.anchor)
      liveModel = NEVoiceRoomLiveModel(create.live)
    }
  }

  init(liveInfo: _NEVoiceRoomInfoResponse?) {
    if let info = liveInfo {
      anchor = NEVoiceRoomAnchor(info.anchor)
      liveModel = NEVoiceRoomLiveModel(info.live)
    }
  }
}

@objcMembers
/// 主播信息
public class NEVoiceRoomAnchor: NSObject {
  /// 用户编号
  public var userUuid: String?
  /// 房间用户编号
  public var rtcUid: Int = 0
  /// 昵称
  public var userName: String?
  /// 头像地址
  public var icon: String?
  init(_ anchor: _NECreateLiveAnchor?) {
    if let anchor = anchor {
      userUuid = anchor.userUuid
      userName = anchor.userName
      icon = anchor.icon
      rtcUid = anchor.rtcUid ?? 0
    }
  }
}

@objcMembers
/// 直播信息
public class NEVoiceRoomLiveModel: NSObject {
  /// 直播记录编号
  public var liveRecordId: Int = 0
  /// 房间号
  public var roomUuid: String?
  /// 创建人账号
  public var userUuid: String?
  /// 直播类型
  public var liveType: NEVoiceRoomLiveRoomType = .multiAudio
  /// 直播记录是否有效 1: 有效 -1 无效
  public var status: Int = 1
  /// 直播状态
  public var live: NEVoiceRoomLiveStatus = .idle
  /// 直播主题
  public var liveTopic: String?
  /// 背景图地址
  public var cover: String?
  /// 打赏总额
  public var rewardTotal: Int = 0
  /// 观众人数
  public var audienceCount: Int = 0
  /// 麦位人数
  public var onSeatCount: Int = 0
  /// 打赏信息
  public var seatUserReward: [NEVoiceRoomBatchSeatUserReward]?
  /// 房间名称
  public var roomName: String?
  /// 当前在玩的游戏
  public var gameName: String?

  init(_ live: _NECreateLiveLive?) {
    if let live = live {
      roomUuid = live.roomUuid
      userUuid = live.userUuid
      liveRecordId = live.liveRecordId ?? 0
      liveType = NEVoiceRoomLiveRoomType(rawValue: Int(live.liveType ?? 3)) ?? .multiAudio
      status = live.status ?? 1
      liveTopic = live.liveTopic
      cover = live.cover
      rewardTotal = live.rewardTotal ?? 0
      audienceCount = live.audienceCount ?? 0
      self.live = NEVoiceRoomLiveStatus(rawValue: Int(live.live ?? 0)) ?? .idle
      onSeatCount = live.onSeatCount ?? 0
      roomName = live.roomName
      if let infoSeatUserReward = live.seatUserReward {
        seatUserReward = infoSeatUserReward.map { NEVoiceRoomBatchSeatUserReward($0) }
      }
      gameName = live.gameName
    }
  }
}

@objcMembers
/// 语聊房 房间列表
public class NEVoiceRoomList: NSObject {
  /// 数据列表
  public var list: [NEVoiceRoomInfo]?
  /// 当前页
  public var pageNum: Int = 0
  /// 是否有下一页
  public var hasNextPage: Bool = false
  init(_ list: _NEVoiceRoomListResponse?) {
    if let list = list {
      pageNum = list.pageNum ?? 1
      hasNextPage = list.hasNextPage
      if let details = list.list {
        self.list = details.compactMap { detail in
          NEVoiceRoomInfo(liveInfo: detail)
        }
      }
    }
  }
}

/// 网络探测配置
@objcMembers
public class NEVoiceRoomRtcLastmileProbeConfig: NSObject {
  // * 是否探测上行网络。
  public var probeUplink: Bool = false
  // * 是否探测下行网络。
  public var probeDownlink: Bool = false
  // * 本端期望的最高发送码率。
  // * 单位为 bps，范围为 [100000, 5000000]。
  // * 推荐参考 `setLocalVideoConfig` 中的码率值设置该参数的值。
  public var expectedUplinkBitrate: UInt = 0
  // * 本端期望的最高接收码率。
  // * <br>单位为 bps，范围为 [100000, 5000000]。
  public var expectedDownlinkBitrate: UInt = 0
}

///  质量探测结果的状态。
@objc
public enum NEVoiceRoomRtcLastmileProbeTestState: Int {
  /// * 表示本次 last mile 质量探测的结果是完整的
  case complete = 1
  /// * 表示本次 last mile 质量探测未进行带宽预测，因此结果不完整。一个可能的原因是测试资源暂时受限
  case incompleteNoBwe
  /// * 未进行 last mile 质量探测。一个可能的原因是网络连接中断
  case unavailable
}

/// 网络质量类型
@objc
public enum NEVoiceRoomRtcNetworkStatusType: Int {
  /// 网络质量未知
  case unknown = 0
  /// 网络质量极好
  case excellent
  /// 用户主观感觉和 excellent 差不多，但码率可能略低于 excellent
  case good
  /// 用户主观感受有瑕疵但不影响沟通
  case poor
  /// 勉强能沟通但不顺畅
  case bad
  /// 网络质量非常差，基本不能沟通
  case veryBad
  /// 完全无法沟通
  case down
}

/// 网络质量探测结果
@objcMembers
public class NEVoiceRoomRtcLastmileProbeTest: NSObject {
  public var state: NEVoiceRoomRtcLastmileProbeTestState
  public var rtt: UInt = 0
  // * 上行网络质量报告。
  public var uplinkReport: NEVoiceRoomRtcLastmileProbeOneWayResult
  // * 下行网络质量报告。
  public var downlinkReport: NEVoiceRoomRtcLastmileProbeOneWayResult

  init(result: NERoomRtcLastmileProbeResult) {
    state = NEVoiceRoomRtcLastmileProbeTestState(rawValue: Int(result.state.rawValue)) ?? .unavailable
    rtt = result.rtt
    uplinkReport = NEVoiceRoomRtcLastmileProbeOneWayResult(result.uplinkReport)
    downlinkReport = NEVoiceRoomRtcLastmileProbeOneWayResult(result.downlinkReport)
  }
}

/// 网络质量探测结果报告
@objcMembers
public class NEVoiceRoomRtcLastmileProbeOneWayResult: NSObject {
  public var packetLossRate: UInt = 0
  public var jitter: UInt = 0
  public var availableBandwidth: UInt = 0
  convenience init(_ result: NERoomRtcLastmileProbeOneWayResult) {
    self.init()
    packetLossRate = result.packetLossRate
    jitter = result.jitter
    availableBandwidth = result.availableBandwidth
  }
}
