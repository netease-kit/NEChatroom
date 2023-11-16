// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import SnapKit
import UIKit

public class NESocialAnnouncementView: UIView {
  override init(frame: CGRect) {
    super.init(frame: frame)

    backgroundColor = UIColor(white: 0, alpha: 0.5)

    addSubview(containerView)
    containerView.addSubview(titleLable)
    containerView.addSubview(contentLabel)
    containerView.addSubview(closeButton)

    containerView.snp.makeConstraints { make in
      make.size.equalTo(CGSizeMake(280, 150))
      make.center.equalToSuperview()
    }

    titleLable.snp.makeConstraints { make in
      make.top.equalTo(containerView).offset(20)
      make.left.equalTo(containerView).offset(20)
    }

    contentLabel.snp.makeConstraints { make in
      make.top.equalTo(titleLable.snp.bottom).offset(16)
      make.left.equalTo(titleLable)
      make.right.equalTo(containerView).offset(-20)
    }

    closeButton.snp.makeConstraints { make in
      make.top.equalTo(containerView).offset(12)
      make.right.equalTo(containerView).offset(-12)
      make.size.equalTo(CGSizeMake(16, 16))
    }
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  lazy var containerView: UIView = {
    let view = UIView()
    view.layer.cornerRadius = 8
    view.backgroundColor = .white
    return view
  }()

  lazy var titleLable: UILabel = {
    let view = UILabel()
    view.text = NESocialBundle.localized("Announcement")
    view.textColor = UIColor(hexString: "#222222")
    view.font = UIFont.systemFont(ofSize: 16)
    return view
  }()

  lazy var contentLabel: UILabel = {
    let view = UILabel()
    view.text = NESocialBundle.localized("Announcement_Content")
    view.textColor = UIColor(hexString: "#222222")
    view.font = UIFont.systemFont(ofSize: 14)
    view.numberOfLines = 0
    return view
  }()

  lazy var closeButton: UIButton = {
    let btn = UIButton()
    btn.setImage(NESocialBundle.loadImage("notice_close"), for: .normal)
    btn.addTarget(self, action: #selector(closeButtonClicked), for: .touchUpInside)
    return btn
  }()

  @objc func closeButtonClicked() {
    isHidden = true
  }
}
