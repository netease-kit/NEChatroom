// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import UIKit

@objcMembers public class NESocialPaddingLabel: UILabel {
  public var edgeInsets: UIEdgeInsets = .init(top: 4, left: 8, bottom: 4, right: 8)

  override public func draw(_ rect: CGRect) {
    super.drawText(in: rect.inset(by: edgeInsets))
  }

  override public var intrinsicContentSize: CGSize {
    var size = super.intrinsicContentSize
    size.width += edgeInsets.left
    size.width += edgeInsets.right
    size.height += edgeInsets.top
    size.height += edgeInsets.bottom
    return size
  }
}
