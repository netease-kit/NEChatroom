// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import NECommonUIKit
import SnapKit
import UIKit
import NESocialUIKit

var lightBlue = UIColor(red: 0.925, green: 0.953, blue: 1, alpha: 1)
var blue = UIColor(red: 0.2, green: 0.494, blue: 1, alpha: 1)

public class NEVRBaseGiftCountCell: UITableViewCell {
  override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    contentView.backgroundColor = .clear
    contentView.addSubview(contentLabel)
    selectionStyle = .none
    contentLabel.snp.makeConstraints { make in
      make.width.equalTo(96)
      make.height.equalTo(28)
      make.centerY.centerX.equalToSuperview()
    }
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public var isCustomSelected: Bool = false {
    didSet {
      if isCustomSelected {
        contentLabel.layer.borderWidth = 1
        contentLabel.backgroundColor = lightBlue
        contentLabel.textColor = blue
      } else {
        contentLabel.layer.borderWidth = 0
        contentLabel.backgroundColor = .clear
        contentLabel.textColor = UIColor(hexString: "#333333")
      }
    }
  }

  public lazy var contentLabel: UILabel = {
    var label = UILabel()
    label.textColor = UIColor(hexString: "#333333")
    label.font = UIFont(name: "PingFangSC-Regular", size: 14)
    label.textAlignment = .center
    label.layer.cornerRadius = 14
    label.clipsToBounds = true
    label.layer.borderColor = blue.cgColor
    return label
  }()
}

public class NEVRBaseGiftCell: UICollectionViewCell {
  public var tapAction: ((Int) -> Void)?
  public var index: Int = 0

  class func size() -> CGSize {
    // 一排放4个
    CGSize(width: (UIScreen.main.bounds.width - 30) / 4, height: 136)
  }

  override public init(frame: CGRect) {
    super.init(frame: frame)
    contentView.backgroundColor = .white
    contentView.addSubview(bgView)
    bgView.addSubview(icon)
    bgView.addSubview(displayNameLabel)
    bgView.addSubview(coinLabel)

    bgView.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(4)
      make.right.equalToSuperview().offset(-4)
      make.top.equalToSuperview().offset(20)
      make.height.equalTo(98)
    }

    icon.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.width.height.equalTo(40)
      make.top.equalToSuperview().offset(8)
    }

    displayNameLabel.snp.makeConstraints { make in
      make.left.right.equalToSuperview()
      make.top.equalTo(icon.snp.bottom).offset(4)
    }

    coinLabel.snp.makeConstraints { make in
      make.left.right.equalToSuperview()
      make.top.equalTo(displayNameLabel.snp.bottom).offset(4)
    }

    let gesture = UITapGestureRecognizer(target: self, action: #selector(tap))
    contentView.addGestureRecognizer(gesture)
  }

  @objc func tap() {
    tapAction?(index)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public var isCustomSelected: Bool = false {
    didSet {
      if isCustomSelected {
        bgView.layer.borderWidth = 1
        bgView.backgroundColor = lightBlue
      } else {
        bgView.layer.borderWidth = 0
        bgView.backgroundColor = .clear
      }
    }
  }

  public func setup(item: NESocialGiftModel, index: Int) {
    self.index = index
    icon.image = item.icon
    displayNameLabel.text = item.displayName
    // 礼物值
    if item.price > 0 {
      var coinsCount = String(item.price)
      if item.price > 99999 {
        coinsCount = "99999+"
      }
      let mutableString = NSMutableAttributedString()
      let attachment = NSTextAttachment()
      attachment.image = NEVRBaseBundle.loadImage("seat_coin")
      attachment.bounds = CGRect(x: 0, y: (coinLabel.font.capHeight - 12) / 2, width: 12, height: 12)
      mutableString.append(NSAttributedString(attachment: attachment))
      mutableString.append(NSAttributedString(string: " "))
      mutableString.append(NSAttributedString(string: coinsCount, attributes: [.font: coinLabel.font ?? UIFont.systemFont(ofSize: 10), .foregroundColor: UIColor(hexString: "#FFC86B")]))
      coinLabel.attributedText = mutableString
    } else {
      coinLabel.attributedText = nil
    }
  }

  lazy var icon: UIImageView = {
    let icon = UIImageView()
    return icon
  }()

  lazy var displayNameLabel: UILabel = {
    let label = UILabel()
    label.textColor = UIColor(hexString: "#333333")
    label.font = UIFont(name: "PingFangSC-Regular", size: 14)
    label.textAlignment = .center
    return label
  }()

  lazy var bgView: UIView = {
    let view = UIView()
    view.layer.cornerRadius = 4
    view.clipsToBounds = true
    view.layer.borderColor = blue.cgColor
    return view
  }()

  lazy var coinLabel: UILabel = {
    let view = UILabel()
    view.textAlignment = .center
    view.font = UIFont(name: "PingFangSC-Regular", size: 10) ?? UIFont.systemFont(ofSize: 10)
    return view
  }()
}

public class NEVRBaseGiftSeatCell: UICollectionViewCell {
  var tapAction: ((Int) -> Void)?
  public var index: Int = 0

  override public init(frame: CGRect) {
    super.init(frame: frame)

    addSubview(icon)
    addSubview(nameLabel)

    icon.snp.makeConstraints { make in
      make.width.height.equalTo(30)
      make.centerX.equalToSuperview()
    }

    nameLabel.snp.makeConstraints { make in
      make.left.right.equalToSuperview()
      make.top.equalTo(icon.snp.bottom).offset(4)
    }

    let gesture = UITapGestureRecognizer(target: self, action: #selector(tap))
    contentView.addGestureRecognizer(gesture)
  }

  @objc func tap() {
    tapAction?(index)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public var isCustomSelected: Bool = false {
    didSet {
      icon.layer.borderWidth = isCustomSelected ? 1 : 0
      nameLabel.textColor = isCustomSelected ? blue : UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
    }
  }

  lazy var icon: UIImageView = {
    let view = UIImageView()
    view.layer.cornerRadius = 15
    view.clipsToBounds = true
    view.layer.borderColor = blue.cgColor
    return view
  }()

  lazy var nameLabel: UILabel = {
    var view = UILabel()
    view.frame = CGRect(x: 0, y: 0, width: 20, height: 12)
    view.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
    view.font = UIFont(name: "PingFangSC-Regular", size: 10)
    view.textAlignment = .center
    return view
  }()

  weak var seatModel: NEVRBaseSeatCellModel?

  func setup(model: NEVRBaseSeatCellModel, index: Int) {
    self.index = index
    seatModel = model

    if model.state == .taken,
       let str = model.iconUrl,
       let url = URL(string: str) {
      icon.sd_setImage(with: url, placeholderImage: NEVRBaseBundle.loadImage("seat_empty"))
    } else {
      icon.image = NEVRBaseBundle.loadImage("seat_empty")
    }
    nameLabel.text = String(model.seatIndex ?? 0)
    if model.seatIndex == 1 {
      nameLabel.text = NEVRBaseBundle.localized("Host")
    }
  }
}

var giftViewController: NEVRBaseGiftViewController?

@objcMembers public class NEVRBaseGiftViewController: UIViewController {
  var action: ((NESocialGiftModel, Int, [NEVRBaseSeatCellModel]) -> Void)?
  var seats: [NEVRBaseSeatCellModel] = []

  var selectedSeats: [Int] = [0]
  var selectedGift: Int = 0

  public static func show(viewController: UIViewController, seats: [NEVRBaseSeatCellModel], action: ((NESocialGiftModel, Int, [NEVRBaseSeatCellModel]) -> Void)?) {
    if giftViewController == nil {
      giftViewController = NEVRBaseGiftViewController()
    }
    giftViewController?.action = action
    giftViewController?.seats = seats
    giftViewController?.seats.forEach { model in
      /// model的属性发生了变化，刷新单个cell
      model.propertyChanged.append {
        if let row = giftViewController?.seats.firstIndex(of: model) {
          if model.state != .taken {
            giftViewController?.selectedSeats.removeAll(where: { $0 == row })
          }
          UIView.performWithoutAnimation {
            giftViewController?.seatsCollectionView.reloadItems(at: [IndexPath(row: row, section: 0)])
          }
        }
      }
    }
    giftViewController?.selectCount = 1
    giftViewController?.selectedGift = 0
    if let giftViewController = giftViewController {
      giftViewController.reload()
      let actionSheet = NEActionSheetController(rootViewController: giftViewController)
      actionSheet.dismissOnTouchOutside = true
      viewController.present(actionSheet, animated: true)
    }
  }

  public static func destroy() {
    giftViewController = nil
  }

  override public func viewDidLoad() {
    super.viewDidLoad()
    title = NESocialBundle.localized("Gift")

    view.backgroundColor = .white
    view.addSubview(bottomSendGiftView)
    view.addSubview(collectionView)
    view.addSubview(sendLabel)
    view.addSubview(seatsCollectionView)

    let line = UIView()
    line.backgroundColor = UIColor(red: 0.892, green: 0.892, blue: 0.892, alpha: 1)
    view.addSubview(line)

    bottomSendGiftView.snp.makeConstraints { make in
      if #available(iOS 11.0, *) {
        make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-10)
      } else {
        make.bottom.equalToSuperview().offset(-10)
      }
      make.right.equalToSuperview().offset(-12)
      make.height.equalTo(32)
      make.width.equalTo(140)
    }

    collectionView.snp.makeConstraints { make in
      make.left.right.equalToSuperview()
      make.bottom.equalTo(bottomSendGiftView.snp.top).offset(-16)
      make.height.equalTo(136)
    }

    sendLabel.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(6)
      make.top.equalToSuperview().offset(24)
    }

    seatsCollectionView.snp.makeConstraints { make in
      make.left.equalTo(sendLabel.snp.right).offset(9)
      make.right.equalToSuperview()
      make.top.equalToSuperview().offset(16)
      make.height.equalTo(47)
    }

    line.snp.makeConstraints { make in
      make.left.right.equalToSuperview()
      make.height.equalTo(0.5)
      make.bottom.equalTo(bottomSendGiftView.snp.top).offset(-10)
    }
  }

  override public func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    seatsCollectionView.reloadData()
    collectionView.reloadData()
  }

  lazy var collectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.itemSize = NEVRBaseGiftCell.size()
    layout.scrollDirection = .horizontal
    layout.minimumInteritemSpacing = 5
    layout.minimumLineSpacing = 5

    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    collectionView.backgroundColor = .clear
    collectionView.dataSource = self
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.isScrollEnabled = false
    collectionView.register(NEVRBaseGiftCell.self, forCellWithReuseIdentifier: NSStringFromClass(NEVRBaseGiftCell.self))
    collectionView.allowsMultipleSelection = false
    return collectionView
  }()

  lazy var bottomSendGiftView: UIView = {
    let view = UIView(frame: CGRect(x: 0, y: 200, width: 140, height: 32))
    view.backgroundColor = UIColor(hexString: "#EDEFF2")
    view.layer.cornerRadius = 14
    view.clipsToBounds = true
    view.addSubview(bottomSendGiftButton)
    view.addSubview(bottomGiftCountButton)
    bottomSendGiftButton.snp.makeConstraints { make in
      make.top.equalToSuperview().offset(1)
      make.bottom.equalToSuperview().offset(-1)
      make.right.equalToSuperview().offset(-1)
      make.width.equalTo(60)
    }
    bottomGiftCountButton.snp.makeConstraints { make in
      make.left.equalToSuperview()
      make.right.equalTo(bottomSendGiftButton.snp.left)
      make.top.bottom.equalToSuperview()
    }
    return view
  }()

  func sendGift() {
    if selectedSeats.isEmpty {
      return
    }
    action?(dataSource[selectedGift], selectCount, selectedSeats.map { index in
      seats[index]
    })
    navigationController?.dismiss(animated: true)
  }

  lazy var bottomSendGiftButton: UIButton = {
    let view = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 30))
    view.setTitle(NESocialBundle.localized("Gift_Send"), for: .normal)
    view.setTitleColor(UIColor.white, for: .normal)
    view.clipsToBounds = true
    view.layer.cornerRadius = 14
    view.backgroundColor = blue
    view.setTitleColor(UIColor(white: 1, alpha: 0.5), for: .disabled)
    view.addTarget(self, action: #selector(sendGift), for: .touchUpInside)
    return view
  }()

  lazy var bottomGiftCountButton: UIButton = {
    let view = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 30))
    view.setTitle("1", for: .normal)
    view.setTitleColor(UIColor(hexString: "#333333"), for: .normal)
    view.setImage(NESocialBundle.loadImage("gift_up"), for: .normal)
    view.setImage(NESocialBundle.loadImage("gift_down"), for: .selected)
    view.addTarget(self, action: #selector(selectGiftCount(sender:)), for: .touchUpInside)
    view.imageEdgeInsets = UIEdgeInsets(top: 0, left: -6, bottom: 0, right: 6)
    view.titleEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: -6)
    return view
  }()

  lazy var sendLabel: UILabel = {
    var view = UILabel()
    view.frame = CGRect(x: 0, y: 0, width: 20, height: 12)
    view.textColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1)
    view.font = UIFont(name: "PingFangSC-Regular", size: 10)
    view.text = NEVRBaseBundle.localized("Send_To")
    return view
  }()

  lazy var seatsCollectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.itemSize = CGSize(width: 40, height: 47)
    layout.scrollDirection = .horizontal
    layout.minimumInteritemSpacing = 3
    layout.minimumLineSpacing = 3

    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    collectionView.backgroundColor = .clear
    collectionView.dataSource = self
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.isScrollEnabled = true
    collectionView.register(NEVRBaseGiftSeatCell.self, forCellWithReuseIdentifier: NSStringFromClass(NEVRBaseGiftSeatCell.self))
    collectionView.allowsMultipleSelection = false
    return collectionView
  }()

  func selectGiftCount(sender: UIButton) {
    sender.isSelected = !sender.isSelected
    if sender.isSelected {
      // 弹出popup
      popover.show(popoverView, fromView: bottomSendGiftView)
    } else {
      // 收回popup
      popover.dismiss()
    }
  }

  lazy var popover: Popover = {
    let options = [
      .blackOverlayColor(.clear),
      .cornerRadius(4),
      .dismissOnBlackOverlayTap(true),
      .type(.up),
      .animationIn(0.5),
      .arrowSize(CGSize.zero),
      .color(.clear),
    ] as [PopoverOption]
    let popover = Popover(options: options)
    popover.willDismissHandler = { [weak self] in
      self?.bottomGiftCountButton.isSelected = false
    }
    return popover
  }()

  lazy var popoverView: UIView = {
    let view = UIView(frame: CGRect(x: 0, y: 0, width: 140, height: 250))
    view.backgroundColor = .clear
    let backImage = UIImageView(image: NESocialBundle.loadImage("gift_back"))
    view.addSubview(backImage)
    view.addSubview(tableView)

    backImage.snp.makeConstraints { make in
      make.top.left.width.equalToSuperview()
      make.bottom.equalToSuperview().offset(20)
    }
    tableView.snp.makeConstraints { make in
      make.width.equalTo(100)
      make.centerY.centerX.equalToSuperview()
      make.height.equalTo(giftCounts.count * 35)
    }
    return view
  }()

  lazy var tableView: UITableView = {
    let giftTableView = UITableView(frame: CGRect(x: 0, y: 0, width: 120, height: 232))
    giftTableView.backgroundColor = .white
    giftTableView.separatorStyle = .none
    giftTableView.delegate = self
    giftTableView.dataSource = self
    giftTableView.allowsMultipleSelection = false
    giftTableView.isScrollEnabled = false
    giftTableView.register(NEVRBaseGiftCountCell.self, forCellReuseIdentifier: NSStringFromClass(NEVRBaseGiftCountCell.self))
    return giftTableView
  }()

  var giftCounts = [1314, 520, 66, 20, 6, 1]
  var selectCount = 1

  lazy var dataSource: [NESocialGiftModel] = NESocialGiftModel.defaultGifts()

  func reload() {
    tableView.reloadData()
    collectionView.reloadData()
    seatsCollectionView.reloadData()
    bottomGiftCountButton.setTitle(String(giftCounts.last ?? 1), for: .normal)
  }

  override public var preferredContentSize: CGSize {
    get {
      var total: CGFloat = 245
      if #available(iOS 11.0, *) {
        total += UIApplication.shared.keyWindow?.rootViewController?.view.safeAreaInsets.bottom ?? 0
      }
      return CGSize(width: UIScreen.main.bounds.width, height: total)
    }
    set {
      super.preferredContentSize = newValue
    }
  }
}

extension NEVRBaseGiftViewController: UICollectionViewDelegate {
  public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    if collectionView == self.collectionView {
      if dataSource.count > indexPath.row {
        bottomSendGiftButton.isEnabled = true
      }
      collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .top)
    } else if collectionView == seatsCollectionView {
      let seat = seats[indexPath.row]
      if seat.state != .taken {
        collectionView.deselectItem(at: indexPath, animated: false)
      }
    }
  }
}

extension NEVRBaseGiftViewController: UICollectionViewDataSource {
  public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if collectionView == self.collectionView {
      return dataSource.count
    } else if collectionView == seatsCollectionView {
      return seats.count
    }
    return 0
  }

  public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    if collectionView == self.collectionView {
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(NEVRBaseGiftCell.self), for: indexPath)
      if dataSource.count > indexPath.row,
         let cell = cell as? NEVRBaseGiftCell {
        let gift = dataSource[indexPath.row]
        cell.setup(item: gift, index: indexPath.row)
        cell.isCustomSelected = indexPath.row == selectedGift
        cell.tapAction = { [weak self] index in
          if !cell.isCustomSelected {
            self?.selectedGift = index
            self?.collectionView.reloadData()
          }
        }
      }
      return cell
    } else if collectionView == seatsCollectionView {
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(NEVRBaseGiftSeatCell.self), for: indexPath)
      if seats.count > indexPath.row,
         let cell = cell as? NEVRBaseGiftSeatCell {
        let seat = seats[indexPath.row]
        cell.setup(model: seat, index: indexPath.row)
        cell.isCustomSelected = selectedSeats.contains(indexPath.row)
        cell.tapAction = { [weak self] index in
          if self?.seats[index].state == .taken {
            if let isContains = self?.selectedSeats.contains(index),
               isContains {
              self?.selectedSeats.removeAll(where: { $0 == index })
            } else {
              self?.selectedSeats.append(index)
            }
            self?.seatsCollectionView.reloadData()
          }
        }
      }
      return cell
    }
    return UICollectionViewCell()
  }
}

extension NEVRBaseGiftViewController: UITableViewDelegate {
  public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    bottomGiftCountButton.setTitle(String(giftCounts[indexPath.row]), for: .normal)
    selectCount = giftCounts[indexPath.row]
    tableView.reloadData()
    popover.dismiss()
  }
}

extension NEVRBaseGiftViewController: UITableViewDataSource {
  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let isSelected = giftCounts[indexPath.row] == selectCount
    if let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(NEVRBaseGiftCountCell.self)) as? NEVRBaseGiftCountCell {
      cell.contentLabel.text = String(giftCounts[indexPath.row])
      cell.isCustomSelected = isSelected
      return cell
    } else {
      let cell = NEVRBaseGiftCountCell(style: .default, reuseIdentifier: NSStringFromClass(NEVRBaseGiftCountCell.self))
      cell.contentLabel.text = String(giftCounts[indexPath.row])
      cell.isCustomSelected = isSelected
      return cell
    }
  }

  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    giftCounts.count
  }

  public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    35
  }
}
