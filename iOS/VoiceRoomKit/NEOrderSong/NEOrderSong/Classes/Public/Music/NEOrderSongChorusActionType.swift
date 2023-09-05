// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Foundation

@objc
/// 合唱状态
public enum NEOrderSongChorusActionType: Int {
  /// 开始播放
  case startSong = 1013
  /// 暂停唱歌
  case pauseSong = 1014
  /// 已准备好合唱
  case ready = 1015
  /// 恢复唱歌
  case resumeSong = 1016
//  /// 播放下一首歌
//  case next = 1500
}

@objc
/// 点歌状态
public enum NEOrderSongPickSongActionType: Int {
  /// 点歌
  case pick = 1008
  /// 删除歌曲
  case cancelPick = 1009
  /// 切歌
  case switchSong = 1010
  /// 置顶
  case top = 1011
  /// 列表变化
  case listChange = 1012
}

@objc
/// 点歌状态
public enum NEOrderSongCustomAction: Int {
  /// 获取进度
  case getPosition = 10001
  /// 发送进度
  case sendPosition = 10002
  case downloadProcess = 10003
}
