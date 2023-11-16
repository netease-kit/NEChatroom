// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import LottieSwift
import SDWebImage
import UIKit

/// 麦位闲忙状态
public enum NEVRBaseSeatState {
  /// 空闲
  case idle
  /// 申请中
  case taking
  /// 已占用
  case taken
  /// 关闭
  case closed
}

/// 麦位麦克风状态
public enum NEVRBaseSeatMicState {
  /// 关闭
  case off
  /// 打开
  case on
  /// 禁用
  case banded
}

public class NEVRBaseSeatCellModel: NSObject {
  /// 麦位闲忙状态
  public var state: NEVRBaseSeatState = .idle
  /// 麦位麦克风状态
  public var micState: NEVRBaseSeatMicState = .off

  /// 麦位上的用户uuid
  public var uuid: String?
  /// 麦位上的用户昵称
  public var nickname: String?
  /// 麦位上的用户头像url
  public var iconUrl: String?
  /// 麦位上的用户云币数
  public var coinsCount: Int = 0
  /// 是否正在讲话
  var isSpeaking: Bool = false {
    didSet {
      if isSpeaking != oldValue {
        isSpeakingChanged.forEach { listener in
          listener(isSpeaking)
        }
      }
    }
  }

  /// 对应的服务器下发的麦位的index，除了操作麦位的时候作为SDK的入参，没有其他用途
  public var seatIndex: Int?

  /// 外面在将property全部更新完之后主动调用propertyChanged来刷新cell
  /// NESocialMoreItem中直接通过 didset 来触发界面更新是因为它的property变动不频繁
  public var propertyChanged: [() -> Void] = []
  /// 因为这个处理可能会频繁，所以跟propertyChanged区分开来，只做波纹动画的刷新
  /// 正在讲话状态变更，外部只需要赋值isSpeaking，不需要单独调用这个
  fileprivate var isSpeakingChanged: [(Bool) -> Void] = []

  /// 自定义信息
  public var ext: String?

  /// 自定义图片，会展示到最上层
  public var extImage: UIImage?

  convenience init(state: NEVRBaseSeatState, micState: NEVRBaseSeatMicState, uuid: String?, nickname: String?, iconUrl: String?, coinsCount: Int, isSpeaking: Bool = false) {
    self.init()
    self.state = state
    self.micState = micState
    self.uuid = uuid
    self.nickname = nickname
    self.iconUrl = iconUrl
    self.coinsCount = coinsCount
    self.isSpeaking = isSpeaking
  }

  public func reloadByProperty() {
    propertyChanged.forEach { block in
      block()
    }
  }
}

class NEVRBaseSeatCell: UICollectionViewCell {
  weak var cellModel: NEVRBaseSeatCellModel?

  override init(frame: CGRect) {
    super.init(frame: frame)

    contentView.addSubview(waveAnimationView)
    contentView.addSubview(iconImageView)
    contentView.addSubview(loadingView)
    loadingView.addSubview(loadingAnimationView)
    contentView.addSubview(micImageView)
    contentView.addSubview(nameLabel)
    contentView.addSubview(coinLabel)

    waveAnimationView.snp.makeConstraints { make in
      make.width.top.equalToSuperview()
      make.height.equalTo(waveAnimationView.snp.width)
    }
    iconImageView.snp.makeConstraints { make in
      make.top.left.equalTo(waveAnimationView).offset(15)
      make.bottom.right.equalTo(waveAnimationView).offset(-15)
    }
    iconImageView.layer.cornerRadius = (frame.width - 30) / 2
    iconImageView.clipsToBounds = true

    micImageView.snp.makeConstraints { make in
      make.width.height.equalTo(16)
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
      make.top.equalTo(waveAnimationView.snp.bottom)
      make.left.right.equalToSuperview()
    }
    coinLabel.snp.makeConstraints { make in
      make.top.equalTo(nameLabel.snp.bottom).offset(5)
      make.left.right.equalToSuperview()
    }
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

    if cellModel.state != .taken {
      setupWave(isSpeaking: false)
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

    // 礼物值
    if cellModel.coinsCount > 0,
       cellModel.state == .taken {
      var coinsCount = String(cellModel.coinsCount)
      if cellModel.coinsCount > 99999 {
        coinsCount = "99999+"
      }
      let mutableString = NSMutableAttributedString()
      let attachment = NSTextAttachment()
      attachment.image = NEVRBaseBundle.loadImage("seat_coin")
      attachment.bounds = CGRect(x: 0, y: (coinLabel.font.capHeight - 12) / 2, width: 12, height: 12)
      mutableString.append(NSAttributedString(attachment: attachment))
      mutableString.append(NSAttributedString(string: " "))
      mutableString.append(NSAttributedString(string: coinsCount, attributes: [.font: coinLabel.font ?? UIFont.systemFont(ofSize: 10), .foregroundColor: UIColor(hexString: "#FFC86B")]))
      coinLabel.attributedText = mutableString
    } else {
      coinLabel.attributedText = nil
    }
    /// 申请loading动画
    if cellModel.state == .taking {
      loadingView.isHidden = false
      loadingAnimationView.play()
    } else {
      loadingView.isHidden = true
      loadingAnimationView.stop()
    }
  }

  func setupWave(isSpeaking: Bool) {
    if cellModel?.state != .taken {
      waveAnimationView.isHidden = true
      waveAnimationView.stop()
      return
    }
    /// 波纹动画
    if isSpeaking {
      waveAnimationView.isHidden = false
      waveAnimationView.play()
    } else {
      waveAnimationView.isHidden = true
      waveAnimationView.stop()
    }
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
    view.font = UIFont(name: "PingFangSC-Regular", size: 12) ?? UIFont.systemFont(ofSize: 12)
    return view
  }()

  lazy var coinLabel: UILabel = {
    let view = UILabel()
    view.textAlignment = .center
    view.textColor = .white
    view.font = UIFont(name: "PingFangSC-Regular", size: 10) ?? UIFont.systemFont(ofSize: 10)
    return view
  }()

  lazy var waveAnimationView: LottieAnimationView = {
    let view = LottieAnimationView(name: "speaker_wave", bundle: NEVRBaseBundle.bundle())
    view.loopMode = .loop
    view.isHidden = true
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
}

public class NEVRBaseSeatsView: UIView {
  var cellModels: [NEVRBaseSeatCellModel]?
  var clickedAction: ((NEVRBaseSeatCellModel) -> Void)?

  override init(frame: CGRect) {
    super.init(frame: frame)

    addSubview(collectionView)
    addSubview(ownerView)
    let layout = calculateLayout(width: frame.width)
    ownerView.snp.makeConstraints { make in
      make.width.equalTo(layout.itemSize.width)
      make.height.equalTo(layout.itemSize.height)
      make.centerX.top.equalToSuperview()
    }
    collectionView.snp.makeConstraints { make in
      make.left.right.bottom.equalToSuperview()
      make.height.equalTo(calculateCollectionViewSize(width: frame.width))
    }
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  /// 设置观众麦位状态
  /// - Parameter cellModels: 观众麦位model，Swift的list是值类型，这里只支持修改NEVRBaseSeatCellModel的属性，不支持动态增删item，如有需要后续改为引用类型
  func setupAudience(_ cellModels: [NEVRBaseSeatCellModel]) {
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
      model.isSpeakingChanged.append { [weak self] isSpeaking in
        if let row = self?.cellModels?.firstIndex(of: model),
           let cell = self?.collectionView.cellForItem(at: IndexPath(row: row, section: 0)) as? NEVRBaseSeatCell {
          cell.setupWave(isSpeaking: isSpeaking)
        }
      }
    }
    reloadData()
  }

  /// 设置主播麦位状态
  /// - Parameter cellModel: 主播麦位model
  func setupOwner(_ cellModel: NEVRBaseSeatCellModel) {
    ownerView.setup(cellModel)
    /// model的属性发生了变化，刷新单个cell
    cellModel.propertyChanged.append { [weak self] in
      self?.ownerView.setup(cellModel)
    }
    cellModel.isSpeakingChanged.append { [weak self] isSpeaking in
      self?.ownerView.setupWave(isSpeaking: isSpeaking)
    }
  }

  func reloadData() {
    collectionView.reloadData()
  }

  lazy var collectionView: UICollectionView = {
    let view = UICollectionView(frame: .zero, collectionViewLayout: calculateLayout(width: bounds.width))
    view.backgroundColor = .clear
    view.dataSource = self
    view.delegate = self
    view.register(NEVRBaseSeatCell.self, forCellWithReuseIdentifier: "NEVRBaseSeatCell")
    return view
  }()

  lazy var ownerView: NEVRBaseSeatCell = {
    let layout = calculateLayout(width: bounds.width)
    let cell = NEVRBaseSeatCell(frame: CGRect(x: 0, y: 0, width: layout.itemSize.width, height: layout.itemSize.height))
    return cell
  }()
}

extension NEVRBaseSeatsView: UICollectionViewDelegate {
  public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    if let cellModels = cellModels,
       indexPath.row < cellModels.count {
      clickedAction?(cellModels[indexPath.row])
    }
  }
}

extension NEVRBaseSeatsView: UICollectionViewDataSource {
  public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    cellModels?.count ?? 0
  }

  public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NEVRBaseSeatCell", for: indexPath) as? NEVRBaseSeatCell {
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

// MARK: 布局的计算方法

extension NEVRBaseSeatsView {
  /// 计算整个View的大小，width需要固定，height最终计算获得
  /// - Parameters:
  ///   - width: 整个view的宽度
  /// - Returns: view的合适size
  func calculateViewSize(width: CGFloat) -> CGSize {
    let size = calculateCollectionViewSize(width: width)
    var height = size.height
    // 加与主播cell之间的间距
    height += 1
    let flowLayout = calculateLayout(width: width)
    // 加主播cell的大小
    height += flowLayout.itemSize.height
    return CGSize(width: width, height: height)
  }

  /// 计算collectionView的大小，width需要固定，height最终计算获得
  /// - Parameters:
  ///   - width: 整个view的宽度
  /// - Returns: view的合适size
  func calculateCollectionViewSize(width: CGFloat) -> CGSize {
    let flowLayout = calculateLayout(width: width)
    var preferedHeight: CGFloat = 0
    // 固定两行
    let lineCount: CGFloat = 2
    preferedHeight += lineCount * flowLayout.itemSize.height
    preferedHeight += (lineCount - 1) * flowLayout.minimumLineSpacing
    return CGSizeMake(width, preferedHeight)
  }

  /// 根据width计算4个一行的理想layout
  /// - Parameter width: 整个view的宽度
  /// - Returns: collectionView合适的layout
  func calculateLayout(width: CGFloat) -> UICollectionViewFlowLayout {
    let layout = UICollectionViewFlowLayout()
    layout.minimumLineSpacing = 1
    layout.minimumInteritemSpacing = 10
    // 单个cell的宽度是(总宽度-5个间距)/4
    let itemWidth = (width - 5 * 10) / 4
    // 高度要比宽度多39，因为要放几个label，不是正方形的
    layout.itemSize = CGSize(width: itemWidth, height: itemWidth + 39)
    return layout
  }
}
