// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import NESocialUIKit
import NEVoiceRoomKit
import UIKit

@objcMembers public class NEVRBaseViewControllerParams: NSObject {
  /// 房间uid
  public var roomUuid: String = ""
  /// 房间内昵称
  public var nick: String = ""
  /// 直播id
  public var liveRecordId: Int = 0
  /// 角色
  public var role: NEVoiceRoomRole = .audience
  /// 直播背景图
  public var cover: String = ""
  /// 扩展参数
  public var roomName: String = ""
  /// 主播名字
  public var ownerName: String = ""
  /// 主播头像
  public var ownerIcon: String = ""
  /// 主播uuid
  public var ownerUuid: String = ""

  func toVoiceRoomKit() -> NEJoinVoiceRoomParams {
    let param = NEJoinVoiceRoomParams()
    param.roomUuid = roomUuid
    param.nick = nick
    param.liveRecordId = liveRecordId
    param.role = role
    return param
  }
}

@objcMembers open class NEVRBaseViewController: UIViewController {
  // 是否是第一次加入聊天室，用于区分joinOrRejoinChatroom中的参数
  internal var hasJoinChatroom: Bool = false

  // 储存最新的打赏信息，因为人的麦位状态会变
  internal var seatUserRewards: [NEVoiceRoomBatchSeatUserReward] = []

  public var joinParams: NEVRBaseViewControllerParams!

  /// 初始化ViewController
  /// - Parameters:
  ///   - roomUuid: 房间号，必须
  ///   - isOwner: 自己是否是房主
  public init(params: NEVRBaseViewControllerParams) {
    super.init(nibName: nil, bundle: nil)
    joinParams = params
  }

  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override open func viewDidLoad() {
    super.viewDidLoad()

    // 添加对present的监听
    observePresentEvent()
    // 添加对麦位present的监听
    observeSeatPresentEvent()

    hasJoinChatroom = false
    seatUserRewards.removeAll()
    // 进入页面先加入房间
    present.joinRoom(params: joinParams.toVoiceRoomKit()) { [weak self] code, msg, info in
      if code != 0 {
        DispatchQueue.main.async {
          self?.showToastInWindow(NEVRBaseBundle.localized("Join_Room_Failed"))
          self?.dismiss()
        }
      } else {
        // 默认人数
        DispatchQueue.main.async {
          self?.headerView.onlineNumber = NEVoiceRoomKit.getInstance().allMemberList.count
          if let seatUserRewards = info?.liveModel?.seatUserReward {
            self?.updateSeatCoins(seatUserRewards: seatUserRewards)
          }
        }
        self?.afterJoinRoom()
      }
    }

    view.addSubview(backgroundImage)
    view.addSubview(headerView)
    view.addSubview(seatsView)
    view.addSubview(chatroomView)
    view.addSubview(footerView)
    view.addSubview(giftAnimation)
    if !isOwner {
      view.addSubview(seatRequestToast)
      view.addSubview(seatRequestResultToast)
    }
    view.addSubview(keyboardView)
    view.addSubview(announcementView)

    observeKeyboard()

    layoutSubviews()
    customLayout()

    view.bringSubviewToFront(giftAnimation)
    if !isOwner {
      view.bringSubviewToFront(seatRequestToast)
      view.bringSubviewToFront(seatRequestResultToast)
    }
    view.bringSubviewToFront(keyboardView)
    // announcementView始终在最上面
    view.bringSubviewToFront(announcementView)

    // 开启网络监听
    try? reachability?.startNotifier()

    UIApplication.shared.isIdleTimerDisabled = true
  }

  override open func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
  }

  override open func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    DispatchQueue.main.async {
      self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
  }

  deinit {
    print("=========== deinit")
    // 移除网络监听
    reachability?.stopNotifier()
    NEVRBaseGiftViewController.destroy()
    UIApplication.shared.isIdleTimerDisabled = false
  }

  func layoutSubviews() {
    backgroundImage.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    headerView.snp.makeConstraints { make in
      make.height.equalTo(54)
      make.left.right.equalToSuperview()
      if #available(iOS 11.0, *) {
        make.top.equalTo(view.safeAreaLayoutGuide).offset(8)
      } else {
        make.top.equalTo(view).offset(8)
      }
    }
    seatsView.snp.makeConstraints { make in
      make.left.right.equalToSuperview()
      make.height.equalTo(seatsView.calculateViewSize(width: view.frame.width).height)
      make.top.equalTo(headerView.snp.bottom)
    }
    footerView.snp.makeConstraints { make in
      make.left.right.equalToSuperview()
      make.height.equalTo(36)
      if #available(iOS 11.0, *) {
        make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-10)
      } else {
        make.bottom.equalTo(view).offset(-10)
      }
    }
    chatroomView.snp.makeConstraints { make in
      make.top.greaterThanOrEqualTo(seatsView.snp.bottom).offset(16)
      make.height.greaterThanOrEqualTo(100)
      make.bottom.equalTo(footerView.snp.top).offset(-16)
      make.left.equalToSuperview().offset(8)
      make.width.lessThanOrEqualTo(280)
    }
    announcementView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    if isOwner {
    } else {
      seatRequestToast.snp.makeConstraints { make in
        make.top.equalTo(headerView)
        make.centerX.equalToSuperview()
        make.height.equalTo(40)
      }
      seatRequestResultToast.snp.makeConstraints { make in
        make.top.equalTo(headerView)
        make.centerX.equalToSuperview()
        make.height.equalTo(40)
      }
    }
  }

  public lazy var reachability: NESocialReachability? = {
    let reachability = try? NESocialReachability(hostname: "163.com")
    reachability?.whenUnreachable = { [weak self] reachability in
      self?.showToastInWindow(NEVRBaseBundle.localized("Net_Disconnect"))
    }
    return reachability
  }()

  public lazy var headerView: NESocialHeaderView = {
    let view = NESocialHeaderView()
    view.closeAction = { [weak self] button in
      // 控制连续点击的情况
      button.isEnabled = false
      self?.isOwner ?? false ? self?.closeRoom(callback: {
        DispatchQueue.main.async {
          button.isEnabled = true
        }
      }) : self?.leaveRoom(callback: {
        DispatchQueue.main.async {
          button.isEnabled = true
        }
      })
    }
    view.announcementAction = { [weak self] in
      self?.announcementView.isHidden = false
    }
    view.smallWindowAction = { [weak self] in
      self?.smallWindow()
    }
    view.onlineNumber = 0
    view.roomName = joinParams.roomName
    return view
  }()

  public lazy var seatsView: NEVRBaseSeatsView = {
    /// width 是必要的，因为要提前计算内部的一些尺寸
    let view = NEVRBaseSeatsView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 0))
    view.setupAudience(defaultAudienceSeats)
    view.setupOwner(defaultOwnerSeat)
    view.clickedAction = { [weak self] cellModel in
      self?.clickSeatCell(model: cellModel)
    }
    return view
  }()

  public lazy var defaultAudienceSeats: [NEVRBaseSeatCellModel] = {
    var array: [NEVRBaseSeatCellModel] = []
    for i in 0 ..< 8 {
      let model = NEVRBaseSeatCellModel(state: .idle, micState: .off, uuid: nil, nickname: NEVRBaseBundle.localized("Seat") + " \(i + 1)", iconUrl: nil, coinsCount: 0)
      array.append(model)
    }
    return array
  }()

  public lazy var defaultOwnerSeat: NEVRBaseSeatCellModel = // 直接设置为taken状态，让icon显示早一点
    .init(state: .taken, micState: .off, uuid: joinParams.ownerUuid, nickname: joinParams.ownerName, iconUrl: joinParams.ownerIcon, coinsCount: 0)

  lazy var footerView: NESocialFooterView = {
    let view = NESocialFooterView(frame: CGRect.zero, customButtonItems: customFooterButtonItems)
    view.inputMessage = { [weak self] in
      let _ = self?.keyboardView.becomeFirstResponder()
    }
    return view
  }()

  open lazy var chatroomView: NESocialChatroomView = .init()

  lazy var backgroundImage: UIImageView = {
    let image = UIImageView()
    image.backgroundColor = UIColor(red: 0.12, green: 0.12, blue: 0.3, alpha: 1)
    if let url = URL(string: joinParams.cover) {
      image.sd_setImage(with: url, placeholderImage: NEVRBaseBundle.loadImage("background"))
    }
    return image
  }()

  lazy var keyboardView: NESocialInputView = {
    let frame = CGRect(x: 0, y: view.bounds.height, width: view.bounds.width, height: view.bounds.height)
    let view = NESocialInputView(frame: frame)
    view.isHidden = true
    view.sendAction = { [weak self] text in
      if let text = text,
         !text.isEmpty {
        self?.present.sendTextMessage(message: text, callback: { code, msg in
          if code == 0 {
            let message = NESocialChatroomTextMessage()
            message.sender = NEVoiceRoomKit.getInstance().localMember?.name
            message.text = text
            message.iconSize = CGSize(width: 32, height: 16)
            message.icon = self?.isOwner ?? false ? NEVRBaseBundle.loadImage(NEVRBaseBundle.localized("Owner_Icon")) : nil
            self?.chatroomView.addMessage(message)
            self?.onSendTextMessage(message: message)
          } else {
            // TODO: 发送消息失败时候的Toast提示
          }
        })
        return true
      }
      self?.showToastInWindow(NEVRBaseBundle.localized("Message_Empty"))
      return false
    }
    view.sendBtnTitle = NEVRBaseBundle.localized("Send_Message")
    return view
  }()

  lazy var announcementView: NESocialAnnouncementView = {
    let view = NESocialAnnouncementView()
    view.isHidden = true
    return view
  }()

  // MARK: 麦位相关的顶部弹窗

  /// 观众申请上麦中的弹窗，用来取消申请
  lazy var seatRequestToast: UIView = {
    let view = UIView()
    view.backgroundColor = .white
    view.layer.cornerRadius = 20
    let label = UILabel()
    label.text = NEVRBaseBundle.localized("Seat_Request_Waiting")
    label.textColor = .black
    label.font = UIFont(name: "PingFangSC-Regular", size: 14)
    view.addSubview(label)
    label.snp.makeConstraints { make in
      make.top.bottom.equalToSuperview()
      make.left.equalToSuperview().offset(16)
    }
    let button = UIButton()
    button.setTitle(NEVRBaseBundle.localized("Cancel"), for: .normal)
    button.setTitleColor(UIColor(red: 0.2, green: 0.494, blue: 1, alpha: 1), for: .normal)
    button.titleLabel?.font = UIFont(name: "PingFangSC-Regular", size: 14)
    button.addTarget(self, action: #selector(cancelSeatRequest), for: .touchUpInside)
    view.addSubview(button)
    button.snp.makeConstraints { make in
      make.top.bottom.equalToSuperview()
      make.right.equalToSuperview().offset(-16)
      make.left.equalTo(label.snp.right)
    }
    view.isHidden = true
    return view
  }()

  func cancelSeatRequest() {
    NESocialActionSheet.show(controller: self, actions: [cancelSeatRequestAction(), cancelAction()])
  }

  /// 观众上麦请求的结果弹窗，被主播拒绝或者同意
  lazy var seatRequestResultToast: NEVRBaseSeatRequestView = {
    let view = NEVRBaseSeatRequestView()
    view.isHidden = true
    return view
  }()

  /// 主播展开后的麦位申请列表弹窗
  lazy var seatRequestListView: NEVRBaseSeatRequestListView = {
    let view = NEVRBaseSeatRequestListView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 0))
    view.acceptAction = { [weak self] seat in
      if let user = seat.user {
        self?.seatPresent.approveSeatRequest(user) { code, _ in
          if code == 0 {
            DispatchQueue.main.async {
              // 操作完成马上更新界面
              self?.seatRequestListView.remove(seat: seat)
            }
          }
        }
      }
    }
    view.rejectAction = { [weak self] seat in
      if let user = seat.user {
        self?.seatPresent.rejectSeatRequest(user) { code, _ in
          if code == 0 {
            DispatchQueue.main.async {
              // 操作完成马上更新界面
              self?.seatRequestListView.remove(seat: seat)
            }
          }
        }
      }
    }
    return view
  }()

  /// 礼物动画视图
  lazy var giftAnimation: NESocialGiftLottieView = {
    let giftAnimation = NESocialGiftLottieView()
    giftAnimation.isHidden = true
    return giftAnimation
  }()

  // MARK: 支持继承重写的变量

  /// 麦位列表页面专用present，如有需要也可以重写
  open lazy var seatPresent: NEVRBaseSeatPresent = .init(viewController: self)

  /// 除麦位列表外的其他UI使用的present，如有需要也可以重写
  open lazy var present: NEVRBasePresent = .init(viewController: self)

  /// 继承后设置自己的自定义底部按钮
  open lazy var customFooterButtonItems: [NESocialFooterButtonItem] = {
    var items = [NESocialFooterButtonItem]()
    // 礼物按钮
    let gift = NESocialFooterButtonItem.giftItem(action: { [weak self] _ in
      if let weakSelf = self {
        let whole = [weakSelf.defaultOwnerSeat] + weakSelf.defaultAudienceSeats
        NEVRBaseGiftViewController.show(viewController: weakSelf, seats: whole) { gift, count, seats in
          var uuids: [String] = []
          seats.forEach { model in
            if let uuid = model.uuid,
               model.state == .taken {
              uuids.append(uuid)
            }
          }
          NEVoiceRoomKit.getInstance().sendBatchGift(gift.giftId, giftCount: count, userUuids: uuids)
        }
      }
    })
    gift.isHidden = false
    items.append(gift)
    // 麦克风按钮
    let mic = NESocialFooterButtonItem.micItem(action: { [weak self] item in
      self?.mute(!item.isSelected)
    })
    mic.isHidden = true
    items.append(mic)
    // 更多按钮
    let more = NESocialFooterButtonItem.moreItem(action: { [weak self] _ in
      if let weakSelf = self {
        NESocialMoreViewController.show(in: weakSelf, dataSource: weakSelf.moreItems)
      }
    })
    more.isHidden = true
    items.append(more)
    return items
  }()

  /// 更新底部按钮排列，在麦位变化的时候
  open func dealCustomFooterButtonItems(isOnSeat: Bool) {
    customFooterButtonItems.forEach { item in
      if isOnSeat {
        item.isHidden = false
      } else {
        item.isHidden = item.tag != NESocialFooterInternalTag.gift.rawValue
      }
    }
    footerView.reload(customButtonItems: customFooterButtonItems)
  }

  /// 继承后设置自己的更多底部弹窗里的按钮
  open lazy var moreItems: [NESocialMoreItem] = {
    var items = [NESocialMoreItem]()
    // 麦克风按钮
    items.append(NESocialMoreItem.micItem(action: { [weak self] item in
      self?.mute(!item.isSelected)
    }))
    // 耳返按钮
    let IEMs = NESocialMoreItem.IEMsItem(action: { [weak self] item in
      if item.isSelected {
        if !NEVoiceRoomKit.getInstance().isHeadSetPlugging() {
          self?.showToastInWindow(NEVRBaseBundle.localized("IEMs_Tips"))
          return
        }
        self?.present.turnOnIEMs()
      } else {
        self?.present.turnOffIEMs()
      }
    })
    IEMs.isSelected = !present.isIEMsOn
    items.append(IEMs)
    // 调音台按钮
    items.append(NESocialMoreItem.mixerItem(action: { [weak self] item in
      if let self = self {
        NEVRBaseMixerViewController.show(in: self, present: self.present)
      }
    }))
    // 音效按钮
    let effect = NESocialMoreItem.effectsItem(action: { [weak self] item in
      if let self = self {
        NESocialEffectsViewController.show(in: self, present: self.present)
      }
    })
    effect.isHidden = joinParams.role == .audience
    items.append(effect)
    // 关播按钮
    let end = NESocialMoreItem.endItem(action: { [weak self] item in
      self?.closeRoom()
    })
    end.isHidden = joinParams.role == .audience
    items.append(end)
    return items
  }()

  /// 更新更多底部弹窗按钮排列，在麦位变化的时候
  open func dealMoreItems(isOnSeat: Bool) {
    if let item = moreItems.first(where: { $0.tag == NESocialMoreInternalTag.mic.rawValue }) {
      item.isHidden = !isOnSeat
    }
    // 因为更多弹窗的高度是根据现实的item数量计算的，所以为了在变更的时候不出现其他异常，直接隐藏该窗口
    NESocialMoreViewController.dismiss()
  }
}

// MARK: 支持继承重写的方法

extension NEVRBaseViewController {
  /// 继承后添加自己的一些布局，这个函数会在viewDidLoad的时候被调用
  open func customLayout() {}

  /// 继承后添加对自己的present事件监听，这个函数会在viewDidLoad的时候被调用
  open func observeCustomPresentEvent() {}

  /// 继承后添加自己在加入房间后的行为，这个函数会在joinRoom的回调里触发
  open func afterJoinRoom() {}
  /// 发送文本消息后触发回调
  open func onSendTextMessage(message: NESocialChatroomTextMessage) {}

  /// 加入或重入聊天室
  /// - Parameter firstTime: 是否是第一次加入
  open func joinOrRejoinChatroom(firstTime: Bool) {}

  /// 自己从麦上到了麦下，可以在此做一些销毁操作
  open func didSelfLeaveSeat() {}
  /// 麦位变化
  open func onSeatListChanged(seats: [NEVoiceRoomSeatItem]) {}
}

// MARK: 键盘弹出管理

extension NEVRBaseViewController {
  func observeKeyboard() {
    let center = NotificationCenter.default
    center.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    center.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
  }

  @objc func keyboardWillShow(notification: Notification) {
    if let userInfo = notification.userInfo,
       let rect = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
       let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double {
      let keyboardHeight = rect.size.height
      UIView.animate(withDuration: duration) { [weak self] in
        if let weakSelf = self {
          weakSelf.keyboardView.isHidden = false
          weakSelf.keyboardView.frame = CGRect(x: 0, y: 0, width: weakSelf.view.bounds.width, height: weakSelf.view.bounds.height - keyboardHeight)
        }
      }
    }
  }

  @objc func keyboardWillHide(notification: Notification) {
    UIView.animate(withDuration: 0.1) { [weak self] in
      if let weakSelf = self {
        weakSelf.keyboardView.isHidden = true
        weakSelf.keyboardView.frame = CGRect(x: 0, y: weakSelf.view.bounds.height, width: weakSelf.view.bounds.width, height: weakSelf.view.bounds.height)
      }
    }
  }

  override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesBegan(touches, with: event)
    keyboardView.resignFirstResponder()
    view.endEditing(true)
  }
}

// MARK: 对present的事件监听

extension NEVRBaseViewController {
  func observePresentEvent() {
    // 有成员加入房间
    present.onMembersJoinRoom = { [weak self] names in
      let messages = names.map { name in
        let message = NESocialChatroomNotiMessage()
        message.notification = String(format: "%@ %@", name, NEVRBaseBundle.localized("Join_Room"))
        return message
      }
      self?.chatroomView.addMessages(messages)
      self?.headerView.onlineNumber = NEVoiceRoomKit.getInstance().allMemberList.count
    }
    // 有成员离开房间
    present.onMembersLeaveRoom = { [weak self] names in
      let messages = names.map { name in
        let message = NESocialChatroomNotiMessage()
        message.notification = String(format: "%@ %@", name, NEVRBaseBundle.localized("Leave_Room"))
        return message
      }
      self?.chatroomView.addMessages(messages)
      self?.headerView.onlineNumber = NEVoiceRoomKit.getInstance().allMemberList.count
    }
    // 静音状态变化
    present.onMemberAudioMuteChanged = { [weak self] uuid, mute in
      /// 如果是自己，则更新一下麦克风按钮的状态
      if uuid == NEVoiceRoomKit.getInstance().localMember?.account {
        self?.updateMicSelected(mute)
      }
    }
    // 收到文本消息
    present.onReceiveTextMessage = { [weak self] message in
      let isOwner = message.fromUserUuid == self?.joinParams.ownerUuid
      let text = NESocialChatroomTextMessage()
      text.sender = message.fromNick ?? message.fromUserUuid
      text.text = message.text
      text.iconSize = CGSize(width: 32, height: 16)
      text.icon = isOwner ? NEVRBaseBundle.loadImage(NEVRBaseBundle.localized("Owner_Icon")) : nil
      self?.chatroomView.addMessage(text)
    }
    // 房间关闭
    present.onRoomEnd = { [weak self] reason in
      if reason != .leaveBySelf {
        self?.showToastInWindow(NEVRBaseBundle.localized("Room_Closed"))
      }
      self?.dismiss()
    }
    // 收到批量礼物
    present.onReceiveBatchGift = { [weak self] gift in
      if let model = NESocialGiftModel.getGift(giftId: gift.giftId) {
        self?.playGiftAnimation(model)
        let messages: [NESocialChatroomMessage] = gift.rewardeeUsers.map { userRewardee in
          let message = NESocialChatroomRewardMessage()
          message.giftImage = model.icon
          message.giftImageSize = CGSize(width: 20, height: 20)
          message.sender = gift.rewarderUserName
          message.receiver = userRewardee.userName
          message.rewardText = NEVRBaseBundle.localized("Send_Gift_To")
          message.rewardColor = UIColor(white: 1, alpha: 0.6)
          message.giftColor = UIColor(hexString: "#FFD966")
          message.giftCount = gift.giftCount
          message.giftName = model.displayName
          return message
        }
        self?.chatroomView.addMessages(messages)
      }
      self?.updateSeatCoins(seatUserRewards: gift.seatUserReward)
    }
    // 耳返状态变更
    present.onIEMsStateChanged = { [weak self] on in
      if let item = self?.moreItems.first(where: { $0.tag == NESocialMoreInternalTag.IEMs.rawValue }) {
        item.isSelected = !on
      }
    }
    observeCustomPresentEvent()
  }
}

// MARK: ViewController内部可复用代码的封装

extension NEVRBaseViewController {
  /// 自己是否是主播
  public var isOwner: Bool {
    joinParams.role == .host
  }

  /// 主播主动关闭房间，两个入口：
  /// 1. 顶部的关闭按钮
  /// 2. 底部的更多弹窗
  /// 3. 小窗的关闭按钮，此时不需要弹出Alert
  func closeRoom(shouldCheck: Bool = true, callback: (() -> Void)? = nil) {
    if shouldCheck {
      let alert = UIAlertController(title: NEVRBaseBundle.localized("Close_Room_Title"), message: NEVRBaseBundle.localized("Close_Room_Message"), preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: NEVRBaseBundle.localized("Comfirm"), style: .default) { [weak self] _ in
        self?.present.endRoom(callback: { code, msg in
          DispatchQueue.main.async {
            NESocialFloatWindow.instance.floatingView.isHidden = true
            NESocialFloatWindow.instance.target = nil
            self?.showToastInWindow(NEVRBaseBundle.localized("Room_Deleted"))
            self?.dismiss()
            callback?()
          }
        })
      })
      alert.addAction(UIAlertAction(title: NEVRBaseBundle.localized("Cancel"), style: .cancel) { _ in
        callback?()
      })
      if let controller = presentedViewController {
        controller.present(alert, animated: true)
      } else {
        present(alert, animated: true)
      }
    } else {
      present.endRoom(callback: { [weak self] code, msg in
        DispatchQueue.main.async {
          NESocialFloatWindow.instance.floatingView.isHidden = true
          NESocialFloatWindow.instance.target = nil
          self?.showToastInWindow(NEVRBaseBundle.localized("Room_Deleted"))
          self?.dismiss()
          callback?()
        }
      })
    }
  }

  /// 观众离开直播间
  open func leaveRoom(callback: (() -> Void)? = nil) {
    present.leaveRoom { [weak self] code, msg in
      DispatchQueue.main.async {
        NESocialFloatWindow.instance.floatingView.isHidden = true
        NESocialFloatWindow.instance.target = nil
        self?.dismiss()
        callback?()
      }
    }
  }

  open func dismiss() {
    if let controller = presentedViewController {
      controller.dismiss(animated: false)
    }
    navigationController?.popViewController(animated: false)
  }

  /// 主动静音接口，三个入口：
  /// 1. 底部的工具栏
  /// 2. 底部的更多弹窗
  /// 3. 上麦后默认打开麦克风
  /// 操作完成之后要更新麦克风图标
  func mute(_ mute: Bool) {
    if mute {
      present.mute { [weak self] code, msg in
        if code == 0 {
          // 麦克风按钮更新为选中状态
          self?.updateMicSelected(true)
        }
        DispatchQueue.main.async { [weak self] in
          self?.showToastInWindow(NEVRBaseBundle.localized(code == 0 ? "Mute_Succeed" : "Mute_Failed"))
        }
      }
    } else {
      present.unmute { [weak self] code, msg in
        if code == 0 {
          // 麦克风按钮更新为非选中状态
          self?.updateMicSelected(false)
        }
        DispatchQueue.main.async { [weak self] in
          self?.showToastInWindow(NEVRBaseBundle.localized(code == 0 ? "Unmute_Succeed" : "Unmute_Failed"))
        }
      }
    }
  }

  /// 更新麦克风的图标是否选中，两个入口：
  /// 1. 主动操作静音
  /// 2. onMemberAudioMuteChanged回调更新
  func updateMicSelected(_ isSelected: Bool) {
    // 麦克风按钮更新为选中状态
    DispatchQueue.main.async { [weak self] in
      if let item = self?.customFooterButtonItems.first(where: { $0.tag == NESocialFooterInternalTag.mic.rawValue }) {
        item.isSelected = isSelected
      }
      if let item = self?.moreItems.first(where: { $0.tag == NESocialMoreInternalTag.mic.rawValue }) {
        item.isSelected = isSelected
      }
    }
  }

  func playGiftAnimation(_ gift: NESocialGiftModel) {
    // 房主不展示礼物动画
    if !isOwner,
       UIApplication.shared.applicationState != .background {
      DispatchQueue.main.async { [weak self] in
        if let self = self {
          self.view.bringSubviewToFront(self.giftAnimation)
          self.giftAnimation.addGift(gift.animation)
        }
      }
    }
  }

  /// 小窗
  func smallWindow() {
    NESocialFloatWindow.instance.addViewControllerTarget(self, roomUuid: joinParams.roomUuid) { [weak self] callback in
      NESocialFloatWindow.instance.floatingView.isHidden = true
      self?.isOwner ?? false ? self?.closeRoom(shouldCheck: false, callback: callback) : self?.leaveRoom(callback: callback)
    }
    NESocialFloatWindow.instance.floatingView.isHidden = false
    NESocialFloatWindow.instance.setupUI(icon: joinParams.ownerIcon, title: "")
    dismiss()
  }

  /// 检查当前是否有可用网络
  /// - Parameter showToast: 是否展示Toast
  /// - Returns: 是否有网络
  func checkNetwork(showToast: Bool = true) -> Bool {
    if reachability?.connection == .cellular || reachability?.connection == .wifi {
      return true
    }
    if showToast {
      showToastInWindow(NEVRBaseBundle.localized("Net_Error"))
    }
    return false
  }
}
