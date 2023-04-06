// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import AVFAudio
import Foundation
/// 歌曲相关接口
public extension NEListenTogetherKit {
  /// 开始唱歌
  /// - Parameters:
  ///   - orderId: 点歌台id
  ///   - chorusId: 合唱id
  ///   - ext: 额外参数
  ///   - callback: 回调
  func readyPlaySong(orderId: Int64,
                     chorusId: String?,
                     ext: [String: Any]? = nil,
                     callback: NEListenTogetherCallback<AnyObject>? = nil) {
    NEListenTogetherLog.apiLog(kitTag, desc: "Ready song.")
    Judge.preCondition({
      self.musicService!.ready(orderId: orderId,
                               chorusId: chorusId,
                               ext: ext) {
        NEListenTogetherLog.successLog(kitTag, desc: "Successfully ready song.")
        callback?(NEListenTogetherErrorCode.success, nil, nil)
      } failure: { error in
        NEListenTogetherLog.errorLog(
          kitTag,
          desc: "Failed to ready song. Code: \(error.code). Msg: \(error.localizedDescription)"
        )
        callback?(error.code, error.localizedDescription, nil)
      }
    }, failure: callback)
  }

  /// 是否插入耳机
  func isHeadSetPlugging() -> Bool {
    let route = AVAudioSession.sharedInstance().currentRoute
    var isHead = false
    for desc in route.outputs {
      switch desc.portType {
      case .headphones, .bluetoothA2DP, .usbAudio, .bluetoothHFP:
        isHead = true
      default: break
      }
    }
    return isHead
  }

  /// 暂停歌曲
  /// - Parameter callback: 回调
  func requestPausePlayingSong(_ orderId: Int64, callback: NEListenTogetherCallback<AnyObject>? = nil) {
    NEListenTogetherLog.apiLog(kitTag, desc: "Pause song.")

    Judge.preCondition({
      self.musicService!.operation(orderId,
                                   action: .pause,
                                   success: {
                                     NEListenTogetherLog.successLog(
                                       kitTag,
                                       desc: "Successfully pause song."
                                     )
                                     callback?(NEListenTogetherErrorCode.success, nil, nil)
                                   }, failure: { error in
                                     NEListenTogetherLog.errorLog(
                                       kitTag,
                                       desc: "Failed to pause song. Code: \(error.code). Msg: \(error.localizedDescription)"
                                     )
                                     callback?(error.code, error.localizedDescription, nil)
                                   })
    }, failure: callback)
  }

  /// 恢复演唱
  /// - Parameter callback: 回调
  func requestResumePlayingSong(_ orderId: Int64, callback: NEListenTogetherCallback<AnyObject>? = nil) {
    NEListenTogetherLog.apiLog(kitTag, desc: "Resume song.")

    Judge.preCondition({
      self.musicService!.operation(orderId,
                                   action: .resume,
                                   success: {
                                     NEListenTogetherLog.successLog(
                                       kitTag,
                                       desc: "Successfully resume song."
                                     )
                                     callback?(NEListenTogetherErrorCode.success, nil, nil)
                                   }, failure: { error in
                                     NEListenTogetherLog.errorLog(
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
                callback: NEListenTogetherCallback<AnyObject>? = nil) {
    NEListenTogetherLog.apiLog(kitTag, desc: "Next song.")
    Judge.preCondition({
      self.musicService!.switchSong(orderId, attachment: attachment) {
        self.audioPlayService?.stopSong()
        callback?(NEListenTogetherErrorCode.success, nil, nil)
      } failure: { error in
        NEListenTogetherLog.errorLog(
          kitTag,
          desc: "Failed to switch song. Code: \(error.code). Msg: \(error.localizedDescription)"
        )
        callback?(error.code, error.localizedDescription, nil)
      }
    }, failure: callback)
  }

  /// 获取当前房间内歌曲信息
  /// - Parameter callback: 回调
  func queryPlayingSongInfo(_ callback: NEListenTogetherCallback<NEListenTogetherPlayMusicInfo>? = nil) {
    NEListenTogetherLog.apiLog(kitTag, desc: "Get current song info.")
    Judge.preCondition({
      self.musicService!.currentInfo { data in
        NEListenTogetherLog.successLog(kitTag, desc: "Successfully get current song info.")
        callback?(NEListenTogetherErrorCode.success, nil, data)
      } failure: { error in
        NEListenTogetherLog.errorLog(
          kitTag,
          desc: "Failed to get current song info. Code: \(error.code). Msg: \(error.localizedDescription)"
        )
        callback?(error.code, error.localizedDescription, nil)
      }
    }, failure: callback)
  }

  /// 是否是原唱
  var isOriginalSongPlaying: Bool {
    if let song = _audioPlayService {
      return song.isOriginal
    } else {
      return false
    }
  }

  /// 调音台使用的音效Id
  var currentSongIdForAudioEffect: Int {
    if let song = _audioPlayService {
      return Int(song.currentEffectId)
    }
    return -1
  }

  /// 点歌台接口
  /// 点歌
  func orderSong(_ songinfo: NEListenTogetherOrderSongModel,
                 callback: NEListenTogetherCallback<NEListenTogetherOrderSongModel>? = nil) {
    NEListenTogetherLog.apiLog(kitTag, desc: "Order Song")
    Judge.preCondition({
      self.musicService!.orderSong(songInfo: songinfo) { data in
        NEListenTogetherLog.successLog(kitTag, desc: "Successfully orderSong")
        callback?(NEListenTogetherErrorCode.success, nil, data)
      } failure: { error in
        NEListenTogetherLog.errorLog(
          kitTag,
          desc: "Failed to orderSong. Code: \(error.code). Msg: \(error.localizedDescription)"
        )
        callback?(error.code, error.localizedDescription, nil)
      }
    }, failure: callback)
  }

  /// 获取已点列表
  func getOrderedSongs(callback: NEListenTogetherCallback<[NEListenTogetherOrderSongModel]>? = nil) {
    NEListenTogetherLog.apiLog(kitTag, desc: "Get Ordered Songs")
    Judge.preCondition({
      self.musicService?.getOrderedSongs { data in
        NEListenTogetherLog.successLog(kitTag, desc: "Successfully getOrderedSongs")
        callback?(NEListenTogetherErrorCode.success, nil, data)
      } failure: { error in
        NEListenTogetherLog.errorLog(
          kitTag,
          desc: "Failed to getOrderedSongs. Code: \(error.code). Msg: \(error.localizedDescription)"
        )
        callback?(error.code, error.localizedDescription, nil)
      }
    }, failure: callback)
  }

  /// 删除歌曲
  func deleteSong(orderId: Int64, callback: NEListenTogetherCallback<AnyObject>? = nil) {
    NEListenTogetherLog.apiLog(kitTag, desc: "Delete Song")
    Judge.preCondition({
      self.musicService?.deleteSong(orderId, {
        NEListenTogetherLog.successLog(kitTag, desc: "Successfully deleteSong")
        callback?(NEListenTogetherErrorCode.success, nil, nil)
      }, failure: { error in
        NEListenTogetherLog.errorLog(
          kitTag,
          desc: "Failed to deleteSong. Code: \(error.code). Msg: \(error.localizedDescription)"
        )
        callback?(error.code, error.localizedDescription, nil)

      })
    }, failure: callback)
  }

  /// 置顶歌曲
  func topSong(orderId: Int64, callback: NEListenTogetherCallback<AnyObject>? = nil) {
    NEListenTogetherLog.apiLog(kitTag, desc: "Top Song")
    Judge.preCondition({
      self.musicService?.topSong(orderId, {
        NEListenTogetherLog.successLog(kitTag, desc: "Successfully topSong")
        callback?(NEListenTogetherErrorCode.success, nil, nil)
      }, failure: { error in
        NEListenTogetherLog.errorLog(
          kitTag,
          desc: "Failed to topSong. Code: \(error.code). Msg: \(error.localizedDescription)"
        )
        callback?(error.code, error.localizedDescription, nil)

      })
    }, failure: callback)
  }
}
