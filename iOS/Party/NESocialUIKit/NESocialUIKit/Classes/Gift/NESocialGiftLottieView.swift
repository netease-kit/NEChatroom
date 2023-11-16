// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Foundation
import LottieSwift

@objcMembers public class NESocialGiftLottieView: UIView {
  /// 保护队列
  var queue: DispatchQueue = .init(label: "com.social.gift.queue")
  /// 礼物集合
  var gifts: [String] = .init()

  override public init(frame: CGRect) {
    let rect = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
    super.init(frame: rect)
    addSubview(animationView)
    isUserInteractionEnabled = false
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public func addGift(_ gift: String) {
    queue.sync {
      self.gifts.append(gift)
      self._play()
    }
  }

  private func _removeFirstGift() {
    queue.sync {
      if self.gifts.count > 0 {
        self.gifts.remove(at: 0)
      }
    }
  }

  private func _play() {
    if animationView.isAnimationPlaying || gifts.count == 0 {
      return
    }
    let gift = gifts[0]
    animationView.animation = LottieAnimation.named(gift, bundle: NESocialBundle.bundle())
    DispatchQueue.main.async {
      self.isHidden = false
      self.animationView.isHidden = false
      self.animationView.play(completion: { animationFinished in
        if !animationFinished {
          return
        }
        self.animationView.isHidden = true
        self.isHidden = true
        self._removeFirstGift()
        self._play()
      })
    }
  }

  // lazy load
  lazy var animationView: LottieAnimationView = {
    let rect = CGRect(x: 0, y: (frame.height - frame.width) / 2, width: frame.width, height: frame.width)
    let view = LottieAnimationView(frame: rect)
    return view
  }()
}
