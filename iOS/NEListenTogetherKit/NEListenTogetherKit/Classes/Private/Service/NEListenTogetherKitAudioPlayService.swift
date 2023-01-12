// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Foundation
import NERoomKit

enum NEListenTogetherSinger {
  // 主唱
  case anchor
  // 合唱者
  case chorister
  // 观众
  case audience
}

@objc

/// 播放状态的相关回调
protocol NEListenTogetherPlayStateChangeCallback {
  /// 播放进度
  func onSongPlayPosition(_ postion: UInt64)

  func onReceiveSongPosition(_ actionType: NEListenTogetherCustomAction,
                             data: [String: Any]?)
}

internal let SEI_POS: String = "pos"
internal let SEI_ORDER: String = "orderId"

/// 唱歌 相关操作接口
/// 独唱、合唱
internal class NEListenTogetherAudioPlayService: NSObject {
  internal var currentOrderId: Int64?

  internal var currentEffectId: UInt32 {
    isOriginal ? NEListenTogetherKit.OriginalEffectId : NEListenTogetherKit.AccompanyEffectId
  }

  internal var roomContext: NERoomContext?
  internal var callback: NEListenTogetherPlayStateChangeCallback?
  // 歌唱者类型
  internal var singer: NEListenTogetherSinger = .audience

  var roomUuid: String = ""
  // 主唱Id
  var anchorId: String = ""
  // 副唱Id
  var chorusId: String?
  // 本地原唱地址
  var orginalPath: String?
  // 本地伴唱地址
  var accompanyPath: String?
  // 实时合唱传入的音量
  var realTimeVolume: Int?
  /// 初始化
  /// - Parameter roomUuid: 房间id
  init(roomUuid: String) {
    super.init()
    self.roomUuid = roomUuid
    // 默认配置
    defaultConfig()
  }

  func defaultConfig() {
    roomContext = NERoomKit.shared().roomService.getRoomContext(roomUuid: roomUuid)
    roomContext?.addRoomListener(listener: self)
    NERoomKit.shared().messageChannelService.addMessageChannelListener(listener: self)
    // 会前 设置场景
    roomContext?.rtcController.setChannelProfile(.liveBroadcasting)
    /// 设置音频编码属性
    roomContext?.rtcController.setAudioProfile(.highQualityStereo, scenario: .music)
    // 设置录制和播放声音混音后的数据格式
    let format = NERoomRtcAudioFrameRequestFormat()
    format.channels = 2
    format.sampleRate = 48000
    format.mode = .readonly
    roomContext?.rtcController.setMixedAudioFrameParameters(format)
    // 设置采集的音频格式
    let recordFormat = NERoomRtcAudioFrameRequestFormat()
    recordFormat.channels = 2
    recordFormat.sampleRate = 48000
    recordFormat.mode = .readwrite
    roomContext?.rtcController.setRecordingAudioFrameParameters(recordFormat)
  }

  /// 销毁
  internal func destroy() {
    NERoomKit.shared().messageChannelService.removeMessageChannelListener(listener: self)
    roomContext?.rtcController.setAudioFrame(withObserver: nil)
    roomContext?.removeRoomListener(listener: self)
    roomContext = nil
  }

  @discardableResult
  /// 暂停歌曲
  func pauseSong() -> Int {
    roomContext?.rtcController.pauseAllEffects() ?? NEListenTogetherErrorCode.failed
  }

  @discardableResult
  /// 恢复播放
  func resumeSong() -> Int {
    roomContext?.rtcController.resumeAllEffects() ?? NEListenTogetherErrorCode.failed
  }

  @discardableResult
  /// 停止播放
  func stopSong() -> Int {
    roomContext?.rtcController.stopAllEffects() ?? NEListenTogetherErrorCode.failed
  }

  internal var isOriginal: Bool = true

  /// 设置本地伴音播放音量
  /// - Parameter volume: 0～100取值，默认100
  func setPlaybackVolume(volume: UInt32) {
    roomContext?.rtcController.setEffectPlaybackVolume(
      effectId: currentEffectId,
      volume: volume
    )
  }

  /// 设置伴音发送音量
  /// - Parameter volume: 0～100取值，默认100
  func setSendVolume(volume: UInt32) {
    roomContext?.rtcController.setEffectSendVolume(effectId: currentEffectId, volume: volume)
  }

  func getEffectDuration() -> UInt64 {
    roomContext?.rtcController.getEffectDuration(effectId: currentEffectId) ?? 0
  }

  func setEffectPosition(position: UInt64) -> Int {
    roomContext?.rtcController.setEffectPosition(effectId: NEListenTogetherKit.OriginalEffectId, postion: position) ?? -1
  }

  private func solo(path _: String, startTimeStamp _: Int) {}

  private func getLocalStartTime(receiveServerTime _: Int, countdownTime _: Int = 0) -> Int {
    0
  }

  internal var audioChannels: UInt32 = 0
  internal var samplesPerChannel: UInt32 = 0
  /// 是否为开始混音前
  internal var beforeStartMix: Bool = false
  internal var rtt: UInt64 = 0
  var roomMembers: [NERoomMember] {
    roomContext?.remoteMembers ?? []
  }
}
