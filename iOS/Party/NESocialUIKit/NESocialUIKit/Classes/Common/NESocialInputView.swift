// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import NECommonUIKit
import UIKit

public class NESocialInputView: UIView {
  /// 返回值为是否要完成编辑，为true就会缩回键盘
  public var sendAction: ((String?) -> Bool)?
  public var defaultText: String? {
    didSet {
      textField.text = defaultText
    }
  }

  public var sendBtnTitle: String? {
    didSet {
      sendBtn.setTitle(sendBtnTitle, for: .normal)
    }
  }

  override public init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = UIColor(white: 0, alpha: 0.5)

    addSubview(inputContentView)
    inputContentView.addSubview(textField)
    inputContentView.addSubview(sendBtn)

    inputContentView.snp.makeConstraints { make in
      make.height.equalTo(50)
      make.right.left.bottom.equalToSuperview()
    }
    sendBtn.snp.makeConstraints { make in
      make.right.bottom.equalToSuperview().offset(-8)
      make.width.equalTo(60)
      make.top.equalToSuperview().offset(8)
    }
    textField.snp.makeConstraints { make in
      make.left.top.equalToSuperview().offset(8)
      make.right.equalTo(sendBtn.snp.left).offset(-12)
      make.bottom.equalToSuperview().offset(-8)
    }

    addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap)))
  }

  @objc func tap() {
    resignFirstResponder()
    endEditing(true)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private lazy var inputContentView: UIView = {
    let view = UIView()
    view.backgroundColor = .white
    return view
  }()

  private lazy var textField: UITextField = {
    let view = UITextField()
    view.font = UIFont.systemFont(ofSize: 14)
    view.backgroundColor = UIColor(hexString: "#F0F0F2")
    view.textColor = .black
    view.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 0))
    view.leftViewMode = .always
    view.layer.cornerRadius = 16
    view.clipsToBounds = true
    return view
  }()

  private lazy var sendBtn: UIButton = {
    let btn = UIButton()
    btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
    btn.layer.cornerRadius = 16
    btn.clipsToBounds = true
    btn.backgroundColor = UIColor(hexString: "#337EFF")
    btn.setTitle("发送", for: .normal)
    btn.addTarget(self, action: #selector(sendBtnClicked(sender:)), for: .touchUpInside)
    return btn
  }()

  @objc private func sendBtnClicked(sender: UIButton) {
    /// 处理输入字符串里的空格
    let characterSet = CharacterSet.whitespacesAndNewlines
    let text = textField.text?.trimmingCharacters(in: characterSet)
    if let complete = sendAction?(text),
       complete {
      textField.text = nil
      textField.resignFirstResponder()
    }
  }

  override public func becomeFirstResponder() -> Bool {
    textField.becomeFirstResponder()
  }
}
