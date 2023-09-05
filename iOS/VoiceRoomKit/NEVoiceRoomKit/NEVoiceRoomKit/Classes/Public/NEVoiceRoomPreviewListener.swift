// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Foundation
@objc
/// 鉴权监听协议
public protocol NEVoiceRoomPreviewListener: NSObjectProtocol {
  // MARK: 通话前网络测试

  /// 报告本地用户的网络质量。
  @objc optional func onVoiceRoomRtcLastmileQuality(_ quality: NEVoiceRoomRtcNetworkStatusType)
  /// 报告通话前网络上下行 last mile 质量。
  @objc optional func onVoiceRoomRtcLastmileProbeResult(_ result: NEVoiceRoomRtcLastmileProbeTest)
}
