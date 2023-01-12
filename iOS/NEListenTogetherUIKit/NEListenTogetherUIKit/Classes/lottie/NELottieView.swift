// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Foundation
import UIKit

@objcMembers
public class NELottieView: UIView {
  var animationView: LottieAnimationView?

  public init(frame: CGRect, lottie: String) {
    super.init(frame: frame)

    let path = Bundle.main.path(forResource: "Frameworks/NEListenTogetherUIKit.framework/NEListenTogetherUIKit", ofType: "bundle")
    animationView = LottieAnimationView(name: lottie, bundle: Bundle(path: path ?? "") ?? .main)
    if let animationView = animationView {
      animationView.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
      animationView.loopMode = .loop
      animationView.play()
      addSubview(animationView)
    }
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public func play() {
    animationView?.play()
  }

  public func stop() {
    animationView?.stop()
  }
}
