// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import UIKit
import SnapKit

class NPTUserAgreementViewController: UIViewController {
  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)

    view.addSubview(bgView)
    bgView.addSubview(titleLabel)
    bgView.addSubview(textView)
    bgView.addSubview(lineView)
    bgView.addSubview(disagreeButton)
    bgView.addSubview(agreeButton)
    bgView.addSubview(line2View)

    updateViewConstrain(contentHeight: calculateHeight(string: textView.attributedText.string, width: 270, font: UIFont(name: "PingFangSC-Regular", size: 15) ?? UIFont.systemFont(ofSize: 15)))
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

  lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont(name: "PingFangSC-Medium", size: 17)
    label.textColor = UIColor(red: 0.133, green: 0.133, blue: 0.133, alpha: 1)
    label.text = "User_Agreement".localized
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
    let view = UITextView(frame: self.view.frame)
    view.textContainerInset = .zero
    view.isEditable = false
    view.isScrollEnabled = false

    let color = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
    let blue = UIColor(red: 0.133, green: 0.133, blue: 0.133, alpha: 1)
    let font = UIFont(name: "PingFangSC-Regular", size: 14) ?? UIFont.systemFont(ofSize: 14)

    let attributedString = NSMutableAttributedString()
    attributedString.append(NSAttributedString(string: "User_Agreement_Content1".localized, attributes: [.foregroundColor: color, .font: font]))
    var tempAttr = NSMutableAttributedString(string: "Privacy_Agreement".localized, attributes: [.foregroundColor: blue, .link: URL(string: Configs.privacyUrl) as Any, .font: font])
    attributedString.append(tempAttr)
    attributedString.append(NSAttributedString(string: "User_Agreement_Content2".localized, attributes: [.foregroundColor: color, .font: font]))
    tempAttr = NSMutableAttributedString(string: "Terms_Of_Service".localized, attributes: [.foregroundColor: blue, .link: URL(string: Configs.termsUrl) as Any, .font: font])
    attributedString.append(tempAttr)

    attributedString.append(NSAttributedString(string: "User_Agreement_Content3".localized, attributes: [.foregroundColor: color, .font: font]))

    view.attributedText = attributedString

    return view
  }()

  lazy var agreeButton: UIButton = {
    let btn = UIButton()
    btn.setTitleColor(UIColor(red: 0.2, green: 0.494, blue: 1, alpha: 1), for: .normal)
    btn.setTitle("Agree".localized, for: .normal)
    btn.addTarget(self, action: #selector(confirm(btn:)), for: .touchUpInside)
    return btn
  }()

  lazy var disagreeButton: UIButton = {
    let btn = UIButton()
    btn.setTitleColor(UIColor(red: 0.133, green: 0.133, blue: 0.133, alpha: 1), for: .normal)
    btn.setTitle("Disagree".localized, for: .normal)
    btn.addTarget(self, action: #selector(confirm(btn:)), for: .touchUpInside)
    return btn
  }()

  lazy var lineView: UIView = {
    let line = UIView()
    line.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
    return line
  }()

  lazy var line2View: UIView = {
    let line = UIView()
    line.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
    return line
  }()

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

    disagreeButton.snp.updateConstraints { make in
      make.top.equalTo(lineView.snp.bottom)
      make.left.equalToSuperview()
      make.bottom.equalToSuperview()
      make.right.equalTo(textView.snp.centerX)
    }

    agreeButton.snp.updateConstraints { make in
      make.top.equalTo(lineView.snp.bottom)
      make.right.equalToSuperview()
      make.left.equalTo(disagreeButton.snp.right)
      make.bottom.equalToSuperview()
    }

    line2View.snp.updateConstraints { make in
      make.top.equalTo(lineView.snp.bottom)
      make.bottom.equalToSuperview()
      make.width.equalTo(0.5)
      make.centerX.equalToSuperview()
    }
  }

  @objc func confirm(btn: UIButton) {
    if btn == agreeButton {
      UserDefaults.standard.setValue(false, forKey: "FirstRun")
      UserDefaults.standard.synchronize()
      userAgreementWindow.dismiss()
    } else if btn == disagreeButton {
      exit(0)
    }
  }
}

var userAgreementWindow = NPTUserAgreementWindow(frame: UIScreen.main.bounds)

class NPTUserAgreementWindow: UIWindow {
  override init(frame: CGRect) {
    super.init(frame: frame)

    layer.masksToBounds = true
    windowLevel = UIWindow.Level.alert + 1
    rootViewController = NPTUserAgreementViewController()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func show() {
    isHidden = false
  }

  func dismiss() {
    isHidden = true
  }
}
