// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Foundation
import NERoomKit

@objcMembers

/// 创建Karaoke房间参数
public class NEListenTogetherCreateVoiceRoomParams: NSObject {
  /// 房间名称
  public var title: String = ""
  /// 房间内昵称
  public var nick: String = ""
  /// 扩展参数
  public var extraData: String?
  /// 直播封面图
  public var cover: String?
  /// 模版 ID
  public var configId: Int = 0
  /// 麦位数量。如果设置为大于**0**的值，则会在创建的房间中启用麦位管理
  public var seatCount: Int = 0
  /// 麦位模式，0：自由模式，1：管理员控制模式，不传默认为自由模式
  internal var seatMode: Int = 1
  public var liveType: NEListenTogetherLiveRoomType = .multiAudio
}
