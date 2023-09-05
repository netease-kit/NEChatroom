// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Foundation

@objcMembers

/// VoiceRoomKit 配置项
public class NEVoiceRoomKitConfig: NSObject {
  /// appKey 为VoiceRoom服务的Key
  public var appKey: String = ""
  /// 预留字段
  public var extras: [String: String] = .init()
  /// 推送证书
  public var APNSCerName: String = ""
}
