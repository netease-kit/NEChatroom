// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Foundation

struct NEAPIItem: NEAPIProtocol {
  let urlPath: String
  var url: String { NE.config.baseUrl + urlPath }
  let description: String
  let extra: String?
  var method: NEHttpMethod
  init(_ url: String,
       desc: String,
       method: NEHttpMethod = .post,
       extra: String? = nil) {
    urlPath = url
    self.method = method
    description = desc
    self.extra = extra
  }
}

enum NEAPI {
  static let prePath =
    "/scene/apps/\(NEOrderSong.getInstance().config?.appKey ?? "")/ent/live/v1"
  // 房间模块
  enum Room {
    static let create = NEAPIItem("\(NEAPI.prePath)/createLive", desc: "创建房间")
    static let roomList = NEAPIItem("\(NEAPI.prePath)/list", desc: "获取房间列表")
    static let destroy = NEAPIItem("\(NEAPI.prePath)/destroyLive", desc: "结束房间")
    static let reward = NEAPIItem("\(NEAPI.prePath)/reward", desc: "打赏功能")
    static let info = NEAPIItem("\(NEAPI.prePath)/info", desc: "获取房间详情")
    static let liveInfo = NEAPIItem(
      "\(NEAPI.prePath)/getDefaultLiveInfo",
      desc: "获取直播主题及背景图",
      method: .get
    )
  }

  // 音乐模块
  enum Music {
    static let pre_path =
      "/scene/apps/\(NEOrderSong.getInstance().config?.appKey ?? "")/ent/listen/v1"

    static func ready(_ roomUuid: String) -> NEAPIItem {
      NEAPIItem("\(pre_path)/\(roomUuid)/ready", desc: "播放ready")
    }

    static func action(_ roomUuid: String) -> NEAPIItem {
      NEAPIItem("\(pre_path)/\(roomUuid)/listenAction", desc: "暂停/继续/结束演唱")
    }

    static func info(_ roomUuid: String) -> NEAPIItem {
      NEAPIItem("\(pre_path)/\(roomUuid)/info", desc: "获取房间当前演唱信息")
    }
  }

  enum PickSong {
    static let pre_path = "/scene/apps/\(NEOrderSong.getInstance().config?.appKey ?? "")/ent/song"
    static func getMusicToken() -> NEAPIItem {
      NEAPIItem("\(pre_path)/v2/getMusicToken", desc: "获取实时计算Token")
    }

    static func orderSong(_ roomUuid: String) -> NEAPIItem {
      NEAPIItem("\(pre_path)/\(roomUuid)/v1/song/orderSong", desc: "点歌")
    }

    static func getOrderedSongs(_ roomUuid: String) -> NEAPIItem {
      NEAPIItem("\(pre_path)/\(roomUuid)/v1/orderSongs", desc: "获取已点列表", method: .get)
    }

    static func deleteSong(_ roomUuid: String) -> NEAPIItem {
      NEAPIItem("\(pre_path)/\(roomUuid)/v1/cancelOrderSong", desc: "删除已点歌曲")
    }

    static func topSong(_ roomUuid: String) -> NEAPIItem {
      NEAPIItem("\(pre_path)/\(roomUuid)/v1/songSetTop", desc: "置顶歌曲")
    }

    static func switchSong(_ roomUuid: String) -> NEAPIItem {
      NEAPIItem("\(pre_path)/\(roomUuid)/v1/switchSong", desc: "切歌")
    }
  }
}
