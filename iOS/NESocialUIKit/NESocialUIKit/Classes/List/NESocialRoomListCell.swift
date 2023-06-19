// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import UIKit
import SnapKit

@objcMembers public class NESocialRoomViewModel: NSObject {
  var roomName: String?
  var anchorName: String?
  var memberCount: String?
  var isOnline: Bool?
  var onlineText: String?
  var image: UIImage?
}

@objcMembers public class NESocialRoomListCell: UICollectionViewCell {
  static func cell(collectionView: UICollectionView, indexPath: IndexPath, viewModel: NESocialRoomViewModel) -> NESocialRoomListCell {
    if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NESocialRoomListCell.description(), for: indexPath) as? NESocialRoomListCell {
      cell.setupViews(viewModel: viewModel)
      return cell
    }
    return NESocialRoomListCell(frame: .zero)
  }

  override public init(frame: CGRect) {
    super.init(frame: frame)

    contentView.backgroundColor = .blue

    contentView.addSubview(coverImageView)
    contentView.addSubview(roomNameLabel)
    contentView.addSubview(anchorNameLabel)
    contentView.addSubview(onlineLabel)
    contentView.addSubview(onlineCircle)
    contentView.addSubview(memberCountLabel)

    coverImageView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }

    onlineLabel.snp.makeConstraints { make in
      make.top.equalToSuperview().offset(8)
      make.right.equalToSuperview().offset(-8)
      make.height.equalTo(15)
      make.width.lessThanOrEqualTo(30)
    }

    onlineCircle.snp.makeConstraints { make in
      make.centerY.equalTo(onlineLabel)
      make.width.height.equalTo(5)
      make.right.equalTo(onlineLabel.snp.left).offset(-4)
    }

    memberCountLabel.snp.makeConstraints { make in
      make.bottom.right.equalToSuperview().offset(-8)
      make.height.equalTo(20)
      make.width.lessThanOrEqualTo(70)
    }

    anchorNameLabel.snp.makeConstraints { make in
      make.bottom.equalToSuperview().offset(-8)
      make.left.equalToSuperview().offset(8)
      make.height.equalTo(20)
      make.right.lessThanOrEqualTo(memberCountLabel.snp.left).offset(-8)
    }

    roomNameLabel.snp.makeConstraints { make in
      make.left.equalTo(anchorNameLabel)
      make.right.lessThanOrEqualToSuperview().offset(-8)
      make.height.equalTo(20)
      make.bottom.equalTo(anchorNameLabel.snp.top).offset(-8)
    }
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func setupViews(viewModel: NESocialRoomViewModel) {
    coverImageView.image = viewModel.image
    if let roomName = viewModel.roomName {
      roomNameLabel.isHidden = false
      roomNameLabel.text = roomName
    } else {
      roomNameLabel.isHidden = true
    }
    if let anchorName = viewModel.anchorName {
      anchorNameLabel.isHidden = false
      anchorNameLabel.text = anchorName
    } else {
      anchorNameLabel.isHidden = true
    }
    if let memberCount = viewModel.memberCount {
      memberCountLabel.isHidden = false
      memberCountLabel.text = memberCount
    } else {
      memberCountLabel.isHidden = true
    }
    if let online = viewModel.isOnline,
       online {
      onlineCircle.isHidden = false
      if let onlineText = viewModel.onlineText {
        onlineLabel.isHidden = false
        onlineLabel.text = onlineText
      }
    } else {
      onlineLabel.isHidden = true
      onlineCircle.isHidden = true
    }
  }

  // MARK: lazy

  lazy var coverImageView: UIImageView = {
    let view = UIImageView()
    return view
  }()

  lazy var roomNameLabel: NESoicalPaddingLabel = {
    let view = NESoicalPaddingLabel()
    view.textColor = .white
    view.font = UIFont(name: "PingFangSC-Regular", size: 13)
    view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
    view.layer.cornerRadius = 2
    return view
  }()

  lazy var anchorNameLabel: NESoicalPaddingLabel = {
    let view = NESoicalPaddingLabel()
    view.textColor = .white
    view.font = UIFont(name: "PingFangSC-Regular", size: 12)
    view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
    view.layer.cornerRadius = 2
    return view
  }()

  lazy var onlineLabel: UILabel = {
    let view = UILabel()
    view.textColor = .white
    view.font = UIFont(name: "PingFangSC-Regular", size: 10)
    return view
  }()

  lazy var onlineCircle: UIView = {
    let circleView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 5))
    circleView.backgroundColor = .green
    circleView.layer.cornerRadius = 2.5
    return circleView
  }()

  lazy var memberCountLabel: NESoicalPaddingLabel = {
    let view = NESoicalPaddingLabel()
    view.textColor = .white
    view.font = UIFont(name: "PingFangSC-Regular", size: 12)
    view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
    view.layer.cornerRadius = 2
    return view
  }()
}
