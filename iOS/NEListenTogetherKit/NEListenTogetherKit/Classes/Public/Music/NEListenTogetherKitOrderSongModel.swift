// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Foundation

@objcMembers
/// 点歌模型
public class NEListenTogetherOrderSongModel: NSObject, Codable {
  /// 点歌编号
  public var orderId: Int64 = 0
  /// 应用编号
  public var appId: String = ""
  /// 房间编号
  public var roomUuid: String = ""
  private var userUuid: String?
  /// 用户编号
  public var account: String {
    get {
      userUuid ?? ""
    }
    set {
      userUuid = newValue
    }
  }

  /// 用户名称
  public var userName: String?
  /// 用户头像
  public var icon: String?
  /// 歌曲标号
  public var songId: String = ""
  /// 歌曲名称
  public var songName: String?
  /// 播放URL
  public var songCover: String?
  /// 演唱者
  public var singer: String?
  /// 歌手封面
  public var singerCover: String?
  /// 歌曲时长
  public var songTime: Int?
  /// Object-C使用
  public var oc_songTime: Int {
    get {
      songTime ?? 0
    }
    set {
      songTime = newValue
    }
  }

  // 附带消息
  public var nextOrderSong: NEListenTogetherOrderSongModel?
  public var attachment: String?

  /// 操作者信息
  public var actionOperator: NEListenTogetherOperator?

  /// 歌曲状态 -2 已唱 -1 删除 0:等待唱 1 唱歌中
  public var status: Int?
  /// Object-C使用
  public var oc_status: Int {
    status ?? -2
  }

  /// 是否置顶（1 置顶 0 否)
  public var setTop: Int?
  /// Object-C使用 是否置顶（1 置顶 0 否)
  public var oc_setTop: Int {
    setTop ?? 0
  }

  /// 版权来源：1：云音乐  2、咪咕
  public var channel: Int?
  /// Object-C使用  版权来源：1：云音乐  2、咪咕
  public var oc_channel: Int {
    get {
      channel ?? 1
    }
    set {
      channel = newValue
    }
  }
}
