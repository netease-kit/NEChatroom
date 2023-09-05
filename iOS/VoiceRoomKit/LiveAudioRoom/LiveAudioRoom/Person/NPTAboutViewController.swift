// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import UIKit
import SnapKit

class NPTAboutViewController: UIViewController {
  let titles = ["Privacy_Agreement".localized, "Terms_Of_Service".localized, "Version".localized]

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor.partyBackground

    view.addSubview(icon)
    view.addSubview(displayName)
    view.addSubview(tableView)
    view.addSubview(copyright)

    icon.snp.makeConstraints { make in
      make.width.height.equalTo(88)
      make.centerX.equalToSuperview()
      if #available(iOS 11.0, *) {
        make.top.equalTo(view.safeAreaLayoutGuide).offset(48)
      } else {
        make.top.equalTo(view).offset(48)
      }
    }

    displayName.snp.makeConstraints { make in
      make.top.equalTo(icon.snp.bottom).offset(9)
      make.left.right.equalToSuperview()
      make.height.equalTo(50)
    }

    tableView.snp.makeConstraints { make in
      make.top.equalTo(displayName.snp.bottom).offset(48)
      make.left.equalToSuperview().offset(20)
      make.right.equalToSuperview().offset(-20)
      make.height.equalTo(47 * titles.count)
    }

    copyright.snp.makeConstraints { make in
      make.height.equalTo(40)
      make.left.right.equalToSuperview()
      make.bottom.equalTo(view).offset(-48)
    }
  }

  lazy var icon: UIImageView = {
    let view = UIImageView(image: UIImage(named: "about_us"))
    return view
  }()

  lazy var displayName: UILabel = {
    let view = UILabel()
    view.textColor = UIColor(red: 0.133, green: 0.133, blue: 0.133, alpha: 1)
    view.font = UIFont(name: "PingFangSC-Medium", size: 16)
    view.textAlignment = .center
    view.text = "DisplayName".localized
    view.numberOfLines = 0
    view.accessibilityIdentifier = "party.NPTAboutViewController.displayNameLabel"
    return view
  }()

  lazy var tableView: UITableView = {
    let view = UITableView(frame: CGRect.zero, style: .plain)
    view.delegate = self
    view.dataSource = self
    view.isScrollEnabled = false
    view.layer.cornerRadius = 8
    view.clipsToBounds = true
    return view
  }()

  lazy var copyright: UILabel = {
    let view = UILabel()
    view.textColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
    view.font = UIFont(name: "PingFangSC-Regular", size: 12)
    view.numberOfLines = 0
    view.lineBreakMode = .byWordWrapping
    view.textAlignment = .center
    view.text = "Copyright © 2023\("DisplayName".localized)\nAll Rights Reserved"
    return view
  }()

  lazy var versionLabel: UILabel = {
    let versionLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 20))
    versionLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
    versionLabel.font = UIFont(name: "PingFangSC-Regular", size: 16)
    var version = "1.0.0"
    if let projectVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
      version = projectVersion
    }
    versionLabel.text = "v\(version)"
    versionLabel.textAlignment = .right
    versionLabel.accessibilityIdentifier = "party.NPTAboutViewController.versionLabel"
    return versionLabel
  }()
}

extension NPTAboutViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: false)
    let cell = tableView.cellForRow(at: indexPath)
    let title = cell?.textLabel?.text ?? ""
    switch indexPath.row {
    case 0:
      let view = NPTWebViewController()
      view.urlString = Configs.privacyUrl
      view.title = title
      navigationController?.pushViewController(view, animated: true)
    case 1:
      let view = NPTWebViewController()
      view.urlString = Configs.termsUrl
      view.title = title
      navigationController?.pushViewController(view, animated: true)
    default:
      break
    }
  }
}

extension NPTAboutViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    47
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    titles.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    var cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier")
    if cell == nil {
      cell = UITableViewCell(style: .default, reuseIdentifier: "CellIdentifier")
    }
    if let cell = cell {
      cell.textLabel?.text = titles[indexPath.row]
      cell.textLabel?.textColor = UIColor.partyBlack
      cell.textLabel?.accessibilityIdentifier = "party.NPTAboutViewController.versionCellLabel"
      if indexPath.row != 2 {
        cell.accessoryType = .disclosureIndicator
        cell.accessoryView = nil
      } else {
        cell.accessoryType = .none
        cell.accessoryView = versionLabel
      }
    }
    return cell ?? UITableViewCell()
  }
}
