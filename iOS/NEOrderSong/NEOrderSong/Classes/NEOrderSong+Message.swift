// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Foundation
import NERoomKit

public extension NEOrderSong {
  /// 给房间内用户发送自定义消息，如房间内信令
  /// - Parameters:
  ///   - userUuid: 目标成员Id
  ///   - commandId: 消息类型 区间[10000 - 19999]
  ///   - data: 自定义消息内容
  ///   - callback: 回调
  func sendCustomMessage(_ userUuid: String,
                         commandId: Int,
                         data: String,
                         callback: NEOrderSongCallback<AnyObject>? = nil) {
    NEOrderSongLog.apiLog(
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
            NEOrderSongLog.successLog(kitTag, desc: "Successfully send custom message.")
          } else {
            NEOrderSongLog.errorLog(
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
    NEOrderSongLog.infoLog(kitTag, desc: "Receive custom message.")
    guard let dic = message.attachStr?.toDictionary() else { return }
    if let data = dic["data"] as? [String: Any],
       let cmd = data["cmd"] as? Int {
      switch cmd {
      // 合唱消息
      case NEOrderSongChorusActionType.startSong.rawValue ... NEOrderSongChorusActionType.next
        .rawValue:
        NEOrderSongLog.infoLog(kitTag, desc: "Chorus message. \(data)")
        guard let dic = data["data"] as? [String: Any] else { return }
        handleChorusMessage(cmd, data: dic)
      case NEOrderSongPickSongActionType.pick.rawValue ... NEOrderSongPickSongActionType
        .listChange.rawValue: // 点歌台
        handlePickSongMessage(cmd, data: dic)
      default: break
      }
    }
  }

  /// 处理合唱消息
  func handleChorusMessage(_ cmd: Int, data: [String: Any]) {
    NEOrderSongLog.messageLog(kitTag, desc: "Handle chorus message. Cmd: \(cmd). Data: \(data)")
    let actionType = NEOrderSongChorusActionType(rawValue: cmd) ?? .startSong
    guard let songModel = NEOrderSongDecoder.decode(NEOrderSongSongModel.self, param: data)
    else { return }
    // 回调
    DispatchQueue.main.async {
      for pointerListener in self.listeners.allObjects {
        guard pointerListener is NEOrderSongListener, let listener = pointerListener as? NEOrderSongListener else { continue }
        if listener
          .responds(to: #selector(NEOrderSongListener.onReceiveChorusMessage(_:songModel:))) {
          listener.onReceiveChorusMessage?(actionType, songModel: songModel)
        }
      }
    }
  }

  /// 处理点歌台消息
  func handlePickSongMessage(_ cmd: Int, data: [String: Any]) {
    NEOrderSongLog.messageLog(
      kitTag,
      desc: "Handle pick song message. Cmd: \(cmd). Data: \(data)"
    )
    // 列表变化特殊处理
    guard cmd != NEOrderSongPickSongActionType.listChange.rawValue else {
      DispatchQueue.main.async {
        for pointerListener in self.listeners.allObjects {
          guard pointerListener is NEOrderSongListener, let listener = pointerListener as? NEOrderSongListener else { continue }
          if listener.responds(to: #selector(NEOrderSongListener.onSongListChanged)) {
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
    let actionType = NEOrderSongPickSongActionType(rawValue: cmd) ?? .pick
    let orderSongModel = NEOrderSongDecoder.decode(NEOrderSongOrderSongModel.self, param: temp)
    if let attachment = temp["attachment"] as? String {
      orderSongModel?.attachment = attachment
    }
    if let operato = temp["operator"] as? [String: Any] {
      orderSongModel?.actionOperator = NEOrderSongDecoder.decode(
        NEOrderSongOperator.self,
        param: operato
      )
    }

    if let nextOrderSong = temp["nextOrderSong"] as? [String: Any] {
      orderSongModel?.nextOrderSong = NEOrderSongDecoder.decode(
        NEOrderSongOrderSongModel.self,
        param: nextOrderSong
      )
    }
    DispatchQueue.main.async {
      for pointerListener in self.listeners.allObjects {
        guard pointerListener is NEOrderSongListener, let listener = pointerListener as? NEOrderSongListener else { continue }

        if actionType == NEOrderSongPickSongActionType.pick {
          if listener.responds(to: #selector(NEOrderSongListener.onSongOrdered(_:))) {
            listener.onSongOrdered?(orderSongModel)
          }
        } else if actionType == NEOrderSongPickSongActionType.cancelPick {
          if listener.responds(to: #selector(NEOrderSongListener.onSongDeleted(_:))) {
            listener.onSongDeleted?(orderSongModel)
          }
        } else if actionType == NEOrderSongPickSongActionType.switchSong {
          if listener.responds(to: #selector(NEOrderSongListener.onNextSong(_:))) {
            listener.onNextSong?(orderSongModel)
          }
        } else if actionType == NEOrderSongPickSongActionType.top {
          if listener.responds(to: #selector(NEOrderSongListener.onSongTopped(_:))) {
            listener.onSongTopped?(orderSongModel)
          }
        }
      }
    }
  }
}

extension NEOrderSong: NERoomListener {
  public func onReceiveChatroomMessages(messages: [NERoomChatMessage]) {
    DispatchQueue.main.async {
      for message in messages {
        switch message.messageType {
        case .custom:
          if let msg = message as? NERoomChatCustomMessage {
            self.handleCustomMessage(msg)
            break
          }
        @unknown default: break
        }
      }
    }
  }
}
