// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import NECommonUIKit
import NEVoiceRoomKit
import SnapKit
import UIKit
import NESocialUIKit

// TODO: 要不要支持动态变化成员列表
class NESocialInviteViewController: UIViewController {
  // 点击的麦位index
  var seatIndex = 0

  init(seatIndex: Int) {
    super.init(nibName: nil, bundle: nil)

    self.seatIndex = seatIndex
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    title = NEVRBaseBundle.localized("Invite_Title")
    view.backgroundColor = .white

    navigationItem.leftBarButtonItem = UIBarButtonItem(title: NEVRBaseBundle.localized("Cancel"), style: .done, target: self, action: #selector(cancel))
    let attributes = [
      NSAttributedString.Key.foregroundColor: UIColor.black,
      NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16),
    ]
    navigationItem.leftBarButtonItem?.setTitleTextAttributes(attributes, for: .normal)

    view.addSubview(tableView)
    view.addSubview(emptyView)

    tableView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }

    emptyView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }

    fetchMembers()
  }

  @objc func cancel() {
    dismiss(animated: true)
  }

  lazy var tableView: UITableView = {
    let view = UITableView()
    view.delegate = self
    view.dataSource = self
    view.rowHeight = 56
    view.backgroundColor = .white
    view.separatorStyle = .none
    view.isHidden = false
    view.tableFooterView = UIView()
    return view
  }()

  lazy var emptyView: UIView = {
    let view = UIView()
    view.isHidden = true
    let imageView = UIImageView(image: NESocialBundle.loadImage("empty_ico"))
    view.addSubview(imageView)
    imageView.snp.makeConstraints { make in
      make.height.equalTo(123)
      make.width.equalTo(166)
      make.center.equalToSuperview()
    }
    let label = UILabel()
    label.text = NEVRBaseBundle.localized("No_Members")
    label.font = UIFont.systemFont(ofSize: 15)
    label.textColor = UIColor(hexString: "#BFBFBF")
    label.textAlignment = .center
    view.addSubview(label)
    label.snp.makeConstraints { make in
      make.left.right.equalToSuperview()
      make.top.equalTo(imageView.snp.bottom).offset(10)
    }
    return view
  }()

  private var members: [NEVoiceRoomMember]?

  // 打开后查询一把未在麦上的观众
  func fetchMembers() {
    NEVoiceRoomKit.getInstance().getSeatInfo { [weak self] code, _, seatInfo in
      if code == 0,
         let seatInfo = seatInfo {
        var tempArr = [NEVoiceRoomMember]()
        NEVoiceRoomKit.getInstance().allMemberList.forEach { member in
          if let _ = seatInfo.seatItems.first(where: { $0.user == member.account && $0.status == .taken }) {
            // 这个member在麦上
          } else {
            // 这个member不在麦上
            tempArr.append(member)
          }
        }
        self?.members = tempArr
        DispatchQueue.main.async {
          self?.tableView.isHidden = tempArr.count == 0
          self?.emptyView.isHidden = tempArr.count != 0
          self?.tableView.reloadData()
        }
      }
    }
  }
}

extension NESocialInviteViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: false)
    if let member = members?[indexPath.row] {
      NEVoiceRoomKit.getInstance().sendSeatInvitation(seatIndex: seatIndex, account: member.account) { [weak self] code, msg, _ in
        if code != 0 {
          self?.showToast(NEVRBaseBundle.localized("Seat_Invite_Failed"))
        }
        DispatchQueue.main.async {
          self?.navigationController?.dismiss(animated: true)
        }
      }
    }
  }
}

extension NESocialInviteViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    members?.count ?? 0
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if let cell = tableView.dequeueReusableCell(withIdentifier: "UserInfoCell") {
      if let member = members?[indexPath.row] {
        cell.textLabel?.text = member.name
        if let avatar = member.avatar {
          cell.imageView?.sd_setImage(with: URL(string: avatar), placeholderImage: NEVRBaseBundle.loadImage("default_user_icon"))
          cell.imageView?.clipsToBounds = true
          cell.imageView?.layer.cornerRadius = 28
        }
      }
      return cell
    } else {
      let cell = UITableViewCell(style: .default, reuseIdentifier: "UserInfoCell")
      if let member = members?[indexPath.row] {
        cell.textLabel?.text = member.name
        if let avatar = member.avatar {
          cell.imageView?.sd_setImage(with: URL(string: avatar), placeholderImage: NEVRBaseBundle.loadImage("default_user_icon"))
          cell.imageView?.clipsToBounds = true
          cell.imageView?.layer.cornerRadius = 28
        }
      }
      return cell
    }
  }
}
