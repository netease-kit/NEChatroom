// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import LottieSwift
import SDWebImage
import UIKit

/// 简易版麦位列表cell，与正常版对比少了币值与说话波纹
class NEVRBaseSeatExCell: UICollectionViewCell {
  weak var cellModel: NEVRBaseSeatCellModel?

  override init(frame: CGRect) {
    super.init(frame: frame)

    contentView.addSubview(iconImageView)
    contentView.addSubview(loadingView)
    loadingView.addSubview(loadingAnimationView)
    contentView.addSubview(extImageView)
    contentView.addSubview(micImageView)
    contentView.addSubview(nameLabel)
    contentView.addSubview(extLabel)

    iconImageView.snp.makeConstraints { make in
      make.height.width.equalTo(38)
      make.left.equalToSuperview()
      make.top.equalToSuperview().offset(9)
    }
    iconImageView.layer.cornerRadius = 19
    iconImageView.clipsToBounds = true

    micImageView.snp.makeConstraints { make in
      make.width.height.equalTo(12)
      make.right.bottom.equalTo(iconImageView)
    }
    loadingView.snp.makeConstraints { make in
      make.edges.equalTo(iconImageView)
    }
    loadingView.layer.cornerRadius = iconImageView.layer.cornerRadius
    loadingView.clipsToBounds = true

    loadingAnimationView.snp.makeConstraints { make in
      make.width.height.equalTo(loadingView).dividedBy(2)
      make.center.equalTo(loadingView)
    }
    nameLabel.snp.makeConstraints { make in
      make.top.equalTo(iconImageView.snp.bottom).offset(4)
      make.left.right.bottom.equalToSuperview()
    }
    extLabel.snp.makeConstraints { make in
      make.width.equalTo(36)
      make.height.equalTo(14)
      make.centerX.equalToSuperview()
      make.top.equalToSuperview()
    }
    extLabel.layer.cornerRadius = 7
    extLabel.clipsToBounds = true

    extImageView.snp.makeConstraints { make in
      make.edges.equalTo(iconImageView)
    }
    extImageView.layer.cornerRadius = iconImageView.layer.cornerRadius
    extImageView.clipsToBounds = true
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  /// 根据cellModel来更新UI
  /// - Parameter cellModel: cell的model
  func setup(_ cellModel: NEVRBaseSeatCellModel) {
    self.cellModel = cellModel
    if let index = cellModel.seatIndex {
      nameLabel.text = NEVRBaseBundle.localized("Seat") + " \(index - 1)"
    } else {
      nameLabel.text = cellModel.nickname ?? cellModel.uuid
    }
    switch cellModel.state {
    case .idle:
      iconImageView.image = NEVRBaseBundle.loadImage("seat_free")
      iconImageView.layer.borderWidth = 0
    case .closed:
      iconImageView.image = NEVRBaseBundle.loadImage("seat_closed")
      iconImageView.layer.borderWidth = 0
    case .taking, .taken:
      if let urlStr = cellModel.iconUrl,
         let url = URL(string: urlStr) {
        iconImageView.sd_setImage(with: url)
        iconImageView.layer.borderWidth = 1
      }
      nameLabel.text = cellModel.nickname ?? cellModel.uuid
    }

    // 麦克风图标
    micImageView.isHidden = cellModel.state != .taken
    switch cellModel.micState {
    case .on:
      micImageView.image = NEVRBaseBundle.loadImage("seat_mic_on")
    case .off:
      micImageView.image = NEVRBaseBundle.loadImage("seat_mic_off")
    case .banded:
      micImageView.image = NEVRBaseBundle.loadImage("seat_mic_banded")
    }

    /// 申请loading动画
    if cellModel.state == .taking {
      loadingView.isHidden = false
      loadingAnimationView.play()
    } else {
      loadingView.isHidden = true
      loadingAnimationView.stop()
    }

    if let ext = cellModel.ext,
       !ext.isEmpty {
      extLabel.isHidden = false
      extLabel.text = ext
    } else {
      extLabel.isHidden = true
    }

    extImageView.image = cellModel.extImage
    extImageView.isHidden = cellModel.extImage == nil
  }

  lazy var iconImageView: UIImageView = {
    let view = UIImageView()
    view.layer.borderColor = UIColor.white.cgColor
    return view
  }()

  lazy var micImageView: UIImageView = .init()

  lazy var nameLabel: UILabel = {
    let view = UILabel()
    view.textAlignment = .center
    view.textColor = .white
    view.font = UIFont(name: "PingFangSC-Regular", size: 10) ?? UIFont.systemFont(ofSize: 10)
    return view
  }()

  lazy var loadingView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor(white: 0, alpha: 0.5)
    return view
  }()

  lazy var loadingAnimationView: LottieAnimationView = {
    let view = LottieAnimationView(name: "loading", bundle: NEVRBaseBundle.bundle())
    view.loopMode = .loop
    return view
  }()

  lazy var extImageView: UIImageView = .init()

  lazy var extLabel: UILabel = {
    let view = UILabel()
    view.backgroundColor = .white
    view.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
    view.font = UIFont(name: "PingFangSC-Regular", size: 8)
    view.textAlignment = .center
    return view
  }()
}

/// 搭载NEVRBaseSeatExCell的View，给游戏房等场景使用
public class NEVRBaseSeatsViewEx: UIView {
  var cellModels: [NEVRBaseSeatCellModel]?
  public var clickedAction: ((NEVRBaseSeatCellModel) -> Void)?

  override public init(frame: CGRect) {
    super.init(frame: frame)

    addSubview(collectionView)
    collectionView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  /// 设置观众麦位状态，只在layout是focus的时候生效
  /// - Parameter cellModels: 观众麦位model，Swift的list是值类型，这里只支持修改NEVRBaseSeatCellModel的属性，不支持动态增删item，如有需要后续改为引用类型
  public func setupWholeModels(_ cellModels: [NEVRBaseSeatCellModel]) {
    self.cellModels = cellModels
    self.cellModels?.forEach { model in
      /// model的属性发生了变化，刷新单个cell
      model.propertyChanged.append { [weak self] in
        if let row = self?.cellModels?.firstIndex(of: model) {
          UIView.performWithoutAnimation {
            self?.collectionView.reloadItems(at: [IndexPath(row: row, section: 0)])
          }
        }
      }
    }
    reloadData()
  }

  func reloadData() {
    collectionView.reloadData()
  }

  lazy var collectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.minimumLineSpacing = 10
    layout.minimumInteritemSpacing = 10
    layout.itemSize = CGSize(width: 38, height: 63)
    layout.scrollDirection = .horizontal
    let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
    view.backgroundColor = .clear
    view.dataSource = self
    view.delegate = self
    view.register(NEVRBaseSeatExCell.self, forCellWithReuseIdentifier: "NEVRBaseSeatExCell")
    view.showsHorizontalScrollIndicator = false
    return view
  }()
}

extension NEVRBaseSeatsViewEx: UICollectionViewDelegate {
  public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    if let cellModels = cellModels,
       indexPath.row < cellModels.count {
      clickedAction?(cellModels[indexPath.row])
    }
  }
}

extension NEVRBaseSeatsViewEx: UICollectionViewDataSource {
  public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    cellModels?.count ?? 0
  }

  public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NEVRBaseSeatExCell", for: indexPath) as? NEVRBaseSeatExCell {
      if let dataSource = cellModels,
         indexPath.row < dataSource.count {
        let data = dataSource[indexPath.row]
        cell.setup(data)
      }
      return cell
    }
    return UICollectionViewCell()
  }
}
