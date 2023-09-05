// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Foundation
import NERoomKit

/// 麦位扩展
public extension NEVoiceRoomKit {
  /// 获取麦位信息
  ///
  /// 使用前提：该方法仅在调用[login]方法登录成功后调用有效
  /// - Parameter callback: 回调
  func getSeatInfo(_ callback: NEVoiceRoomCallback<NEVoiceRoomSeatInfo>? = nil) {
    NEVoiceRoomLog.apiLog(kitTag, desc: "Get seat info.")

    Judge.preCondition({
      self.roomContext!.seatController.getSeatInfo { code, msg, info in
        if code == 0 {
          guard let info = info else {
            NEVoiceRoomLog.errorLog(
              kitTag,
              desc: "Failed to get seat info. Data structure error."
            )
            callback?(
              NEVoiceRoomErrorCode.failed,
              "Failed to get seat info. Data structure error.",
              nil
            )
            return
          }
          NEVoiceRoomLog.successLog(kitTag, desc: "Successfully get seat info.")
          callback?(NEVoiceRoomErrorCode.success, nil, NEVoiceRoomSeatInfo(info))
        } else {
          NEVoiceRoomLog.errorLog(
            kitTag,
            desc: "Failed to get seat info. Code: \(code). Msg: \(msg ?? "")"
          )
          callback?(code, msg, nil)
        }
      }
    }, failure: callback)
  }

  /// 获取麦位申请列表。按照申请时间正序排序，先申请的成员排在列表前面
  ///
  /// 使用前提：该方法仅在调用[login]方法登录成功后调用有效
  /// - Parameter callback: 回调
  func getSeatRequestList(_ callback: NEVoiceRoomCallback<[NEVoiceRoomSeatRequestItem]>? = nil) {
    NEVoiceRoomLog.apiLog(kitTag, desc: "Get seat request list.")

    Judge.preCondition({
      self.roomContext!.seatController.getSeatRequestList { code, msg, items in
        if code == 0 {
          guard let items = items else {
            NEVoiceRoomLog.errorLog(
              kitTag,
              desc: "Failed to get seat request list. Data structure error."
            )
            callback?(
              NEVoiceRoomErrorCode.failed,
              "Failed to get seat request list. Data structure error.",
              nil
            )
            return
          }
          let requestItems = items.map { NEVoiceRoomSeatRequestItem($0) }
          NEVoiceRoomLog.successLog(kitTag, desc: "Successfully get seat request list.")
          callback?(NEVoiceRoomErrorCode.success, nil, requestItems)
        } else {
          NEVoiceRoomLog.errorLog(
            kitTag,
            desc: "Failed to get seat request list. Code: \(code). Msg: \(msg ?? "")"
          )
          callback?(code, msg, nil)
        }
      }
    }, failure: callback)
  }

  /// 房主向成员[user]发送上麦邀请，指定位置为[seatIndex]，非管理员执行该操作会失败。
  /// - Parameters:
  ///   - seatIndex: 麦位位置
  ///   - account: 用户Id
  ///   - callback: 回调
  func sendSeatInvitation(seatIndex: Int, account: String,
                          callback: NEVoiceRoomCallback<AnyObject>? = nil) {
    NEVoiceRoomLog.apiLog(
      kitTag,
      desc: "Send seat invitation. SeatIndex: \(seatIndex). User: \(account)"
    )

    Judge.preCondition({
      self.roomContext!.seatController.sendSeatInvitation(seatIndex,
                                                          userUuid: account) { code, msg, _ in
        if code == 0 {
          NEVoiceRoomLog.successLog(kitTag, desc: "Successfully send seat invitation.")
        } else {
          NEVoiceRoomLog.errorLog(
            kitTag,
            desc: "Failed to send seat invitation. Code: \(code). Msg: \(msg ?? "")"
          )
        }
        callback?(code, msg, nil)
      }
    }, failure: callback)
  }

  /// 申请上麦
  ///
  /// 使用前提：该方法仅在调用[login]方法登录成功后调用有效
  /// - Parameters:
  ///   - seatIndex: 麦位位置
  ///   - exclusive: 是否占用麦位
  ///   - callback: 回调
  func submitSeatRequest(_ seatIndex: Int,
                         exclusive: Bool = true,
                         callback: NEVoiceRoomCallback<AnyObject>? = nil) {
    NEVoiceRoomLog.apiLog(kitTag, desc: "Submit seat request. SeatIndex: \(seatIndex).")
    Judge.preCondition({
      self.roomContext!.seatController
        .submitSeatRequest(seatIndex, exclusive: exclusive) { code, msg, _ in
          if code == 0 {
            NEVoiceRoomLog.successLog(kitTag, desc: "Successfully submit seat request.")
          } else {
            NEVoiceRoomLog.errorLog(
              kitTag,
              desc: "Failed to submit seat request. Code: \(code). Msg: \(msg ?? "")"
            )
          }
          callback?(code, msg, nil)
        }
    }, failure: callback)
  }

  /// 申请上麦
  /// - Parameter callback: 回调
  func requestSeat(_ callback: NEVoiceRoomCallback<AnyObject>? = nil) {
    NEVoiceRoomLog.apiLog(kitTag, desc: "Apply on seat.")
    Judge.preCondition({
      self.roomContext!.seatController.submitSeatRequest { code, msg, _ in
        if code == 0 {
          NEVoiceRoomLog.successLog(kitTag, desc: "Successfully apply on seat.")
        } else {
          NEVoiceRoomLog.errorLog(
            kitTag,
            desc: "Failed to apply on seat. Code: \(code). Msg: \(msg ?? "")"
          )
        }
        callback?(code, msg, nil)
      }
    }, failure: callback)
  }

  /// 取消申请上麦
  ///
  /// 使用前提：该方法仅在调用[login]方法登录成功后调用有效
  /// - Parameter callback: 回调
  func cancelSeatRequest(_ callback: NEVoiceRoomCallback<AnyObject>? = nil) {
    NEVoiceRoomLog.apiLog(kitTag, desc: "Cancel seat request.")

    Judge.preCondition({
      self.roomContext!.seatController.cancelSeatRequest { code, msg, _ in
        if code == 0 {
          NEVoiceRoomLog.successLog(kitTag, desc: "Successfully cancel seat request.")
        } else {
          NEVoiceRoomLog.errorLog(
            kitTag,
            desc: "Failed to cancel seat request. Code: \(code). Msg: \(msg ?? "")"
          )
        }
        callback?(code, msg, nil)
      }
    }, failure: callback)
  }

  /// 同意上麦
  ///
  /// 使用前提：该方法仅在调用[login]方法登录成功后调用有效
  /// - Parameters:
  ///   - account: 被同意上麦的用户account
  ///   - callback: 回调
  func approveSeatRequest(account: String, callback: NEVoiceRoomCallback<AnyObject>? = nil) {
    NEVoiceRoomLog.apiLog(kitTag, desc: "Approve seat request. Account: \(account).")

    Judge.preCondition({
      self.roomContext!.seatController.approveSeatRequest(account) { code, msg, _ in
        if code == 0 {
          NEVoiceRoomLog.successLog(kitTag, desc: "Successfully approve seat request.")
        } else {
          NEVoiceRoomLog.errorLog(
            kitTag,
            desc: "Failed to approve seat request. Code: \(code). Msg: \(msg ?? "")"
          )
        }
        callback?(code, msg, nil)
      }
    }, failure: callback)
  }

  /// 拒绝上麦
  ///
  /// 使用前提：该方法仅在调用[login]方法登录成功后调用有效
  /// - Parameters:
  ///   - account: 被拒绝上麦的用户account
  ///   - callback: 回调
  func rejectSeatRequest(account: String, callback: NEVoiceRoomCallback<AnyObject>? = nil) {
    NEVoiceRoomLog.apiLog(kitTag, desc: "Reject seat request. Account: \(account)")
    Judge.preCondition({
      self.roomContext!.seatController.rejectSeatRequest(account) { code, msg, _ in
        if code == 0 {
          NEVoiceRoomLog.successLog(kitTag, desc: "Successfully reject seat request.")
        } else {
          NEVoiceRoomLog.errorLog(
            kitTag,
            desc: "Failed to reject seat request. Code: \(code). Msg: \(msg ?? "")"
          )
        }
        callback?(code, msg, nil)
      }
    }, failure: callback)
  }

  /// 踢麦
  ///
  /// 使用前提：该方法仅在调用[login]方法登录成功后调用有效
  /// - Parameters:
  ///   - account: 被踢用户的account
  ///   - callback: 回调
  func kickSeat(account: String, callback: NEVoiceRoomCallback<AnyObject>? = nil) {
    NEVoiceRoomLog.apiLog(kitTag, desc: "Kick seat. Account: \(account)")

    Judge.preCondition({
      self.roomContext!.seatController.kickSeat(account) { code, msg, _ in
        if code == 0 {
          NEVoiceRoomLog.successLog(kitTag, desc: "Successfully kick seat.")
        } else {
          NEVoiceRoomLog.errorLog(
            kitTag,
            desc: "Failed to kick seat. Code: \(code). Msg: \(msg ?? "")"
          )
        }
        callback?(code, msg, nil)
      }
    }, failure: callback)
  }

  /// 下麦
  ///
  /// 使用前提：该方法仅在调用[login]方法登录成功后调用有效
  /// - Parameter callback: 回调
  func leaveSeat(_ callback: NEVoiceRoomCallback<AnyObject>? = nil) {
    NEVoiceRoomLog.apiLog(kitTag, desc: "Leave seat.")
    Judge.preCondition({
      self.roomContext!.seatController.leaveSeat { code, msg, _ in
        if code == 0 {
          NEVoiceRoomLog.successLog(kitTag, desc: "Successfully leave seat.")
        } else {
          NEVoiceRoomLog.errorLog(
            kitTag,
            desc: "Failed to leave seat. Code: \(code). Msg: \(msg ?? "")"
          )
        }
        callback?(code, msg, nil)
      }
    }, failure: callback)
  }

  /// 对麦位上的指定成员静音
  /// - Parameters:
  ///   - seatIndex: 麦位位置
  ///   - callback: 回调
  private func muteSeat(seatIndex: Int, callback: NEVoiceRoomCallback<AnyObject>? = nil) {
    NEVoiceRoomLog.apiLog(kitTag, desc: "Mute seat. SeatIndex: \(seatIndex)")
  }

  /// 对麦位上的指定成员解除静音
  /// - Parameters:
  ///   - seatIndex: 麦位位置
  ///   - callback: 回调
  private func unmuteSeat(seatIndex: Int, callback: NEVoiceRoomCallback<AnyObject>? = nil) {}

  /// 打开麦位
  /// - Parameters:
  ///   - seatIndex: 麦位位置
  ///   - callback: 回调
  func openSeats(seatIndices: [Int], callback: NEVoiceRoomCallback<AnyObject>? = nil) {
    NEVoiceRoomLog.apiLog(kitTag, desc: "Open seat. SeatIndices: \(seatIndices)")
    Judge.preCondition({
      self.roomContext!.seatController.openSeat(seatIndices) { code, msg, _ in
        if code == 0 {
          NEVoiceRoomLog.successLog(kitTag, desc: "Successfully open seat.")
        } else {
          NEVoiceRoomLog.errorLog(
            kitTag,
            desc: "Failed to open seat. Code: \(code). Msg: \(msg ?? "")"
          )
        }
        callback?(code, msg, nil)
      }
    }, failure: callback)
  }

  /// 关闭麦位
  /// - Parameters:
  ///   - seatIndex: 麦位位置
  ///   - callback: 回调
  func closeSeats(seatIndices: [Int], callback: NEVoiceRoomCallback<AnyObject>? = nil) {
    NEVoiceRoomLog.apiLog(kitTag, desc: "Close seat. SeatIndices: \(seatIndices)")
    Judge.preCondition({
      self.roomContext!.seatController.closeSeat(seatIndices) { code, msg, _ in
        if code == 0 {
          NEVoiceRoomLog.successLog(kitTag, desc: "Successfully close seat.")
        } else {
          NEVoiceRoomLog.errorLog(
            kitTag,
            desc: "Failed to close seat. Code: \(code). Msg: \(msg ?? "")"
          )
        }
        callback?(code, msg, nil)
      }
    }, failure: callback)
  }
}

extension NEVoiceRoomKit: NESeatEventListener {}
