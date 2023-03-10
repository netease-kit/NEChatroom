// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Foundation

@objc

public enum NEVoiceRoomLiveState: Int {
  /// 未开始
  case notStart = 0
  /// 直播中
  case live = 1
  /// 直播结束
  case liveClose = 6
}
