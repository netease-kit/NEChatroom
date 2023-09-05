// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import UIKit
import NIMSDK
import SnapKit

protocol NPTBlackListCellDelegate: NSObjectProtocol {
  func removeButtonClick(user: NIMUser?)
}

class NPTBlackListCell: UITableViewCell {
  weak var delegate: NPTBlackListCellDelegate?
  var user: NIMUser?

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    contentView.addSubview(avatarImage)
    contentView.addSubview(nameLabel)
    contentView.addSubview(removeButton)

    avatarImage.snp.makeConstraints { make in
      make.width.height.equalTo(40)
      make.left.equalToSuperview().offset(16)
      make.centerY.equalToSuperview()
    }

    removeButton.snp.makeConstraints { make in
      make.width.equalTo(80)
      make.height.equalTo(28)
      make.centerY.equalToSuperview()
      make.right.equalToSuperview().offset(-20)
    }

    nameLabel.snp.makeConstraints { make in
      make.left.equalTo(avatarImage.snp.right).offset(16)
      make.right.equalTo(removeButton.snp.left)
      make.centerY.equalToSuperview()
    }
  }

  func setupCell(user: NIMUser) {
    self.user = user
    if let userId = user.userId,
       let userInfo = NIMSDK.shared().userManager.userInfo(userId)?.userInfo {
      nameLabel.text = userInfo.nickName
      if let avatar = userInfo.avatarUrl,
         let url = URL(string: avatar) {
        avatarImage.sd_setImage(with: url, placeholderImage: UIImage(named: "default_icon"), context: nil)
      }
    }
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  lazy var avatarImage: UIImageView = {
    let image = UIImageView()
    return image
  }()

  lazy var nameLabel: UILabel = {
    var view = UILabel()
    view.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
    view.font = UIFont(name: "PingFangSC-Regular", size: 17)
    return view
  }()

  lazy var removeButton: UIButton = {
    let view = UIButton(frame: CGRect(x: 0, y: 0, width: 80, height: 28))
    view.setTitle("Remove_Black".localized, for: .normal)
    view.setTitleColor(.white, for: .normal)
    view.backgroundColor = UIColor(red: 0.2, green: 0.494, blue: 1, alpha: 1)
    view.layer.cornerRadius = 14
    view.clipsToBounds = true
    view.addTarget(self, action: #selector(removeBlackList), for: .touchUpInside)
    return view
  }()

  @objc func removeBlackList() {
    delegate?.removeButtonClick(user: user)
  }
}

class NPTBlackListEmptyView: UIView {
  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = .clear

    addSubview(imageView)
    addSubview(titleLabel)

    imageView.snp.makeConstraints { make in
      make.width.height.equalTo(150)
      make.centerX.equalToSuperview()
      if #available(iOS 11.0, *) {
        make.top.equalTo(self.safeAreaLayoutGuide).offset(105)
      } else {
        make.top.equalToSuperview().offset(105)
      }
    }

    titleLabel.snp.makeConstraints { make in
      make.width.equalToSuperview()
      make.centerX.equalToSuperview()
      make.top.equalTo(imageView.snp.bottom).offset(27)
    }
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  lazy var imageView: UIImageView = {
    let image = UIImageView(image: UIImage(named: "black_empty"))
    return image
  }()

  lazy var titleLabel: UILabel = {
    var view = UILabel()
    view.textColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
    view.text = "Black_Empty".localized
    view.font = UIFont(name: "PingFangSC-Regular", size: 14)
    view.textAlignment = .center
    return view
  }()
}

class NPTBlackListViewController: UIViewController {
  var dataSource: [NIMUser] = .init()

  override func viewDidLoad() {
    super.viewDidLoad()

    view.addSubview(tableView)
    view.addSubview(emptyView)
    view.backgroundColor = UIColor.partyBackground

    reloadTableView()
  }

  lazy var tableView: UITableView = {
    let view = UITableView(frame: self.view.bounds)
    view.dataSource = self
    view.allowsSelection = false
    view.register(NPTBlackListCell.self, forCellReuseIdentifier: NPTBlackListCell.description())
    view.backgroundColor = UIColor.partyBackground
    return view
  }()

  lazy var emptyView: NPTBlackListEmptyView = {
    let view = NPTBlackListEmptyView(frame: self.view.bounds)
    view.isHidden = true
    return view
  }()

  func reloadTableView() {
    if let blackList = NIMSDK.shared().userManager.myBlackList() {
      dataSource = blackList
      emptyView.isHidden = !blackList.isEmpty
      let users = blackList.compactMap(\.userId)
      NIMSDK.shared().userManager.fetchUserInfos(users) { [weak self] _, _ in
        DispatchQueue.main.async {
          self?.tableView.reloadData()
        }
      }
    } else {
      emptyView.isHidden = false
    }
  }
}

extension NPTBlackListViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let user = dataSource[indexPath.row]
    if let cell = tableView.dequeueReusableCell(withIdentifier: NPTBlackListCell.description()) as? NPTBlackListCell {
      cell.setupCell(user: user)
      cell.delegate = self
      return cell
    }
    return UITableViewCell()
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    dataSource.count
  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    64
  }
}

extension NPTBlackListViewController: NPTBlackListCellDelegate {
  func removeButtonClick(user: NIMUser?) {
    if let user = user,
       let userId = user.userId {
      NIMSDK.shared().userManager.remove(fromBlackBlackList: userId) { [weak self] _ in
        self?.reloadTableView()
      }
    }
  }
}
