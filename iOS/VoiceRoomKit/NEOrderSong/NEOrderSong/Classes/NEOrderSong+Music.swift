// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import AVFAudio
import Foundation
/// 歌曲相关接口
public extension NEOrderSong {
  /// 开始唱歌
  /// - Parameters:
  ///   - orderId: 点歌台id
  ///   - chorusId: 合唱id
  ///   - ext: 额外参数
  ///   - callback: 回调
  func readyPlaySong(orderId: Int64,
                     chorusId: String?,
                     ext: [String: Any]? = nil,
                     callback: NEOrderSongCallback<AnyObject>? = nil) {
    NEOrderSongLog.apiLog(kitTag, desc: "Start song.")
    Judge.preCondition({
      self.musicService!.ready(orderId: orderId,
                               chorusId: chorusId,
                               ext: ext) {
        NEOrderSongLog.successLog(kitTag, desc: "Successfully start song.")
        callback?(NEOrderSongErrorCode.success, nil, nil)
      } failure: { error in
        NEOrderSongLog.errorLog(
          kitTag,
          desc: "Failed to start song. Code: \(error.code). Msg: \(error.localizedDescription)"
        )
        callback?(error.code, error.localizedDescription, nil)
      }
    }, failure: callback)
  }

  /// 暂停歌曲
  /// - Parameter callback: 回调
  func requestPausePlayingSong(_ orderId: Int64, callback: NEOrderSongCallback<AnyObject>? = nil) {
    NEOrderSongLog.apiLog(kitTag, desc: "Pause song.")

    Judge.preCondition({
      self.musicService!.operation(orderId,
                                   action: .pause,
                                   success: {
                                     NEOrderSongLog.successLog(
                                       kitTag,
                                       desc: "Successfully pause song."
                                     )
                                     callback?(NEOrderSongErrorCode.success, nil, nil)
                                   }, failure: { error in
                                     NEOrderSongLog.errorLog(
                                       kitTag,
                                       desc: "Failed to pause song. Code: \(error.code). Msg: \(error.localizedDescription)"
                                     )
                                     callback?(error.code, error.localizedDescription, nil)
                                   })
    }, failure: callback)
  }

  /// 恢复演唱
  /// - Parameter callback: 回调
  func requestResumePlayingSong(_ orderId: Int64, callback: NEOrderSongCallback<AnyObject>? = nil) {
    NEOrderSongLog.apiLog(kitTag, desc: "Resume song.")

    Judge.preCondition({
      self.musicService!.operation(orderId,
                                   action: .resume,
                                   success: {
                                     NEOrderSongLog.successLog(
                                       kitTag,
                                       desc: "Successfully resume song."
                                     )
                                     callback?(NEOrderSongErrorCode.success, nil, nil)
                                   }, failure: { error in
                                     NEOrderSongLog.errorLog(
                                       kitTag,
                                       desc: "Failed to resume song. Code: \(error.code). Msg: \(error.localizedDescription)"
                                     )
                                     callback?(error.code, error.localizedDescription, nil)
                                   })
    }, failure: callback)
  }

  /// 切歌
  /// - Parameters:
  ///   - orderId: 点歌编号
  ///   - callback: 回调
  func nextSong(orderId: Int64,
                attachment: String?,
                callback: NEOrderSongCallback<AnyObject>? = nil) {
    NEOrderSongLog.apiLog(kitTag, desc: "Next song.")
    Judge.preCondition({
      self.musicService!.switchSong(orderId, attachment: attachment) {
        callback?(NEOrderSongErrorCode.success, nil, nil)
      } failure: { error in
        NEOrderSongLog.errorLog(
          kitTag,
          desc: "Failed to switch song. Code: \(error.code). Msg: \(error.localizedDescription)"
        )
        callback?(error.code, error.localizedDescription, nil)
      }
    }, failure: callback)
  }

  /// 获取当前房间内歌曲信息
  /// - Parameter callback: 回调
  func queryPlayingSongInfo(_ callback: NEOrderSongCallback<NEOrderSongPlayMusicInfo>? = nil) {
    NEOrderSongLog.apiLog(kitTag, desc: "Get current song info.")
    Judge.preCondition({
      self.musicService!.currentInfo { data in
        NEOrderSongLog.successLog(kitTag, desc: "Successfully get current song info.")
        callback?(NEOrderSongErrorCode.success, nil, data)
      } failure: { error in
        NEOrderSongLog.errorLog(
          kitTag,
          desc: "Failed to get current song info. Code: \(error.code). Msg: \(error.localizedDescription)"
        )
        callback?(error.code, error.localizedDescription, nil)
      }
    }, failure: callback)
  }

  /// 点歌台接口
  /// 点歌
  func orderSong(_ songinfo: NEOrderSongOrderSongParams,
                 callback: NEOrderSongCallback<NEOrderSongResponse>? = nil) {
    NEOrderSongLog.apiLog(kitTag, desc: "Order Song")
    Judge.preCondition({
      self.musicService?.orderSong(songInfo: songinfo) { data in
        NEOrderSongLog.successLog(kitTag, desc: "Successfully orderSong")
        callback?(NEOrderSongErrorCode.success, nil, data)
      } failure: { error in
        NEOrderSongLog.errorLog(
          kitTag,
          desc: "Failed to orderSong. Code: \(error.code). Msg: \(error.localizedDescription)"
        )
        callback?(error.code, error.localizedDescription, nil)
      }
    }, failure: callback)
  }

  /// 获取已点列表
  func getOrderedSongs(callback: NEOrderSongCallback<[NEOrderSongResponse]>? = nil) {
    NEOrderSongLog.apiLog(kitTag, desc: "Get Ordered Songs")
    Judge.preCondition({
      self.musicService?.getOrderedSongs { data in
        NEOrderSongLog.successLog(kitTag, desc: "Successfully getOrderedSongs")
        callback?(NEOrderSongErrorCode.success, nil, data)
      } failure: { error in
        NEOrderSongLog.errorLog(
          kitTag,
          desc: "Failed to getOrderedSongs. Code: \(error.code). Msg: \(error.localizedDescription)"
        )
        callback?(error.code, error.localizedDescription, nil)
      }
    }, failure: callback)
  }

  /// 删除歌曲
  func deleteSong(orderId: Int64, callback: NEOrderSongCallback<AnyObject>? = nil) {
    NEOrderSongLog.apiLog(kitTag, desc: "Delete Song")
    Judge.preCondition({
      self.deletingSongs.append(orderId)
      self.musicService?.deleteSong(orderId, {
        NEOrderSongLog.successLog(kitTag, desc: "Successfully deleteSong")
        self.deletingSongs.removeAll(where: { $0 == orderId })
        callback?(NEOrderSongErrorCode.success, nil, nil)
      }, failure: { error in
        NEOrderSongLog.errorLog(
          kitTag,
          desc: "Failed to deleteSong. Code: \(error.code). Msg: \(error.localizedDescription)"
        )
        self.deletingSongs.removeAll(where: { $0 == orderId })
        callback?(error.code, error.localizedDescription, nil)

      })
    }, failure: callback)
  }

  /// 置顶歌曲
  func topSong(orderId: Int64, callback: NEOrderSongCallback<AnyObject>? = nil) {
    NEOrderSongLog.apiLog(kitTag, desc: "Top Song")
    Judge.preCondition({
      self.musicService?.topSong(orderId, {
        NEOrderSongLog.successLog(kitTag, desc: "Successfully topSong")
        callback?(NEOrderSongErrorCode.success, nil, nil)
      }, failure: { error in
        NEOrderSongLog.errorLog(
          kitTag,
          desc: "Failed to topSong. Code: \(error.code). Msg: \(error.localizedDescription)"
        )
        callback?(error.code, error.localizedDescription, nil)

      })
    }, failure: callback)
  }
}
