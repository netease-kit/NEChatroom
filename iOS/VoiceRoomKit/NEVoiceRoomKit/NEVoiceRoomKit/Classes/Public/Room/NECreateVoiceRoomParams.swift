// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Foundation
import NERoomKit

@objcMembers

/// 创建Karaoke房间参数
public class NECreateVoiceRoomParams: NSObject {
  /// 用户账号Id（直播间创建者）
  public var userUuid: String = ""
  /// 直播类型
  public var liveType: NEVoiceRoomLiveRoomType = .multiAudio
  /// 直播主题
  public var liveTopic: String?
  /// 直播封面图
  public var cover: String?
  /// 房间名称
  public var roomName: String?
  /// 模版 ID
  public var configId: Int = 0
  /// 麦位数量。如果设置为大于**0**的值，则会在创建的房间中启用麦位管理
  public var seatCount: Int = 0

  /// 麦位模式，0：自由模式，1：管理员控制模式，不传默认为自由模式
  /// 0申请上麦时不需要管理员同意，直接上麦；1:申请上麦时需要管理员同意
  var seatApplyMode: Int = 1
  /// 默认0）0抱麦时不需要对方同意；1:抱麦时需要对方同意
  var seatInviteMode: Int = 0
}
