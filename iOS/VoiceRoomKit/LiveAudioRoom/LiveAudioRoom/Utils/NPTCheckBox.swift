// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import UIKit

public class NPTCheckBox: UIControl {
  private var checkImage = UIImage(named: "checked")
  private var uncheckImage = UIImage(named: "uncheck")

  public init(frame: CGRect, title: String) {
    super.init(frame: frame)
    addSubview(imageView)
    addSubview(titleLabel)
    titleLabel.text = title
  }

  public init(frame: CGRect, title: String, checkImage: UIImage, uncheckImage: UIImage) {
    super.init(frame: frame)
    self.checkImage = checkImage
    self.uncheckImage = uncheckImage
    addSubview(imageView)
    addSubview(titleLabel)
    titleLabel.text = title
  }

  /// 文本
  lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.textColor = UIColor.partyBlack
    label.font = UIFont(name: "PingFangSC-Regular", size: 14)
    label.text = " "
    label.textAlignment = .left
    return label
  }()

  /// 图标
  lazy var imageView: UIImageView = {
    let image = UIImageView()
    image.contentMode = .scaleAspectFit
    image.image = uncheckImage
    return image
  }()

  private func setUpViews() {
    imageView.frame = CGRect(x: 0, y: 0, width: frame.height, height: frame.height)
    titleLabel.frame = CGRect(x: imageView.frame.width + 9, y: 0, width: frame.width - 9 - imageView.frame.width, height: frame.height)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  /// 按钮当前是否是选中状态
  override public var isSelected: Bool {
    get { super.isSelected }
    set {
      super.isSelected = newValue

      if newValue {
        imageView.image = checkImage
      } else {
        imageView.image = uncheckImage
      }
    }
  }

  override public func layoutSubviews() {
    super.layoutSubviews()
    setUpViews()
  }
}
