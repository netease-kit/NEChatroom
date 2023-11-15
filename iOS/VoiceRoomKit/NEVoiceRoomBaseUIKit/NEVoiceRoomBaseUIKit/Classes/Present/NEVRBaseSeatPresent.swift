// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import NEVoiceRoomKit
import UIKit

public class NEVRBaseSeatPresent: NSObject {
  weak var viewController: NEVRBaseViewController?

  var onSeatListChanged: (([NEVoiceRoomSeatItem]) -> Void)?
  var onMemberAudioMuteChanged: ((String, Bool) -> Void)?
  var onRtcRemoteAudioVolumeIndication: (([NEVoiceRoomMemberVolumeInfo]) -> Void)?
  var onRtcLocalAudioVolumeIndication: ((Int) -> Void)?
  var onSeatRequestSubmitted: ((Int, String) -> Void)?
  var onSeatRequestCancelled: ((Int, String) -> Void)?
  var onSeatRequestApproved: ((Int, String) -> Void)?
  var onSeatRequestRejected: ((Int, String) -> Void)?
  var onSeatLeave: ((Int, String) -> Void)?
  var onSeatKicked: ((Int, String) -> Void)?
  var onSeatInvitationAccepted: ((Int, String) -> Void)?
  var onMemberAudioBanned: ((String, Bool) -> Void)?
  var onSelfJoinOrRejoin: (() -> Void)?
  var onSelfDidLeaveSeat: (() -> Void)?
  var onSelfDidOccupySeat: (() -> Void)?

  // 自己在麦上的状态，通过onSeatListChanged更新
  var selfSeatStatus = NEVoiceRoomSeatItemStatus.initial

  public convenience init(viewController: NEVRBaseViewController) {
    self.init()
    self.viewController = viewController
    NEVoiceRoomKit.getInstance().addVoiceRoomListener(self)
  }

  deinit {
    NEVoiceRoomKit.getInstance().removeVoiceRoomListener(self)
  }

  func getSeatInfo() {
    NEVoiceRoomKit.getInstance().getSeatInfo { [weak self] code, msg, seat in
      if code == 0,
         let items = seat?.seatItems {
        DispatchQueue.main.async {
          self?.onSeatListChanged?(items)
        }
      }
    }
  }

  func submitSeatRequest(_ seatIndex: Int, exclusive: Bool = true, callback: NEVRBaseCallback?) {
    guard let hasNetwork = viewController?.checkNetwork(),
          hasNetwork else {
      return
    }
    NEVoiceRoomKit.getInstance().submitSeatRequest(seatIndex) { code, msg, obj in
      callback?(code, msg)
    }
  }

  func cancelSeatRequest(callback: NEVRBaseCallback?) {
    guard let hasNetwork = viewController?.checkNetwork(),
          hasNetwork else {
      return
    }
    NEVoiceRoomKit.getInstance().cancelSeatRequest { code, msg, obj in
      callback?(code, msg)
    }
  }

  public func leaveSeat(callback: NEVRBaseCallback?) {
    guard let hasNetwork = viewController?.checkNetwork(),
          hasNetwork else {
      return
    }
    NEVoiceRoomKit.getInstance().leaveSeat { code, msg, obj in
      callback?(code, msg)
    }
  }

  func banRemoteAudio(_ uuid: String, callback: NEVRBaseCallback?) {
    guard let hasNetwork = viewController?.checkNetwork(),
          hasNetwork else {
      return
    }
    NEVoiceRoomKit.getInstance().banRemoteAudio(uuid) { code, msg, obj in
      callback?(code, msg)
    }
  }

  func unbanRemoteAudio(_ uuid: String, callback: NEVRBaseCallback?) {
    guard let hasNetwork = viewController?.checkNetwork(),
          hasNetwork else {
      return
    }
    NEVoiceRoomKit.getInstance().unbanRemoteAudio(uuid) { code, msg, obj in
      callback?(code, msg)
    }
  }

  public func closeSeats(_ seatIndexs: [Int], callback: NEVRBaseCallback?) {
    guard let hasNetwork = viewController?.checkNetwork(),
          hasNetwork else {
      return
    }
    NEVoiceRoomKit.getInstance().closeSeats(seatIndices: seatIndexs) { code, msg, obj in
      callback?(code, msg)
    }
  }

  func openSeats(_ seatIndexs: [Int], callback: NEVRBaseCallback?) {
    guard let hasNetwork = viewController?.checkNetwork(),
          hasNetwork else {
      return
    }
    NEVoiceRoomKit.getInstance().openSeats(seatIndices: seatIndexs) { code, msg, obj in
      callback?(code, msg)
    }
  }

  public func kickSeat(_ uuid: String, callback: NEVRBaseCallback?) {
    guard let hasNetwork = viewController?.checkNetwork(),
          hasNetwork else {
      return
    }
    NEVoiceRoomKit.getInstance().kickSeat(account: uuid) { code, msg, obj in
      callback?(code, msg)
    }
  }

  func approveSeatRequest(_ uuid: String, callback: NEVRBaseCallback?) {
    guard let hasNetwork = viewController?.checkNetwork(),
          hasNetwork else {
      return
    }
    NEVoiceRoomKit.getInstance().approveSeatRequest(account: uuid) { code, msg, obj in
      callback?(code, msg)
    }
  }

  func rejectSeatRequest(_ uuid: String, callback: NEVRBaseCallback?) {
    guard let hasNetwork = viewController?.checkNetwork(),
          hasNetwork else {
      return
    }
    NEVoiceRoomKit.getInstance().rejectSeatRequest(account: uuid) { code, msg, obj in
      callback?(code, msg)
    }
  }
}

extension NEVRBaseSeatPresent: NEVoiceRoomListener {
  public func onMemberJoinChatroom(_ members: [NEVoiceRoomMember]) {
    if members.contains(where: { $0.account == NEVoiceRoomKit.getInstance().localMember?.account }) {
      // 自己加入聊天室
      onSelfJoinOrRejoin?()
    }
  }

  public func onSeatRequestSubmitted(_ seatIndex: Int, account: String) {
    onSeatRequestSubmitted?(seatIndex, account)
  }

  public func onSeatRequestCancelled(_ seatIndex: Int, account: String) {
    onSeatRequestCancelled?(seatIndex, account)
  }

  public func onSeatRequestApproved(_ seatIndex: Int, account: String, operateBy: String, isAutoAgree: Bool) {
    onSeatRequestApproved?(seatIndex, account)
  }

  public func onSeatRequestRejected(_ seatIndex: Int, account: String, operateBy: String) {
    onSeatRequestRejected?(seatIndex, account)
  }

  public func onSeatLeave(_ seatIndex: Int, account: String) {
    onSeatLeave?(seatIndex, account)
  }

  public func onSeatKicked(_ seatIndex: Int, account: String, operateBy: String) {
    onSeatKicked?(seatIndex, account)
  }

  public func onSeatInvitationAccepted(_ seatIndex: Int, account: String, isAutoAgree: Bool) {
    onSeatInvitationAccepted?(seatIndex, account)
  }

  public func onMemberAudioBanned(_ member: NEVoiceRoomMember, banned: Bool) {
    onMemberAudioBanned?(member.account, banned)
  }

  public func onSeatListChanged(_ seatItems: [NEVoiceRoomSeatItem]) {
    onSeatListChanged?(seatItems)
  }

  // 虽然BasicPresent里面已经监听了这个事件，但是为了麦位列表自己能够闭环在这里也要单独监听
  public func onMemberAudioMuteChanged(_ member: NEVoiceRoomMember, mute: Bool, operateBy: NEVoiceRoomMember?) {
    onMemberAudioMuteChanged?(member.account, mute)
  }

  public func onRtcRemoteAudioVolumeIndication(volumes: [NEVoiceRoomMemberVolumeInfo], totalVolume: Int) {
    onRtcRemoteAudioVolumeIndication?(volumes)
  }

  public func onRtcLocalAudioVolumeIndication(volume: Int, enableVad: Bool) {
    onRtcLocalAudioVolumeIndication?(volume)
  }

  public func onSelfSeatStatusChanged(new: NEVoiceRoomSeatItemStatus, old: NEVoiceRoomSeatItemStatus) {
    selfSeatStatus = new
    if new == .taken {
      onSelfDidOccupySeat?()
    } else if new == .initial, old == .taken {
      onSelfDidLeaveSeat?()
    }
  }
}
