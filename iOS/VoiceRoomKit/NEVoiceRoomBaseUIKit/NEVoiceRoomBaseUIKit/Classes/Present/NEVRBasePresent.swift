// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import NEVoiceRoomKit
import UIKit

public typealias NEVRBaseCallback = (Int, String?) -> Void
public typealias NEVRBaseRoomInfoCallback = (Int, String?, NEVoiceRoomInfo?) -> Void

public class NEVRBasePresent: NSObject {
  weak var viewController: NEVRBaseViewController?

  var onMembersJoinRoom: (([String]) -> Void)?
  var onMembersLeaveRoom: (([String]) -> Void)?
  var onMemberAudioMuteChanged: ((String, Bool) -> Void)?
  var onReceiveTextMessage: ((NEVoiceRoomChatTextMessage) -> Void)?
  var onRoomEnd: ((NEVoiceRoomEndReason) -> Void)?
  var onReceiveBatchGift: ((NEVoiceRoomBatchGiftModel) -> Void)?
  // 静音操作，因为目前界面中有多处需要感知这个状态，为了同步这个状态，统一从这里触发
  var onIEMsStateChanged: ((Bool) -> Void)?
  // 是否可操作耳返，取决于是否插入了耳机
  var onIEMsEnableChanged: ((Bool) -> Void)?

  public convenience init(viewController: NEVRBaseViewController) {
    self.init()
    self.viewController = viewController
    NEVoiceRoomKit.getInstance().addVoiceRoomListener(self)
  }

  deinit {
    NEVoiceRoomKit.getInstance().removeVoiceRoomListener(self)
  }

  func joinRoom(params: NEJoinVoiceRoomParams, callback: NEVRBaseRoomInfoCallback?) {
    NEVoiceRoomKit.getInstance().joinRoom(params, options: NEJoinVoiceRoomOptions()) { code, msg, obj in
      if code == 0 {
        // 开启音量回调上报，用于上层显示波纹，目前是个通用需求，所以封装在这里
        NEVoiceRoomKit.getInstance().enableAudioVolumeIndication(enable: true, interval: 1000)
      }
      callback?(code, msg, obj)
    }
  }

  public func leaveRoom(callback: NEVRBaseCallback?) {
    NEVoiceRoomKit.getInstance().leaveRoom { code, msg, obj in
      callback?(code, msg)
    }
  }

  func endRoom(callback: NEVRBaseCallback?) {
    NEVoiceRoomKit.getInstance().endRoom { code, msg, obj in
      callback?(code, msg)
    }
  }

  func mute(callback: NEVRBaseCallback?) {
    guard let hasNetwork = viewController?.checkNetwork(),
          hasNetwork else {
      return
    }
    NEVoiceRoomKit.getInstance().muteMyAudio { code, msg, obj in
      callback?(code, msg)
    }
  }

  func unmute(callback: NEVRBaseCallback?) {
    guard let hasNetwork = viewController?.checkNetwork(),
          hasNetwork else {
      return
    }
    NEVoiceRoomKit.getInstance().unmuteMyAudio { code, msg, obj in
      callback?(code, msg)
    }
  }

  func sendTextMessage(message: String, callback: NEVRBaseCallback?) {
    guard let hasNetwork = viewController?.checkNetwork(),
          hasNetwork else {
      return
    }
    NEVoiceRoomKit.getInstance().sendTextMessage(message) { code, msg, obj in
      callback?(code, msg)
    }
  }

  func getRoomInfo(callback: NEVRBaseRoomInfoCallback?) {
    if let liveRecordId = viewController?.joinParams.liveRecordId {
      NEVoiceRoomKit.getInstance().getRoomInfo(liveRecordId) { code, msg, obj in
        callback?(code, msg, obj)
      }
    } else {
      callback?(-1, nil, nil)
    }
  }

  func getRecordVolume() -> Int {
    NEVoiceRoomKit.getInstance().getRecordingSignalVolume()
  }

  public func adjustRecordingSignalVolume(volume: Int) {
    NEVoiceRoomKit.getInstance().adjustRecordingSignalVolume(UInt32(volume))
  }

  /// 当前耳返是否打开
  var isIEMsOn = false {
    didSet {
      onIEMsStateChanged?(isIEMsOn)
    }
  }

  /// 当前是否可以打开耳返
  var isIEMsEnabled = NEVoiceRoomKit.getInstance().isHeadSetPlugging() {
    didSet {
      onIEMsEnableChanged?(isIEMsEnabled)
    }
  }

  func turnOnIEMs() {
    let code = NEVoiceRoomKit.getInstance().enableEarBack(80)
    if code == 0 {
      isIEMsOn = true
    }
  }

  func turnOffIEMs() {
    let code = NEVoiceRoomKit.getInstance().disableEarBack()
    if code == 0 {
      isIEMsOn = false
    }
  }
}

extension NEVRBasePresent: NEVoiceRoomListener {
  public func onMemberJoinChatroom(_ members: [NEVoiceRoomMember]) {}

  public func onMemberJoinRoom(_ members: [NEVoiceRoomMember]) {
    let nicks = members.map(\.name)
    onMembersJoinRoom?(nicks)
  }

  public func onMemberLeaveRoom(_ members: [NEVoiceRoomMember]) {
    let nicks = members.map(\.name)
    onMembersLeaveRoom?(nicks)
  }

  public func onRoomEnded(_ reason: NEVoiceRoomEndReason) {
    onRoomEnd?(reason)
  }

  public func onAudioOutputDeviceChanged(_ device: NEVoiceRoomAudioOutputDevice) {
    if device == .wiredHeadset || device == .bluetoothHeadset {
      isIEMsEnabled = true
    } else {
      isIEMsEnabled = false
      // 如果不是耳机，则直接关闭耳返
      turnOffIEMs()
    }
  }

  public func onMemberAudioMuteChanged(_ member: NEVoiceRoomMember, mute: Bool, operateBy: NEVoiceRoomMember?) {
    onMemberAudioMuteChanged?(member.account, mute)
  }

  public func onReceiveTextMessage(_ message: NEVoiceRoomChatTextMessage) {
    onReceiveTextMessage?(message)
  }

  public func onReceiveBatchGift(giftModel: NEVoiceRoomBatchGiftModel) {
    onReceiveBatchGift?(giftModel)
  }
}
