// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Foundation

@objcMembers
public class NEVoiceRoomPlayMusicInfo: NSObject, Codable {
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
}
