// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Foundation

@objcMembers
/// 动作操作人
public class NEListenTogetherOperator: NSObject, Codable {
  /// 操作人ID
  private var userUuid: String?
  public var account: String {
    userUuid ?? ""
  }

  /// 操作人昵称
  public var userName: String?
  /// 操作人头像
  public var icon: String?
}

@objcMembers
public class NEListenTogetherPlayMusicInfo: NSObject, Codable {
  /// 应用id
  public var appId: String?
  /// 渠道
  public var channel: Int?
  /// 点歌编号
  public var orderId: Int64 = 0
  /// 房间uuid
  public var roomUuid: String = ""
  /// 歌曲封面
  public var songCover: String?
  /// 歌手名称
  public var singer: String?
  /// 歌手封面
  public var singerCover: String?
  /// 歌曲名称
  public var songName: String?

  /// 歌曲编号
  public var songId: String?
  /// 状态：0: 暂停  1:播放  2:结束
  public var songStatus: Int?
  /// 歌曲时长
  public var songTime: Int?

  /// oc使用 状态：0: 暂停  1:播放  2:结束
  public var oc_songStatus: Int {
    songStatus ?? 0
  }

  /// Object-C使用
  /// 歌曲时长
  public var oc_songTime: Int {
    songTime ?? 0
  }

  public var oc_channel: Int {
    channel ?? 0
  }

  override public init() {
    super.init()
  }
}

@objcMembers
/// 邀请合唱模型
public class NEListenTogetherSongModel: NSObject, Codable {
  /// 额外参数
  public var ext: [String: Any]?

  public var actionOperator: NEListenTogetherOperator?
  public var playMusicInfo: NEListenTogetherPlayMusicInfo?

  enum CodingKeys: String, CodingKey {
    case ext,
         actionOperator = "operatorInfo",
         playMusicInfo
  }

  override public init() {
    super.init()
  }

  public convenience init(_ orderModel: NEListenTogetherOrderSongModel) {
    self.init()
    playMusicInfo = NEListenTogetherPlayMusicInfo()
    playMusicInfo?.appId = orderModel.appId
    playMusicInfo?.channel = orderModel.channel
    playMusicInfo?.orderId = orderModel.orderId
    playMusicInfo?.roomUuid = orderModel.roomUuid
    playMusicInfo?.songCover = orderModel.songCover
    playMusicInfo?.singer = orderModel.singer
    playMusicInfo?.singerCover = orderModel.songCover
    playMusicInfo?.singer = orderModel.singer
    playMusicInfo?.songName = orderModel.songName
    playMusicInfo?.songId = orderModel.songId
    playMusicInfo?.songTime = orderModel.songTime
    actionOperator? = orderModel.actionOperator ?? NEListenTogetherOperator()
  }

  public required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    ext = try container.decodeIfPresent([String: Any].self, forKey: .ext)
    actionOperator = try container.decodeIfPresent(
      NEListenTogetherOperator.self,
      forKey: .actionOperator
    )
    playMusicInfo = try container.decodeIfPresent(NEListenTogetherPlayMusicInfo.self, forKey: .playMusicInfo)
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encodeIfPresent(ext, forKey: .ext)
    try container.encodeIfPresent(actionOperator, forKey: .actionOperator)
    try container.encodeIfPresent(playMusicInfo, forKey: .playMusicInfo)
  }
}
