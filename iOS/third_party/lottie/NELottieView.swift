// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Foundation
import UIKit

@objcMembers
public class NELottieView: UIView {
  var animationView: LottieAnimationView?

  public init(frame: CGRect, lottie: String, bundle: Bundle) {
    super.init(frame: frame)

    animationView = LottieAnimationView(name: lottie, bundle: bundle)
    if let animationView = animationView {
      animationView.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
      animationView.loopMode = .loop
      animationView.play()
      addSubview(animationView)
    }
  }

  override public var frame: CGRect {
    set {
      super.frame = newValue
      if let animationView = animationView {
        animationView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
      }
    }
    get {
      super.frame
    }
  }

  public var animationViewFrame: CGRect {
    set {
      if let animationView = animationView {
        animationView.frame = newValue
      }
    }
    get {
      if let animationView = animationView {
        return animationView.frame
      }
      return CGRect.zero
    }
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public var isAnimationPlaying: Bool {
    if let isPlaying = animationView?.isAnimationPlaying {
      return isPlaying
    }
    return false
  }

  public func play() {
    if let isPlaying = animationView?.isAnimationPlaying,
       isPlaying {
      return
    }
    animationView?.play()
  }

  public func stop() {
    if let isPlaying = animationView?.isAnimationPlaying,
       isPlaying {
      animationView?.stop()
    }
  }

  public func pause() {
    if let isPlaying = animationView?.isAnimationPlaying,
       isPlaying {
      animationView?.pause()
    }
  }
}
