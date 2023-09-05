// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Foundation

import Foundation

@objcMembers
/// OneOnOneKit 配置项
public class NELoginSampleConfig: NSObject {
  /// appKey 为LoginSample服务的Key
  public var appKey: String = ""
  public var appSecret: String = ""
  /// 预留字段
  public var extras: [String: String] = .init()
}
