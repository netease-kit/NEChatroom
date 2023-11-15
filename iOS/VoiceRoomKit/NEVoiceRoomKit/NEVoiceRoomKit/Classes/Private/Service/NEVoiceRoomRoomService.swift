// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Foundation

class NEVoiceRoomRoomService {
  /// 获取房间列表
  /// - Parameters:
  ///   - type: 房间类型，默认为2：ChatRoom
  ///   - liveType: 房间类型
  ///   - pageNum: 每页数量
  ///   - pageSize: 页号
  ///   - callback: 回调
  ///  liveType类型：
  /// 1：互动直播,
  /// 2：语聊房,
  /// 3："KTV房间"，
  /// 4：互动直播——跨频道转发房间，
  /// 5：一起听
  func getRoomList(_ type: Int = 2,
                   pageNum: Int,
                   pageSize: Int,
                   success: ((NEVoiceRoomList?) -> Void)? = nil,
                   failure: ((NSError) -> Void)? = nil) {
    let params: [String: Any] = [
      "pageNum": pageNum,
      "pageSize": pageSize,
      "liveType": type,
    ]
    NEAPI.Room.roomList.request(params,
                                returnType: _NEVoiceRoomListResponse.self) { data in
      guard let data = data else {
        success?(nil)
        return
      }
      let roomList = NEVoiceRoomList(data)
      success?(roomList)
    } failed: { error in
      failure?(error)
    }
  }

  func getVoiceRoomRoomInfo(_ liveRecordId: Int,
                            success: ((_NECreateLiveResponse?) -> Void)? = nil,
                            failure: ((NSError) -> Void)? = nil) {
    let params: [String: Any] = [
      "liveRecordId": liveRecordId,
    ]
    NEAPI.Room.info.request(params, returnType: _NECreateLiveResponse.self,
                            success: { data in
                              guard let data = data else {
                                success?(nil)
                                return
                              }
                              success?(data)
                            }, failed: failure)
  }

  func getDefaultLiveInfo(success: ((_NECreateRoomDefaultInfo?) -> Void)? = nil,
                          failure: ((NSError) -> Void)? = nil) {
    NEAPI.Room.liveInfo.request(
      returnType: _NECreateRoomDefaultInfo.self,
      success: { defaultInfo in
        guard let data = defaultInfo else {
          success?(nil)
          return
        }
        success?(data)
      },
      failed: failure
    )
  }

  func authenticate(name: String,
                    cardNo: String,
                    success: (() -> Void)? = nil,
                    failure: ((NSError) -> Void)? = nil) {
    let param: [String: String] = [
      "name": name,
      "cardNo": cardNo,
    ]
    NEAPI.Room.auth.request(param) { _ in
      success?()
    } failed: { error in
      failure?(error)
    }
  }

  /// 创建房间
  /// - Parameters:
  ///   - params: 创建房间参数
  ///   - isDebug: 是否为debug模式
  ///   - success: 成功回调
  ///   - failure: 失败回调
  func startVoiceRoom(_ params: NECreateVoiceRoomParams,
                      success: ((_NECreateLiveResponse?) -> Void)? = nil,
                      failure: ((NSError) -> Void)? = nil) {
    let param: [String: Any] = [
      //      "userUuid": "",
      "liveType": params.liveType.rawValue,
      "liveTopic": params.liveTopic ?? "",
      "cover": params.cover ?? "",
      "configId": params.configId,
      "roomName": params.roomName ?? "",
      "seatCount": params.seatCount,
      "seatApplyMode": params.seatApplyMode.rawValue,
      "seatInviteMode": params.seatInviteMode,
    ]
    NEAPI.Room.create.request(param,
                              returnType: _NECreateLiveResponse.self) { resp in
      success?(resp)
    } failed: { error in
      failure?(error)
    }
  }

//
  /// 结束房间
  /// - Parameters:
  ///   - liveRecordId: 直播记录编号
  ///   - success: 成功回调
  ///   - failure: 失败回调
  func endRoom(_ liveRecordId: Int,
               success: (() -> Void)? = nil,
               failure: ((NSError) -> Void)? = nil) {
    let param: [String: Any] = [
      "liveRecordId": liveRecordId,
    ]
    NEAPI.Room.destroy.request(param,
                               success: { _ in
                                 success?()
                               }, failed: failure)
  }

  /// 批量礼物打赏
  /// - Parameters:
  ///   - liveRecordId: 直播编号
  ///   - giftId: 礼物id
  ///   - giftCount: 礼物个数
  ///   - userUuids: 打赏给主播或者麦上观众
  ///   - success: 成功回调
  ///   - failure: 失败回调
  func batchReward(_ liveRecordId: Int,
                   giftId: Int,
                   giftCount: Int,
                   userUuids: [String],
                   success: (() -> Void)? = nil,
                   failure: ((NSError) -> Void)? = nil) {
    let param = [
      "liveRecordId": liveRecordId,
      "giftId": giftId,
      "giftCount": giftCount,
      "targets": userUuids,
    ] as [String: Any]
    NEAPI.Room.batchReward.request(param, success: { _ in
      success?()
    }, failed: failure)
  }

  /// 获取房间当前演唱信息
  /// - Parameters:
  ///   - success: 成功回调
  ///   - failure: 失败回调
//  func currentInfo(_ roomUuid: String,
//                   success: ((NEVoiceRoomPlayMusicInfo?) -> Void)? = nil,
//                   failure: ((NSError) -> Void)? = nil) {
//    NEAPI.Music.info(roomUuid).request(returnType: NEVoiceRoomPlayMusicInfo.self,
//                                       success: success,
//                                       failed: failure)
//  }
}
