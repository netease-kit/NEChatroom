// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import UIKit

@objcMembers
public class NESocialFloatWindow: NSObject {
  var floatWindowWidth: CGFloat = 100
  var floatWindowHeight: CGFloat = 132

  public static let instance = NESocialFloatWindow()

  public var hasFloatWindow: Bool {
    !floatingView.isHidden
  }

  public var target: UIViewController?

  // 入参的block代表close执行完成之后要做的事情
  public var closeAction: ((@escaping (() -> Void)) -> Void)?

  public var roomUuid: String?

  override private init() {
    super.init()

    let subDetailView = UIView(frame: CGRectMake(0, 28, 80, 104))
    subDetailView.backgroundColor = UIColor(white: 0, alpha: 0.6)
    subDetailView.layer.cornerRadius = 6
    subDetailView.layer.masksToBounds = true

    floatingView.addSubview(subDetailView)
    floatingView.addSubview(button)
    floatingView.addSubview(closeButton)
    floatingView.addSubview(titleLabel)
    floatingView.isHidden = true
    UIApplication.shared.keyWindow?.addSubview(floatingView)
  }

  public func addViewControllerTarget(_ controller: UIViewController, roomUuid: String, closeAction: ((@escaping (() -> Void)) -> Void)?) {
    target = controller
    self.roomUuid = roomUuid
    self.closeAction = closeAction
    if let view = UIApplication.shared.keyWindow?.rootViewController?.view {
      button.rootView = view
    }
  }

  public func setupUI(icon: String, title: String) {
    button.setupImage(image: icon)
    if !title.isEmpty {
      titleLabel.text = title
    }
  }

  public lazy var button: NESocialDraggableButton = {
    let btn = NESocialDraggableButton()
    btn.imageView?.contentMode = .scaleAspectFill
    btn.frame = CGRectMake(20, 48, 40, 40)
    btn.initOrientation = UIApplication.shared.statusBarOrientation
    btn.originTransform = btn.transform
    btn.layer.masksToBounds = true
    btn.layer.cornerRadius = 20
    btn.layer.borderWidth = 2
    btn.layer.borderColor = UIColor.white.cgColor
    btn.clickAction = { [weak self] in
      btn.isSelected = !btn.isSelected
      if let hasFloatWindow = self?.hasFloatWindow,
         hasFloatWindow,
         let target = self?.target {
        let currentViewController = self?.findVisibleViewController()
        target.hidesBottomBarWhenPushed = true
        if let nav = currentViewController?.navigationController {
          nav.pushViewController(target, animated: true)
        } else {
          currentViewController?.present(target, animated: true)
        }
        self?.floatingView.isHidden = true
      }
    }
    return btn
  }()

  lazy var closeButton: UIButton = {
    let btn = UIButton(frame: CGRectMake(floatWindowWidth - 24, 0, 24, 24))
    btn.setImage(NESocialBundle.loadImage("close_room"), for: .normal)
    btn.backgroundColor = UIColor(white: 1, alpha: 0.6)
    btn.layer.cornerRadius = 12
    btn.clipsToBounds = true
    btn.addTarget(self, action: #selector(clickCloseButton), for: .touchUpInside)
    return btn
  }()

  func clickCloseButton() {
    closeAction?({})
    floatingView.isHidden = true
    target = nil
  }

  public lazy var floatingView: UIView = {
    let view = UIView(frame: CGRect(x: 0, y: 100, width: floatWindowWidth, height: floatWindowHeight))
    view.backgroundColor = .clear
    return view
  }()

  lazy var titleLabel: UILabel = {
    let view = UILabel(frame: CGRect(x: 15, y: 94, width: 50, height: 18))
    view.text = NESocialBundle.localized("Chatroom")
    view.font = UIFont.systemFont(ofSize: 14)
    view.textColor = .white
    return view
  }()

  func findVisibleViewController() -> UIViewController? {
    var currentViewController = getRootViewController()
    let runLoopFind = true

    while runLoopFind {
      if let presentedViewController = currentViewController?.presentedViewController {
        currentViewController = presentedViewController
      } else {
        if let navigationController = currentViewController as? UINavigationController {
          currentViewController = navigationController.visibleViewController
        } else if let tabBarController = currentViewController as? UITabBarController {
          currentViewController = tabBarController.selectedViewController
        } else {
          break
        }
      }
    }
    return currentViewController
  }

  func getRootViewController() -> UIViewController? {
    if let delegate = UIApplication.shared.delegate,
       let window = delegate.window {
      return window?.rootViewController
    }
    return UIApplication.shared.keyWindow?.rootViewController
  }
}
