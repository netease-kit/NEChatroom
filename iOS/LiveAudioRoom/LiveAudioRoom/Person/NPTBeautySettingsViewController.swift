// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import UIKit
import SnapKit
import FaceUnity
import NERtcSDK

// TODO: 一对一视频通话要留口子来设置美颜
class NPTBeautySettingsViewController: UIViewController {
  override func viewDidLoad() {
    super.viewDidLoad()

    title = "Setting_Beauty".localized

    view.addSubview(videoView)
    videoView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }

    view.addSubview(buttonsView)
    buttonsView.snp.makeConstraints { make in
      make.height.equalTo(60)
      make.left.equalToSuperview().offset(56)
      make.right.equalToSuperview().offset(-56)
      if #available(iOS 11.0, *) {
        make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-56)
      } else {
        make.bottom.equalTo(view).offset(-56)
      }
    }

    buttonsView.addSubview(cameraBtn)
    cameraBtn.snp.makeConstraints { make in
      make.width.height.equalTo(60)
      make.left.top.equalToSuperview()
    }

    buttonsView.addSubview(checkBtn)
    checkBtn.snp.makeConstraints { make in
      make.width.height.equalTo(60)
      make.centerX.top.equalToSuperview()
    }

    buttonsView.addSubview(beautyBtn)
    beautyBtn.snp.makeConstraints { make in
      make.width.height.equalTo(60)
      make.right.top.equalToSuperview()
    }

    var safeAreaBottom: CGFloat = 0.0
    if #available(iOS 11.0, *) {
      safeAreaBottom = view.safeAreaInsets.bottom
    }
    FUDemoManager.share().show(inTargetController: self, originY: view.frame.height - safeAreaBottom - 88)
    FUDemoManager.share().hide()

    let context = NERtcEngineContext()
    context.appKey = Configs.AppKey
    NERtcEngine.shared().setupEngine(with: context)
    NERtcEngine.shared().setParameters([kNERtcKeyVideoCaptureObserverEnabled: true])
    let config = NERtcVideoEncodeConfiguration()
    config.width = 360
    config.height = 640
    config.frameRate = .fps60
    NERtcEngine.shared().setLocalVideoConfig(config)
    NERtcEngine.shared().setVideoFrameObserver(self)

    let canvas = NERtcVideoCanvas()
    canvas.container = videoView
    canvas.renderMode = .cropFill
    NERtcEngine.shared().setupLocalVideoCanvas(canvas)
    NERtcEngine.shared().startPreview()

    NotificationCenter.default.addObserver(self, selector: #selector(receiveInvite), name: NSNotification.Name("receiveInvite"), object: nil)
  }

  @objc func receiveInvite() {
    navigationController?.popViewController(animated: true)
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
    NERtcEngine.shared().stopPreview()
    NERtcEngine.destroy()
  }

  lazy var videoView: UIView = {
    let view = UIView()
    view.backgroundColor = .black
    let tap = UITapGestureRecognizer(target: self, action: #selector(hideBeauty))
    view.addGestureRecognizer(tap)
    return view
  }()

  @objc func hideBeauty() {
    FUDemoManager.share().hide()
    buttonsView.isHidden = false
  }

  lazy var buttonsView: UIView = {
    let view = UIView()
    return view
  }()

  lazy var cameraBtn: UIButton = {
    let btn = UIButton()
    btn.setImage(UIImage(named: "beauty_camera"), for: .normal)
    btn.addTarget(self, action: #selector(switchCamera), for: .touchUpInside)
    return btn
  }()

  @objc func switchCamera() {
    NERtcEngine.shared().switchCamera()
  }

  lazy var checkBtn: UIButton = {
    let btn = UIButton()
    btn.setImage(UIImage(named: "beauty_check"), for: .normal)
    btn.addTarget(self, action: #selector(check), for: .touchUpInside)
    return btn
  }()

  @objc func check() {
    navigationController?.popViewController(animated: true)
  }

  lazy var beautyBtn: UIButton = {
    let btn = UIButton()
    btn.setImage(UIImage(named: "beauty_settings"), for: .normal)
    btn.addTarget(self, action: #selector(beauty), for: .touchUpInside)
    return btn
  }()

  @objc func beauty() {
    FUDemoManager.share().show()
    buttonsView.isHidden = true
  }
}

extension NPTBeautySettingsViewController: NERtcEngineVideoFrameObserver {
  func onNERtcEngineVideoFrameCaptured(_ bufferRef: CVPixelBuffer, rotation: NERtcVideoRotationType) {
    FUManager.share().renderItems(to: bufferRef)
  }
}
