// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import UIKit
import SnapKit

class NPTNetworkDetailView: UIView {
  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)

    addSubview(bgView)
    addSubview(titleLabel)
    addSubview(textView)
    addSubview(lineView)
    addSubview(confirmButton)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont(name: "PingFangSC-Medium", size: 17)
    label.textColor = UIColor(red: 0.133, green: 0.133, blue: 0.133, alpha: 1)
    label.text = "Net_Status".localized
    label.textAlignment = .center
    return label
  }()

  lazy var bgView: UIView = {
    let view = UIView()
    view.backgroundColor = .white
    view.layer.masksToBounds = true
    view.layer.cornerRadius = 7
    return view
  }()

  lazy var textView: UITextView = {
    let view = UITextView()
    view.textContainerInset = .zero
    view.textColor = UIColor(red: 0.133, green: 0.133, blue: 0.133, alpha: 1)
    view.isEditable = false
    view.isSelectable = false
    view.font = UIFont(name: "PingFangSC-Regular", size: 14)
    return view
  }()

  lazy var confirmButton: UIButton = {
    let btn = UIButton()
    btn.setTitleColor(UIColor(red: 0.2, green: 0.494, blue: 1, alpha: 1), for: .normal)
    btn.setTitle("OK".localized, for: .normal)
    btn.addTarget(self, action: #selector(confirm(btn:)), for: .touchUpInside)
    btn.accessibilityIdentifier = "party.NPTNetworkDetailView.confirmButton"
    return btn
  }()

  lazy var lineView: UIView = {
    let line = UIView()
    line.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
    return line
  }()

  func load(content: String) {
    var contentHeight = calculateHeight(string: content, width: 270, font: UIFont(name: "PingFangSC-Regular", size: 15) ?? UIFont.systemFont(ofSize: 15))
    let screenHeight = UIScreen.main.bounds.size.height
    if contentHeight + 133 > screenHeight / 3 * 2 {
      // 超过
      contentHeight = screenHeight / 3 * 2
    }
    updateViewConstrain(contentHeight: contentHeight)
    textView.text = content
  }

  func calculateHeight(string: String, width: CGFloat, font: UIFont) -> CGFloat {
    if string.count < 1 {
      return 0
    }

    let height = NSString(string: string).boundingRect(with: CGSize(width: width, height: CGFloat(MAXFLOAT)),
                                                       options: .usesLineFragmentOrigin,
                                                       attributes: [NSAttributedString.Key.font: font],
                                                       context: nil).size.height
    return height + 1
  }

  func updateViewConstrain(contentHeight: CGFloat) {
    bgView.snp.updateConstraints { make in
      make.center.equalToSuperview()
      make.left.equalToSuperview().offset(53)
      make.right.equalToSuperview().offset(-53)
      make.height.equalTo(contentHeight + 133)
    }

    titleLabel.snp.updateConstraints { make in
      make.top.equalTo(bgView).offset(20)
      make.left.right.equalTo(bgView)
      make.height.equalTo(25)
    }

    textView.snp.updateConstraints { make in
      make.top.equalTo(titleLabel.snp.bottom).offset(24)
      make.left.equalTo(bgView).offset(16)
      make.right.equalTo(bgView).offset(-16)
      make.height.equalTo(contentHeight)
    }

    lineView.snp.updateConstraints { make in
      make.top.equalTo(textView.snp.bottom).offset(20)
      make.left.right.equalTo(bgView)
      make.height.equalTo(0.5)
    }

    confirmButton.snp.updateConstraints { make in
      make.top.equalTo(lineView.snp.bottom).offset(10)
      make.centerX.equalTo(bgView)
      make.width.equalTo(135)
      make.height.equalTo(22)
    }

    layoutIfNeeded()
  }

  @objc func confirm(btn: UIButton) {
    dismiss()
  }

  func show() {
    UIApplication.shared.keyWindow?.addSubview(self)
  }

  func dismiss() {
    removeFromSuperview()
  }
}
