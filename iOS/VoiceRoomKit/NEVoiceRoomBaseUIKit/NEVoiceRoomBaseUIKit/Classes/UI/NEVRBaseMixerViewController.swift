// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import NECommonUIKit
import UIKit

class NEVRBaseMixerViewController: UIViewController {
  static func show(in viewController: UIViewController, present: NEVRBasePresent?) {
    let mixer = NEVRBaseMixerViewController()
    mixer.present = present
    let vc = NEActionSheetController(rootViewController: mixer)
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

    title = NEVRBaseBundle.localized("Mixer")
    view.backgroundColor = .white

    view.addSubview(recordVolumeCell)
    recordVolumeCell.addSubview(recordVolumeLabel)
    recordVolumeCell.addSubview(recordVolumeSlider)

    recordVolumeCell.snp.makeConstraints { make in
      make.height.equalTo(64)
      make.left.right.top.equalToSuperview()
    }
    recordVolumeLabel.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(20)
      make.centerY.equalToSuperview()
      make.width.equalTo(40)
    }
    recordVolumeSlider.snp.makeConstraints { make in
      make.right.equalToSuperview().offset(-20)
      make.centerY.equalToSuperview()
      make.left.equalTo(recordVolumeLabel.snp.right).offset(10)
    }

    if let volume = present?.getRecordVolume() {
      recordVolumeSlider.value = Float(volume)
    } else {
      present?.adjustRecordingSignalVolume(volume: 100)
      recordVolumeSlider.value = 100
    }
  }

  lazy var recordVolumeCell: UIView = .init()

  lazy var recordVolumeSlider: UISlider = {
    let view = UISlider()
    view.addTarget(self, action: #selector(recordVolumeSliderValueChanged(sender:)), for: .valueChanged)
    view.maximumValue = 200
    return view
  }()

  lazy var recordVolumeLabel: UILabel = {
    let view = UILabel()
    view.font = UIFont.systemFont(ofSize: 14)
    view.text = NEVRBaseBundle.localized("Voice")
    return view
  }()

  @objc func recordVolumeSliderValueChanged(sender: UISlider) {
    present?.adjustRecordingSignalVolume(volume: Int(sender.value))
  }

  override public var preferredContentSize: CGSize {
    get {
      var preferedHeight: CGFloat = 0
      if #available(iOS 11.0, *) {
        let safeAreaBottom: CGFloat = UIApplication.shared.keyWindow?.rootViewController?.view.safeAreaInsets.bottom ?? 0
        preferedHeight += safeAreaBottom
      }
      preferedHeight += 65
      return CGSize(width: navigationController?.view.bounds.width ?? 0, height: preferedHeight)
    }
    set {
      super.preferredContentSize = newValue
    }
  }
}
