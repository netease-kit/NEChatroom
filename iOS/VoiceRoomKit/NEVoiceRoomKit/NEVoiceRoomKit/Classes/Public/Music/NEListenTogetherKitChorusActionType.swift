// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Foundation

@objc
/// 合唱状态
public enum NEListenTogetherChorusActionType: Int {
//  /// 邀请合唱
//  case invite = 140
//  /// 同意合唱邀请
//  case agreeInvite = 141
//  /// 取消合唱邀请
//  case cancelInvite = 142
  /// 开始唱歌
  case startSong = 135
  /// 暂停唱歌
  case pauseSong = 136
  /// 已准备好合唱
  case ready = 137
//  /// 恢复唱歌
  case resumeSong = 138
//  /// 结束唱歌
//  case endSong = 147
//  /// 拒绝合唱邀请
//  case rejectInvite = 148
//  /// 放弃演唱
//  case abandon = 149
//  /// 播放下一首歌
  case next = 150
}

@objc
/// 点歌状态
public enum NEListenTogetherPickSongActionType: Int {
  /// 点歌
  case pick = 130
  /// 删除歌曲
  case cancelPick = 131
  /// 切歌
  case switchSong = 132
  /// 置顶
  case top = 133
  /// 列表变化
  case listChange = 134
}

@objc
/// 点歌状态
public enum NEListenTogetherCustomAction: Int {
  /// 获取进度
  case getPosition = 10001
  /// 发送进度
  case sendPosition = 10002
  case downloadProcess = 10003
}
