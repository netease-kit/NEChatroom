// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import NECommonUIKit
import NEVoiceRoomKit
import UIKit

class NEVRBaseSeatRequestAlertView: UIView {
  var action: (() -> Void)?

  override init(frame: CGRect) {
    super.init(frame: frame)
    addSubview(showConnectListBtn)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  lazy var showConnectListBtn: UIButton = {
    let button = UIButton(type: .custom)
    button.setTitleColor(.white, for: .normal)
    button.titleLabel?.font = UIFont(name: "PingFangSC-Regular", size: 14)
    button.addTarget(target, action: #selector(onShowConnectListBtnClicked), for: .touchUpInside)
    button.layer.cornerRadius = 19
    button.clipsToBounds = true
    button.layer.insertSublayer(gradientLayer, at: 0)
    return button
  }()

  lazy var gradientLayer: CAGradientLayer = {
    let gradientLayer = CAGradientLayer()
    gradientLayer.colors = [UIColor(hexString: "#4D88FF").cgColor, UIColor(hexString: "#D2A6FF").cgColor]
    gradientLayer.startPoint = CGPoint(x: 0, y: 0)
    gradientLayer.endPoint = CGPoint(x: 0, y: 1)
    gradientLayer.cornerRadius = 19
    return gradientLayer
  }()

  @objc func onShowConnectListBtnClicked() {
    action?()
    showConnectListBtn.isHidden = true
  }

  func updateConnectCount(connectCount: Int) {
    showConnectListBtn.setTitle(String(format: "%@(%zd)", NEVRBaseBundle.localized("Seat_Submitted"), connectCount), for: .normal)
  }

  func refreshAlertView(isListViewPushed: Bool) {
    showConnectListBtn.isHidden = isListViewPushed
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    showConnectListBtn.frame = bounds

    if let layer = showConnectListBtn.layer.sublayers?.first(where: { $0 == gradientLayer }) {
      layer.frame = showConnectListBtn.bounds
    }
  }
}

class NEVRBaseSeatRequestCell: UITableViewCell {
  var seatItem: NEVoiceRoomSeatItem?

  var acceptAction: ((NEVoiceRoomSeatItem) -> Void)?
  var rejectAction: ((NEVoiceRoomSeatItem) -> Void)?

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    backgroundColor = .clear
    selectionStyle = .none
    contentView.addSubview(avatar)
    contentView.addSubview(nameLabel)
    contentView.addSubview(acceptBtn)
    contentView.addSubview(rejectBtn)
    contentView.addSubview(bottomLine)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    avatar.frame = CGRect(x: 16, y: 8, width: 32, height: 32)
    acceptBtn.frame = CGRect(x: contentView.frame.width - 32, y: 16, width: 16, height: 16)
    rejectBtn.frame = CGRect(x: contentView.frame.width - 64, y: 16, width: 16, height: 16)
    nameLabel.frame = CGRect(x: avatar.right + 8, y: 0, width: contentView.frame.width - 80 - avatar.right, height: contentView.frame.height)
    bottomLine.frame = CGRect(x: avatar.left, y: contentView.frame.height - 0.5, width: contentView.width - avatar.left, height: 0.5)
  }

  func setup(seatItem: NEVoiceRoomSeatItem) {
    self.seatItem = seatItem

    if let icon = seatItem.icon {
      avatar.sd_setImage(with: URL(string: icon))
    }
    nameLabel.text = String(format: "%@ %@%d", seatItem.userName ?? "", NEVRBaseBundle.localized("Seat_Request"), seatItem.index - 1)
  }

  lazy var bottomLine: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor(white: 1, alpha: 0.2)
    return view
  }()

  lazy var avatar: UIImageView = {
    let image = UIImageView()
    image.layer.cornerRadius = 16
    image.layer.masksToBounds = true
    return image
  }()

  lazy var nameLabel: UILabel = {
    let view = UILabel()
    view.textColor = .white
    view.font = UIFont.systemFont(ofSize: 14)
    view.lineBreakMode = .byTruncatingMiddle
    view.sizeToFit()
    return view
  }()

  lazy var acceptBtn: UIButton = {
    let button = UIButton(type: .custom)
    button.setImage(NEVRBaseBundle.loadImage("seat_accept"), for: .normal)
    button.addTarget(self, action: #selector(buttonClicked(sender:)), for: .touchUpInside)
    return button
  }()

  lazy var rejectBtn: UIButton = {
    let button = UIButton(type: .custom)
    button.setImage(NEVRBaseBundle.loadImage("seat_reject"), for: .normal)
    button.addTarget(self, action: #selector(buttonClicked(sender:)), for: .touchUpInside)
    return button
  }()

  @objc func buttonClicked(sender: UIButton) {
    if let seatItem = seatItem {
      if sender == acceptBtn {
        acceptAction?(seatItem)
      } else if sender == rejectBtn {
        rejectAction?(seatItem)
      }
    }
  }
}

class NEVRBaseSeatRequestListView: UIView {
  let cellHeight: CGFloat = 48
  let connectAlertViewHeight: CGFloat = 38
  let connectAlertViewWidth: CGFloat = 120
  let titleLabelHeight: CGFloat = 51
  let tableviewMaxHeight: CGFloat = 216
  let foldBtnHeight: CGFloat = 38

  var acceptAction: ((NEVoiceRoomSeatItem) -> Void)?
  var rejectAction: ((NEVoiceRoomSeatItem) -> Void)?

  var isListViewPushed = false
  var isShown = false

  var smallRect = CGRect.zero
  var largeRect = CGRect.zero
  var preRect = CGRect.zero

  var seats: [NEVoiceRoomSeatItem]?

  override init(frame: CGRect) {
    super.init(frame: frame)

    addSubview(bar)
    bar.addSubview(titleLable)
    bar.addSubview(coverView)
    bar.addSubview(tableView)
    bar.addSubview(connectAlertView)
    bar.addSubview(foldButton)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func refresh(seats: [NEVoiceRoomSeatItem]) {
    // 过滤自己，正常情况下只有主播刚加入房间的时候主播会在申请列表
    let seats = seats.filter { $0.user != NEVoiceRoomKit.getInstance().localMember?.account && $0.status == .waiting }
    if seats.count < 1 {
      dismiss()
    }
    self.seats = seats
    connectAlertView.updateConnectCount(connectCount: seats.count)
    titleLable.text = String(format: "%@(%ld)", NEVRBaseBundle.localized("Seat_Submitted"), seats.count)
    tableView.reloadData()
    forceLayoutSubviews()
  }

  // 为了操作之后界面可以快速响应，增加这个方法
  func remove(seat: NEVoiceRoomSeatItem) {
    if var seats = seats {
      seats.removeAll(where: { $0 == seat })
      refresh(seats: seats)
    }
  }

  func showAsAlert(view: UIView) {
    if isShown {
      return
    }
    view.addSubview(self)
    // 刷新宽高
    layoutIfNeeded()

    setBottom(bottom: 0)

    if CGRectEqualToRect(largeRect, .zero) {
      largeRect = frame
      smallRect = CGRect(x: 80, y: frame.origin.y, width: largeRect.width - 160, height: frame.height)
    }
    frame = CGRect(x: smallRect.origin.x, y: frame.origin.y, width: smallRect.width, height: frame.height)
    connectAlertView.centerX = frame.width / 2
    tableView.isHidden = true
    titleLable.isHidden = true
    foldButton.isHidden = true

    UIView.animate(withDuration: 0.25) { [weak self] in
      if let self = self {
        self.setBottom(bottom: UIApplication.shared.statusBarFrame.height + self.connectAlertViewHeight)
      }
    }
    isListViewPushed = false
    connectAlertView.refreshAlertView(isListViewPushed: false)
    isShown = true
  }

  func showListView() {
    tableView.isHidden = false
    titleLable.isHidden = false
    foldButton.isHidden = false
    setBottom(bottom: 0)
    frame = CGRect(x: largeRect.origin.x, y: frame.origin.y, width: largeRect.width, height: frame.height)
    connectAlertView.centerX = frame.width / 2
    forceLayoutSubviews()
    UIView.animate(withDuration: 0.25) { [weak self] in
      self?.setTop(y: 0)
    } completion: { [weak self] _ in
      self?.isListViewPushed = true
      self?.connectAlertView.refreshAlertView(isListViewPushed: true)
    }
  }

  func dismissListView() {
    layoutIfNeeded()
    UIView.animate(withDuration: 0.25) { [weak self] in
      self?.setBottom(bottom: 0)
    } completion: { [weak self] _ in
      if let self = self {
        self.frame = CGRect(x: self.smallRect.origin.x, y: self.frame.origin.y, width: self.smallRect.width, height: self.frame.height)
        self.connectAlertView.centerX = self.frame.width / 2
        self.tableView.isHidden = true
        self.titleLable.isHidden = true
        self.foldButton.isHidden = true
        self.isListViewPushed = false
        self.setBottom(bottom: UIApplication.shared.statusBarFrame.height + self.connectAlertViewHeight)
        self.layoutIfNeeded()
        self.connectAlertView.refreshAlertView(isListViewPushed: false)
      }
    }
  }

  func dismiss() {
    if !isShown {
      return
    }
    UIView.animate(withDuration: 0.25) { [weak self] in
      self?.setBottom(bottom: 0)
    } completion: { [weak self] _ in
      self?.removeFromSuperview()
      self?.isListViewPushed = false
    }
    isShown = false
  }

  func forceLayoutSubviews() {
    if !tableView.isHidden {
      setHeight(height: barHeight)
      bar.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
      coverView.frame = CGRect(x: 0, y: 0, width: frame.width, height: bar.frame.height - listViewHeight - titleLabelHeight - connectAlertViewHeight)
      titleLable.frame = CGRect(x: 0, y: coverView.frame.origin.y + coverView.frame.height, width: frame.width, height: titleLabelHeight)
      tableView.frame = CGRect(x: 0, y: titleLable.frame.origin.y + titleLable.frame.height, width: frame.width, height: listViewHeight)
      foldButton.frame = CGRect(x: 0, y: tableView.frame.origin.y + tableView.frame.height, width: frame.width, height: foldBtnHeight)

      // 给foldButton添加圆角
      foldButton.layoutIfNeeded()
      foldButton.addCorner(conrners: [.bottomLeft, .bottomRight], radius: 8)

      connectAlertView.width = connectAlertViewWidth
      connectAlertView.height = connectAlertViewHeight
      connectAlertView.centerX = width / 2
      var frame = connectAlertView.frame
      frame.origin.y = bar.bottom - frame.size.height
      connectAlertView.frame = frame
    }
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    if !CGRectEqualToRect(preRect, bounds) {
      forceLayoutSubviews()
      preRect = bounds
    }
  }

  private func setBottom(bottom: CGFloat) {
    var frame = frame
    frame.origin.y = bottom - frame.size.height
    self.frame = frame
  }

  private func setTop(y: CGFloat) {
    var frame = frame
    frame.origin.y = y
    self.frame = frame
  }

  private func setHeight(height: CGFloat) {
    var frame = frame
    frame.size.height = height
    self.frame = frame
  }

  private var listViewHeight: CGFloat {
    if let count = seats?.count {
      let tableviewHeight = CGFloat(count) * cellHeight
      return min(tableviewHeight, tableviewMaxHeight)
    } else {
      return 0
    }
  }

  private var barHeight: CGFloat {
    listViewHeight + connectAlertViewHeight + titleLabelHeight + UIApplication.shared.statusBarFrame.height
  }

  lazy var bar: UIView = .init()

  lazy var coverView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor(hexString: "#1D1D24", 0.9)
    return view
  }()

  lazy var connectAlertView: NEVRBaseSeatRequestAlertView = {
    let view = NEVRBaseSeatRequestAlertView()
    view.backgroundColor = .clear
    view.action = { [weak self] in
      if let self = self {
        self.isListViewPushed ? self.dismissListView() : self.showListView()
      }
    }
    return view
  }()

  lazy var titleLable: UILabel = {
    let titleLabel = UILabel()
    titleLabel.textColor = .white
    titleLabel.textAlignment = .center
    titleLabel.font = UIFont.systemFont(ofSize: 15)
    titleLabel.backgroundColor = UIColor(hexString: "#1D1D24", 0.9)
    return titleLabel
  }()

  lazy var tableView: UITableView = {
    let view = UITableView()
    view.dataSource = self
    view.register(NEVRBaseSeatRequestCell.self, forCellReuseIdentifier: "NEVRBaseSeatRequestCell")
    view.backgroundColor = UIColor(hexString: "#1D1D24", 0.9)
    view.tableFooterView = UIView()
    view.separatorStyle = .none
    return view
  }()

  lazy var foldButton: UIButton = {
    let btn = UIButton()
    btn
      .backgroundColor = UIColor(hexString: "#1D1D24", 0.9)
    let res = NSMutableAttributedString(string: NEVRBaseBundle.localized("Hide"), attributes: [
      NSAttributedString.Key.foregroundColor: UIColor.white,
      NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14.0),
    ])
    let attachment = NSTextAttachment()
    attachment.bounds = CGRect(x: 0, y: -2, width: 14, height: 14)
    attachment.image = NEVRBaseBundle.loadImage("seat_hide")
    let icoStr = NSAttributedString(attachment: attachment)
    res.append(icoStr)

    btn.setAttributedTitle(res.copy() as? NSAttributedString, for: .normal)
    btn.addTarget(self, action: #selector(foldConnectList), for: .touchUpInside)
    return btn
  }()

  @objc func foldConnectList() {
    dismissListView()
    connectAlertView.showConnectListBtn.isHidden = false
  }
}

extension NEVRBaseSeatRequestListView: UITableViewDataSource {
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    cellHeight
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    seats?.count ?? 0
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if let cell = tableView.dequeueReusableCell(withIdentifier: "NEVRBaseSeatRequestCell") as? NEVRBaseSeatRequestCell,
       let seats = seats,
       indexPath.row < seats.count {
      let seat = seats[indexPath.row]
      cell.setup(seatItem: seat)
      cell.acceptAction = { [weak self] seat in
        self?.acceptAction?(seat)
      }
      cell.rejectAction = { [weak self] seat in
        self?.rejectAction?(seat)
      }
      return cell
    }
    return UITableViewCell()
  }
}
