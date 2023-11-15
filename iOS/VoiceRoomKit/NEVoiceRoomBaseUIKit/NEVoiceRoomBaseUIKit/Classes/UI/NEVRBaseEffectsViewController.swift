// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import NECommonUIKit
import UIKit
import NEVoiceRoomKit

class NESocialEffectsViewController: UIViewController {
  let clapEffectId: UInt32 = 8888
  let laughEffectId: UInt32 = 8889

  static func show(in viewController: UIViewController, present: NEVRBasePresent?) {
    let effects = NESocialEffectsViewController()
    effects.present = present
    let vc = NEActionSheetController(rootViewController: effects)
    if let lastVC = viewController.presentedViewController {
      lastVC.dismiss(animated: true) {
        viewController.present(vc, animated: true)
      }
    } else {
      viewController.present(vc, animated: true)
    }
  }

  weak var present: NEVRBasePresent?

  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
    title = NEVRBaseBundle.localized("Effects")
    view.backgroundColor = .white

    view.addSubview(clapButton)
    view.addSubview(laughButton)

    let width = (view.width - 40 - 12) / 2

    clapButton.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(20)
      make.top.equalToSuperview().offset(12)
      make.height.equalTo(36)
      make.width.equalTo(width)
    }
    laughButton.snp.makeConstraints { make in
      make.right.equalToSuperview().offset(-20)
      make.top.equalToSuperview().offset(12)
      make.height.equalTo(36)
      make.width.equalTo(width)
    }
  }

  lazy var clapButton: UIButton = createEffectsButton(image: "effects_clap", title: "Effects_Clap")

  lazy var laughButton: UIButton = createEffectsButton(image: "effects_laugh", title: "Effects_Laugh")

  func createEffectsButton(image: String, title: String) -> UIButton {
    let button = UIButton(type: .custom)
    button.clipsToBounds = true
    button.layer.cornerRadius = 6
    button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
    button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
    button.backgroundColor = UIColor(red: 242 / 255, green: 242 / 255, blue: 242 / 255, alpha: 1)
    button.setTitleColor(UIColor(red: 34 / 255, green: 34 / 255, blue: 34 / 255, alpha: 1), for: .normal)
    button.setImage(NEVRBaseBundle.loadImage(image), for: .normal)
    button.setTitle(NEVRBaseBundle.localized(title), for: .normal)
    button.addTarget(self, action: #selector(playEffects(sender:)), for: .touchUpInside)
    return button
  }

  @objc func playEffects(sender: UIButton) {
    NEVoiceRoomKit.getInstance().stopEffect(effectId: clapEffectId)
    NEVoiceRoomKit.getInstance().stopEffect(effectId: laughEffectId)

    var filePath: String?
    var effectId = clapEffectId
    if sender == clapButton {
      filePath = NEVRBaseBundle.bundle().path(forResource: "audio_effect_clap", ofType: "wav")
      effectId = clapEffectId
    } else if sender == laughButton {
      filePath = NEVRBaseBundle.bundle().path(forResource: "audio_effect_laugh", ofType: "wav")
      effectId = laughEffectId
    }
    if let path = filePath {
      let option = NEVoiceRoomCreateAudioEffectOption()
      option.path = path
      option.sendVolume = 100
      option.playbackVolume = 100
      option.sendWithAudioType = .main
      NEVoiceRoomKit.getInstance().playEffect(effectId, option: option)
    }
  }

  override public var preferredContentSize: CGSize {
    get {
      var preferedHeight: CGFloat = 0
      if #available(iOS 11.0, *) {
        let safeAreaBottom: CGFloat = UIApplication.shared.keyWindow?.rootViewController?.view.safeAreaInsets.bottom ?? 0
        preferedHeight += safeAreaBottom
      }
      preferedHeight += 60
      return CGSize(width: navigationController?.view.bounds.width ?? 0, height: preferedHeight)
    }
    set {
      super.preferredContentSize = newValue
    }
  }
}
