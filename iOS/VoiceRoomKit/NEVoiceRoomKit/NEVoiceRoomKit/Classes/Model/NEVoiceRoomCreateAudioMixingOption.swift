// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Foundation
import NERoomKit

@objc
/// 音频流类型，目前同时支持音频两路流：主流和辅流
public enum NEVoiceRoomAudioStreamType: Int {
  /// 音频流主流
  case main = 0
  /// 音频流辅流
  case sub
}

@objcMembers
public class NEVoiceRoomCreateAudioMixingOption: NSObject {
  /**
   待播放的音效文件的绝对路径或 URL 地址。
   */
  public var path: String = ""
  /**
   音效循环播放的次数：

   - 1：（默认）播放音效一次。
   - ≤ 0：无限循环播放音效，直至调用stopEffect或stopAllEffects后停止。
   */
  public var loopCount = 1
  /**
   是否将音效发送远端，默认为 YES，即音效在本地播放的同时，远端用户也能听到该音效。
   */
  public var sendEnabled = true
  /**
   是否可回放。默认为 YES，即可回放。
   */
  public var playbackEnabled = true
  /**
   音效文件的发送音量，取值范围为0~100。默认为100，表示使用文件的原始音量。
   */
  public var sendVolume = 100
  /**
   音效文件的播放音量，取值范围为0~100。默认为100，表示使用文件的原始音量。
   */
  public var playbackVolume = 100
  /**
   音乐文件的播放起始位置，单位 milesenconds，default value 0
   */
  public var startTimeStamp: Int64 = 0
  /**
   伴音跟随音频主流还是辅流，默认跟随主流
   */
  public var sendWithAudioType: NEVoiceRoomAudioStreamType = .main
  override public init() {
    super.init()
  }

  func converToRoom() -> NERoomCreateAudioMixingOption {
    let option = NERoomCreateAudioMixingOption()
    option.path = path
    option.loopCount = loopCount
    option.sendEnabled = sendEnabled
    option.playbackEnabled = playbackEnabled
    option.sendVolume = sendVolume
    option.playbackVolume = playbackVolume
    option
      .sendWithAudioType = NERoomAudioStreamType(rawValue: sendWithAudioType.rawValue) ??
      .main
    option.startTimeStamp = startTimeStamp
    return option
  }
}
