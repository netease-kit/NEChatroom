// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import NECommonUIKit
import SnapKit
import UIKit

@objcMembers public class NESocialAuthenticationViewController: UIViewController {
  public var authenticateAction: ((String?, String?) -> Void)?

  override public func viewDidLoad() {
    super.viewDidLoad()

    title = NESocialBundle.localized("Authentication")
    view.backgroundColor = UIColor(red: 0.938, green: 0.944, blue: 0.956, alpha: 1)

    view.addSubview(authenticationLabel)
    view.addSubview(nameTextField)
    view.addSubview(idTextField)
    view.addSubview(authenticationButton)
    view.addSubview(checkButton)
    view.addSubview(checkLabel)

    authenticationLabel.snp.makeConstraints { make in
      if #available(iOS 11.0, *) {
        make.top.equalTo(view.safeAreaLayoutGuide).offset(24)
      } else {
        make.top.equalTo(view).offset(24)
      }
      make.left.equalTo(view).offset(24)
      make.right.equalTo(view).offset(-24)
    }

    nameTextField.snp.makeConstraints { make in
      make.left.right.equalTo(authenticationLabel)
      make.top.equalTo(authenticationLabel.snp.bottom).offset(24)
      make.height.equalTo(50)
    }

    idTextField.snp.makeConstraints { make in
      make.left.right.equalTo(authenticationLabel)
      make.top.equalTo(nameTextField.snp.bottom).offset(24)
      make.height.equalTo(50)
    }

    authenticationButton.snp.makeConstraints { make in
      make.left.right.equalTo(authenticationLabel)
      make.top.equalTo(idTextField.snp.bottom).offset(24)
      make.height.equalTo(40)
    }

    checkButton.snp.makeConstraints { make in
      make.left.equalTo(authenticationLabel)
      make.width.height.equalTo(23)
      make.top.equalTo(authenticationButton.snp.bottom).offset(24)
    }

    checkLabel.snp.makeConstraints { make in
      make.left.equalTo(checkButton.snp.right).offset(10)
      make.top.equalTo(checkButton)
      make.right.equalTo(authenticationLabel)
    }

    idTextField.delegate = self
    idTextField.keyboardType = .numbersAndPunctuation
    nameTextField.keyboardType = .default
  }

  public func showError(error: String?) {
    let alert = UIAlertController(title: error ?? NESocialBundle.localized("Authentication_Error"), message: nil, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: NESocialBundle.localized("Know"), style: .cancel))
    present(alert, animated: true)
  }

  public func showSucc(succ: String?) {
    navigationController?.popViewController(animated: true)
    showToastInWindow(succ ?? NESocialBundle.localized("Authentication_Succ"))
  }

  lazy var authenticationLabel: UILabel = {
    let view = UILabel()
    view.text = NESocialBundle.localized("Authentication_Content")
    view.font = UIFont(name: "PingFang SC", size: 14)
    view.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
    view.numberOfLines = 0
    return view
  }()

  lazy var nameTextField: UITextField = createTextField(placeholder: NESocialBundle.localized("Name_Placeholder"))

  lazy var idTextField: UITextField = createTextField(placeholder: NESocialBundle.localized("ID_Placeholder"))

  private func createTextField(placeholder: String) -> UITextField {
    let view = UITextField()
    view.placeholder = placeholder
    view.font = UIFont(name: "PingFang SC", size: 16)
    view.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
    view.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    view.backgroundColor = .white
    view.layer.cornerRadius = 8
    view.clipsToBounds = true
    let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 50))
    view.leftView = leftView
    view.leftViewMode = .always
    return view
  }

  func textFieldDidChange(_ textField: UITextField) {
    if textField == idTextField {
      textField.text = textField.text?.uppercased()
    }
    checkAuthenticationButtonIsEnable()
  }

  lazy var authenticationButton: UIButton = {
    let view = UIButton(type: .custom)
    view.setTitle(NESocialBundle.localized("Authentication_Now"), for: .normal)
    view.layer.cornerRadius = 20
    view.backgroundColor = UIColor(red: 0.2, green: 0.494, blue: 1, alpha: 0.5)
    view.addTarget(self, action: #selector(authenticationButtonClicked), for: .touchUpInside)
    view.isEnabled = false
    return view
  }()

  func authenticationButtonClicked() {
    authenticateAction?(nameTextField.text, idTextField.text)
  }

  lazy var checkButton: UIButton = {
    let view = UIButton()
    view.setImage(NESocialBundle.loadImage("auth_unchecked"), for: .normal)
    view.setImage(NESocialBundle.loadImage("auth_checked"), for: .selected)
    view.addTarget(self, action: #selector(checkButtonClicked(sender:)), for: .touchUpInside)
    return view
  }()

  func checkButtonClicked(sender: UIButton) {
    sender.isSelected = !sender.isSelected
    checkAuthenticationButtonIsEnable()
  }

  lazy var checkLabel: UILabel = {
    let view = UILabel()
    view.text = NESocialBundle.localized("Authentication_Check")
    view.font = UIFont(name: "PingFangSC-Regular", size: 14)
    view.textColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
    view.numberOfLines = 0
    return view
  }()

  private func checkAuthenticationButtonIsEnable() {
    if nameTextField.text?.count ?? 0 > 0,
       idTextField.text?.count ?? 0 > 0,
       checkButton.isSelected {
      authenticationButton.isEnabled = true
      authenticationButton.backgroundColor = UIColor(red: 0.2, green: 0.494, blue: 1, alpha: 1)
    } else {
      authenticationButton.isEnabled = false
      authenticationButton.backgroundColor = UIColor(red: 0.2, green: 0.494, blue: 1, alpha: 0.5)
    }
  }

  override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    view.endEditing(true)
  }
}

extension NESocialAuthenticationViewController: UITextFieldDelegate {
  public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    let currentText = textField.text ?? ""
    let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
    // 使用正则表达式来限制用户输入
    let regex = "^[a-zA-Z0-9]{0,18}$"
    let isValid = NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: newText)
    return isValid
  }
}
