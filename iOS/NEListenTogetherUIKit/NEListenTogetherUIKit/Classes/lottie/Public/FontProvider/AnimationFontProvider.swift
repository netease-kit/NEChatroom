// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import CoreGraphics
import CoreText
import Foundation

// MARK: - AnimationFontProvider

/// Font provider is a protocol that is used to supply fonts to `LottieAnimationView`.
///
public protocol AnimationFontProvider {
  func fontFor(family: String, size: CGFloat) -> CTFont?
}

// MARK: - DefaultFontProvider

/// Default Font provider.
public final class DefaultFontProvider: AnimationFontProvider {
  // MARK: Lifecycle

  public init() {}

  // MARK: Public

  public func fontFor(family: String, size: CGFloat) -> CTFont? {
    CTFontCreateWithName(family as CFString, size, nil)
  }
}
