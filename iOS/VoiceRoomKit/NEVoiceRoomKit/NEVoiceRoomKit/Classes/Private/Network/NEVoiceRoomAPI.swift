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
  // 房间模块
  enum Room {
    static let prePath = "/nemo/entertainmentLive/live"
    static let create = NEAPIItem("\(prePath)/createLive", desc: "创建房间")
    static let roomList = NEAPIItem("\(prePath)/list", desc: "获取房间列表")
    static let destroy = NEAPIItem("\(prePath)/destroyLive", desc: "结束房间")
    static let batchReward = NEAPIItem("\(prePath)/batch/reward", desc: "批量打赏功能")
    static let info = NEAPIItem("\(prePath)/info", desc: "获取房间详情")
    static let auth = NEAPIItem("/nemo/entertainmentLive/real-name-authentication", desc: "实名认证")
    static let liveInfo = NEAPIItem("\(prePath)/getDefaultLiveInfo", desc: "获取直播主题及背景图", method: .get)
  }
}
