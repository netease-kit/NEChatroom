// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Foundation
import SnapKit
import NECommonKit

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
    addSubview(titleLable)
    titleLable.snp.makeConstraints { make in
      make.centerX.equalTo(self)
      make.top.equalTo(self).offset(NEConstant.navigationAndStatusHeight)
    }

    addSubview(accountLable)
    accountLable.snp.makeConstraints { make in
      make.left.equalTo(self).offset(20)
      make.centerY.equalTo(self).offset(-50)
    }
    addSubview(accountTextField)
    accountTextField.snp.makeConstraints { make in
      make.left.equalTo(accountLable)
      make.top.equalTo(accountLable.snp.bottom).offset(10)
      make.right.equalTo(self).offset(-20)
    }
    addSubview(loginButton)
    loginButton.snp.makeConstraints { make in
      make.bottom.equalTo(self).offset(-100)
      make.height.equalTo(50)
      make.left.equalTo(self).offset(50)
      make.right.equalTo(self).offset(-50)
    }
  }

  lazy var titleLable: UILabel = {
    var titleLable = UILabel()
    titleLable.text = NELoginSampleBundle.localized("登录")
    titleLable.font = UIFont.systemFont(ofSize: 20)
    return titleLable
  }()

  lazy var accountLable: UILabel = {
    var accountLable = UILabel()
    accountLable.text = NELoginSampleBundle.localized("账号")
    return accountLable
  }()

  lazy var accountTextField: UITextField = {
    var accountTextField = UITextField()
    accountTextField.placeholder = "请输入账号"
    accountTextField.backgroundColor = .green
    return accountTextField
  }()

  lazy var loginButton: UIButton = {
    var loginButton = UIButton()
    loginButton.addTarget(self, action: #selector(clickLogin), for: .touchUpInside)
    loginButton.setTitle(NELoginSampleBundle.localized("登录"), for: .normal)
    loginButton.layer.masksToBounds = true
    loginButton.layer.cornerRadius = 25
    loginButton.backgroundColor = UIColor(hexString: "#337EFF")
    return loginButton
  }()

  func clickLogin() {
    let account = accountTextField.text
    /// 网络请求
    loginCallBack?(0)
    removeFromSuperview()
  }

  override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    endEditing(true)
  }
}
