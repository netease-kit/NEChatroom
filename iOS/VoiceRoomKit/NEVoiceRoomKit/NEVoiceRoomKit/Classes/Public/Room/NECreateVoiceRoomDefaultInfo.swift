// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Foundation

@objcMembers
/// 创建房间的默认信息 （主题、背景图）
public class NECreateVoiceRoomDefaultInfo: NSObject {
  /// 主题
  public var topic: String?
  /// 背景图
  public var livePicture: String?
  /// 可选背景图列表
  public var defaultPictures: [String]?

  override public init() {
    super.init()
  }

  convenience init(_ defaultInfo: _NECreateRoomDefaultInfo?) {
    self.init()
    topic = defaultInfo?.topic
    livePicture = defaultInfo?.livePicture
    defaultPictures = defaultInfo?.defaultPictures
  }
}
