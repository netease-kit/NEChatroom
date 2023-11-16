// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Foundation
import NECommonUIKit

public enum NESocialActionSheetActionType {
  case normal
  case cancel
}

public class NESocialActionSheetAction: NSObject {
  var type: NESocialActionSheetActionType = .normal
  var title: String?
  var titleColor: UIColor = .black
  var handle: ((NESocialActionSheetAction) -> Void)?

  var buttonTag: Int = 0

  public convenience init(type: NESocialActionSheetActionType = .normal, title: String, titleColor: UIColor = .black, handle: ((NESocialActionSheetAction) -> Void)? = nil) {
    self.init()
    self.type = type
    self.title = title
    self.titleColor = titleColor
    self.handle = handle
  }
}

public class NESocialActionSheet: UIView {
  private static var sheet: NESocialActionSheet?

  let kItemHeight: CGFloat = 50.0
  let kMiddleGap: CGFloat = 10.0
  let kItemOriginTag: Int = 23
  let kItemCancelTag: Int = 100

  public static func show(controller: UIViewController? = nil, title: String? = nil, actions: [NESocialActionSheetAction]) {
    sheet = NESocialActionSheet()
    sheet?.show(controller: controller, title: title, actions: actions)
  }

  public static func hide() {
    if let sheet = sheet {
      sheet.hide()
    }
  }

  var title: String?
  var actions: [NESocialActionSheetAction]?

  lazy var bgView: UIView = .init()

  lazy var titleLabel: UILabel = {
    let titleLabel = UILabel()
    titleLabel.font = UIFont.systemFont(ofSize: 12)
    titleLabel.textColor = UIColor(hexString: "#666666")
    titleLabel.textAlignment = .center
    return titleLabel
  }()

  func show(controller: UIViewController?, title: String?, actions: [NESocialActionSheetAction]) {
    self.title = title
    self.actions = actions

    if let view = controller?.view {
      frame = view.bounds
      setupSubviews()
      view.addSubview(self)
      view.addSubview(bgView)
    } else if let window = UIApplication.shared.keyWindow {
      frame = window.bounds
      setupSubviews()
      window.addSubview(self)
      window.addSubview(bgView)
    }
    UIView.animate(withDuration: 0.3) { [weak self] in
      guard let self = self else {
        return
      }
      self.bgView.frame = CGRect(x: 0, y: self.bounds.height - self.bgView.bounds.height, width: self.bounds.width, height: self.bgView.bounds.height)
    }
    bgView.frame = CGRectMake(0, bounds.height - bgView.bounds.height, bounds.width, bgView.bounds.height)
  }

  func hide() {
    UIView.animate(withDuration: 0.3, animations: { [weak self] in
      guard let self = self else {
        return
      }
      self.bgView.frame = CGRect(x: 0, y: self.bounds.height, width: self.bounds.width, height: self.bgView.bounds.height)
    }, completion: { [weak self] finished in
      if finished {
        self?.title = nil
        self?.bgView.removeFromSuperview()
        self?.removeFromSuperview()
        NESocialActionSheet.sheet = nil
      }
    })
  }

  func setupSubviews() {
    backgroundColor = UIColor(white: 0, alpha: 0.6)
    bgView = UIView()
    bgView.backgroundColor = UIColor(hexString: "#EFEFEF")

    var orginItemY: CGFloat = 0
    if let desc = title, !desc.isEmpty {
      let height = titleLabelHeight()
      titleLabel.text = title
      titleLabel.frame = CGRect(x: 15, y: 0, width: bounds.width - 15 * 2, height: height)
      bgView.addSubview(titleLabel)
      orginItemY = height + 1
    }

    let screenWidth = bounds.width
    let screenHeight = bounds.height

    var bgHeight = orginItemY
    if let normal = actions?.filter({ $0.type == .normal }) {
      for i in 0 ..< normal.count {
        let model = normal[i]
        let button = UIButton(frame: CGRect(x: 0, y: orginItemY + CGFloat(kItemHeight + 1) * CGFloat(i), width: screenWidth, height: kItemHeight))
        button.backgroundColor = .white
        button.tag = kItemOriginTag + i
        button.addTarget(self, action: #selector(itemClick(_:)), for: .touchUpInside)
        button.setTitle(model.title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.setTitleColor(model.titleColor, for: .normal)
        bgView.addSubview(button)

        model.buttonTag = button.tag
      }

      let height = CGFloat(normal.count) * (kItemHeight + 1)
      bgHeight += height
    }
    if let model = actions?.first(where: { $0.type == .cancel }) {
      let button = UIButton(frame: CGRect(x: 0, y: CGFloat(bgHeight) + kMiddleGap, width: screenWidth, height: kItemHeight))
      button.backgroundColor = .white
      button.tag = kItemCancelTag
      button.addTarget(self, action: #selector(itemClick(_:)), for: .touchUpInside)
      button.setTitle(model.title, for: .normal)
      button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
      button.setTitleColor(model.titleColor, for: .normal)
      bgView.addSubview(button)

      model.buttonTag = button.tag

      let height = kMiddleGap + kItemHeight
      bgHeight += height
    }
    if #available(iOS 11.0, *) {
      bgHeight += 20
    }
    bgView.frame = CGRect(x: 0, y: screenHeight, width: screenWidth, height: bgHeight)

    addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapAction)))
  }

  func titleLabelHeight() -> CGFloat {
    if let title = title {
      let size = title.boundingRect(with: CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)], context: nil).size
      if size.height < kItemHeight {
        return kItemHeight
      }
      return size.height
    }
    return 0
  }

  @objc func itemClick(_ button: UIButton) {
    hide()
    if let model = actions?.first(where: { $0.buttonTag == button.tag }) {
      model.handle?(model)
    }
  }

  @objc func tapAction() {
    hide()
  }
}
