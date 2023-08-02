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
  let icons = ["setting_nickname", "setting_network", "setting_beauty", "setting_data", "setting_call", "setting_ai", "setting_normal"]
  let titles = ["Setting_Nickname".localized, "Setting_Network".localized, "Setting_Beauty".localized, "Setting_Data".localized, "Setting_Call".localized, "Setting_AI".localized, "Setting_Normal".localized]
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
    updateUserInfo(nickname: nickName, avatar: avatar)
  }

  func updateUserInfo(nickname: String?, avatar: String?) {
    if let nickname = nickname {
      nickName = nickname
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

  lazy var configView: UIView = {
    let view = UIView(frame: CGRect(x: 0, y: 0, width: 180, height: 20))
    view.addSubview(configChina)
    view.addSubview(configOthers)
    return view
  }()

  lazy var configChina: NPTCheckBox = {
    var china: NPTCheckBox
    if let checkImage = UIImage(named: "setting_checked"),
       let uncheckImage = UIImage(named: "setting_uncheck") {
      china = NPTCheckBox(frame: CGRect(x: 0, y: 0, width: 90, height: 20), title: "China_Config".localized, checkImage: checkImage, uncheckImage: uncheckImage)
    } else {
      china = NPTCheckBox(frame: CGRect(x: 0, y: 0, width: 90, height: 20), title: "China_Config".localized)
    }
    china.isSelected = true
    china.addTarget(self, action: #selector(switchConfig(checkBox:)), for: .touchUpInside)
    china.accessibilityIdentifier = "party.NPTPersonViewController.configChina"
    return china
  }()

  lazy var configOthers: NPTCheckBox = {
    var others: NPTCheckBox
    if let checkImage = UIImage(named: "setting_checked"),
       let uncheckImage = UIImage(named: "setting_uncheck") {
      others = NPTCheckBox(frame: CGRect(x: 90, y: 0, width: 90, height: 20), title: "Others_Config".localized, checkImage: checkImage, uncheckImage: uncheckImage)
    } else {
      others = NPTCheckBox(frame: CGRect(x: 90, y: 0, width: 90, height: 20), title: "Others_Config".localized)
    }
    others.isSelected = false
    others.addTarget(self, action: #selector(switchConfig(checkBox:)), for: .touchUpInside)
    others.accessibilityIdentifier = "party.NPTPersonViewController.configOthers"
    return others
  }()

  @objc func switchConfig(checkBox: NPTCheckBox) {
    if checkBox.isSelected {
      return
    }
    let alert = UIAlertController(title: "Confirm_Switch_Config".localized, message: "Need_Relogin".localized, preferredStyle: .alert)
    alert.view.accessibilityIdentifier = "party.NPTPersonViewController.switchConfig"
    let cancelAction = UIAlertAction(title: "No".localized, style: .cancel)
    cancelAction.accessibilityIdentifier = "party.NPTPersonViewController.switchConfig.NO"
    alert.addAction(cancelAction)
    let comfirmAction = UIAlertAction(title: "Yes".localized, style: .default, handler: { action in
      DispatchQueue.main.async {
        checkBox.isSelected = !checkBox.isSelected
        if checkBox.isSelected {
          if checkBox == self.configChina {
            Configs.config = .online
            self.configOthers.isSelected = false
          } else {
            Configs.config = .worldwide
            self.configChina.isSelected = false
          }
          DispatchQueue.main.async {
            exit(0)
          }
        }
      }
    })
    comfirmAction.accessibilityIdentifier = "party.NPTPersonViewController.switchConfig.YES"
    alert.addAction(comfirmAction)
    present(alert, animated: true)
  }

  @objc func tapHUD() {
    IHProgressHUD.dismiss()
  }

  deinit {
    IHProgressHUD.dismiss()
  }
}

extension NPTPersonViewController: UITableViewDelegate {
  func probeNet(context: NEPreviewRoomContext) {
    context.addPreviewRoomListener(listener: self)
    let ret = context.previewController.startLastmileProbeTest(config: nil)
    if ret == 0 {
      DispatchQueue.main.async {
        // 检测网络中可以点击强制返回
        NotificationCenter.default.addObserver(self, selector: #selector(self.tapHUD), name: NotificationName.IHProgressHUDDidReceiveTouchEvent.getNotificationName(), object: nil)
        IHProgressHUD.show(withStatus: "Probing".localized)
      }
    } else {
      DispatchQueue.main.async {
        context.removePreviewRoomListener(listener: self)
        IHProgressHUD.showError(withStatus: "Probe_Failed".localized)
      }
    }
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: false)

    let icon = icons[indexPath.row]
    switch icon {
    case "setting_nickname":
      let vc = NPTNicknameSettingViewController()
      vc.hidesBottomBarWhenPushed = true
      navigationController?.pushViewController(vc, animated: true)
    case "setting_network":
      probeCompleted = (false, false)
      NERoomKit.shared().roomService.previewRoom { code, msg, context in
        if let context = context {
          self.probeNet(context: context)
        }
      }
    case "setting_beauty":
      if let _ = NEVoiceRoomKit.getInstance().getCurrentRoomInfo() {
        // 当前在语聊房小窗里
        IHProgressHUD.showError(withStatus: "Beauty_Error".localized)
        return
      }
      let vc = NPTBeautySettingsViewController()
      vc.hidesBottomBarWhenPushed = true
      navigationController?.pushViewController(vc, animated: true)
    case "setting_data": break
    case "setting_call":
      let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
      sheet.addAction(UIAlertAction(title: "4009-000-123", style: .default, handler: { action in
        if let number = URL(string: "tel://4009-000-123") {
          UIApplication.shared.open(number)
        }
      }))
      sheet.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel))
      present(sheet, animated: true)
    case "setting_ai":
      let vc = NPTAIGCViewController()
      vc.hidesBottomBarWhenPushed = true
      navigationController?.pushViewController(vc, animated: true)
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
      if item.title == "Setting_Data".localized {
        cell.accessoryType = .none
        cell.accessoryView = configView
        if Configs.config == .worldwide {
          configOthers.isSelected = true
          configChina.isSelected = false
        } else {
          configOthers.isSelected = false
          configChina.isSelected = true
        }
      } else {
        cell.accessoryType = .disclosureIndicator
        cell.accessoryView = nil
      }
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

extension NPTPersonViewController: NEPreviewRoomListener {
  func onRtcLastmileQuality(_ quality: NERoomRtcNetworkStatusType) {
    probeCompleted.quality = true
    var netQuality: String?
    switch quality {
    case .unknown:
      netQuality = "Net_Unknown".localized
    case .excellent:
      netQuality = "Net_Excellent".localized
    case .good:
      netQuality = "Net_Good".localized
    case .poor:
      netQuality = "Net_Poor".localized
    case .bad:
      netQuality = "Net_Bad".localized
    case .veryBad:
      netQuality = "Net_Very_Bad".localized
    case .down:
      netQuality = "Net_Down".localized
    default:
      netQuality = "Net_Unknown".localized
    }
    if let netQuality = netQuality {
      probeContent.quality = "Net_Quality".localized + netQuality
      showDetailView()
    }
  }

  func onRtcLastmileProbeResult(_ result: NERoomRtcLastmileProbeResult) {
    probeCompleted.result = true
    var probeResult = "Net_Probe".localized
    switch result.state {
    case .complete:
      probeResult += "Net_Probe_Complete".localized
    case .incompleteNoBwe:
      probeResult += "Net_Probe_No_Bwe".localized
    case .unavailable:
      probeResult += "Net_Probe_Unavailable".localized
    default:
      probeResult += "Net_Probe_Unavailable".localized
    }

    probeResult = probeResult + "\n" + "Net_RTT".localized
    probeResult += String(result.rtt)
    probeResult += "ms"
    probeResult = probeResult + "\n" + "Net_Up_Packet_Lose_Rate".localized
    probeResult += String(result.uplinkReport.packetLossRate)
    probeResult += "%"
    probeResult = probeResult + "\n" + "Net_Up_Jitter".localized
    probeResult += String(result.uplinkReport.jitter)
    probeResult += "ms"
    probeResult = probeResult + "\n" + "Net_Up_Available_Band_Width".localized
    probeResult += String(result.uplinkReport.availableBandwidth / 1000)
    probeResult += "Kbps"
    probeResult = probeResult + "\n" + "Net_Down_Packet_Lose_Rate".localized
    probeResult += String(result.downlinkReport.packetLossRate)
    probeResult += "%"
    probeResult = probeResult + "\n" + "Net_Down_Jitter".localized
    probeResult += String(result.downlinkReport.jitter)
    probeResult += "ms"
    probeResult = probeResult + "\n" + "Net_Down_Available_Band_Width".localized
    probeResult += String(result.downlinkReport.availableBandwidth / 1000)
    probeResult += "Kbps"

    probeContent.result = probeResult
    showDetailView()
  }

  func showDetailView() {
    if probeCompleted.quality,
       probeCompleted.result,
       let quality = probeContent.quality,
       let result = probeContent.result {
      DispatchQueue.main.async {
        if let context = NERoomKit.shared().roomService.getPreviewRoomContext() {
          context.removePreviewRoomListener(listener: self)
        }
        IHProgressHUD.dismiss()

        let view = NPTNetworkDetailView(frame: self.view.bounds)
        view.load(content: quality + "\n" + result)
        view.show()
      }
    }
  }
}
