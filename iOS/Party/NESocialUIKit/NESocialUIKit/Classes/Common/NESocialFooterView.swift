// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import NECommonUIKit
import UIKit

/// 内置按钮的tag，ViewController中的present通过tag来找到需要更新的按钮，比如被静音之后需要更新麦克风按钮
public enum NESocialFooterInternalTag: Int {
  case mic = 10000
  case gift
  case more
}

public class NESocialFooterButtonItem: NSObject {
  public var image: UIImage?
  public var selectedImage: UIImage?
  public var isSelected: Bool = false {
    // 同步修改与自己绑定的button的选中状态
    didSet {
      button?.isSelected = isSelected
    }
  }

  public var action: ((NESocialFooterButtonItem) -> Void)?
  /// 用来对应按钮的tag，会默认生成一个，也可以自定义
  public var tag: Int = 0

  weak var button: UIButton?

  private static var customTag = 1100

  /// 当前是否显示
  public var isHidden = false

  convenience init(image: UIImage?, selectedImage: UIImage? = nil, isSelected: Bool = false, isHidden: Bool = false, tag: Int? = nil, action: ((NESocialFooterButtonItem) -> Void)?) {
    self.init()
    self.image = image
    self.selectedImage = selectedImage
    self.isSelected = isSelected
    self.action = action
    self.isHidden = isHidden

    /// 生成一个唯一自增id
    if let tag = tag {
      self.tag = tag
    } else {
      NESocialFooterButtonItem.customTag += 1
      self.tag = NESocialFooterButtonItem.customTag
    }
  }

  // MARK: 内部提供了一些通用的按钮，如有定制化比较强的按钮则自行去实现

  /// 麦克风按钮
  public static func micItem(action: ((NESocialFooterButtonItem) -> Void)?) -> NESocialFooterButtonItem {
    NESocialFooterButtonItem(
      image: NESocialBundle.loadImage("footer_mic_on"),
      selectedImage: NESocialBundle.loadImage("footer_mic_off"),
      tag: NESocialFooterInternalTag.mic.rawValue,
      action: action
    )
  }

  /// 礼物按钮
  public static func giftItem(action: ((NESocialFooterButtonItem) -> Void)?) -> NESocialFooterButtonItem {
    NESocialFooterButtonItem(
      image: NESocialBundle.loadImage("footer_gift"),
      tag: NESocialFooterInternalTag.gift.rawValue,
      action: action
    )
  }

  /// 更多按钮
  public static func moreItem(action: ((NESocialFooterButtonItem) -> Void)?) -> NESocialFooterButtonItem {
    NESocialFooterButtonItem(
      image: NESocialBundle.loadImage("footer_more"),
      tag: NESocialFooterInternalTag.more.rawValue,
      action: action
    )
  }
}

public class NESocialFooterView: UIView {
  /// 自定义按钮
  public var customButtonItems: [NESocialFooterButtonItem]?
  /// 点击开始聊天
  public var inputMessage: (() -> Void)?

  /// 初始化底部工具栏
  /// - Parameters:
  ///   - frame: 底部工具栏的frame
  ///   - customButtonItems: 数据源，Swift的list是值类型，这里只支持修改NESocialFooterButtonItem的属性，不支持动态增删item，如有需要后续改为引用类型
  public init(frame: CGRect, customButtonItems: [NESocialFooterButtonItem]?) {
    super.init(frame: frame)

    self.customButtonItems = customButtonItems

    addSubview(messageInputView)
    addSubview(itemsView)

    layout()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func layout() {
    messageInputView.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(8)
      make.top.bottom.equalToSuperview()
    }
    itemsView.snp.makeConstraints { make in
      make.top.bottom.right.equalToSuperview()
      make.left.equalTo(messageInputView.snp.right)
    }

    layoutButtons()
  }

  public func reload(customButtonItems: [NESocialFooterButtonItem]?) {
    self.customButtonItems = customButtonItems
    layoutButtons()
  }

  private func layoutButtons() {
    itemsView.subviews.forEach { view in
      view.removeFromSuperview()
    }
    // 如果有自定义的按钮，添加进来
    if let items = customButtonItems?.filter({ $0.isHidden == false }) {
      for index in (0 ..< items.count).reversed() {
        let item = items[index]
        let button = UIButton()
        button.setImage(item.image, for: .normal)
        button.setImage(item.selectedImage, for: .selected)
        button.isSelected = item.isSelected
        button.addTarget(self, action: #selector(buttonClicked(sender:)), for: .touchUpInside)
        button.tag = item.tag
        item.button = button
        itemsView.addSubview(button)

        // 右边距 8，按钮间距 12，按钮大小 36
        // 从右往左排列
        let right = 8 + (36 + 12) * (items.count - 1 - index)
        button.snp.makeConstraints { make in
          make.width.height.equalTo(36)
          make.top.equalToSuperview()
          make.right.equalToSuperview().offset(-right)
        }
      }
    }
  }

  @objc private func buttonClicked(sender: UIButton) {
    // 通过tag匹配到按钮，触发action
    if let items = customButtonItems,
       let item = items.first(where: { $0.tag == sender.tag }) {
      item.action?(item)
    }
  }

  private lazy var messageInputView: NESocialPaddingLabel = {
    var view = NESocialPaddingLabel()
    view.edgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 38)
    view.backgroundColor = UIColor(white: 0, alpha: 0.5)
    view.layer.cornerRadius = 18
    view.clipsToBounds = true
    let font = UIFont.systemFont(ofSize: 13)
    let mutableString = NSMutableAttributedString()
    if let image = NESocialBundle.loadImage("message_input") {
      let attachment = NSTextAttachment()
      attachment.image = image
      attachment.bounds = CGRect(x: 0, y: (font.capHeight - 14) / 2, width: 14, height: 14)
      mutableString.append(NSAttributedString(attachment: attachment))
    }
    mutableString.append(NSAttributedString(string: " "))
    mutableString.append(NSAttributedString(string: NESocialBundle.localized("Message_Input"), attributes: [.font: font, .foregroundColor: UIColor(hexString: "#AAACB7", 1)]))
    view.attributedText = mutableString
    let tap = UITapGestureRecognizer(target: self, action: #selector(messageInputViewClicked))
    view.addGestureRecognizer(tap)
    view.isUserInteractionEnabled = true
    return view
  }()

  @objc private func messageInputViewClicked() {
    inputMessage?()
  }

  private lazy var itemsView: UIView = {
    let view = UIView()
    return view
  }()
}
