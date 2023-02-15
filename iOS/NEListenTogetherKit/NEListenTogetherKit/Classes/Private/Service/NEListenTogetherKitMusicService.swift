// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Foundation
/// 关于
class NEListenTogetherMusicService {
  var roomUuid: String!
  init(_ roomUuid: String) {
    self.roomUuid = roomUuid
  }

  /// 开始演唱
  /// - Parameters:
  ///   - leaderUuid: 主唱userUuid
  ///   - assistantUuid: 副唱userUuid
  ///   - orderId: 点歌编号
  ///   - chorusId: 合唱编号，存在时即可不传其他信息
  ///   - success: 成功回调
  ///   - failure: 失败回调
  func ready(orderId: Int64,
             chorusId: String?,
             ext: [String: Any]? = nil,
             success: (() -> Void)? = nil,
             failure: ((NSError) -> Void)? = nil) {
    let params: [String: Any] = [
      "orderId": orderId,
    ]

    NEAPI.Music.ready(roomUuid).request(params, success: { _ in
      success?()
    }, failed: failure)
  }

  /// 歌曲操作 （暂停/继续播放/结束）
  /// - Parameters:
  ///   - action: 歌曲操作，2: 暂停  1：继续播放
  ///   - success: 成功回调
  ///   - failure: 失败回调
  func operation(_ orderId: Int64,
                 action: _NEListenTogetherMusicOperationType,
                 success: (() -> Void)? = nil,
                 failure: ((NSError) -> Void)? = nil) {
    let params: [String: Any] = [
      "action": action.rawValue,
    ]
    NEAPI.Music.action(roomUuid).request(params, success: { _ in
      success?()
    }, failed: failure)
  }

  func switchSong(_ orderId: Int64,
                  attachment: String?,
                  success: (() -> Void)? = nil,
                  failure: ((NSError) -> Void)? = nil) {
    var params: [String: Any] = [
      "currentOrderId": orderId,
    ]
    if let attachment = attachment {
      params["attachment"] = attachment
    }
    NEAPI.PickSong.switchSong(roomUuid).request(params,
                                                success: { _ in
                                                  success?()
                                                }, failed: failure)
  }

  /// 获取房间当前演唱信息
  /// - Parameters:
  ///   - success: 成功回调
  ///   - failure: 失败回调
  func currentInfo(_ success: ((NEListenTogetherPlayMusicInfo?) -> Void)? = nil,
                   failure: ((NSError) -> Void)? = nil) {
    NEAPI.Music.info(roomUuid).request(returnType: NEListenTogetherPlayMusicInfo.self,
                                       success: success,
                                       failed: failure)
  }

  /// 点歌
  /// - Parameters:
  /// - success: 成功回调
  /// - failure: 失败回调
  func orderSong(songInfo: NEListenTogetherOrderSongModel,
                 _ success: ((NEListenTogetherOrderSongModel?) -> Void)? = nil,
                 failure: ((NSError) -> Void)? = nil) {
    let params: [String: Any] = [
      "songId": songInfo.songId,
      "channel": songInfo.channel ?? 0,
      "songName": songInfo.songName ?? "",
      "songCover": songInfo.songCover ?? "",
      "songTime": songInfo.songTime ?? 0,
      "singer": songInfo.singer ?? "",
    ]
    NEAPI.PickSong.orderSong(roomUuid).request(params,
                                               returnType: NEListenTogetherOrderSongModel.self,
                                               success: success,
                                               failed: failure)
  }

  /// 获取已点列表
  /// - Parameters:
  ///   - success: 成功回调
  ///   - failure: 失败回调
  func getOrderedSongs(_ success: (([NEListenTogetherOrderSongModel]?) -> Void)? = nil,
                       failure: ((NSError) -> Void)? = nil) {
    NEAPI.PickSong.getOrderedSongs(roomUuid).request(success: { data in
      guard let data = data,
            let arr = data["data"] as? [[String: Any]],
            let models = NEListenTogetherDecoder.decode(NEListenTogetherOrderSongModel.self, array: arr)
      else {
        failure?(makeError(NEListenTogetherErrorCode.failed))
        return
      }
      success?(models)

    }, failed: failure)
  }

  /// 取消已点歌曲
  /// - Parameters:
  ///   - orderId: 歌曲ID
  ///   - success: 成功回调
  ///   - failure: 失败回调
  func deleteSong(_ orderId: Int64,
                  _ success: (() -> Void)? = nil,
                  failure: ((NSError) -> Void)? = nil) {
    let params: [String: Any] = [
      "orderId": orderId,
    ]
    NEAPI.PickSong.deleteSong(roomUuid).request(params, success: { _ in
      success?()
    }, failed: failure)
  }

  /// 指定歌曲
  /// - Parameters:
  ///   - orderId: 歌曲ID
  ///   - success: 成功回调
  ///   - failure: 失败回调
  func topSong(_ orderId: Int64,
               _ success: (() -> Void)? = nil,
               failure: ((NSError) -> Void)? = nil) {
    let params: [String: Any] = [
      "orderId": orderId,
    ]
    NEAPI.PickSong.topSong(roomUuid).request(params, success: { _ in
      success?()
    }, failed: failure)
  }
}
