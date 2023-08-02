// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import UIKit
import SnapKit
import LottieSwift
import NEVoiceRoomUIKit
import NECoreKit

class NPTHomeCell: UITableViewCell {
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    contentView.backgroundColor = .clear
    contentView.addSubview(backgroundImage)
    backgroundImage.addSubview(lottieView)
    backgroundImage.addSubview(typeLabel)
    backgroundImage.addSubview(descriptionLabel)

    backgroundImage.snp.makeConstraints { make in
      make.top.bottom.equalTo(contentView)
      make.left.equalTo(contentView).offset(20)
      make.right.equalTo(contentView).offset(-20)
    }

    lottieView.snp.makeConstraints { make in
      make.left.top.right.bottom.equalToSuperview()
    }

    typeLabel.snp.makeConstraints { make in
      make.left.equalTo(backgroundImage).offset(20)
      make.top.equalTo(backgroundImage).offset(30)
      make.right.equalTo(backgroundImage)
      make.height.equalTo(30)
    }

    descriptionLabel.snp.makeConstraints { make in
      make.left.equalTo(backgroundImage).offset(20)
      make.top.equalTo(typeLabel.snp.bottom).offset(4)
      make.width.equalTo(150)
      make.bottom.equalToSuperview()
    }
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  lazy var backgroundImage: UIImageView = {
    let image = UIImageView(image: UIImage(named: "home_blue"))
    return image
  }()

  lazy var lottieView: LottieAnimationView = {
    let lottie = LottieAnimationView(name: "oneOnOne")
    lottie.loopMode = .loop
    return lottie
  }()

  lazy var typeLabel: UILabel = {
    var view = UILabel()
    view.textColor = .white
    view.font = UIFont(name: "PingFangSC-Medium", size: 18)
    return view
  }()

  lazy var descriptionLabel: UITextView = {
    var view = UITextView()
    view.backgroundColor = .clear
    view.textColor = .white
    view.font = UIFont(name: "PingFangSC-Regular", size: 14)
    return view
  }()
}

class NPTHomeViewController: UIViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.

    navigationItem.leftBarButtonItem = leftBarButtonItem
    navigationItem.rightBarButtonItem = rightBarButtonItem

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

    view.addSubview(tableView)
  }

  lazy var leftBarButtonItem: UIBarButtonItem = {
    let item = UIBarButtonItem()
    let image = UIImageView()
    image.image = UIDevice.isChinese ? UIImage(named: "yunxin") : UIImage(named: "yunxin_en")
    item.customView = image
    return item
  }()

  lazy var rightBarButtonItem: UIBarButtonItem = {
    let item = UIBarButtonItem()
    let btn = UIButton()
    btn.setTitle("Feedback".localized, for: .normal)
    btn.setTitleColor(UIColor.partyBlack, for: .normal)
    btn.titleLabel?.font = UIFont(name: "PingFangSC-Medium", size: 17)
    btn.addTarget(self, action: #selector(feedback), for: .touchUpInside)
    item.customView = btn
    return item
  }()

  @objc func feedback() {
    let viewController = NPTFeedbackViewController()
    viewController.hidesBottomBarWhenPushed = true
    navigationController?.pushViewController(viewController, animated: true)
  }

  lazy var tableView: UITableView = {
    let view = UITableView(frame: view.bounds, style: .grouped)
    view.delegate = self
    view.dataSource = self
    view.register(NPTHomeCell.self, forCellReuseIdentifier: "NPTHomeCellIdentifier")
    view.backgroundColor = .white
    view.separatorStyle = .none
    return view
  }()
}

extension NPTHomeViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: false)
    if let delegate = UIApplication.shared.delegate as? AppDelegate {
      if !delegate.checkNetwork() {
        return
      }
    }

    if indexPath.section == 0 {
      let vc = NEChatRoomListViewController()
      vc.hidesBottomBarWhenPushed = true
      navigationController?.pushViewController(vc, animated: true)
    }
  }
}

extension NPTHomeViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    UIView()
  }

  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    6
  }

  func numberOfSections(in tableView: UITableView) -> Int {
    1
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    1
  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    190
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if let cell = tableView.dequeueReusableCell(withIdentifier: "NPTHomeCellIdentifier") as? NPTHomeCell {
      cell.selectionStyle = .none
      if indexPath.section == 0 {
        cell.backgroundImage.image = UIImage(named: "home_green")
        cell.lottieView.animation = LottieAnimation.named("voiceRoom")
        cell.typeLabel.text = "Voice_Room".localized
        cell.descriptionLabel.text = "Voice_Room_Description".localized
        cell.lottieView.play()
      }
      return cell
    }
    return UITableViewCell()
  }
}
