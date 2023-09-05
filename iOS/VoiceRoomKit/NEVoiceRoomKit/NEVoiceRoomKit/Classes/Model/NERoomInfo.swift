// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Foundation

@objc
open class NERoomInfo: NSObject {
  /// 房间唯一标识
  @objc
  public var roomId: String?

  /// 创建者Id
  @objc
  public var creatorId: String?

  /// 创建者头像
  @objc
  public var creatorAvatarURL: URL?

  /// 创建者昵称
  @objc
  public var creatorNickname: String?

  /// 房间标题
  @objc
  public var title: String?

  /// 房间封面URL
  @objc
  public var coverURL: URL?

  /// 0: 旁路推流, 1: Rtc
  @objc
  public var pushType: NELiveRoomPushType = .RTC

  /// 房间类型
  @objc
  public var roomType: NEVoiceRoomLiveRoomType = .multiAudio

  /// 创建时间
  @objc
  public var createTime: Date?

  /// 人数
  @objc
  public var memberCount: Int = 0

  /// 初始化
  @objc
  init(dictionary: [AnyHashable: Any]) {
    super.init()
    if let avRoomDic = dictionary["avRoom"] as? [AnyHashable: Any] {
      roomId = avRoomDic["roomId"] as? String
      creatorId = avRoomDic["creatorAccountId"] as? String
      title = avRoomDic["roomTopic"] as? String
      if let createTime = avRoomDic["roomCreateTime"] as? UInt64 {
        self.createTime = Date(timeIntervalSince1970: Double(createTime) / 1000.0)
      }
    }
    if let liveHostRecordDic = dictionary["liveHostRecord"] as? [AnyHashable: Any] {
      if let cover = liveHostRecordDic["cover"] as? String {
        coverURL = URL(string: cover)
      }
      if let pushTypeRaw = liveHostRecordDic["pushType"] as? Int {
        pushType = NELiveRoomPushType(rawValue: pushTypeRaw) ?? .RTC
      }
      if let roomTypeRaw = liveHostRecordDic["type"] as? Int {
        roomType = NEVoiceRoomLiveRoomType(rawValue: roomTypeRaw) ?? .multiAudio
      }
      creatorNickname = liveHostRecordDic["nickname"] as? String
      if let creatorAvatarURLString = liveHostRecordDic["avatar"] as? String {
        creatorAvatarURL = URL(string: creatorAvatarURLString)
      }
    }
    memberCount = dictionary["memberCount"] as? Int ?? 0
  }
}
