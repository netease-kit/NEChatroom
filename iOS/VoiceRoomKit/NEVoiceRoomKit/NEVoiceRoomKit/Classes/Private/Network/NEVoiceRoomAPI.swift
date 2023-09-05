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
    "/scene/apps/\(NEVoiceRoomKit.getInstance().config?.appKey ?? "")/ent/live/v1"
  // 房间模块
  enum Room {
    static let create = NEAPIItem("/nemo/entertainmentLive/live/createLive", desc: "创建房间")
    static let roomList = NEAPIItem("/nemo/entertainmentLive/live/list", desc: "获取房间列表")
    static let destroy = NEAPIItem("/nemo/entertainmentLive/live/destroyLive", desc: "结束房间")
    static let reward = NEAPIItem("\(NEAPI.prePath)/reward", desc: "打赏功能")
    static let batchReward = NEAPIItem("/nemo/entertainmentLive/live/batch/reward", desc: "批量打赏功能")
    static let info = NEAPIItem("/nemo/entertainmentLive/live/info", desc: "获取房间详情")
    static let auth = NEAPIItem("/nemo/entertainmentLive/real-name-authentication", desc: "实名认证")
    static let liveInfo = NEAPIItem(
      "/nemo/entertainmentLive/live/getDefaultLiveInfo",
      desc: "获取直播主题及背景图",
      method: .get
    )
  }

  // 音乐模块
  enum Music {
    static let pre_path =
      "/scene/apps/\(NEVoiceRoomKit.getInstance().config?.appKey ?? "")/ent/listen/v1"

//    static func info(_ roomUuid: String) -> NEAPIItem {
//      NEAPIItem("\(pre_path)/\(roomUuid)/info", desc: "获取房间当前演唱信息")
//    }
  }
}
