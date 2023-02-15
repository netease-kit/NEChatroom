// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Foundation

@objcMembers
public class NEListenTogetherInfo: NSObject {
  /// 主播信息
  public var anchor: NEListenTogetherAnchor?
  /// 直播信息
  public var liveModel: NEListenTogetherLiveModel?

  internal init(create: _NECreateLiveResponse?) {
    if let create = create {
      anchor = NEListenTogetherAnchor(create.anchor)
      liveModel = NEListenTogetherLiveModel(create.live)
    }
  }

  internal init(liveInfo: _NEListenTogetherInfoResponse?) {
    if let info = liveInfo {
      anchor = NEListenTogetherAnchor(info.anchor)
      liveModel = NEListenTogetherLiveModel(info.live)
    }
  }
}

@objcMembers
/// 主播信息
public class NEListenTogetherAnchor: NSObject {
  /// 用户编号
  public var userUuid: String?
  /// 房间用户编号
  public var rtcUid: Int = 0
  /// 昵称
  public var userName: String?
  /// 头像地址
  public var icon: String?
  internal init(_ anchor: _NECreateLiveAnchor?) {
    if let anchor = anchor {
      userUuid = anchor.userUuid
      userName = anchor.userName
      icon = anchor.icon
    }
  }
}

@objcMembers
/// 直播信息
public class NEListenTogetherLiveModel: NSObject {
  /// 应用编号
  public var appId: String = ""
  /// 房间号
  public var roomUuid: String?
  /// 创建人账号
  public var userUuid: String?
  /// 直播记录编号
  public var liveRecordId: Int = 0
  /// 直播类型
  public var liveType: NEListenTogetherLiveRoomType = .multiAudio
  /// 直播记录是否有效 1: 有效 -1 无效
  public var status: Int = 1
  /// 直播主题
  public var liveTopic: String?
  /// 背景图地址
  public var cover: String?
  /// 打赏总额
  public var rewardTotal: Int = 0
  /// 观众人数
  public var audienceCount: Int = 0
  /// 直播状态
  public var live: NEListenTogetherLiveStatus = .idle
  /// 唱歌模式
  ///  public var singMode: NEKaraokeSingMode = .AIChorus
  /// 麦位人数
  public var onSeatCount: Int = 0

  internal init(_ live: _NECreateLiveLive?) {
    if let live = live {
      roomUuid = live.roomUuid
      userUuid = live.userUuid
      liveRecordId = live.liveRecordId ?? 0
      liveType = NEListenTogetherLiveRoomType(rawValue: Int(live.liveType ?? 3)) ?? .multiAudio
      status = live.status ?? 1
      liveTopic = live.liveTopic
      cover = live.cover
      rewardTotal = live.rewardTotal ?? 0
      audienceCount = live.audienceCount ?? 0
      self.live = NEListenTogetherLiveStatus(rawValue: UInt(live.live ?? 0)) ?? .idle
      /// singMode = NEKaraokeSingMode(rawValue: live.singMode ?? 0) ?? .AIChorus
      onSeatCount = live.onSeatCount ?? 0
    }
  }
}

@objcMembers
/// Karaoke 房间列表
public class NEListenTogetherList: NSObject {
  /// 数据列表
  public var list: [NEListenTogetherInfo]?
  /// 当前页
  public var pageNum: Int = 0
  /// 是否有下一页
  public var hasNextPage: Bool = false
  internal init(_ list: _NEListenTogetherListResponse?) {
    if let list = list {
      pageNum = list.pageNum ?? 0
      hasNextPage = list.hasNextPage
      if let details = list.list {
        self.list = details.compactMap { detail in
          NEListenTogetherInfo(liveInfo: detail)
        }
      }
    }
  }
}
