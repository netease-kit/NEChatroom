// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import UIKit
import SnapKit
import NERoomKit
import IHProgressHUD

class NPTFeedbackViewController: UIViewController {
  var checkBoxs: [NPTCheckBox] = []

  override func viewDidLoad() {
    super.viewDidLoad()

    title = "Use_Feedback".localized
    view.backgroundColor = UIColor.partyBackground

    view.addSubview(backgroundView)
    backgroundView.addSubview(typeLabel)
    backgroundView.addSubview(detailLabel)
    backgroundView.addSubview(textField)
    view.addSubview(submitBtn)

    backgroundView.snp.makeConstraints { make in
      make.height.equalTo(348)
      make.left.equalTo(view).offset(15)
      make.right.equalTo(view).offset(-15)
      if #available(iOS 11.0, *) {
        make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
      } else {
        make.top.equalTo(view).offset(20)
      }
    }

    typeLabel.snp.makeConstraints { make in
      make.left.equalTo(backgroundView).offset(14)
      make.right.equalTo(backgroundView)
      make.top.equalTo(backgroundView).offset(18)
      make.height.equalTo(28)
    }

    detailLabel.snp.makeConstraints { make in
      make.left.equalTo(backgroundView).offset(14)
      make.right.equalTo(backgroundView)
      make.top.equalTo(backgroundView).offset(151)
      make.height.equalTo(28)
    }

    textField.snp.makeConstraints { make in
      make.left.equalTo(backgroundView).offset(14)
      make.right.equalTo(backgroundView).offset(-14)
      make.top.equalTo(detailLabel.snp.bottom).offset(20)
      make.bottom.equalTo(backgroundView).offset(-11)
    }

    submitBtn.snp.makeConstraints { make in
      make.height.equalTo(50)
      make.top.equalTo(backgroundView.snp.bottom).offset(20)
      make.left.equalTo(view).offset(20)
      make.right.equalTo(view).offset(-20)
    }

    addButtons()
  }

  lazy var backgroundView: UIView = {
    var view = UIView()
    view.frame = CGRect(x: 0, y: 0, width: 347, height: 348)
    view.backgroundColor = .white
    view.layer.cornerRadius = 8
    return view
  }()

  lazy var typeLabel: UILabel = {
    var label = createTitleLabel(title: "Feedback_Type".localized)
    return label
  }()

  lazy var detailLabel: UILabel = {
    var label = createTitleLabel(title: "Feedback_Detail".localized)
    return label
  }()

  lazy var submitBtn: UIButton = {
    var view = UIButton()
    view.frame = CGRect(x: 0, y: 0, width: 335, height: 50)
    view.backgroundColor = UIColor(red: 0.2, green: 0.494, blue: 1, alpha: 0.5)
    view.setTitle("Submit".localized, for: .normal)
    view.setTitleColor(.white, for: .normal)
    view.layer.cornerRadius = 25
    view.addTarget(self, action: #selector(submit), for: .touchUpInside)
    view.isEnabled = false
    return view
  }()

  @objc func submit() {
    if let delegate = UIApplication.shared.delegate as? AppDelegate {
      if !delegate.checkNetwork() {
        return
      }
    }
    // 同时满足之后按钮才可点
//    if !checkBoxsStatus() {
//      IHProgressHUD.showError(withStatus: "Feedback_Type_Empty".localized)
//      return
//    }
//    if !checkTextField() {
//      IHProgressHUD.showError(withStatus: "Feedback_Detail_Empty".localized)
//      return
//    }

    IHProgressHUD.show(withStatus: "Feedbacking".localized)
    // 上传日志
    NERoomKit.shared().uploadLog()
    // 反馈
    if let url = URL(string: "https://statistic.live.126.net/statics/report/common/form") {
      var version = "1.0.0"
      if let projectVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
        version = projectVersion
      }
      var request = URLRequest(url: url)
      request.httpMethod = "POST"
      request.addValue(version, forHTTPHeaderField: "ver")
      request.addValue(Configs.AppKey, forHTTPHeaderField: "appkey")
      request.addValue("allInOne", forHTTPHeaderField: "sdktype")
      let body = [
        "event": [
          "feedback": [
            "ver": version,
            "os_ver": UIDevice.current.systemVersion,
            "device_id": NERoomKit.shared().deviceId(),
            "description": textField.text ?? "",
            "platform": "iOS",
            "manufacturer": "Apple",
            "app_key": Configs.AppKey,
            "phone": "phone",
            "nickname": userName,
            "user_uuid": userUuid,
            "client": "allInOne",
            "model": UIDevice.modelName,
            "time": Int(Date().timeIntervalSince1970 * 1000),
            "category": submitContent(),
          ],
        ],
      ]
      /// 请求session
      let sessionConfigure = URLSessionConfiguration.default
      sessionConfigure
        .httpAdditionalHeaders = ["Content-Type": "application/json;charset=utf-8"]
      sessionConfigure.timeoutIntervalForRequest = 10
      sessionConfigure.requestCachePolicy = .reloadIgnoringLocalCacheData
      let session = URLSession(configuration: sessionConfigure)
      if let data = try? JSONSerialization.data(withJSONObject: body, options: []) {
        request.httpBody = data
        let task = session.dataTask(with: request) { data, response, error in
          if let response = response as? HTTPURLResponse,
             response.statusCode == 200 {
            DispatchQueue.main.async {
              IHProgressHUD.showSuccesswithStatus("Feedback_Succ".localized)
              self.navigationController?.popViewController(animated: true)
            }
          } else {
            IHProgressHUD.showSuccesswithStatus("Feedback_Fail".localized)
          }
        }
        task.resume()
      }
    }
  }

  func submitContent() -> String {
    var content = ""
    for checkBox in checkBoxs {
      if checkBox.isSelected {
        content.append(checkBox.titleLabel.text ?? "")
        content.append(",")
      }
    }
    return content
  }

  lazy var textField: UITextView = {
    let view = UITextView()
    view.text = "Submit_Placeholder".localized
    view.textColor = .lightGray
    view.delegate = self
    view.layer.cornerRadius = 4
    view.layer.borderColor = UIColor(red: 0.882, green: 0.889, blue: 0.9, alpha: 1).cgColor
    view.layer.borderWidth = 1
    return view
  }()

  func createTitleLabel(title: String) -> UILabel {
    let view = UILabel()
    view.frame = CGRect(x: 0, y: 0, width: 335, height: 28)
    view.backgroundColor = .white
    view.textColor = UIColor.partyBlack
    view.font = UIFont(name: "PingFangSC-Medium", size: 20)
    view.text = title
    return view
  }

  func addButtons() {
    let titles = ["APP_Crash".localized, "Hard_To_Use".localized, "Bad_UI".localized, "Other".localized]
    for index in 0 ..< titles.count {
      var x = 0, y = 0
      if index == 0 || index == 2 {
        x = 17
      } else {
        x = 150
      }
      if index == 0 || index == 1 {
        y = 66
      } else {
        y = 100
      }
      let btn = NPTCheckBox(frame: CGRect(x: x, y: y, width: 120, height: 20), title: titles[index])
      btn.addTarget(self, action: #selector(check(button:)), for: .touchUpInside)
      backgroundView.addSubview(btn)
      checkBoxs.append(btn)
    }
  }

  @objc func check(button: UIButton) {
    button.isSelected = !button.isSelected
    checkBtnStatus()
  }

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    textField.endEditing(true)
  }

  func checkBtnStatus() {
    let boxChecked = checkBoxsStatus()
    let hasContent = checkTextField()
    let canSubmit = hasContent && boxChecked
    submitBtn.isEnabled = canSubmit
    submitBtn.backgroundColor = canSubmit ? UIColor(red: 0.2, green: 0.494, blue: 1, alpha: 1) : UIColor(red: 0.2, green: 0.494, blue: 1, alpha: 0.5)
  }

  func checkBoxsStatus() -> Bool {
    var boxChecked = false
    for box in checkBoxs {
      if box.isSelected {
        boxChecked = true
        break
      }
    }
    return boxChecked
  }

  func checkTextField() -> Bool {
    !textField.text.isEmpty && textField.text != "Submit_Placeholder".localized
  }
}

extension NPTFeedbackViewController: UITextViewDelegate {
  func textViewDidBeginEditing(_ textView: UITextView) {
    if textView.textColor == UIColor.lightGray {
      textView.text = nil
      textView.textColor = UIColor.partyBlack
    }
  }

  func textViewDidEndEditing(_ textView: UITextView) {
    if textView.text.isEmpty {
      textView.text = "Submit_Placeholder".localized
      textView.textColor = UIColor.lightGray
    }
    checkBtnStatus()
  }

  func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    textView.text.count + (text.count - range.length) <= 200
  }
}
