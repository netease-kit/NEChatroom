// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of netease_voiceroomkit;

/// 房间结束原因枚举
enum NEVoiceRoomEndReason {
  /// 成员主动离开房间
  leaveBySelf,

  /// 数据同步错误
  syncDataError,

  /// 多端同时加入同一房间被踢
  kickBySelf,

  /// 被管理员踢出房间
  kickOut,

  /// 房间被关闭
  closeByMember,

  /// 房间到期关闭
  endOfLife,

  /// 所有成员退出
  allMembersOut,

  /// 后台关闭
  closeByBackend,

  /// 账号异常
  loginStateError,

  /// rtc 异常，退出
  endOfRtc,

  /// 未知异常
  unknown
}

/// 本地音频输出设备
enum NEVoiceRoomAudioOutputDevice {
  /// 扬声器
  speakerPhone,

  /// 有线耳机
  wiredHeadSet,

  /// 听筒
  earPiece,

  /// 蓝牙耳机
  bluetoothHeadset
}

/// 登录事件枚举
enum NEVoiceRoomAuthEvent {
  /// 被踢出登录
  kickOut,

  /// 授权过期或失败
  unAuthorized,

  /// 服务端禁止登录
  forbidden,

  /// 账号或密码错误
  accountTokenError,

  /// 登录成功
  loggedIn,

  /// 未登录
  loggedOut,

  /// Token过期
  tokenExpired,

  /// 授权错误
  incorrectToken
}

/// 直播状态
/// @property value 状态
/// @constructor
enum NEVoiceRoomLiveState {
  /// 未开始
  notStart,

  /// 直播中
  live,

  /// 关播
  liveClose
}

/// 角色
/// @property value 角色值
/// @constructor
enum NEVoiceRoomRole {
  /// 房主
  host,

  /// 观众
  audience
}

/// 错误码
class NEVoiceRoomErrorCode {
  /// 通用失败code码
  static const int failure = -1;

  /// 成功code码
  static const int success = 0;
}
