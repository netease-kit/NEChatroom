// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Foundation
@objc
/// 邀请操作类型
public enum NEListenTogetherInviteAction: Int, Codable {
  /// 邀请
  case invite = 1
  /// 同意邀请
  case agree
  /// 拒绝邀请
  case reject
  /// 取消邀请
  case cancel
}

@objcMembers
/// 邀请请求模型
public class NEListenTogetherInviteRequest: NSObject, Codable {
  /// 点歌编号，action=1 时必传
  public var orderId: Int?
  /// 操作类型，1：邀请， 2：同意， 3：拒绝，4：取消
  public var action: NEListenTogetherInviteAction = .invite
  /// 合唱id，当action=2 3 4 时 必传
  public var chorusId: String?
  /// 目标用户编号(被邀请者)
  public var anchorUserUuid: String?
}
