// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Foundation
import NERoomKit
import UIKit

public extension NEListenTogetherKit {
  /// 查询房间列表
  /// - Parameters:
  ///   - liveState: 直播状态
  ///   - pageNum: 页码
  ///   - pageSize: 页大小
  ///   - callback: 房间列表回调
  func getVoiceRoomList(_ type: Int = 2,
                        liveState: NEListenTogetherLiveState,
                        pageNum: Int,
                        pageSize: Int,
                        callback: NEListenTogetherCallback<NEListenTogetherList>? = nil) {
    NEListenTogetherLog.apiLog(kitTag, desc: "Room List.")
    Judge.initCondition({
      self.roomService.getVoiceRoomList(
        type,
        liveState: liveState.rawValue,
        pageNum: pageNum,
        pageSize: pageSize
      ) { list in
        NEListenTogetherLog.successLog(kitTag, desc: "Successfully get room list.")
        callback?(NEListenTogetherErrorCode.success, nil, list)
      } failure: { error in
        NEListenTogetherLog.errorLog(
          kitTag,
          desc: "Failed to get room list. Code: \(error.code). Msg: \(error.localizedDescription)"
        )
        callback?(error.code, error.localizedDescription, nil)
      }
    }, failure: callback)
  }

  /// 获取房间的信息
  func getRoomInfo(_ liveRecordId: Int,
                   callback: NEListenTogetherCallback<NEListenTogetherInfo>? = nil) {
    NEListenTogetherLog.apiLog(kitTag, desc: "get VoiceRoom RoomInfo.")

    Judge.initCondition({
      self.roomService.getVoiceRoomRoomInfo(liveRecordId) { info in
        NEListenTogetherLog.successLog(
          kitTag,
          desc: "Successfully get create room default info."
        )
        callback?(NEListenTogetherErrorCode.success, nil, NEListenTogetherInfo(create: info))
      }
        failure: { error in
        NEListenTogetherLog.errorLog(
          kitTag,
          desc: "Failed to get room list. Code: \(error.code). Msg: \(error.localizedDescription)"
        )
        callback?(error.code, error.localizedDescription, nil)
      }

    }, failure: callback)
  }

  /// 当前所在房间信息
  func getCurrentRoomInfo() -> NEListenTogetherInfo? {
    if let _ = roomContext,
       let liveInfo = liveInfo {
      return NEListenTogetherInfo(create: liveInfo)
    }
    return nil
  }

  /// 获取创建房间的默认信息
  /// - Parameter callback: 回调
  func getCreateRoomDefaultInfo(_ callback: NEListenTogetherCallback<NECreateVoiceRoomDefaultInfo>? =
    nil) {
    NEListenTogetherLog.apiLog(kitTag, desc: "Get create room default info.")
    Judge.initCondition({
      self.roomService.getDefaultLiveInfo { info in
        NEListenTogetherLog.successLog(
          kitTag,
          desc: "Successfully get create room default info."
        )
        callback?(NEListenTogetherErrorCode.success, nil, NECreateVoiceRoomDefaultInfo(info))
      } failure: { error in
        NEListenTogetherLog.errorLog(
          kitTag,
          desc: "Failed to get create room default info. Code: \(error.code). Msg: \(error.localizedDescription)"
        )
        callback?(error.code, error.localizedDescription, nil)
      }
    }, failure: callback)
  }

  /// 创建房间并进入房间
  /// - Parameters:
  ///   - params: 房间参数
  ///   - options: 房间配置
  ///   - callback: 回调
  func createRoom(_ params: NEListenTogetherCreateVoiceRoomParams,
                  options: NEListenTogetherCreateVoiceRoomOptions,
                  callback: NEListenTogetherCallback<NEListenTogetherInfo>? = nil) {
    NEListenTogetherLog.apiLog(kitTag, desc: "Create room.")

    // 初始化判断
    Judge.initCondition({
      self.roomService.startVoiceRoom(params) { [weak self] resp in
        guard let self = self else { return }
        guard let resp = resp else {
          NEListenTogetherLog.errorLog(kitTag, desc: "Failed to create room. RoomUuid is nil.")
          callback?(
            NEListenTogetherErrorCode.failed,
            "Failed to create room. RoomUuid is nil.",
            nil
          )
          return
        }
        // 存储直播信息
        self.liveInfo = resp
        NEListenTogetherLog.successLog(kitTag, desc: "Successfully create room.")
        callback?(NEListenTogetherErrorCode.success, nil, NEListenTogetherInfo(create: resp))
      } failure: { error in
        NEListenTogetherLog.errorLog(
          kitTag,
          desc: "Failed to create room. Code: \(error.code). Msg: \(error.localizedDescription)"
        )
        callback?(error.code, error.localizedDescription, nil)
      }
    }, failure: callback)
  }

  /// 加入房间
  /// - Parameters:
  ///   - params: 加入房间时参数
  ///   - options: 加入房间时配置
  ///   - callback: 回调
  func joinRoom(_ params: NEListenTogetherKitJoinVoiceRoomParams,
                options: NEJoinVoiceRoomOptions,
                callback: NEListenTogetherCallback<NEListenTogetherInfo>? = nil) {
    NEListenTogetherLog.apiLog(kitTag, desc: "Join room.")

    // 初始化判断
    Judge.initCondition({
      func join(_ params: NEListenTogetherKitJoinVoiceRoomParams,
                callback: NEListenTogetherCallback<NEListenTogetherInfo>?) {
        self._joinRoom(params.roomUuid,
                       userName: params.nick,
                       role: params.role.toString()) { joinCode, joinMsg, _ in
          if joinCode == 0 {
            self.roomService
              .getVoiceRoomRoomInfo(params.liveRecordId) { [weak self] data in
                guard let self = self else { return }
                guard let data = data else {
                  NEListenTogetherLog.infoLog(
                    kitTag,
                    desc: "Failed to join room. RoomInfo is nil."
                  )
                  return
                }
                self.liveInfo = data
                callback?(joinCode, nil, NEListenTogetherInfo(create: data))
              } failure: { error in
                NEListenTogetherLog.errorLog(
                  kitTag,
                  desc: "Failed to join room. Code: \(error.code). Msg: \(error.localizedDescription)"
                )
                callback?(error.code, error.localizedDescription, nil)
              }
          } else {
            callback?(joinCode, joinMsg, nil)
          }
        }
      }
      // 如果已经在此房间里则先退出
      if let context = NERoomKit.shared().roomService
        .getRoomContext(roomUuid: params.roomUuid) {
        context.leaveRoom { code, msg, obj in
          join(params, callback: callback)
        }
      } else {
        join(params, callback: callback)
      }
    }, failure: callback)
  }

  /// 离开房间
  /// - Parameter callback: 回调
  func leaveRoom(_ callback: NEListenTogetherCallback<AnyObject>? = nil) {
    NEListenTogetherLog.apiLog(kitTag, desc: "Leave room.")

    // 初始化、roomContext 判断
    Judge.preCondition({
      self.roomContext!.leaveRoom { [weak self] code, msg, _ in
        guard let self = self else { return }
        if code == 0 {
          NEListenTogetherLog.successLog(kitTag, desc: "Successfully leave room.")
        } else {
          NEListenTogetherLog.errorLog(
            kitTag,
            desc: "Failed to leave room. Code: \(code). Msg: \(msg ?? "")"
          )
        }
        self.reset()
        // 销毁
        //          self.audioPlayService?.destroy()
        callback?(code, msg, nil)
      }
    }, failure: callback)
  }

  /// 结束房间
  /// - Parameter callback: 回调
  func endRoom(_ callback: NEListenTogetherCallback<AnyObject>? = nil) {
    NEListenTogetherLog.apiLog(kitTag, desc: "End room.")
    Judge.initCondition({
      guard let liveRecordId = self.liveInfo?.live?.liveRecordId else {
        NEListenTogetherLog.errorLog(
          kitTag,
          desc: "Failed to end room. LiveRecordId don't exist."
        )
        callback?(
          NEListenTogetherErrorCode.failed,
          "Failed to end room. LiveRecordId don't exist.",
          nil
        )
        return
      }
      self.roomContext?.endRoom(isForce: true)
      self.roomService.endRoom(liveRecordId) {
        NEListenTogetherLog.successLog(kitTag, desc: "Successfully end room.")
        callback?(NEListenTogetherErrorCode.success, nil, nil)
      } failure: { error in
        NEListenTogetherLog.errorLog(
          kitTag,
          desc: "Failed to end room. Code: \(error.code). Msg: \(error.localizedDescription)"
        )
        callback?(error.code, error.localizedDescription, nil)
      }
      self.reset()
    }, failure: callback)
  }

  internal func reset() {
    liveInfo = nil
    // 移除 房间监听、消息监听
    roomContext?.removeRoomListener(listener: self)
    roomContext?.seatController.removeSeatListener(self)
    roomContext = nil
    _audioPlayService?.destroy()
  }

  /// 获取实时Token
  /// - Parameter callback: 回调
  func getSongToken(callback: NEListenTogetherCallback<NEListenTogetherDynamicToken>? = nil) {
    NEListenTogetherLog.apiLog(kitTag, desc: "Get Song Token")
    Judge.initCondition({
      self.roomService.getSongToken { data in
        NEListenTogetherLog.successLog(kitTag, desc: "Successfully getSongToken")
        callback?(NEListenTogetherErrorCode.success, nil, data)
      } failure: { error in
        NEListenTogetherLog.errorLog(
          kitTag,
          desc: "Failed to getSongToken. Code: \(error.code). Msg: \(error.localizedDescription)"
        )
        callback?(error.code, error.localizedDescription, nil)
      }

    }, failure: callback)
  }
}

// 加入karaoke扩展
extension NEListenTogetherKit {
  func _joinRoom(_ context: NERoomContext,
                 callback: NEListenTogetherCallback<AnyObject>? = nil) {
    // 初始化播放模块
    context.rtcController.setClientRole(.audience)
    _audioPlayService = NEListenTogetherAudioPlayService(roomUuid: context.roomUuid)
    _audioPlayService?.callback = self
    musicService = NEListenTogetherMusicService(context.roomUuid)
    // 加入rtc
    context.rtcController.joinRtcChannel { rtcCode, rtcMsg, _ in
      guard rtcCode == 0 else {
        // 加入rtc 失败，离开房间
        context.leaveRoom()
        NEListenTogetherLog.errorLog(
          kitTag,
          desc: "Failed to join rtc. Code: \(rtcCode). Msg: \(rtcMsg ?? "")"
        )
        callback?(rtcCode, rtcMsg, nil)
        return
      }
      // 加入聊天室
      context.chatController.joinChatroom { chatCode, chatMsg, _ in
        guard chatCode == 0 else {
          // 加入聊天室失败，离开房间
          context.leaveRoom()
          NEListenTogetherLog.errorLog(
            kitTag,
            desc: "Failed to join chatroom. Code: \(chatCode). Msg: \(chatMsg ?? "")"
          )
          callback?(chatCode, chatMsg, nil)
          return
        }
//                context.rtcController.getNtpTimeOffset()
        NEListenTogetherLog.successLog(kitTag, desc: "Successfully join room.")
        callback?(chatCode, nil, nil)
      }
    }
  }

  func _joinRoom(_ roomUuid: String,
                 userName: String,
                 role: String,
                 roomContext: NERoomContext? = nil,
                 callback: NEListenTogetherCallback<AnyObject>? = nil) {
    // 加入
    if let context = roomContext {
      _joinRoom(context, callback: callback)
      return
    }
    // 进入房间
    let joinParams = NEJoinRoomParams()
    joinParams.roomUuid = roomUuid
    joinParams.userName = userName
    joinParams.role = role
    let joinOptions = NEJoinRoomOptions()
    NERoomKit.shared().roomService.joinRoom(params: joinParams,
                                            options: joinOptions) { [weak self] joinCode, joinMsg, context in
      guard let self = self else { return }
      guard let context = context else {
        NEListenTogetherLog.errorLog(
          kitTag,
          desc: "Failed to join room. Code: \(joinCode). Msg: \(joinMsg ?? "")"
        )
        callback?(joinCode, joinMsg, nil)
        return
      }
      self.roomContext = context
      context.addRoomListener(listener: self)
      context.seatController.addSeatListener(self)
      // 加入chatroom、rtc
      self._joinRoom(context, callback: callback)
    }
  }
}
