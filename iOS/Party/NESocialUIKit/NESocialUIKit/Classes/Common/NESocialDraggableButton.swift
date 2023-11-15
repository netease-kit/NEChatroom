// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import UIKit

enum NESocialFloatWindowDirection {
  case left
  case right
  case top
  case bottom
}

enum NESocialScreenChangeOrientation {
  case origin
  case upside
  case left
  case right
}

@objcMembers
public class NESocialDraggableButton: UIButton {
  public var clickAction: (() -> Void)?

  var touchStartPosition: CGPoint = .zero

  var initOrientation: UIInterfaceOrientation!

  var originTransform: CGAffineTransform!

  lazy var rootView: UIView = .init()

  func buttonRotate() {
    buttonAutoAdjust(center)
    let change2orien = screenChange()
    switch change2orien {
    case .origin:
      transform = originTransform
    case .left:
      transform = originTransform
      transform = CGAffineTransformMakeRotation(-90 * .pi / 180.0)
    case .right:
      transform = originTransform
      transform = CGAffineTransformMakeRotation(90 * .pi / 180.0)
    case .upside:
      transform = originTransform
      transform = CGAffineTransformMakeRotation(180 * .pi / 180.0)
    }
  }

  func screenChange() -> NESocialScreenChangeOrientation {
    let orientation = UIApplication.shared.statusBarOrientation
    if initOrientation == orientation {
      return .origin
    }
    let isUpside = orientation.rawValue + initOrientation.rawValue
    if isUpside == 3 || isUpside == 7 {
      return .upside
    }
    var change2orien: NESocialScreenChangeOrientation = .origin
    switch initOrientation {
    case .portrait:
      if orientation == .landscapeLeft {
        change2orien = .left
      } else if orientation == .landscapeRight {
        change2orien = .right
      }
    case .portraitUpsideDown:
      if orientation == .landscapeLeft {
        change2orien = .right
      } else if orientation == .landscapeRight {
        change2orien = .left
      }
    case .landscapeRight:
      if orientation == .portrait {
        change2orien = .left
      } else if orientation == .portraitUpsideDown {
        change2orien = .right
      }
    case .landscapeLeft:
      if orientation == .portrait {
        change2orien = .right
      } else if orientation == .portraitUpsideDown {
        change2orien = .left
      }
    default: break
    }
    return change2orien
  }

  func setupImage(image: String) {
    sd_setImage(with: URL(string: image), for: .normal)
  }

  override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    if let touch = touches.first {
      touchStartPosition = touch.location(in: rootView)
      touchStartPosition = convertDir(touchStartPosition)
    }
  }

  override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    if let touch = touches.first {
      var curPoint = touch.location(in: rootView)
      curPoint = convertDir(curPoint)
      superview?.center = curPoint
    }
  }

  override public func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    touchesEnded(touches, with: event)
  }

  override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    if let touch = touches.first {
      var curPoint = touch.location(in: rootView)
      curPoint = convertDir(curPoint)
      if pow(touchStartPosition.x - curPoint.x, 2) + pow(touchStartPosition.y - curPoint.y, 2) < 1 {
        clickAction?()
        return
      }
      buttonAutoAdjust(curPoint)
    }
  }

  func convertDir(_ point: CGPoint) -> CGPoint {
    var width = UIScreen.main.bounds.size.width
    var height = UIScreen.main.bounds.size.height
    switch screenChange() {
    case .left:
      return CGPoint(x: point.y, y: width - point.x)
    case .right:
      return CGPoint(x: height - point.y, y: point.x)
    case .upside:
      return CGPoint(x: width - point.x, y: height - point.y)
    default: return point
    }
  }

  func buttonAutoAdjust(_ point: CGPoint) {
    let orientation = UIApplication.shared.statusBarOrientation
    var width = UIScreen.main.bounds.size.width
    var height = UIScreen.main.bounds.size.height
    let judge = orientation.rawValue + initOrientation.rawValue
    if orientation != initOrientation,
       judge != 3,
       judge != 7 {
      let temp = width
      width = height
      height = width
    }
    let left = point.x
    let right = width - point.x
    var minDir = NESocialFloatWindowDirection.left
    if right < left {
      minDir = .right
    }
    switch minDir {
    case .left:
      UIView.animate(withDuration: 0.3) { [weak self] in
        if let superview = self?.superview {
          let x = superview.width / 2
          let y = (superview.centerY <= superview.height / 2)
            ? (superview.height / 2)
            : superview.centerY > (height - superview.height / 2)
            ? (height - superview.height / 2)
            : superview.centerY
          superview.center = CGPoint(x: x, y: y)
        }
      }
    case .right:
      UIView.animate(withDuration: 0.3) { [weak self] in
        if let superview = self?.superview {
          let x = width - superview.width / 2
          let y = (superview.centerY <= superview.height / 2)
            ? (superview.height / 2)
            : superview.centerY > (height - superview.height / 2)
            ? (height - superview.height / 2)
            : superview.centerY
          superview.center = CGPoint(x: x, y: y)
        }
      }
    case .top:
      UIView.animate(withDuration: 0.3) { [weak self] in
        if let superview = self?.superview {
          if #available(iOS 11, *) {
            if UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0 > 20 {
              superview.center = CGPoint(x: superview.centerX, y: superview.height / 2 + 50)
            } else {
              superview.center = CGPoint(x: superview.centerX, y: superview.height / 2)
            }
          } else {
            superview.center = CGPoint(x: superview.centerX, y: superview.height / 2)
          }
        }
      }
    case .bottom:
      UIView.animate(withDuration: 0.3) { [weak self] in
        if let superview = self?.superview {
          superview.center = CGPoint(x: superview.centerX, y: height - superview.height / 2)
        }
      }
    }
  }
}
