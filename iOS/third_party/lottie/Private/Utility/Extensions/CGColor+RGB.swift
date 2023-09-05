// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import QuartzCore

extension CGColor {
  /// Initializes a `CGColor` using the given `RGB` values
  static func rgb(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat) -> CGColor {
    CGColor(
      colorSpace: CGColorSpaceCreateDeviceRGB(),
      components: [red, green, blue]
    )!
      .copy(alpha: 1)!
  }

  /// Initializes a `CGColor` using the given grayscale value
  static func gray(_ gray: CGFloat) -> CGColor {
    CGColor(
      colorSpace: CGColorSpaceCreateDeviceGray(),
      components: [gray]
    )!
      .copy(alpha: 1)!
  }

  /// Initializes a `CGColor` using the given `RGBA` values
  static func rgba(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat, _ alpha: CGFloat) -> CGColor {
    CGColor.rgb(red, green, blue).copy(alpha: alpha)!
  }
}
