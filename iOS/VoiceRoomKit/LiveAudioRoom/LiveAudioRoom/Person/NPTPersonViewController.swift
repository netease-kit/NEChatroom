// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import UIKit
import SnapKit
import NERoomKit
import IHProgressHUD
import SDWebImage
import NEVoiceRoomUIKit

class NPTSettingItem: NSObject {
  var icon: UIImage?
  var title: String

  init(icon: UIImage?, title: String) {
    self.icon = icon
    self.title = title
  }
}

class NPTPersonViewController: UIViewController {
  // 先隐藏美颜设置
  let icons = ["setting_normal"]
  let titles = ["Setting_Normal".localized]
  var items: [NPTSettingItem] = []

  // 两个回调的结果同时满足
  var probeCompleted = (quality: false, result: false)
  var probeContent: (quality: String?, result: String?)

  override func viewDidLoad() {
    super.viewDidLoad()

    if #available(iOS 13.0, *) {
      let appearance = UINavigationBarAppearance()
      appearance.backgroundColor = .white
      navigationController?.navigationBar.scrollEdgeAppearance = appearance
      navigationController?.navigationBar.standardAppearance = appearance
      navigationController?.navigationBar.tintColor = .black
    } else {
      navigationController?.navigationBar.tintColor = .black
      navigationController?.navigationBar.barTintColor = .white
      navigationController?.navigationBar.isTranslucent = false
    }

    for index in 0 ..< icons.count {
      let item = NPTSettingItem(icon: UIImage(named: icons[index]), title: titles[index])
      items.append(item)
    }

    view.backgroundColor = .white
    navigationController?.delegate = self

    // HUD消失的时候把事件监听移除，避免网络探测中途退出的影响
    NotificationCenter.default.addObserver(forName: NotificationName.IHProgressHUDWillDisappear.getNotificationName(), object: nil, queue: nil) { _ in
      NotificationCenter.default.removeObserver(self)
    }
    NotificationCenter.default.addObserver(forName: NSNotification.Name("Logined"), object: nil, queue: nil) { notification in
      if let userInfo = notification.userInfo,
         let nickname = userInfo["nickname"] as? String,
         let avatar = userInfo["avatar"] as? String {
        self.updateUserInfo(nickname: nickname, avatar: avatar)
      }
    }

    let headerView = UIView()
    headerView.addSubview(backgroudImage)
    headerView.addSubview(iconImage)
    headerView.addSubview(nameLabel)
    view.addSubview(headerView)
    view.addSubview(tableView)

    headerView.snp.makeConstraints { make in
      make.top.left.right.equalTo(view)
      make.height.equalTo(230)
    }

    backgroudImage.snp.makeConstraints { make in
      make.top.left.right.equalTo(headerView)
      make.height.equalTo(140)
    }

    iconImage.snp.makeConstraints { make in
      make.width.height.equalTo(60)
      make.top.equalTo(backgroudImage.snp.bottom).offset(-30)
      make.left.equalTo(headerView).offset(26)
    }

    nameLabel.snp.makeConstraints { make in
      make.left.equalTo(headerView).offset(14)
      make.top.equalTo(iconImage.snp.bottom).offset(12)
      make.right.bottom.equalTo(headerView)
    }

    tableView.snp.makeConstraints { make in
      make.top.equalTo(headerView.snp.bottom).offset(30)
      make.left.right.equalTo(view)
      if #available(iOS 11.0, *) {
        make.bottom.equalTo(view.safeAreaLayoutGuide)
      } else {
        make.bottom.equalTo(view)
      }
    }
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    updateUserInfo(nickname: userName, avatar: icon)
  }

  func updateUserInfo(nickname: String?, avatar: String?) {
    if let nickname = nickname {
      userName = nickname
      nameLabel.text = nickname
    }
    if let avatar = avatar,
       let url = URL(string: avatar) {
      iconImage.sd_setImage(with: url, placeholderImage: UIImage(named: "default_icon"), context: nil)
    }
  }

  lazy var iconImage: UIImageView = {
    let image = UIImageView(image: UIImage(named: "default_icon"))
    image.clipsToBounds = true
    image.layer.borderWidth = 1.0
    image.layer.cornerRadius = 30
    image.layer.borderColor = UIColor.white.cgColor
    return image
  }()

  lazy var nameLabel: UILabel = {
    let label = UILabel()
    label.textColor = UIColor.partyBlack
    label.font = UIFont(name: "PingFangSC-Medium", size: 22)
    label.text = "Nicaldai"
    label.accessibilityIdentifier = "party.NPTPersonViewController.nameLabel"
    return label
  }()

  lazy var backgroudImage: UIImageView = {
    let image = UIImageView(image: UIImage(named: "my_background"))
    return image
  }()

  lazy var tableView: UITableView = {
    let view = UITableView()
    view.delegate = self
    view.dataSource = self
    return view
  }()

  @objc func tapHUD() {
    IHProgressHUD.dismiss()
  }

  deinit {
    IHProgressHUD.dismiss()
  }
}

extension NPTPersonViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: false)

    let icon = icons[indexPath.row]
    switch icon {
    case "setting_normal":
      let vc = NPTNormalSettingViewController()
      vc.hidesBottomBarWhenPushed = true
      navigationController?.pushViewController(vc, animated: true)
    default: break
    }
  }
}

extension NPTPersonViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    var cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier")
    if cell == nil {
      cell = UITableViewCell(style: .default, reuseIdentifier: "CellIdentifier")
    }
    if let cell = cell {
      let item = items[indexPath.row]
      cell.textLabel?.text = item.title
      cell.textLabel?.textColor = UIColor.partyBlack
      cell.imageView?.image = item.icon
      cell.accessoryType = .disclosureIndicator
      cell.accessoryView = nil
    }
    return cell ?? UITableViewCell()
  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    52
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    items.count
  }

  func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    UIView()
  }
}

extension NPTPersonViewController: UINavigationControllerDelegate {
  /// 处理右滑手势到一半就取消的场景，didshow与willshow都要处理

  func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
    // 隐藏导航栏，语聊房的小窗可能会从这里push
    let shouldHidden = viewController.isKind(of: NPTPersonViewController.self) || viewController.isKind(of: NEVoiceRoomViewController.self)
    navigationController.setNavigationBarHidden(shouldHidden, animated: false)
  }

  func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
    // 隐藏导航栏，语聊房的小窗可能会从这里push
    let shouldHidden = viewController.isKind(of: NPTPersonViewController.self) || viewController.isKind(of: NEVoiceRoomViewController.self)
    navigationController.setNavigationBarHidden(shouldHidden, animated: true)
  }
}
