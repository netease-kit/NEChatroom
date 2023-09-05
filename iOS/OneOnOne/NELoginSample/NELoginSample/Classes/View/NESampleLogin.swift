// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Foundation
import NECommonKit
import SnapKit

@objcMembers public class NELoginSampleView: UIView {
  public static func showLoginSampleView(callback: @escaping Callback) {
    let loginSampleView = NELoginSampleView(frame: UIScreen.main.bounds)
    loginSampleView.loginCallBack = callback
    UIApplication.shared.keyWindow?.addSubview(loginSampleView)
  }

  public typealias Callback = (Int) -> Void
  public var loginCallBack: Callback?

  override public init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = .white
    addViews()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func addViews() {
    addSubview(iconImageView)
    iconImageView.snp.makeConstraints { make in
      make.centerX.equalTo(self)
      make.centerY.equalTo(self).offset(-150)
      make.width.height.equalTo(130)
    }

    addSubview(titleLable)
    titleLable.snp.makeConstraints { make in
      make.centerX.equalTo(self)
      make.top.equalTo(iconImageView.snp.bottom).offset(10)
    }

    addSubview(loginButton)
    loginButton.snp.makeConstraints { make in
      make.bottom.equalTo(self).offset(-200)
      make.height.equalTo(50)
      make.left.equalTo(self).offset(50)
      make.right.equalTo(self).offset(-50)
    }
  }

  lazy var titleLable: UILabel = {
    var titleLable = UILabel()
    titleLable.text = NELoginSampleBundle.localized("title")
    titleLable.font = UIFont.systemFont(ofSize: 18)
    titleLable.textAlignment = .center
    titleLable.numberOfLines = 0
    return titleLable
  }()

  lazy var iconImageView: UIImageView = {
    let iconImageView = UIImageView()
    iconImageView.contentMode = .scaleAspectFit

    // 设置阴影的属性
    iconImageView.layer.shadowColor = UIColor.black.cgColor
    iconImageView.layer.shadowOpacity = 0.5
    iconImageView.layer.shadowOffset = CGSize(width: 3, height: 3)
    iconImageView.layer.shadowRadius = 5

    // 如果需要阴影的形状与UIImageView的形状相同，则可以将其设置为与UIImageView的边界相同。
    iconImageView.layer.masksToBounds = false

    return iconImageView
  }()

  lazy var loginButton: UIButton = {
    var loginButton = UIButton()
    loginButton.addTarget(self, action: #selector(clickLogin), for: .touchUpInside)
    loginButton.setTitle(NELoginSampleBundle.localized("开始体验"), for: .normal)
    loginButton.layer.masksToBounds = true
    loginButton.layer.cornerRadius = 25
    loginButton.backgroundColor = UIColor(hexString: "#337EFF")
    return loginButton
  }()

  func clickLogin() {
    /// 网络请求
    loginCallBack?(0)
  }

  public func setIcon(_ image: UIImage) {
    iconImageView.image = image
  }

  public func setTitle(_ title: String) {
    titleLable.text = title
  }

  override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    endEditing(true)
  }
}
