// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Foundation
import NERoomKit

public extension NEListenTogetherKit {
  /// 发送聊天室消息
  ///
  /// 使用前提：该方法仅在调用[login]方法登录成功后调用有效
  /// - Parameters:
  ///   - content: 发送内容
  ///   - callback: 回调
  func sendTextMessage(_ content: String, callback: NEListenTogetherCallback<AnyObject>? = nil) {
    NEListenTogetherLog.apiLog(kitTag, desc: "Send text message. Content: \(content).")
    Judge.preCondition({
      self.roomContext!.chatController
        .sendBroadcastTextMessage(message: content) { code, msg, _ in
          if code == 0 {
            NEListenTogetherLog.successLog(kitTag, desc: "Successfully send text messge.")
          } else {
            NEListenTogetherLog.errorLog(
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
                         callback: NEListenTogetherCallback<AnyObject>? = nil) {
    NEListenTogetherLog.apiLog(
      kitTag,
      desc: "Send custom message. UserUuid: \(userUuid). CommandId: \(commandId). Data: \(data)"
    )
    Judge.preCondition({
      NERoomKit.shared().messageChannelService
        .sendCustomMessage(roomUuid: self.roomContext!.roomUuid,
                           userUuid: userUuid,
                           commandId: commandId,
                           data: data) { code, msg, _ in
          if code == 0 {
            NEListenTogetherLog.successLog(kitTag, desc: "Successfully send custom message.")
          } else {
            NEListenTogetherLog.errorLog(
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
    NEListenTogetherLog.infoLog(kitTag, desc: "Receive custom message.")
    guard let dic = message.attachStr?.toDictionary() else { return }
    if let data = dic["data"] as? [String: Any],
       let cmd = data["cmd"] as? Int {
      switch cmd {
      // 合唱消息
      case NEListenTogetherChorusActionType.startSong.rawValue ... NEListenTogetherChorusActionType.next
        .rawValue:
        NEListenTogetherLog.infoLog(kitTag, desc: "Chorus message. \(data)")
        guard let dic = data["data"] as? [String: Any] else { return }
        handleChorusMessage(cmd, data: dic)
      case NEListenTogetherPickSongActionType.pick.rawValue ... NEListenTogetherPickSongActionType
        .listChange.rawValue: // 点歌台
        handlePickSongMessage(cmd, data: dic)
      default: break
      }
    } else if let content = message.attachStr,
              let subCmd = dic["subCmd"] as? Int,
              let type = dic["type"] as? Int,
              subCmd == 2,
              type == 1001,
              let obj = NEListenTogetherDecoder.decode(
                _NEListenTogetherRewardMessage.self,
                jsonString: content
              ) {
      handleGiftMessage(obj)
    }
  }

  /// 处理合唱消息
  func handleChorusMessage(_ cmd: Int, data: [String: Any]) {
    NEListenTogetherLog.messageLog(kitTag, desc: "Handle chorus message. Cmd: \(cmd). Data: \(data)")
    let actionType = NEListenTogetherChorusActionType(rawValue: cmd) ?? .startSong
    guard let songModel = NEListenTogetherDecoder.decode(NEListenTogetherSongModel.self, param: data)
    else { return }
    // 回调
    DispatchQueue.main.async {
      for pointerListener in self.listeners.allObjects {
        guard pointerListener is NEListenTogetherListener, let listener = pointerListener as? NEListenTogetherListener else { continue }
        if listener
          .responds(to: #selector(NEListenTogetherListener.onReceiveChorusMessage(_:songModel:))) {
          listener.onReceiveChorusMessage?(actionType, songModel: songModel)
        }
      }
    }
  }

  /// 发送礼物
  /// - Parameters:
  ///   - giftId: 礼物Id
  func sendGift(_ giftId: Int,
                callback: NEListenTogetherCallback<AnyObject>? = nil) {
    NEListenTogetherLog.apiLog(kitTag, desc: "Send gift. GiftId: \(giftId)")
    guard NEListenTogetherKit.getInstance().isInitialized else {
      NEListenTogetherLog.errorLog(kitTag, desc: "Failed to send Gift. Uninitialized.")
      callback?(NEListenTogetherErrorCode.failed, "Failed to send Gift. Uninitialized.", nil)
      return
    }
    guard let liveRecordId = liveInfo?.live?.liveRecordId
    else {
      NEListenTogetherLog.errorLog(kitTag, desc: "Failed to send Gift. liveRecordId not exist.")
      callback?(
        NEListenTogetherErrorCode.failed,
        "Failed to send Gift. liveRecordId not exist.",
        nil
      )
      return
    }
    roomService.reward(liveRecordId, giftId: giftId) {
      callback?(NEListenTogetherErrorCode.success, "Successfully send gift.", nil)
    } failure: { error in
      callback?(error.code, error.localizedDescription, nil)
    }
  }

  /// 处理点歌台消息
  func handlePickSongMessage(_ cmd: Int, data: [String: Any]) {
    NEListenTogetherLog.messageLog(
      kitTag,
      desc: "Handle pick song message. Cmd: \(cmd). Data: \(data)"
    )
    // 列表变化特殊处理
    guard cmd != NEListenTogetherPickSongActionType.listChange.rawValue else {
      DispatchQueue.main.async {
        for pointerListener in self.listeners.allObjects {
          guard pointerListener is NEListenTogetherListener, let listener = pointerListener as? NEListenTogetherListener else { continue }
          if listener.responds(to: #selector(NEListenTogetherListener.onSongListChanged)) {
            listener.onSongListChanged?()
          }
        }
      }
      return
    }
    guard let dic = data["data"] as? [String: Any] else { return }
    var temp = dic
    // 有些有两层
    if let data = dic["data"] as? [String: Any] {
      temp = data
    }
    let actionType = NEListenTogetherPickSongActionType(rawValue: cmd) ?? .pick
    let orderSongModel = NEListenTogetherDecoder.decode(NEListenTogetherOrderSongModel.self, param: temp)
    if let attachment = temp["attachment"] as? String {
      orderSongModel?.attachment = attachment
    }
    if let operato = temp["operator"] as? [String: Any] {
      orderSongModel?.actionOperator = NEListenTogetherDecoder.decode(
        NEListenTogetherOperator.self,
        param: operato
      )
    }
    if let nextOrderSong = temp["nextOrderSong"] as? [String: Any] {
      orderSongModel?.nextOrderSong = NEListenTogetherDecoder.decode(
        NEListenTogetherOrderSongModel.self,
        param: nextOrderSong
      )
    }
    DispatchQueue.main.async {
      for pointerListener in self.listeners.allObjects {
        guard pointerListener is NEListenTogetherListener, let listener = pointerListener as? NEListenTogetherListener else { continue }

        if actionType == NEListenTogetherPickSongActionType.pick {
          if listener.responds(to: #selector(NEListenTogetherListener.onSongOrdered(_:))) {
            listener.onSongOrdered?(orderSongModel)
          }
        } else if actionType == NEListenTogetherPickSongActionType.cancelPick {
          if listener.responds(to: #selector(NEListenTogetherListener.onSongDeleted(_:))) {
            listener.onSongDeleted?(orderSongModel)
          }
        } else if actionType == NEListenTogetherPickSongActionType.switchSong {
          if listener.responds(to: #selector(NEListenTogetherListener.onNextSong(_:))) {
            listener.onNextSong?(orderSongModel)
          }
        } else if actionType == NEListenTogetherPickSongActionType.top {
          if listener.responds(to: #selector(NEListenTogetherListener.onSongTopped(_:))) {
            listener.onSongTopped?(orderSongModel)
          }
        }
      }
    }
  }

  /// 处理礼物消息
  internal func handleGiftMessage(_ rewardMsg: _NEListenTogetherRewardMessage) {
    guard let _ = rewardMsg.rewarderUserUuid,
          let _ = rewardMsg.rewarderUserName,
          let _ = rewardMsg.giftId
    else { return }
    let giftModel = NEListenTogetherGiftModel(rewardMsg)
    NEListenTogetherLog.messageLog(
      kitTag,
      desc: "Handle gift message. SendAccount: \(giftModel.sendAccout). SendNick: \(giftModel.sendNick). GiftId: \(giftModel.giftId)"
    )
    DispatchQueue.main.async {
      for pointerListener in self.listeners.allObjects {
        guard pointerListener is NEListenTogetherListener, let listener = pointerListener as? NEListenTogetherListener else { continue }

        if listener.responds(to: #selector(NEListenTogetherListener.onReceiveGift(giftModel:))) {
          listener.onReceiveGift?(giftModel: giftModel)
        }
      }
    }
  }
}

extension NEListenTogetherKit: NERoomListener {
  public func onRtcAudioEffectFinished(effectId: UInt32) {
    guard NEListenTogetherKit.getInstance().currentSongIdForAudioEffect == effectId else { return }
    DispatchQueue.main.async {
      for pointerListener in self.listeners.allObjects {
        guard pointerListener is NEListenTogetherListener, let listener = pointerListener as? NEListenTogetherListener else { continue }
        if listener.responds(to: #selector(NEListenTogetherListener.onAudioEffectFinished)) {
          listener.onAudioEffectFinished?()
        }
      }
    }
  }

  public func onRtcAudioEffectTimestampUpdate(effectId: UInt32, timeStampMS: UInt64) {
    DispatchQueue.main.async {
      for pointerListener in self.listeners.allObjects {
        guard pointerListener is NEListenTogetherListener, let listener = pointerListener as? NEListenTogetherListener else { continue }
        if listener
          .responds(to: #selector(NEListenTogetherListener.onAudioEffectTimestampUpdate(_:timeStampMS:))) {
          listener.onAudioEffectTimestampUpdate?(effectId, timeStampMS: timeStampMS)
        }
      }
    }
  }

  public func onMemberPropertiesChanged(member: NERoomMember, properties: [String: String]) {
    DispatchQueue.main.async {
      if properties.keys.contains(MemberPropertyConstants.MuteAudio.key) { // mute audio
        for pointListener in self.listeners.allObjects {
          guard pointListener is NEListenTogetherListener, let listener = pointListener as? NEListenTogetherListener else { continue }

          let mem = NEListenTogetherMember(member)
          if listener
            .responds(to: #selector(NEListenTogetherListener
                .onMemberAudioMuteChanged(_:mute:operateBy:))) {
            listener.onMemberAudioMuteChanged?(mem, mute: !mem.isAudioOn, operateBy: nil)
          }
        }
      } else if properties.keys.contains(MemberPropertyConstants.CanOpenMic.key) { // ban
        let ban: Bool = properties[MemberPropertyConstants.CanOpenMic.key] ==
          MemberPropertyConstants.CanOpenMic.no
        let mem = NEListenTogetherMember(member)
        for pointListener in self.listeners.allObjects {
          guard pointListener is NEListenTogetherListener, let listener = pointListener as? NEListenTogetherListener else { continue }

          if listener
            .responds(to: #selector(NEListenTogetherListener.onMemberAudioBanned(_:banned:))) {
            listener.onMemberAudioBanned?(mem, banned: ban)
          }
        }
      }
    }
  }

  public func onMemberJoinRtcChannel(members: [NERoomMember]) {
    for member in members {
      if member.uuid == localMember?.account {
        roomContext?.rtcController.unmuteMyAudio()
      }
    }
  }

  public func onMemberJoinRoom(members: [NERoomMember]) {
    DispatchQueue.main.async {
      let list = members.map { NEListenTogetherMember($0) }
      for pointListener in self.listeners.allObjects {
        guard pointListener is NEListenTogetherListener, let listener = pointListener as? NEListenTogetherListener else { continue }

        if listener.responds(to: #selector(NEListenTogetherListener.onMemberJoinRoom(_:))) {
          listener.onMemberJoinRoom?(list)
        }
      }
    }
  }

  public func onMemberLeaveRoom(members: [NERoomMember]) {
    DispatchQueue.main.async {
      let list = members.map { NEListenTogetherMember($0) }
      for pointListener in self.listeners.allObjects {
        guard pointListener is NEListenTogetherListener, let listener = pointListener as? NEListenTogetherListener else { continue }

        if listener.responds(to: #selector(NEListenTogetherListener.onMemberLeaveRoom(_:))) {
          listener.onMemberLeaveRoom?(list)
        }
      }
    }
  }

  public func onMemberJoinChatroom(members: [NERoomMember]) {
    DispatchQueue.main.async {
      let list = members.map { NEListenTogetherMember($0) }
      for pointListener in self.listeners.allObjects {
        guard pointListener is NEListenTogetherListener, let listener = pointListener as? NEListenTogetherListener else { continue }

        if listener.responds(to: #selector(NEListenTogetherListener.onMemberJoinChatroom(_:))) {
          listener.onMemberJoinChatroom?(list)
        }
      }
    }
  }

  public func onRoomEnded(reason: NERoomEndReason) {
    DispatchQueue.main.async {
      self.reset()
      for pointListener in self.listeners.allObjects {
        guard pointListener is NEListenTogetherListener, let listener = pointListener as? NEListenTogetherListener else { continue }

        if listener.responds(to: #selector(NEListenTogetherListener.onRoomEnded(_:))) {
          listener
            .onRoomEnded?(NEListenTogetherEndReason(rawValue: reason.rawValue) ?? .unknow)
        }
      }
    }
  }

  public func onRtcChannelError(code: Int) {
    DispatchQueue.main.async {
      for pointListener in self.listeners.allObjects {
        guard pointListener is NEListenTogetherListener, let listener = pointListener as? NEListenTogetherListener else { continue }

        if listener.responds(to: #selector(NEListenTogetherListener.onRtcChannelError(_:))) {
          listener.onRtcChannelError?(code)
        }
      }
    }
  }

  /// 本端音频输出设备变更通知，如切换到扬声器、听筒、耳机等
  public func onRtcAudioOutputDeviceChanged(device: NEAudioOutputDevice) {
    DispatchQueue.main.async {
      for pointerListener in self.listeners.allObjects {
        guard pointerListener is NEListenTogetherListener, let listener = pointerListener as? NEListenTogetherListener else { continue }
        if listener
          .responds(to: #selector(NEListenTogetherListener.onAudioOutputDeviceChanged(_:))) {
          listener
            .onAudioOutputDeviceChanged?(NEListenTogetherAudioOutputDevice(rawValue: UInt(device
                .rawValue)) ?? .speakerPhone)
        }
      }
    }
  }

  public func onRtcRemoteAudioVolumeIndication(volumes: [NEMemberVolumeInfo],
                                               totalVolume: Int) {
    DispatchQueue.main.async {
      for pointerListener in self.listeners.allObjects {
        guard pointerListener is NEListenTogetherListener, let listener = pointerListener as? NEListenTogetherListener else { continue }
        if listener.responds(to: #selector(NEListenTogetherListener.onRtcRemoteAudioVolumeIndication(volumes:totalVolume:))) {
          let v: [NEListenTogetherMemberVolumeInfo] = volumes.map { info in
            NEListenTogetherMemberVolumeInfo(info: info)
          }
          listener.onRtcRemoteAudioVolumeIndication?(volumes: v, totalVolume: totalVolume)
        }
      }
    }
  }

  public func onRtcLocalAudioVolumeIndication(volume: Int, enableVad: Bool) {
    DispatchQueue.main.async {
      for pointerListener in self.listeners.allObjects {
        guard pointerListener is NEListenTogetherListener, let listener = pointerListener as? NEListenTogetherListener else { continue }
        if listener.responds(to: #selector(NEListenTogetherListener.onRtcLocalAudioVolumeIndication(volume:enableVad:))) {
          listener.onRtcLocalAudioVolumeIndication?(volume: volume, enableVad: enableVad)
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
            guard pointListener is NEListenTogetherListener, let listener = pointListener as? NEListenTogetherListener,
                  let textMessage = message as? NERoomChatTextMessage else { continue }

            if listener
              .responds(to: #selector(NEListenTogetherListener.onReceiveTextMessage(_:))) {
              listener
                .onReceiveTextMessage?(
                  NEListenTogetherChatTextMessage(textMessage)
                )
            }
          }
        case .custom:
          if let msg = message as? NERoomChatCustomMessage {
            self.handleCustomMessage(msg)
          }

        case .image: break
        case .file: break
        @unknown default: break
        }
      }
    }
  }

  public func onSeatRequestSubmitted(_ seatIndex: Int, user: String) {
    DispatchQueue.main.async {
      for pointListener in self.listeners.allObjects {
        guard pointListener is NEListenTogetherListener, let listener = pointListener as? NEListenTogetherListener else { continue }

        if listener
          .responds(to: #selector(NEListenTogetherListener.onSeatRequestSubmitted(_:account:))) {
          listener.onSeatRequestSubmitted?(seatIndex, account: user)
        }
      }
    }
  }

  public func onSeatRequestCancelled(_ seatIndex: Int, user: String) {
    DispatchQueue.main.async {
      for pointListener in self.listeners.allObjects {
        guard pointListener is NEListenTogetherListener, let listener = pointListener as? NEListenTogetherListener else { continue }

        if listener
          .responds(to: #selector(NEListenTogetherListener.onSeatRequestCancelled(_:account:))) {
          listener.onSeatRequestCancelled?(seatIndex, account: user)
        }
      }
    }
  }

  public func onSeatRequestApproved(_ seatIndex: Int, user: String, operateBy: String,
                                    isAutoAgree: Bool) {
    DispatchQueue.main.async {
      for pointListener in self.listeners.allObjects {
        guard pointListener is NEListenTogetherListener, let listener = pointListener as? NEListenTogetherListener else { continue }

        if listener
          .responds(to: #selector(NEListenTogetherListener
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
        guard pointListener is NEListenTogetherListener, let listener = pointListener as? NEListenTogetherListener else { continue }

        if listener
          .responds(to: #selector(NEListenTogetherListener
              .onSeatRequestRejected(_:account:operateBy:))) {
          listener.onSeatRequestRejected?(seatIndex, account: user, operateBy: operateBy)
        }
      }
    }
  }

  public func onSeatLeave(_ seatIndex: Int, user: String) {
    DispatchQueue.main.async {
      for pointListener in self.listeners.allObjects {
        guard pointListener is NEListenTogetherListener, let listener = pointListener as? NEListenTogetherListener else { continue }

        if listener.responds(to: #selector(NEListenTogetherListener.onSeatLeave(_:account:))) {
          listener.onSeatLeave?(seatIndex, account: user)
        }
      }
    }
  }

  public func onSeatKicked(_ seatIndex: Int, user: String, operateBy: String) {
    DispatchQueue.main.async {
      for pointListener in self.listeners.allObjects {
        guard pointListener is NEListenTogetherListener, let listener = pointListener as? NEListenTogetherListener else { continue }

        if listener
          .responds(to: #selector(NEListenTogetherListener.onSeatKicked(_:account:operateBy:))) {
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
      let items = seatItems.map { NEListenTogetherSeatItem($0) }
      for pointListener in self.listeners.allObjects {
        guard pointListener is NEListenTogetherListener, let listener = pointListener as? NEListenTogetherListener else { continue }

        if listener.responds(to: #selector(NEListenTogetherListener.onSeatListChanged(_:))) {
          listener.onSeatListChanged?(items)
        }
      }
      guard let context = self.roomContext else { return }
      var isOnSeat = false
      for item in items {
        if item.user == context.localMember.uuid,
           item.status == .taken {
          isOnSeat = true
        }
      }
      // 不在麦位，且属性 被ban, 删除属性
      if !isOnSeat, context.localMember.properties[MemberPropertyConstants.CanOpenMic.key] ==
        MemberPropertyConstants.CanOpenMic.no {
        context.deleteMemberProperty(
          userUuid: context.localMember.uuid,
          key: MemberPropertyConstants.CanOpenMic.key
        )
      }
      context.rtcController.setClientRole(isOnSeat ? .broadcaster : .audience)
    }
  }

  public func onSeatInvitationAccepted(_ seatIndex: Int, user: String, isAutoAgree: Bool) {
    DispatchQueue.main.async {
      for pointListener in self.listeners.allObjects {
        guard pointListener is NEListenTogetherListener, let listener = pointListener as? NEListenTogetherListener else { continue }

        if listener
          .responds(to: #selector(NEListenTogetherListener
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
