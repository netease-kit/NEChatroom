// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import SnapKit
import UIKit

public class NESocialHeaderView: UIView {
  /// 点击关闭按钮
  public var closeAction: ((UIButton) -> Void)?
  /// 点击公告
  public var announcementAction: (() -> Void)?
  /// 点击小窗
  public var smallWindowAction: (() -> Void)?
  /// 点击退出游戏
  public var leaveGameAction: (() -> Void)?

  /// 房间名
  public var roomName: String? {
    didSet {
      roomNameLabel.text = roomName
    }
  }

  /// 在线人数
  public var onlineNumber: Int = 0 {
    didSet {
      onlineLabel.text = String(format: NESocialBundle.localized("Number_Of_Online"), onlineNumber)
    }
  }

  /// 用于展示歌曲名等其他信息
  public var detail: NSAttributedString? {
    didSet {
      if let detail = detail {
        detailLabel.isHidden = false
        detailLabel.attributedText = detail
      } else {
        detailLabel.isHidden = true
      }
    }
  }

  override init(frame: CGRect) {
    super.init(frame: frame)

    addSubview(roomNameLabel)
    addSubview(closeBtn)
    addSubview(smallWindowBtn)
    addSubview(leaveGameBtn)
    addSubview(announcementBtn)
    addSubview(onlineLabel)
    addSubview(detailLabel)

    layout()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func layout() {
    closeBtn.snp.makeConstraints { make in
      make.width.height.equalTo(25)
      make.right.equalToSuperview().offset(-8)
      make.top.equalToSuperview()
    }

    smallWindowBtn.snp.makeConstraints { make in
      make.width.height.equalTo(25)
      make.right.equalTo(closeBtn.snp.left).offset(-8)
      make.top.equalToSuperview()
    }

    leaveGameBtn.snp.makeConstraints { make in
      make.edges.equalTo(smallWindowBtn)
    }

    detailLabel.snp.makeConstraints { make in
      make.right.equalTo(smallWindowBtn.snp.left).offset(-8)
      make.centerY.equalTo(closeBtn)
      make.width.lessThanOrEqualTo(100)
    }

    roomNameLabel.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.left.equalToSuperview().offset(8)
      make.right.equalTo(detailLabel.snp.left).offset(-8)
    }

    announcementBtn.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(8)
      make.bottom.equalToSuperview()
      make.height.equalTo(20)
    }

    onlineLabel.snp.makeConstraints { make in
      make.right.equalToSuperview().offset(-8)
      make.bottom.equalToSuperview()
      make.height.equalTo(20)
    }
  }

  private lazy var roomNameLabel: UILabel = {
    var view = UILabel()
    view.frame = CGRect(x: 0, y: 0, width: 128, height: 24)
    view.textColor = .white
    view.font = UIFont.systemFont(ofSize: 16)
    return view
  }()

  private lazy var closeBtn: UIButton = {
    var btn = UIButton()
    btn.setImage(NESocialBundle.loadImage("close_room"), for: .normal)
    btn.addTarget(self, action: #selector(closeBtnClicked(sender:)), for: .touchUpInside)
    return btn
  }()

  private lazy var announcementBtn: NESocialPaddingLabel = {
    var view = NESocialPaddingLabel()
    view.edgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
    view.backgroundColor = UIColor(white: 0, alpha: 0.5)
    view.layer.cornerRadius = 10
    view.clipsToBounds = true
    let font = UIFont.systemFont(ofSize: 12)
    let mutableString = NSMutableAttributedString()
    if let image = NESocialBundle.loadImage("announcement") {
      let attachment = NSTextAttachment()
      attachment.image = image
      attachment.bounds = CGRect(x: 0, y: (font.capHeight - 12) / 2, width: 12, height: 12)
      mutableString.append(NSAttributedString(attachment: attachment))
    }
    mutableString.append(NSAttributedString(string: " "))
    mutableString.append(NSAttributedString(string: NESocialBundle.localized("Announcement"), attributes: [.font: font, .foregroundColor: UIColor.white]))
    view.attributedText = mutableString
    let tap = UITapGestureRecognizer(target: self, action: #selector(announcementBtnClicked))
    view.addGestureRecognizer(tap)
    view.isUserInteractionEnabled = true
    return view
  }()

  private lazy var onlineLabel: NESocialPaddingLabel = {
    var view = NESocialPaddingLabel()
    view.frame = CGRect.zero
    view.backgroundColor = UIColor(white: 0, alpha: 0.5)
    view.layer.cornerRadius = 10
    view.clipsToBounds = true
    view.textColor = .white
    view.font = UIFont.systemFont(ofSize: 12)
    return view
  }()

  private lazy var detailLabel: UILabel = .init()

  public lazy var smallWindowBtn: UIButton = {
    var btn = UIButton()
    btn.setImage(NESocialBundle.loadImage("small_window_icon"), for: .normal)
    btn.addTarget(self, action: #selector(smallWindowBtnClicked), for: .touchUpInside)
    return btn
  }()

  public lazy var leaveGameBtn: UIButton = {
    var btn = UIButton()
    btn.setImage(NESocialBundle.loadImage("leave_game"), for: .normal)
    btn.addTarget(self, action: #selector(leaveGameBtnClicked), for: .touchUpInside)
    btn.isHidden = true
    return btn
  }()

  @objc private func smallWindowBtnClicked() {
    smallWindowAction?()
  }

  @objc private func closeBtnClicked(sender: UIButton) {
    closeAction?(sender)
  }

  @objc private func announcementBtnClicked() {
    announcementAction?()
  }

  @objc private func leaveGameBtnClicked() {
    leaveGameAction?()
  }
}
