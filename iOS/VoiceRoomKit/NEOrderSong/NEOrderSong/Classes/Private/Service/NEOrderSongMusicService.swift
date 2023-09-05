// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Foundation
/// 关于
class NEOrderSongMusicService {
  var liveRecordId: UInt64
  init(_ liveRecordId: UInt64) {
    self.liveRecordId = liveRecordId
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
      "liveRecordId": liveRecordId,
    ]

    NEAPI.Music.ready().request(params, success: { _ in
      success?()
    }, failed: failure)
  }

  /// 歌曲操作 （暂停/继续播放/结束）
  /// - Parameters:
  ///   - action: 歌曲操作，2: 暂停  1：继续播放
  ///   - success: 成功回调
  ///   - failure: 失败回调
  func operation(_ orderId: Int64,
                 action: _NEOrderSongMusicOperationType,
                 success: (() -> Void)? = nil,
                 failure: ((NSError) -> Void)? = nil) {
    let params: [String: Any] = [
      "action": action.rawValue,
      "liveRecordId": liveRecordId,
    ]
    NEAPI.Music.action().request(params, success: { _ in
      success?()
    }, failed: failure)
  }

  func switchSong(_ orderId: Int64,
                  attachment: String?,
                  success: (() -> Void)? = nil,
                  failure: ((NSError) -> Void)? = nil) {
    var params: [String: Any] = [
      "currentOrderId": orderId,
      "liveRecordId": liveRecordId,
    ]
    if let attachment = attachment {
      params["attachment"] = attachment
    }
    NEAPI.PickSong.switchSong().request(params,
                                        success: { _ in
                                          success?()
                                        }, failed: failure)
  }

  /// 获取房间当前演唱信息
  /// - Parameters:
  ///   - success: 成功回调
  ///   - failure: 失败回调
  func currentInfo(_ success: ((NEOrderSongPlayMusicInfo?) -> Void)? = nil,
                   failure: ((NSError) -> Void)? = nil) {
    NEAPI.Music.info(String(liveRecordId)).request(returnType: NEOrderSongPlayMusicInfo.self,
                                                   success: success,
                                                   failed: failure)
  }

  /// 点歌
  /// - Parameters:
  /// - success: 成功回调
  /// - failure: 失败回调
  func orderSong(songInfo: NEOrderSongOrderSongParams,
                 _ success: ((NEOrderSongResponse?) -> Void)? = nil,
                 failure: ((NSError) -> Void)? = nil) {
    let params: [String: Any] = [
      "songId": songInfo.songId,
      "channel": songInfo.channel ?? 0,
      "liveRecordId": liveRecordId,
      "songName": songInfo.songName ?? "",
      "songCover": songInfo.songCover ?? "",
      "songTime": songInfo.songTime ?? 0,
      "singer": songInfo.singer ?? "",
    ]
    NEAPI.PickSong.orderSong().request(params,
                                       returnType: NEOrderSongResponse.self,
                                       success: success,
                                       failed: failure)
  }

  /// 获取已点列表
  /// - Parameters:
  ///   - success: 成功回调
  ///   - failure: 失败回调
  func getOrderedSongs(_ success: (([NEOrderSongResponse]?) -> Void)? = nil,
                       failure: ((NSError) -> Void)? = nil) {
    NEAPI.PickSong.getOrderedSongs(String(liveRecordId)).request(success: { data in
      guard let data = data,
            let arr = data["data"] as? [[String: Any]],
            let models = NEOrderSongDecoder.decode(NEOrderSongResponse.self, array: arr)
      else {
        failure?(makeError(NEOrderSongErrorCode.failed))
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
      "liveRecordId": liveRecordId,
    ]
    NEAPI.PickSong.deleteSong().request(params, success: { _ in
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
      "liveRecordId": liveRecordId,
    ]
    NEAPI.PickSong.topSong().request(params, success: { _ in
      success?()
    }, failed: failure)
  }
}
