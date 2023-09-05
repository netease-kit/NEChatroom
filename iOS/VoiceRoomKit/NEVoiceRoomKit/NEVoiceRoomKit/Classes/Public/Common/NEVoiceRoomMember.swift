// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Foundation
import NERoomKit

/// 成员属性变量
struct MemberPropertyConstants {
  enum MuteAudio {
    static let key = "recordDevice"
    static let on = "on"
    static let off = "off"
  }

  enum CanOpenMic {
    static let key = "canOpenMic"
    static let no = "0"
    static let yes = "1"
  }
}

@objcMembers
/// 用户音量信息
public class NEVoiceRoomMemberVolumeInfo: NSObject {
  /// 成员ID
  public var userUuid: String = ""
  /// 音量大小 区间  **[0~100]**
  public var volume: Int = 0

  init(info: NEMemberVolumeInfo) {
    userUuid = info.userUuid
    volume = info.volume
  }
}

@objcMembers
/// Karaoke 成员模型
public class NEVoiceRoomMember: NSObject {
  /// 用户ID
  public var account: String = ""
  /// 用户名
  public var name: String = ""
  /// 用户角色
  public var role: String = ""
  /// 用户头像
  public var avatar: String?
  /// 音频是否打开
  public var isAudioOn: Bool = false
  /// 音频是否被禁用
  public var isAudioBanned: Bool = false
  override public init() {
    super.init()
  }

  convenience init(_ member: NERoomMember) {
    self.init()
    account = member.uuid
    name = member.name
    role = member.role.name
    avatar = member.avatar

    isAudioOn = member.properties[MemberPropertyConstants.MuteAudio.key] == MemberPropertyConstants
      .MuteAudio.on
    isAudioBanned = member
      .properties[MemberPropertyConstants.CanOpenMic.key] == MemberPropertyConstants.CanOpenMic.no
  }

  init?(member: NERoomMember?) {
    guard let member = member else {
      return nil
    }
    account = member.uuid
    name = member.name
    role = member.role.name
    avatar = member.avatar

    isAudioOn = member.properties[MemberPropertyConstants.MuteAudio.key] == MemberPropertyConstants
      .MuteAudio.on
    isAudioBanned = member
      .properties[MemberPropertyConstants.CanOpenMic.key] == MemberPropertyConstants.CanOpenMic.no
  }
}
