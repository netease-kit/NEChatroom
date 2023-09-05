// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Foundation
import NERoomKit

@objcMembers
public class NEVoiceRoomCreateAudioEffectOption: NSObject {
  /**
   待播放的音效文件的绝对路径或 URL 地址。
   */
  public var path: String = ""
  /**
   音效循环播放的次数：

   - 1：（默认）播放音效一次。
   - ≤ 0：无限循环播放音效，直至调用stopEffect或stopAllEffects后停止。
   */
  public var loopCount: Int = 1
  /**
   是否将音效发送远端，默认为 YES，即音效在本地播放的同时，远端用户也能听到该音效。
   */
  public var sendEnabled: Bool = true
  /**
   是否可回放。默认为 YES，即可回放。
   */
  public var playbackEnabled: Bool = true
  /**
   音效文件的发送音量，取值范围为0~100。默认为100，表示使用文件的原始音量。
   */
  public var sendVolume: Int = 100
  /**
   音效文件的播放音量，取值范围为0~100。默认为100，表示使用文件的原始音量。
   */
  public var playbackVolume: Int = 100
  /**
   音效文件开始播放的时间，UTC 时间戳，默认值为 0，表示立即播放。
   */
  public var startTimeStamp: Int64 = 0
  /**
   音效文件播放时间戳回调间隔 默认100ms
   */
  public var progressInterval: Int64 = 100
  /**
   伴音跟随音频主流还是辅流，默认跟随主流
   */
  public var sendWithAudioType: NEVoiceRoomAudioStreamType = .main

  override public init() {
    super.init()
  }

  func convertToRoom() -> NERoomCreateAudioEffectOption {
    let option = NERoomCreateAudioEffectOption()
    option.path = path
    option.loopCount = loopCount
    option.sendEnabled = sendEnabled
    option.playbackEnabled = playbackEnabled
    option.sendVolume = sendVolume
    option.playbackVolume = playbackVolume
    option.progressInterval = progressInterval
    // FIXME: Karaoke特有
    option
      .sendWithAudioType = NERoomAudioStreamType(rawValue: sendWithAudioType.rawValue) ?? .main
    option.startTimeStamp = startTimeStamp
    return option
  }
}
