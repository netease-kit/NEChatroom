// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Foundation

@objcMembers
public class NEOrderSongDynamicToken: NSObject, Codable {
  // 动态token
  public var accessToken: String?
  // 过期时间（ttl）
  public var expiresIn: Int64?
  public var oc_expiresIn: Int64 {
    expiresIn ?? 0
  }
}
