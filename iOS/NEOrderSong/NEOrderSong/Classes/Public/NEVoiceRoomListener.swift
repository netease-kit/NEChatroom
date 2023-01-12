// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Foundation
import NERoomKit

@objc
/// SDK API的通用回调接口。SDK提供的接口多为异步实现，在调用这些接口时，需要提供一个该接口的实现作为回调参数
public protocol NEOrderSongListener: NSObjectProtocol {
  /// 接收到合唱回调
  /// - Parameters:
  ///   - actionType: 合唱状态
  ///   - songModel: 消息模型
  @objc optional func onReceiveChorusMessage(_ actionType: NEOrderSongChorusActionType,
                                             songModel: NEOrderSongSongModel)

  @objc optional func onReceiveSongPosition(_ actionType: NEOrderSongCustomAction,
                                            data: [String: Any]?)

  /// 已点列表的更新
  @objc optional func onSongListChanged()

  /// 点歌
  /// - Parameter song: 歌曲
  @objc optional func onSongOrdered(_ song: NEOrderSongOrderSongModel?)

  /// 已点列表的删除
  /// - Parameter song: 歌曲
  @objc optional func onSongDeleted(_ song: NEOrderSongOrderSongModel?)

  /// 已点列表的置顶
  /// - Parameter song: 歌曲
  @objc optional func onSongTopped(_ song: NEOrderSongOrderSongModel?)

  /// 切歌
  /// - Parameter song: 被切歌曲
  @objc optional func onNextSong(_ song: NEOrderSongOrderSongModel?)
}
