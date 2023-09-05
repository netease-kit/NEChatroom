// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Foundation

/// 点歌协议模型
@objcMembers
/// 点歌返回模型
public class NEOrderSongProtocolResult: NSObject, Codable {
  public var orderSongResultDto: NEOrderSongResponse?
  // 下一首歌曲
  public var nextOrderSong: NEOrderSongResponse?
  // 附带消息
  public var attachment: String?
  // 操作者消息
  public var operatorUser: NEOrderSongResponseOrderSongUserModel?
}

@objcMembers
/// 点歌返回模型
public class NEOrderSongResponse: NSObject, Codable {
  public var orderSong: NEOrderSongResponseOrderSongModel?
  public var orderSongUser: NEOrderSongResponseOrderSongUserModel?
}

@objcMembers
public class NEOrderSongResponseOrderSongModel: NSObject, Codable {
  /// 点歌编号
  public var orderId: Int64 = 0
  /// 直播间记录编号
  public var liveRecordId: Int64 = 0
  /// 房间编号
  public var roomUuid: String = ""
  /// 歌曲状态 -2 已唱 -1 删除 0:等待唱 1 唱歌中
  public var status: Int?
  /// Object-C使用
  public var oc_status: Int {
    status ?? -2
  }

  /// 歌曲标号
  public var songId: String = ""
  /// 歌曲名称
  public var songName: String?
  /// 歌曲封面
  public var songCover: String?
  /// 演唱者
  public var singer: String?
  /// 歌手封面
  public var singerCover: String?

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

  /// 获取已点列表的时候，服务器会返回这个数据，包含点歌信息
  public var orderSongUser: NEOrderSongResponseOrderSongUserModel?

  /// 获取已点列表的时候，服务器会返回这个数据  歌曲时长
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
}

@objcMembers
public class NEOrderSongResponseOrderSongUserModel: NSObject, Codable {
  public var userUuid: String?
  /// 用户名称
  public var userName: String?
  /// 用户头像
  public var icon: String?
}

@objcMembers
/// 点歌模型
public class NEOrderSongOrderSongParams: NSObject {
  /// 歌曲标号
  public var songId: String = ""
  /// 歌曲名称
  public var songName: String?

  /// 歌曲封面
  public var songCover: String?

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

  /// 演唱者
  public var singer: String?
}
