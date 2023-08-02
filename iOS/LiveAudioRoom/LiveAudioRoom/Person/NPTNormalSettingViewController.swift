// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import UIKit
import SnapKit
import WebKit
import NEVoiceRoomUIKit
// import NEListenTogetherUIKit
import NEOrderSong

class NPTNormalSettingViewController: UIViewController {
  let titles = ["Black_List".localized, "About_Us".localized]

  override func viewDidLoad() {
    super.viewDidLoad()

    title = "Setting_Normal".localized
    view.backgroundColor = UIColor.partyBackground

    view.addSubview(tableView)
    tableView.snp.makeConstraints { make in
      if #available(iOS 11.0, *) {
        make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
      } else {
        make.top.equalTo(view).offset(20)
      }
      make.left.equalTo(view).offset(20)
      make.right.equalTo(view).offset(-20)
      make.height.equalTo(47 * titles.count)
    }
  }

  lazy var tableView: UITableView = {
    let view = UITableView(frame: CGRect.zero, style: .plain)
    view.delegate = self
    view.dataSource = self
    view.isScrollEnabled = false
    view.layer.cornerRadius = 8
    view.clipsToBounds = true
    return view
  }()
}

extension NPTNormalSettingViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: false)
    let cell = tableView.cellForRow(at: indexPath)
    let title = cell?.textLabel?.text ?? ""
    switch indexPath.row {
    case 0:
      let view = NPTBlackListViewController()
      view.title = title
      navigationController?.pushViewController(view, animated: true)
    case 1:
      let view = NPTAboutViewController()
      view.title = title
      navigationController?.pushViewController(view, animated: true)
    default:
      break
    }
  }
}

extension NPTNormalSettingViewController: UITableViewDataSource {
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
      cell.accessoryType = .disclosureIndicator
    }
    return cell ?? UITableViewCell()
  }
}
