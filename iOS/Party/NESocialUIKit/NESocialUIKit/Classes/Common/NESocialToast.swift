// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import UIKit
import NECommonUIKit

class NESocialTopmostView: UIView {
  public weak var weakWindow: UIWindow?

  init(window: UIWindow) {
    super.init(frame: .zero)
    weakWindow = window
    backgroundColor = .clear
    isUserInteractionEnabled = false
    let orientation = UIApplication.shared.statusBarOrientation
    update(orientation: orientation)
    NotificationCenter.default.addObserver(self, selector: #selector(changeOrientationHandler(notification:)), name: UIApplication.willChangeStatusBarOrientationNotification, object: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  deinit {
    NotificationCenter.default.removeObserver(self, name: UIApplication.willChangeStatusBarOrientationNotification, object: nil)
  }

  func updateFrame(orientation: UIInterfaceOrientation) {
    guard let window = weakWindow else {
      return
    }
    var width = window.bounds.width
    var height = window.bounds.height
    if width > height {
      let temp = width
      width = temp
      height = width
    }
    switch orientation {
    case .landscapeLeft, .landscapeRight:
      frame = CGRect(x: 0, y: 0, width: height, height: width)
    default:
      frame = CGRect(x: 0, y: 0, width: width, height: height)
    }
  }

  func update(orientation: UIInterfaceOrientation) {
    updateFrame(orientation: orientation)
  }

  @objc func changeOrientationHandler(notification: NSNotification) {
    if notification.name == UIApplication.willChangeStatusBarOrientationNotification {
      UIView.animate(withDuration: UIApplication.shared.statusBarOrientationAnimationDuration) { [weak self] in
        if let orientation = notification.userInfo?[UIApplication.statusBarOrientationUserInfoKey] as? UIInterfaceOrientation {
          self?.update(orientation: orientation)
        }
      }
    }
  }

  static func viewForApplicationWindow() -> NESocialTopmostView? {
    if let window = UIApplication.shared.delegate?.window {
      return viewForWindow(window)
    }
    return nil
  }

  static func viewForWindow(_ window: UIWindow?) -> NESocialTopmostView? {
    guard let window = window else {
      return nil
    }
    var topmostView: NESocialTopmostView?
    if let view = window.subviews.first(where: { $0.isKind(of: NESocialTopmostView.self) }) as? NESocialTopmostView {
      topmostView = view
    }
    if topmostView == nil {
      topmostView = NESocialTopmostView(window: window)
      window.addSubview(topmostView!)
    }
    if let weakWindow = topmostView?.weakWindow {
      weakWindow.bringSubviewToFront(topmostView!)
    }
    return topmostView
  }
}

@objcMembers public class NESocialToast: NSObject {
  public static func showToast(toast: String, position: ToastPosition = .center) {
    DispatchQueue.main.async {
      NESocialTopmostView.viewForApplicationWindow()?.makeToast(toast, duration: 3.0, position: position)
    }
  }

  public static func showLoading() {
    DispatchQueue.main.async {
      NESocialTopmostView.viewForApplicationWindow()?.makeToastActivity(.center)
    }
  }

  public static func hideLoading() {
    DispatchQueue.main.async {
      NESocialTopmostView.viewForApplicationWindow()?.hideToastActivity()
    }
  }
}
