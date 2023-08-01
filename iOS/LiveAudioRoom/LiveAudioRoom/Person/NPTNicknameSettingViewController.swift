// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import UIKit
import SnapKit
import IHProgressHUD
import NEVoiceRoomUIKit

class NPTNicknameSettingViewController: UIViewController {
  override func viewDidLoad() {
    super.viewDidLoad()

    title = "Setting_Nickname".localized
    view.backgroundColor = UIColor.partyBackground

    view.addSubview(nickTextField)
    view.addSubview(completeButton)

    nickTextField.snp.makeConstraints { make in
      if #available(iOS 11.0, *) {
        make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
      } else {
        make.top.equalTo(view).offset(20)
      }
      make.left.equalTo(view).offset(20)
      make.right.equalTo(view).offset(-20)
      make.height.equalTo(56)
    }

    completeButton.snp.makeConstraints { make in
      make.left.equalTo(view).offset(20)
      make.right.equalTo(view).offset(-20)
      make.height.equalTo(40)
      make.top.equalTo(nickTextField.snp.bottom).offset(18)
    }
  }

  @objc func done() {
    if var nickname = nickTextField.text {
      nickname = nickname.replacingOccurrences(of: " ", with: "")
      if !nickname.isEmpty {
        DispatchQueue.main.async {
          nickName = nickname
          NEVoiceRoomUIManager.sharedInstance().nickname = nickname
          self.navigationController?.popViewController(animated: true)
        }
        return
      }
    }
    IHProgressHUD.showError(withStatus: "Nickname_Empty".localized)
  }

  lazy var nickTextField: UITextField = {
    let textField = UITextField()
    textField.textColor = UIColor.partyBlack
    textField.backgroundColor = .white
    textField.placeholder = "Input_Nickname".localized
    textField.delegate = self
    textField.layer.cornerRadius = 8
    textField.clearButtonMode = .whileEditing
    textField.subviews.forEach { element in
      if element is UIButton {
        element.accessibilityIdentifier = "party.NPTNicknameSettingViewController.nickTextField.clearButton"
      }
    }
    textField.returnKeyType = .done
    let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 40))
    textField.leftView = leftView
    textField.leftViewMode = .always
    textField.text = nickName
    return textField
  }()

  lazy var completeButton: UIButton = {
    let button = UIButton()
    button.backgroundColor = .white
    button.setTitle("Complete".localized, for: .normal)
    button.setTitleColor(UIColor.partyBlack, for: .normal)
    button.layer.cornerRadius = 8
    button.addTarget(self, action: #selector(done), for: .touchUpInside)
    button.accessibilityIdentifier = "party.NPTNicknameSettingViewController.completeButton"
    return button
  }()

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    nickTextField.endEditing(true)
  }
}

extension NPTNicknameSettingViewController: UITextFieldDelegate {
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    if let text = textField.text {
      return text.count + (string.count - range.length) <= 10
    }
    return true
  }
}
