// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Foundation
import NERoomKit

public extension NEVoiceRoomKit {
  /// 发送聊天室消息
  ///
  /// 使用前提：该方法仅在调用[login]方法登录成功后调用有效
  /// - Parameters:
  ///   - content: 发送内容
  ///   - callback: 回调
  func sendTextMessage(_ content: String, callback: NEVoiceRoomCallback<AnyObject>? = nil) {
    NEVoiceRoomLog.apiLog(kitTag, desc: "Send text message. Content: \(content).")
    Judge.preCondition({
      self.roomContext!.chatController
        .sendBroadcastTextMessage(message: content) { code, msg, _ in
          if code == 0 {
            NEVoiceRoomLog.successLog(kitTag, desc: "Successfully send text messge.")
          } else {
            NEVoiceRoomLog.errorLog(
              kitTag,
              desc: "Failed to send text messge. Code: \(code). Msg: \(msg ?? "")"
            )
          }
          callback?(code, msg, nil)
        }
    }, failure: callback)
  }

  /// 给房间内用户发送自定义消息，如房间内信令
  /// - Parameters:
  ///   - userUuid: 目标成员Id
  ///   - commandId: 消息类型 区间[10000 - 19999]
  ///   - data: 自定义消息内容
  ///   - callback: 回调
  func sendCustomMessage(_ userUuid: String,
                         commandId: Int,
                         data: String,
                         callback: NEVoiceRoomCallback<AnyObject>? = nil) {
    NEVoiceRoomLog.apiLog(
      kitTag,
      desc: "Send custom message. UserUuid: \(userUuid). CommandId: \(commandId). Data: \(data)"
    )
    Judge.preCondition({
      NERoomKit.shared().messageChannelService
        .sendCustomMessage(roomUuid: self.roomContext!.roomUuid,
                           userUuid: userUuid,
                           commandId: commandId,
                           data: data, crossAppAuthorization: nil) { code, msg, _ in
          if code == 0 {
            NEVoiceRoomLog.successLog(kitTag, desc: "Successfully send custom message.")
          } else {
            NEVoiceRoomLog.errorLog(
              kitTag,
              desc: "Failed to send custom message. Code: \(code). Msg: \(msg ?? "")"
            )
          }
          callback?(code, msg, nil)
        }
    }, failure: callback)
  }

  /// 处理RoomKit自定义消息
  func handleCustomMessage(_ message: NERoomChatCustomMessage) {
    NEVoiceRoomLog.infoLog(kitTag, desc: "Receive custom message.")
    guard let dic = message.attachStr?.toDictionary() else { return }
    NEVoiceRoomLog.infoLog(kitTag, desc: "custom message:\(dic)")
    if let _ = message.attachStr,
       let data = dic["data"] as? [String: Any],
       let jsonData = try? JSONSerialization.data(withJSONObject: data, options: []),
       let jsonString = String(data: jsonData, encoding: .utf8),
       let type = dic["type"] as? Int,
       type == 1005,
       let obj = NEVoiceRoomDecoder.decode(
         _NEVoiceRoomBatchRewardMessage.self,
         jsonString: jsonString
       ) {
      handleBatchGiftMessage(obj)
    }
  }

  /// 打赏麦上的主播或者观众
  /// - Parameters:
  ///   - giftId: 礼物编号
  ///   - giftCount: 礼物数量
  ///   - userUuids: 要打赏的目标用户
  ///   - callback: 结果回调
  func sendBatchGift(_ giftId: Int,
                     giftCount: Int,
                     userUuids: [String],
                     callback: NEVoiceRoomCallback<AnyObject>? = nil) {
    guard NEVoiceRoomKit.getInstance().isInitialized else {
      NEVoiceRoomLog.errorLog(kitTag, desc: "Failed to send batch gift. Uninitialized.")
      callback?(NEVoiceRoomErrorCode.failed, "Failed to send batch gift. Uninitialized.", nil)
      return
    }
    guard let liveRecordId = liveInfo?.live?.liveRecordId
    else {
      NEVoiceRoomLog.errorLog(kitTag, desc: "Failed to send batch gift. liveRecordId not exist.")
      callback?(
        NEVoiceRoomErrorCode.failed,
        "Failed to send batch gift. liveRecordId not exist.",
        nil
      )
      return
    }
    roomService.batchReward(liveRecordId, giftId: giftId, giftCount: giftCount, userUuids: userUuids) {
      callback?(NEVoiceRoomErrorCode.success, "Successfully send batch gift.", nil)
    } failure: { error in
      callback?(error.code, error.localizedDescription, nil)
    }
  }

  /// 处理批量礼物消息
  internal func handleBatchGiftMessage(_ rewardMsg: _NEVoiceRoomBatchRewardMessage) {
    guard
      let _ = rewardMsg.userUuid,
      let _ = rewardMsg.userName,
      let _ = rewardMsg.giftId,
      rewardMsg.targets.count > 0
    else {
      return
    }
    let giftModel = NEVoiceRoomBatchGiftModel(rewardMsg)
    NEVoiceRoomLog.messageLog(
      kitTag,
      desc: "Handle batch gift message. SendAccount: \(giftModel.sendAccout). SendNick: \(giftModel.rewarderUserName). GiftId: \(giftModel.giftId)."
    )
    DispatchQueue.main.async {
      for pointerListener in self.listeners.allObjects {
        guard pointerListener is NEVoiceRoomListener, let listener = pointerListener as? NEVoiceRoomListener else { continue }

        if listener.responds(to: #selector(NEVoiceRoomListener.onReceiveBatchGift(giftModel:))) {
          listener.onReceiveBatchGift?(giftModel: giftModel)
        }
      }
    }
  }
}

extension NEVoiceRoomKit: NERoomListener {
  public func onRtcRemoteAudioVolumeIndication(volumes: [NEMemberVolumeInfo],
                                               totalVolume: Int) {
    DispatchQueue.main.async {
      for pointerListener in self.listeners.allObjects {
        guard pointerListener is NEVoiceRoomListener, let listener = pointerListener as? NEVoiceRoomListener else { continue }
        if listener.responds(to: #selector(NEVoiceRoomListener.onRtcRemoteAudioVolumeIndication(volumes:totalVolume:))) {
          let v: [NEVoiceRoomMemberVolumeInfo] = volumes.map { info in
            NEVoiceRoomMemberVolumeInfo(info: info)
          }
          listener.onRtcRemoteAudioVolumeIndication?(volumes: v, totalVolume: totalVolume)
        }
      }
    }
  }

  public func onRtcLocalAudioVolumeIndication(volume: Int, enableVad: Bool) {
    DispatchQueue.main.async {
      for pointerListener in self.listeners.allObjects {
        guard pointerListener is NEVoiceRoomListener, let listener = pointerListener as? NEVoiceRoomListener else { continue }
        if listener.responds(to: #selector(NEVoiceRoomListener.onRtcLocalAudioVolumeIndication(volume:enableVad:))) {
          listener.onRtcLocalAudioVolumeIndication?(volume: volume, enableVad: enableVad)
        }
      }
    }
  }

  public func onRtcAudioEffectFinished(effectId: UInt32) {
    guard NEVoiceRoomKit.getInstance().audioPlayService?.currentEffectId == effectId else { return }
    DispatchQueue.main.async {
      for pointerListener in self.listeners.allObjects {
        guard pointerListener is NEVoiceRoomListener, let listener = pointerListener as? NEVoiceRoomListener else { continue }
        if listener.responds(to: #selector(NEVoiceRoomListener.onAudioEffectFinished)) {
          listener.onAudioEffectFinished?()
        }
      }
    }
  }

  public func onRtcAudioEffectTimestampUpdate(effectId: UInt32, timeStampMS: UInt64) {
    DispatchQueue.main.async {
      for pointerListener in self.listeners.allObjects {
        guard pointerListener is NEVoiceRoomListener, let listener = pointerListener as? NEVoiceRoomListener else { continue }
        if listener
          .responds(to: #selector(NEVoiceRoomListener.onAudioEffectTimestampUpdate(_:timeStampMS:))) {
          listener.onAudioEffectTimestampUpdate?(effectId, timeStampMS: timeStampMS)
        }
      }
    }
  }

  public func onMemberPropertiesChanged(member: NERoomMember, properties: [String: String]) {
    DispatchQueue.main.async {
      if properties.keys.contains(MemberPropertyConstants.MuteAudio.key) { // mute audio
        for pointListener in self.listeners.allObjects {
          guard pointListener is NEVoiceRoomListener, let listener = pointListener as? NEVoiceRoomListener else { continue }

          let mem = NEVoiceRoomMember(member)
          if listener
            .responds(to: #selector(NEVoiceRoomListener
                .onMemberAudioMuteChanged(_:mute:operateBy:))) {
            listener.onMemberAudioMuteChanged?(mem, mute: !mem.isAudioOn, operateBy: nil)
          }
        }
      } else if properties.keys.contains(MemberPropertyConstants.CanOpenMic.key) { // ban
        let ban: Bool = properties[MemberPropertyConstants.CanOpenMic.key] ==
          MemberPropertyConstants.CanOpenMic.no
        let mem = NEVoiceRoomMember(member)
        // 如果是自己被ban或者解除ban
        if member.uuid == self.localMember?.account {
          if ban {
            self.internalMute(bySelf: false)
          } else {
            if !self.isSelfMuted {
              self.unmuteMyAudio()
            }
          }
        }
        for pointListener in self.listeners.allObjects {
          guard pointListener is NEVoiceRoomListener, let listener = pointListener as? NEVoiceRoomListener else { continue }
          if listener
            .responds(to: #selector(NEVoiceRoomListener.onMemberAudioBanned(_:banned:))) {
            listener.onMemberAudioBanned?(mem, banned: ban)
          }
        }
      }
    }
  }

  public func onMemberJoinRtcChannel(members: [NERoomMember]) {
    for member in members {
      if member.uuid == localMember?.account {
        // 如果发现自己在麦位上的时候还没有加入RTC，则在这个回调里进行clientRole的处理
        if shouldSetClientRoleWhenJoin {
          if let localItem = localSeats?.first(where: { $0.user == localMember?.account }),
             localItem.status == .taken {
            roomContext?.rtcController.setClientRole(.broadcaster)
          } else {
            roomContext?.rtcController.setClientRole(.audience)
          }
          shouldSetClientRoleWhenJoin = false
        }
        roomContext?.rtcController.unmuteMyAudio()
        return
      }
    }
  }

  public func onMemberJoinRoom(members: [NERoomMember]) {
    DispatchQueue.main.async {
      let list = members.map { NEVoiceRoomMember($0) }
      for pointListener in self.listeners.allObjects {
        guard pointListener is NEVoiceRoomListener, let listener = pointListener as? NEVoiceRoomListener else { continue }

        if listener.responds(to: #selector(NEVoiceRoomListener.onMemberJoinRoom(_:))) {
          listener.onMemberJoinRoom?(list)
        }
      }
    }
  }

  public func onMemberLeaveRoom(members: [NERoomMember]) {
    DispatchQueue.main.async {
      let list = members.map { NEVoiceRoomMember($0) }
      for pointListener in self.listeners.allObjects {
        guard pointListener is NEVoiceRoomListener, let listener = pointListener as? NEVoiceRoomListener else { continue }

        if listener.responds(to: #selector(NEVoiceRoomListener.onMemberLeaveRoom(_:))) {
          listener.onMemberLeaveRoom?(list)
        }
      }
    }
  }

  public func onMemberJoinChatroom(members: [NERoomMember]) {
    DispatchQueue.main.async {
      let list = members.map { NEVoiceRoomMember($0) }
      for pointListener in self.listeners.allObjects {
        guard pointListener is NEVoiceRoomListener, let listener = pointListener as? NEVoiceRoomListener else { continue }

        if listener.responds(to: #selector(NEVoiceRoomListener.onMemberJoinChatroom(_:))) {
          listener.onMemberJoinChatroom?(list)
        }
      }
    }
  }

  public func onRoomEnded(reason: NERoomEndReason) {
    DispatchQueue.main.async {
      self.reset()
      for pointListener in self.listeners.allObjects {
        guard pointListener is NEVoiceRoomListener, let listener = pointListener as? NEVoiceRoomListener else { continue }
        if listener.responds(to: #selector(NEVoiceRoomListener.onRoomEnded(_:))) {
          listener
            .onRoomEnded?(NEVoiceRoomEndReason(rawValue: reason.rawValue) ?? .unknow)
        }
      }
    }
  }

  public func onRtcChannelError(code: Int) {
    DispatchQueue.main.async {
      for pointListener in self.listeners.allObjects {
        guard pointListener is NEVoiceRoomListener, let listener = pointListener as? NEVoiceRoomListener else { continue }

        if listener.responds(to: #selector(NEVoiceRoomListener.onRtcChannelError(_:))) {
          listener.onRtcChannelError?(code)
        }
      }
    }
  }

  /// 本端音频输出设备变更通知，如切换到扬声器、听筒、耳机等
  public func onRtcAudioOutputDeviceChanged(device: NEAudioOutputDevice) {
    DispatchQueue.main.async {
      for pointerListener in self.listeners.allObjects {
        guard pointerListener is NEVoiceRoomListener, let listener = pointerListener as? NEVoiceRoomListener else { continue }
        if listener
          .responds(to: #selector(NEVoiceRoomListener.onAudioOutputDeviceChanged(_:))) {
          listener
            .onAudioOutputDeviceChanged?(NEVoiceRoomAudioOutputDevice(rawValue: UInt(device
                .rawValue)) ?? .speakerPhone)
        }
      }
    }
  }

  public func onReceiveChatroomMessages(messages: [NERoomChatMessage]) {
    DispatchQueue.main.async {
      for message in messages {
        switch message.messageType {
        case .text:
          for pointListener in self.listeners.allObjects {
            guard pointListener is NEVoiceRoomListener, let listener = pointListener as? NEVoiceRoomListener,
                  let textMessage = message as? NERoomChatTextMessage else { continue }

            if listener
              .responds(to: #selector(NEVoiceRoomListener.onReceiveTextMessage(_:))) {
              listener
                .onReceiveTextMessage?(
                  NEVoiceRoomChatTextMessage(textMessage)
                )
            }
          }
        case .custom:
          if let msg = message as? NERoomChatCustomMessage {
            self.handleCustomMessage(msg)
          }

        case .image: break
        case .file: break
        default: break
        }
      }
    }
  }

  public func onSeatRequestSubmitted(_ seatIndex: Int, user: String) {
    DispatchQueue.main.async {
      for pointListener in self.listeners.allObjects {
        guard pointListener is NEVoiceRoomListener, let listener = pointListener as? NEVoiceRoomListener else { continue }

        if listener
          .responds(to: #selector(NEVoiceRoomListener.onSeatRequestSubmitted(_:account:))) {
          listener.onSeatRequestSubmitted?(seatIndex, account: user)
        }
      }
    }
  }

  public func onSeatRequestCancelled(_ seatIndex: Int, user: String) {
    DispatchQueue.main.async {
      for pointListener in self.listeners.allObjects {
        guard pointListener is NEVoiceRoomListener, let listener = pointListener as? NEVoiceRoomListener else { continue }

        if listener
          .responds(to: #selector(NEVoiceRoomListener.onSeatRequestCancelled(_:account:))) {
          listener.onSeatRequestCancelled?(seatIndex, account: user)
        }
      }
    }
  }

  public func onSeatRequestApproved(_ seatIndex: Int, user: String, operateBy: String,
                                    isAutoAgree: Bool) {
    DispatchQueue.main.async {
      for pointListener in self.listeners.allObjects {
        guard pointListener is NEVoiceRoomListener, let listener = pointListener as? NEVoiceRoomListener else { continue }

        if listener
          .responds(to: #selector(NEVoiceRoomListener
              .onSeatRequestApproved(_:account:operateBy:isAutoAgree:))) {
          listener.onSeatRequestApproved?(
            seatIndex,
            account: user,
            operateBy: operateBy,
            isAutoAgree: isAutoAgree
          )
        }
      }
    }
  }

  public func onSeatRequestRejected(_ seatIndex: Int, user: String, operateBy: String) {
    DispatchQueue.main.async {
      for pointListener in self.listeners.allObjects {
        guard pointListener is NEVoiceRoomListener, let listener = pointListener as? NEVoiceRoomListener else { continue }

        if listener
          .responds(to: #selector(NEVoiceRoomListener
              .onSeatRequestRejected(_:account:operateBy:))) {
          listener.onSeatRequestRejected?(seatIndex, account: user, operateBy: operateBy)
        }
      }
    }
  }

  public func onSeatLeave(_ seatIndex: Int, user: String) {
    DispatchQueue.main.async {
      for pointListener in self.listeners.allObjects {
        guard pointListener is NEVoiceRoomListener, let listener = pointListener as? NEVoiceRoomListener else { continue }

        if listener.responds(to: #selector(NEVoiceRoomListener.onSeatLeave(_:account:))) {
          listener.onSeatLeave?(seatIndex, account: user)
        }
      }
    }
  }

  public func onSeatKicked(_ seatIndex: Int, user: String, operateBy: String) {
    DispatchQueue.main.async {
      for pointListener in self.listeners.allObjects {
        guard pointListener is NEVoiceRoomListener, let listener = pointListener as? NEVoiceRoomListener else { continue }

        if listener
          .responds(to: #selector(NEVoiceRoomListener.onSeatKicked(_:account:operateBy:))) {
          listener.onSeatKicked?(seatIndex, account: user, operateBy: operateBy)
        }
      }
    }
  }

  /// seat open
  /// seat close
  /// seat enter

  public func onSeatListChanged(_ seatItems: [NESeatItem]) {
    DispatchQueue.main.async {
      let items = seatItems.map { NEVoiceRoomSeatItem($0) }
      for pointListener in self.listeners.allObjects {
        guard pointListener is NEVoiceRoomListener, let listener = pointListener as? NEVoiceRoomListener else { continue }

        if listener.responds(to: #selector(NEVoiceRoomListener.onSeatListChanged(_:))) {
          listener.onSeatListChanged?(items)
        }
      }
      guard let context = self.roomContext else { return }
      var isOnSeat = false
      var newState = NEVoiceRoomSeatItemStatus.initial
      if let item = items.first(where: { $0.user == context.localMember.uuid }) {
        if item.status == .taken {
          // 新状态自己在麦上
          isOnSeat = true
        }
        newState = item.status
      }

      var localIsOnSeat = false
      var oldState = NEVoiceRoomSeatItemStatus.initial
      if let localItem = self.localSeats?.first(where: { $0.user == context.localMember.uuid }) {
        if localItem.status == .taken {
          // 老状态自己在麦上
          localIsOnSeat = true
        }
        oldState = NEVoiceRoomSeatItemStatus(rawValue: localItem.status.rawValue) ?? .initial
      }
      // 上报自己麦位状态的变更
      if newState != oldState {
        for pointListener in self.listeners.allObjects {
          if let listener = pointListener as? NEVoiceRoomListener,
             listener.responds(to: #selector(NEVoiceRoomListener.onSelfSeatStatusChanged(new:old:))) {
            listener.onSelfSeatStatusChanged?(new: newState, old: oldState)
          }
        }
      }

      if !isOnSeat {
        // 新状态不在麦上，但是老状态在麦上，说明有下麦行为，下麦默认关闭音频
        if localIsOnSeat {
          self.muteMyAudio()
        }
        // 不在麦位，且属性 被ban, 删除属性
        if context.localMember.properties[MemberPropertyConstants.CanOpenMic.key] ==
          MemberPropertyConstants.CanOpenMic.no {
          context.deleteMemberProperty(
            userUuid: context.localMember.uuid,
            key: MemberPropertyConstants.CanOpenMic.key
          )
        }
      } else if !localIsOnSeat {
        // 新状态自己在麦上，但是老状态自己不在麦上，说明是有上麦行为，上麦默认打开音频
        self.unmuteMyAudio()
      }
      self.localSeats = seatItems

      // RTC现在有个bug，当正在加入Channel的情况下设置clientRole会不生效
      if context.localMember.isInRtcChannel {
        // 当前自己在麦上，则要切换RTC的clientRole
        context.rtcController.setClientRole(isOnSeat ? .broadcaster : .audience)
      } else {
        self.shouldSetClientRoleWhenJoin = true
      }
    }
  }

  public func onSeatInvitationAccepted(_ seatIndex: Int, user: String, isAutoAgree: Bool) {
    DispatchQueue.main.async {
      for pointListener in self.listeners.allObjects {
        guard pointListener is NEVoiceRoomListener, let listener = pointListener as? NEVoiceRoomListener else { continue }

        if listener
          .responds(to: #selector(NEVoiceRoomListener
              .onSeatInvitationAccepted(_:account:isAutoAgree:))) {
          listener.onSeatInvitationAccepted?(
            seatIndex,
            account: user,
            isAutoAgree: isAutoAgree
          )
        }
      }
    }
  }
}
