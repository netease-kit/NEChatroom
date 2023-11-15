// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import NESocialUIKit
import NEVoiceRoomKit
import UIKit

// 麦位的代码复杂，放在这里文件里
extension NEVRBaseViewController {
  // MARK: 监听seatPresent里的事件通知

  func observeSeatPresentEvent() {
    // 麦位列表变化
    seatPresent.onSeatListChanged = { [weak self] seats in
      // 通常情况下不会存在所有麦位都空闲的情况
      // 目前发现NERoom在首次启动的时候会触发网络变更回调从而触发麦位查询，这种情况就不处理了，会有误判
      guard seats.contains(where: { $0.status != .initial }) else {
        return
      }
      self?.onSeatListChanged(seats: seats)
      // 主播展示顶部的申请列表
      if self?.isOwner ?? false {
        self?.seatRequestListView.refresh(seats: seats)
        let seats = seats.filter { $0.user != NEVoiceRoomKit.getInstance().localMember?.account && $0.status == .waiting }
        if seats.count > 0,
           let view = self?.view {
          self?.seatRequestListView.showAsAlert(view: view)
        }
      }
      seats.forEach { item in
        guard let self = self else {
          return
        }
        // 有主播的情况下，麦位序号为 1-9
        if item.index == 1 {
          self.updateSeat(cell: self.defaultOwnerSeat, item: item)
        } else {
          let index = item.index - 2
          self.updateSeat(cell: self.defaultAudienceSeats[index], item: item)
        }
      }
      if let seat = seats.first(where: { $0.user == NEVoiceRoomKit.getInstance().localMember?.account }) {
        // 自己在麦上或者申请中
        self?.dealMoreItems(isOnSeat: seat.status == .taken)
        self?.dealCustomFooterButtonItems(isOnSeat: seat.status == .taken)
        if let isOwner = self?.isOwner,
           !isOwner {
          self?.seatRequestToast.isHidden = seat.status != .waiting
        }
      } else {
        // 自己不在麦上
        self?.dealMoreItems(isOnSeat: false)
        self?.dealCustomFooterButtonItems(isOnSeat: false)
        // 不在麦上没有要展示顶部Toast的场景
        if let isOwner = self?.isOwner,
           !isOwner {
          self?.seatRequestToast.isHidden = true
        }
      }
    }
    // 用户音频状态变更
    seatPresent.onMemberAudioMuteChanged = { [weak self] uuid, mute in
      // 如果是主播
      if uuid == self?.joinParams.ownerUuid,
         self?.defaultOwnerSeat.micState != .banded {
        self?.defaultOwnerSeat.micState = mute ? .off : .on
        self?.defaultOwnerSeat.reloadByProperty()
      } else {
        if let seat = self?.defaultAudienceSeats.first(where: { $0.uuid == uuid }),
           seat.micState != .banded {
          seat.micState = mute ? .off : .on
          seat.reloadByProperty()
        }
      }
    }
    seatPresent.onMemberAudioBanned = { [weak self] uuid, banded in
      // 如果是主播
      // 默认unban的时候是off，等onMemberAudioMuteChanged来更新
      if uuid == self?.joinParams.ownerUuid {
        self?.defaultOwnerSeat.micState = banded ? .banded : .off
        self?.defaultOwnerSeat.reloadByProperty()
      } else {
        if let seat = self?.defaultAudienceSeats.first(where: { $0.uuid == uuid }) {
          seat.micState = banded ? .banded : .off
          seat.reloadByProperty()
        }
      }
    }
    // 自己的音量发生变化
    seatPresent.onRtcLocalAudioVolumeIndication = { [weak self] volume in
      guard let self = self,
            let localMember = NEVoiceRoomKit.getInstance().localMember else {
        return
      }
      // 有音量，且没有静音
      let isSpeaking = volume > 0 && localMember.isAudioOn && !localMember.isAudioBanned
      if self.isOwner {
        self.defaultOwnerSeat.isSpeaking = isSpeaking
      } else {
        if let seat = self.defaultAudienceSeats.first(where: { $0.uuid == localMember.account }) {
          seat.isSpeaking = isSpeaking
        }
      }
    }
    // 其他人的音量发生变化
    seatPresent.onRtcRemoteAudioVolumeIndication = { [weak self] volumes in
      guard let self = self else {
        return
      }
      // 用来存放带在volumes中的成员，没有带在volumes中的视为没有声音
      var contains: [String] = []
      volumes.forEach { info in
        contains.append(info.userUuid)
        let member = NEVoiceRoomKit.getInstance().allMemberList.first(where: { $0.account == info.userUuid })
        let isSpeaking = info.volume > 0 && (member?.isAudioOn ?? false) && !(member?.isAudioBanned ?? true)
        if info.userUuid == self.joinParams.ownerUuid {
          // 主播
          self.defaultOwnerSeat.isSpeaking = isSpeaking
        } else {
          // 观众
          if let seat = self.defaultAudienceSeats.first(where: { $0.uuid == member?.account }) {
            seat.isSpeaking = isSpeaking
          }
        }
      }
      self.defaultAudienceSeats.forEach { cellModel in
        if let uuid = cellModel.uuid,
           !contains.contains(uuid),
           uuid != NEVoiceRoomKit.getInstance().localMember?.account {
          cellModel.isSpeaking = false
        }
      }
    }
    // 离开麦位
    seatPresent.onSeatLeave = { [weak self] _, account in
      if let member = NEVoiceRoomKit.getInstance().allMemberList.first(where: { $0.account == account }) {
        DispatchQueue.main.async {
          if account == NEVoiceRoomKit.getInstance().localMember?.account {
            self?.showToastInWindow(NEVRBaseBundle.localized("Seat_Self_Leaved"))
          }
          let message = NESocialChatroomNotiMessage()
          message.notification = String(format: "%@ %@", member.name, NEVRBaseBundle.localized("Seat_Leaved"))
          self?.chatroomView.addMessage(message)
        }
      }
    }
    // 踢下麦位
    seatPresent.onSeatKicked = { [weak self] _, account in
      if let member = NEVoiceRoomKit.getInstance().allMemberList.first(where: { $0.account == account }) {
        DispatchQueue.main.async {
          if let isOwner = self?.isOwner,
             isOwner {
            self?.showToastInWindow(String(format: NEVRBaseBundle.localized("Seat_Kick_Other"), member.name))
          } else if account == NEVoiceRoomKit.getInstance().localMember?.account {
            self?.showToastInWindow(NEVRBaseBundle.localized("Seat_Self_Kicked"))
          }
          let message = NESocialChatroomNotiMessage()
          message.notification = String(format: "%@ %@", member.name, NEVRBaseBundle.localized("Seat_Kicked"))
          self?.chatroomView.addMessage(message)
        }
      }
    }
    // 上麦请求通过
    seatPresent.onSeatRequestApproved = { [weak self] _, account in
      if let member = NEVoiceRoomKit.getInstance().allMemberList.first(where: { $0.account == account }) {
        DispatchQueue.main.async {
          if let isOwner = self?.isOwner,
             !isOwner,
             account == NEVoiceRoomKit.getInstance().localMember?.account {
            self?.seatRequestToast.isHidden = true
            self?.seatRequestResultToast.isSucceed = true
            self?.seatRequestResultToast.isHidden = false
          }
          let message = NESocialChatroomNotiMessage()
          message.notification = String(format: "%@ %@", member.name, NEVRBaseBundle.localized("Seat_Approved"))
          self?.chatroomView.addMessage(message)
        }
      }
    }
    // 上麦请求被拒绝
    seatPresent.onSeatRequestRejected = { [weak self] _, account in
      if let member = NEVoiceRoomKit.getInstance().allMemberList.first(where: { $0.account == account }) {
        DispatchQueue.main.async {
          if let isOwner = self?.isOwner,
             !isOwner,
             account == NEVoiceRoomKit.getInstance().localMember?.account {
            self?.showToastInWindow(NEVRBaseBundle.localized("Seat_Approve_Rejected"))
            self?.seatRequestToast.isHidden = true
            self?.seatRequestResultToast.isSucceed = false
            self?.seatRequestResultToast.isHidden = false
          }
          let message = NESocialChatroomNotiMessage()
          message.notification = String(format: "%@ %@", member.name, NEVRBaseBundle.localized("Seat_Rejected"))
          self?.chatroomView.addMessage(message)
        }
      }
    }
    // 取消申请上麦
    seatPresent.onSeatRequestCancelled = { [weak self] _, account in
      if let member = NEVoiceRoomKit.getInstance().allMemberList.first(where: { $0.account == account }) {
        DispatchQueue.main.async {
          if let isOwner = self?.isOwner,
             !isOwner,
             account == NEVoiceRoomKit.getInstance().localMember?.account {
            self?.seatRequestToast.isHidden = true
          }
          let message = NESocialChatroomNotiMessage()
          message.notification = String(format: "%@ %@", member.name, NEVRBaseBundle.localized("Seat_Canceled"))
          self?.chatroomView.addMessage(message)
        }
      }
    }
    // 申请上麦
    seatPresent.onSeatRequestSubmitted = { [weak self] index, account in
      if let member = NEVoiceRoomKit.getInstance().allMemberList.first(where: { $0.account == account }) {
        DispatchQueue.main.async {
          if let isOwner = self?.isOwner,
             !isOwner,
             account == NEVoiceRoomKit.getInstance().localMember?.account {
            self?.seatRequestToast.isHidden = false
            self?.seatRequestResultToast.isHidden = true
          }
          let message = NESocialChatroomNotiMessage()
          message.notification = String(format: "%@ %@(%d)", member.name, NEVRBaseBundle.localized("Seat_Submitted"), index)
          self?.chatroomView.addMessage(message)
        }
      }
    }
    // 抱麦请求被接受
    seatPresent.onSeatInvitationAccepted = { [weak self] index, account in
      if let member = NEVoiceRoomKit.getInstance().allMemberList.first(where: { $0.account == account }) {
        DispatchQueue.main.async {
          if let isOwner = self?.isOwner,
             isOwner {
            self?.showToastInWindow(String(format: NEVRBaseBundle.localized("Seat_Invite_Accepted"), member.name, index))
          } else if account == NEVoiceRoomKit.getInstance().localMember?.account {
            self?.seatRequestToast.isHidden = true
            self?.seatRequestResultToast.isHidden = true
            self?.showToastInWindow(String(format: NEVRBaseBundle.localized("Seat_Moved_To_Seat"), index))
          }
          let message = NESocialChatroomNotiMessage()
          message.notification = String(format: "%@ %@", member.name, NEVRBaseBundle.localized("Seat_Accepted"))
          self?.chatroomView.addMessage(message)
        }
      }
    }
    // 加入或重入聊天室
    seatPresent.onSelfJoinOrRejoin = { [weak self] in
      self?.joinOrRejoinChatroom(firstTime: !(self?.hasJoinChatroom ?? false))
      self?.hasJoinChatroom = true
      self?.present.getRoomInfo { code, msg, obj in
        if let seatUserRewards = obj?.liveModel?.seatUserReward {
          DispatchQueue.main.async {
            self?.updateSeatCoins(seatUserRewards: seatUserRewards)
          }
        }
      }
    }
    // 自己从麦上到了麦下
    seatPresent.onSelfDidLeaveSeat = { [weak self] in
      self?.didSelfLeaveSeat()
    }
    // 自己从麦下到了麦上
    seatPresent.onSelfDidOccupySeat = { [weak self] in
      self?.present.getRoomInfo(callback: { code, msg, roomInfo in
        DispatchQueue.main.async {
          if let seatUserReward = roomInfo?.liveModel?.seatUserReward {
            self?.updateSeatCoins(seatUserRewards: seatUserReward)
          }
        }
      })
    }
  }

  /// 根据语聊房kit的麦位信息来更新界面
  /// - Parameters:
  ///   - cell: cellModel
  ///   - item: 语聊房kit的麦位对象
  func updateSeat(cell: NEVRBaseSeatCellModel, item: NEVoiceRoomSeatItem) {
    switch item.status {
    case .initial: cell.state = .idle
    case .waiting: cell.state = .taking
    case .taken: cell.state = .taken
    case .closed: cell.state = .closed
    @unknown default: cell.state = .idle
    }
    cell.uuid = item.user
    cell.iconUrl = item.icon
    cell.seatIndex = item.index
    if let userName = item.userName,
       !userName.isEmpty {
      cell.nickname = userName
    }
    if let member = NEVoiceRoomKit.getInstance().allMemberList.first(where: { $0.account == item.user }) {
      if member.isAudioBanned {
        cell.micState = .banded
      } else if member.isAudioOn {
        cell.micState = .on
      } else {
        cell.micState = .off
      }
    }
    cell.coinsCount = seatUserRewards.first(where: { $0.userUuid == item.user })?.rewardTotal ?? 0
    cell.reloadByProperty()
  }

  /// 更新麦位列表的礼物值
  /// - Parameter seatUserRewards: 麦位礼物
  func updateSeatCoins(seatUserRewards: [NEVoiceRoomBatchSeatUserReward]) {
    self.seatUserRewards = seatUserRewards
    seatUserRewards.forEach { seatUserReward in
      if seatUserReward.userUuid == defaultOwnerSeat.uuid {
        defaultOwnerSeat.coinsCount = seatUserReward.rewardTotal
        defaultOwnerSeat.reloadByProperty()
      } else if let seat = defaultAudienceSeats.first(where: { $0.uuid == seatUserReward.userUuid }) {
        seat.coinsCount = seatUserReward.rewardTotal
        seat.reloadByProperty()
      }
    }
  }

  // MARK: 点击麦位

  public func clickSeatCell(model: NEVRBaseSeatCellModel) {
    // 回收键盘
    keyboardView.resignFirstResponder()
    view.endEditing(true)

    // 主播的麦位无法操作
    if model.uuid == joinParams.ownerUuid {
      return
    }

    if isOwner {
      switch model.state {
      case .idle: // 可闭麦，抱麦
        NESocialActionSheet.show(controller: self, actions: [inviteAction(model), closeAction(model), cancelAction()])
      case .taken: // 可踢麦，ban，闭麦
        if model.micState == .banded {
          NESocialActionSheet.show(controller: self, actions: [kickAction(model), unbanAction(model), closeAction(model), cancelAction()])
        } else {
          NESocialActionSheet.show(controller: self, actions: [kickAction(model), banAction(model), closeAction(model), cancelAction()])
        }
      case .taking: break
      case .closed: // 可开启
        NESocialActionSheet.show(controller: self, actions: [openAction(model), cancelAction()])
      }
    } else {
      switch model.state {
      case .idle:
        if seatPresent.selfSeatStatus == .initial {
          // 直接申请上麦
          if let seatIndex = model.seatIndex {
            seatPresent.submitSeatRequest(seatIndex) { [weak self] code, msg in
              DispatchQueue.main.async {
                if code == 0 {
                  if let isOwner = self?.isOwner,
                     !isOwner {
                    self?.seatRequestToast.isHidden = false
                  }
                } else {
                  self?.showToastInWindow(msg ?? NEVRBaseBundle.localized("Seat_Busy"))
                }
              }
            }
          }
        }
      case .taken: // 如果是自己，可下麦
        if model.uuid == NEVoiceRoomKit.getInstance().localMember?.account {
          NESocialActionSheet.show(controller: self, actions: [leaveAction(model), cancelAction()])
        }
      case .taking:
        showToastInWindow(NEVRBaseBundle.localized(model.uuid == NEVoiceRoomKit.getInstance().localMember?.account ? "Seat_Waiting_Self" : "Seat_Waiting_Other"))
      case .closed:
        showToastInWindow(NEVRBaseBundle.localized("Seat_Closed"))
      }
    }
  }

  func banAction(_ model: NEVRBaseSeatCellModel) -> NESocialActionSheetAction {
    NESocialActionSheetAction(title: NEVRBaseBundle.localized("Seat_Ban")) { [weak self] _ in
      if let uuid = model.uuid {
        self?.seatPresent.banRemoteAudio(uuid) { code, msg in
          if code != 0 {
            DispatchQueue.main.async {
              self?.showToastInWindow(NEVRBaseBundle.localized("Seat_Ban_Failed"))
            }
          }
        }
      }
    }
  }

  func unbanAction(_ model: NEVRBaseSeatCellModel) -> NESocialActionSheetAction {
    NESocialActionSheetAction(title: NEVRBaseBundle.localized("Seat_Unban")) { [weak self] _ in
      if let uuid = model.uuid {
        self?.seatPresent.unbanRemoteAudio(uuid) { code, msg in
          if code != 0 {
            DispatchQueue.main.async {
              self?.showToastInWindow(NEVRBaseBundle.localized("Seat_Unban_Failed"))
            }
          }
        }
      }
    }
  }

  func inviteAction(_ model: NEVRBaseSeatCellModel) -> NESocialActionSheetAction {
    NESocialActionSheetAction(title: NEVRBaseBundle.localized("Seat_Invite")) { [weak self] _ in
      DispatchQueue.main.async {
        let view = NESocialInviteViewController(seatIndex: model.seatIndex ?? 0)
        self?.present(UINavigationController(rootViewController: view), animated: true)
      }
    }
  }

  open func kickAction(_ model: NEVRBaseSeatCellModel) -> NESocialActionSheetAction {
    NESocialActionSheetAction(title: NEVRBaseBundle.localized("Seat_Kick")) { [weak self] _ in
      self?.baseKickSeat(model)
    }
  }

  public func baseKickSeat(_ model: NEVRBaseSeatCellModel) {
    if let uuid = model.uuid {
      seatPresent.kickSeat(uuid) { [weak self] code, msg in
        if code != 0 {
          DispatchQueue.main.async {
            self?.showToastInWindow(NEVRBaseBundle.localized("Seat_Kick_Failed"))
          }
        }
      }
    }
  }

  open func closeAction(_ model: NEVRBaseSeatCellModel) -> NESocialActionSheetAction {
    NESocialActionSheetAction(title: NEVRBaseBundle.localized("Seat_Close")) { [weak self] _ in
      self?.baseCloseSeats(model)
    }
  }

  public func baseCloseSeats(_ model: NEVRBaseSeatCellModel) {
    if let index = model.seatIndex {
      seatPresent.closeSeats([index]) { [weak self] code, msg in
        DispatchQueue.main.async {
          if code != 0 {
            self?.showToastInWindow(NEVRBaseBundle.localized("Seat_Close_Failed"))
          } else {
            self?.showToastInWindow(String(format: NEVRBaseBundle.localized("Seat_Close_Succeed"), (model.seatIndex ?? 1) - 1))
          }
        }
      }
    }
  }

  func openAction(_ model: NEVRBaseSeatCellModel) -> NESocialActionSheetAction {
    NESocialActionSheetAction(title: NEVRBaseBundle.localized("Seat_Open")) { [weak self] _ in
      if let index = model.seatIndex {
        self?.seatPresent.openSeats([index]) { code, msg in
          DispatchQueue.main.async {
            if code != 0 {
              self?.showToastInWindow(NEVRBaseBundle.localized("Seat_Open_Failed"))
            } else {
              self?.showToastInWindow(String(format: NEVRBaseBundle.localized("Seat_Open_Succeed"), (model.seatIndex ?? 1) - 1))
            }
          }
        }
      }
    }
  }

  open func leaveAction(_ model: NEVRBaseSeatCellModel) -> NESocialActionSheetAction {
    NESocialActionSheetAction(title: NEVRBaseBundle.localized("Seat_Leave"), titleColor: .red) { [weak self] _ in
      self?.baseLeaveAction()
    }
  }

  public func baseLeaveAction() {
    seatPresent.leaveSeat { [weak self] code, msg in
      if code != 0 {
        DispatchQueue.main.async {
          self?.showToastInWindow(NEVRBaseBundle.localized("Seat_Leave_Failed"))
        }
      }
    }
  }

  func cancelSeatRequestAction() -> NESocialActionSheetAction {
    NESocialActionSheetAction(title: NEVRBaseBundle.localized("Seat_Request_Cancel_Comfirm"), titleColor: .red) { [weak self] _ in
      self?.seatPresent.cancelSeatRequest { _, _ in
        DispatchQueue.main.async {
          if let isOwner = self?.isOwner,
             !isOwner {
            self?.seatRequestToast.isHidden = true
          }
        }
      }
    }
  }

  func cancelAction() -> NESocialActionSheetAction {
    NESocialActionSheetAction(type: .cancel, title: NEVRBaseBundle.localized("Cancel"))
  }
}
