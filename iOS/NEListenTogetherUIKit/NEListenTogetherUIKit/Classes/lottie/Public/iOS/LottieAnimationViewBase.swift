// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#if os(iOS) || os(tvOS) || os(watchOS) || targetEnvironment(macCatalyst)
  import UIKit

  /// The base view for `LottieAnimationView` on iOS, tvOS, watchOS, and macCatalyst.
  ///
  /// Enables the `LottieAnimationView` implementation to be shared across platforms.
  public class LottieAnimationViewBase: UIView {
    // MARK: Public

    override public var contentMode: UIView.ContentMode {
      didSet {
        setNeedsLayout()
      }
    }

    override public func didMoveToWindow() {
      super.didMoveToWindow()
      animationMovedToWindow()
    }

    override public func layoutSubviews() {
      super.layoutSubviews()
      layoutAnimation()
    }

    // MARK: Internal

    var viewLayer: CALayer? {
      layer
    }

    var screenScale: CGFloat {
      UIScreen.main.scale
    }

    func layoutAnimation() {
      // Implemented by subclasses.
    }

    func animationMovedToWindow() {
      // Implemented by subclasses.
    }

    func commonInit() {
      contentMode = .scaleAspectFit
      clipsToBounds = true
      NotificationCenter.default.addObserver(
        self,
        selector: #selector(animationWillEnterForeground),
        name: UIApplication.willEnterForegroundNotification,
        object: nil
      )
      NotificationCenter.default.addObserver(
        self,
        selector: #selector(animationWillMoveToBackground),
        name: UIApplication.didEnterBackgroundNotification,
        object: nil
      )
    }

    @objc
    func animationWillMoveToBackground() {
      // Implemented by subclasses.
    }

    @objc
    func animationWillEnterForeground() {
      // Implemented by subclasses.
    }
  }
#endif
