// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import UIKit

@objcMembers public class NESocialRoomListEmptyView: UIView {
  override public init(frame: CGRect) {
    let rect = CGRect(x: frame.origin.x, y: frame.origin.y, width: 150, height: 156)
    super.init(frame: rect)
    addSubviews()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func addSubviews() {
    addSubview(imgView)
    addSubview(tipLabel)

    imgView.snp.makeConstraints { make in
      make.size.equalTo(CGSize(width: 165.5, height: 123))
      make.centerX.top.equalToSuperview()
    }

    tipLabel.snp.makeConstraints { make in
      make.size.equalTo(CGSize(width: 200, height: 44))
      make.centerX.equalToSuperview()
      make.top.equalTo(imgView.snp.bottom).offset(10)
    }
  }

  lazy var imgView: UIImageView = {
    let view = UIImageView()
    view.image = NESocialBundle.loadImage("empty_ico")
    return view
  }()

  lazy var tipLabel: UILabel = {
    let view = UILabel()
    view.font = UIFont.systemFont(ofSize: 13)
    view.textColor = UIColor(hexString: "#999999")
    view.textAlignment = .center
    view.text = NESocialBundle.localized("Room_List_Empty")
    view.numberOfLines = 0
    return view
  }()
}
