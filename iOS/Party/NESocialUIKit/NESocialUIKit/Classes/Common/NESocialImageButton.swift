// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import UIKit

private class NESocialImageButtonProps {
  var title: String?
  var image: UIImage?
}

/// 图标在上，文字在下的通用按钮
public class NESocialImageButton: UIControl {
  private var stateProps = [UInt: NESocialImageButtonProps]()

  override public init(frame: CGRect) {
    super.init(frame: frame)
    addSubview(imageView)
    addSubview(titleLabel)
  }

  /// 文本
  lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
    label.text = " "
    label.textAlignment = .center
    label.font = UIFont(name: "PingFangSC-Regular", size: 14)
    return label
  }()

  /// 图标
  lazy var imageView: UIImageView = {
    let image = UIImageView()
    image.contentMode = .scaleAspectFit
    return image
  }()

  private func setUpViews() {
    let label = createTextLabel(text: titleLabel.text ?? "", font: titleLabel.font)
    titleLabel.frame = CGRect(x: 0, y: frame.size.height - label.frame.size.height, width: frame.size.width, height: label.frame.size.height)
    let space: CGFloat = 5.0
    imageView.frame = CGRect(x: space, y: space, width: frame.size.width - 2 * space, height: frame.size.width - 2 * space)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  /// 设置不同状态下的文本显示
  /// - Parameters:
  ///   - title: 文本内容
  ///   - state: 对应的状态
  public func setTitle(_ title: String?, for state: UIControl.State) {
    if let props = stateProps[state.rawValue] {
      props.title = title
    } else {
      let props = NESocialImageButtonProps()
      props.title = title
      stateProps[state.rawValue] = props
    }
    updateUI()
  }

  /// 设置不同状态下的图片显示
  /// - Parameters:
  ///   - image: 图片内容
  ///   - state: 对应的状态
  public func setImage(_ image: UIImage?, for state: UIControl.State) {
    if let props = stateProps[state.rawValue] {
      props.image = image
    } else {
      let props = NESocialImageButtonProps()
      props.image = image
      stateProps[state.rawValue] = props
    }
    updateUI()
  }

  /// 按钮当前是否可点击
  override public var isEnabled: Bool {
    get { super.isEnabled }
    set {
      super.isEnabled = newValue
      updateUI()
    }
  }

  /// 按钮当前是否是选中状态
  override public var isSelected: Bool {
    get { super.isSelected }
    set {
      super.isSelected = newValue
      updateUI()
    }
  }

  private func updateUI() {
    let isSelected = state.contains(.selected)
    let isDisabled = state.contains(.disabled)
    let isHighlighted = state.contains(.highlighted)

    if isDisabled,
       let props = stateProps[UIControl.State.disabled.rawValue] {
      updateUI(props: props)
    } else if isSelected,
              let props = stateProps[UIControl.State.selected.rawValue] {
      updateUI(props: props)
    } else if isHighlighted,
              let props = stateProps[UIControl.State.highlighted.rawValue] {
      updateUI(props: props)
    } else if let props = stateProps[UIControl.State.normal.rawValue] {
      updateUI(props: props)
    }

    // 禁用情况下做个置灰
    if isDisabled {
      alpha = 0.4
    } else {
      alpha = 1.0
    }
  }

  private func updateUI(props: NESocialImageButtonProps) {
    DispatchQueue.main.async {
      if let image = props.image {
        self.imageView.image = image
      }
      if let title = props.title {
        self.titleLabel.text = title
      }
    }
  }

  override public func layoutSubviews() {
    super.layoutSubviews()
    setUpViews()
  }

  private func createTextLabel(text: String, font: UIFont) -> UILabel {
    let label = UILabel()
    label.text = text
    label.font = font
    label.sizeToFit()
    return label
  }
}
