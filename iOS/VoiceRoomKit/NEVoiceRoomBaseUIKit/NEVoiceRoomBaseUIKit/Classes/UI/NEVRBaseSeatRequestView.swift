// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import UIKit

class NEVRBaseSeatRequestView: UIView {
  override init(frame: CGRect) {
    super.init(frame: frame)

    backgroundColor = .white

    layer.cornerRadius = 20

    addSubview(label)
    label.snp.makeConstraints { make in
      make.top.bottom.equalToSuperview()
      make.left.equalToSuperview().offset(16)
      make.right.equalToSuperview().offset(-16)
    }
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  /// 请求是否通过
  public var isSucceed: Bool = false {
    didSet {
      label.attributedText = attributedString(isSucceed: isSucceed)
    }
  }

  // 定时器用于让Toast展示两秒后自动消失
  private var timer: Timer?

  override var isHidden: Bool {
    set {
      if isHidden != newValue,
         !newValue {
        // 当设置显示，在两秒后隐藏
        timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false, block: { [weak self] _ in
          DispatchQueue.main.async {
            self?.timer?.invalidate()
            self?.timer = nil
            self?.isHidden = true
          }
        })
      } else {
        // 如果设置了hidden，则直接停止定时器
        timer?.invalidate()
        timer = nil
      }
      super.isHidden = newValue
    }
    get {
      super.isHidden
    }
  }

  lazy var label: UILabel = {
    var label = UILabel()
    label.attributedText = attributedString(isSucceed: false)
    return label
  }()

  func attributedString(isSucceed: Bool) -> NSMutableAttributedString {
    let font = UIFont.systemFont(ofSize: 14)
    let mutableString = NSMutableAttributedString()
    if let image = isSucceed ? NEVRBaseBundle.loadImage("seat_apporved") : NEVRBaseBundle.loadImage("seat_rejected") {
      let attachment = NSTextAttachment()
      attachment.image = image
      attachment.bounds = CGRect(x: 0, y: (font.capHeight - 14) / 2, width: 14, height: 14)
      mutableString.append(NSAttributedString(attachment: attachment))
    }
    mutableString.append(NSAttributedString(string: " "))
    mutableString.append(NSAttributedString(string: NEVRBaseBundle.localized(isSucceed ? "Seat_Request_Approved" : "Seat_Request_Rejected"), attributes: [.font: font, .foregroundColor: UIColor.black]))
    return mutableString
  }
}
