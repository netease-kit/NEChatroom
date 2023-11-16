// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import NECommonUIKit
import UIKit

/// 内置按钮的tag，ViewController中的present通过tag来找到需要更新的按钮，比如耳机被拔掉之后更新耳返按钮的状态
public enum NESocialMoreInternalTag: Int {
  case mic = 10000
  case IEMs
  case effects
  case mixer
  case end
}

public class NESocialMoreItem: NSObject {
  public var image: UIImage?
  public var selectedImage: UIImage?
  public var title: String?
  public var selectedtitle: String?
  public var isSelected: Bool = false {
    didSet {
      if isSelected != oldValue {
        selectChanged?(isSelected)
      }
    }
  }

  public var tag: Int = 0
  public var isEnabled: Bool = true {
    didSet {
      if isEnabled != oldValue {
        enableChanged?(isEnabled)
      }
    }
  }

  public var isHidden: Bool = false

  public var action: ((NESocialMoreItem) -> Void)?

  var selectChanged: ((Bool) -> Void)?
  var enableChanged: ((Bool) -> Void)?

  // MARK: 内部提供了一些通用的按钮，如有定制化比较强的按钮则自行去实现

  /// 麦克风按钮
  public static func micItem(action: ((NESocialMoreItem) -> Void)?) -> NESocialMoreItem {
    let item = NESocialMoreItem()
    item.image = NESocialBundle.loadImage("more_mic_on")
    item.selectedImage = NESocialBundle.loadImage("more_mic_off")
    item.tag = NESocialMoreInternalTag.mic.rawValue
    item.action = action
    item.title = NESocialBundle.localized("Mic")
    item.selectedtitle = NESocialBundle.localized("Mic")
    return item
  }

  /// 耳返按钮
  public static func IEMsItem(action: ((NESocialMoreItem) -> Void)?) -> NESocialMoreItem {
    let item = NESocialMoreItem()
    item.image = NESocialBundle.loadImage("more_IEMs_on")
    item.selectedImage = NESocialBundle.loadImage("more_IEMs_off")
    item.tag = NESocialMoreInternalTag.IEMs.rawValue
    item.action = action
    item.title = NESocialBundle.localized("IEMs")
    item.selectedtitle = NESocialBundle.localized("IEMs")
    return item
  }

  /// 音效按钮
  public static func effectsItem(action: ((NESocialMoreItem) -> Void)?) -> NESocialMoreItem {
    let item = NESocialMoreItem()
    item.image = NESocialBundle.loadImage("more_effects")
    item.tag = NESocialMoreInternalTag.effects.rawValue
    item.action = action
    item.title = NESocialBundle.localized("Effects")
    return item
  }

  /// 调音台按钮
  public static func mixerItem(action: ((NESocialMoreItem) -> Void)?) -> NESocialMoreItem {
    let item = NESocialMoreItem()
    item.image = NESocialBundle.loadImage("more_mixer")
    item.tag = NESocialMoreInternalTag.mixer.rawValue
    item.action = action
    item.title = NESocialBundle.localized("Mixer")
    item.selectedtitle = NESocialBundle.localized("Mixer")
    return item
  }

  /// 结束直播按钮
  public static func endItem(action: ((NESocialMoreItem) -> Void)?) -> NESocialMoreItem {
    let item = NESocialMoreItem()
    item.image = NESocialBundle.loadImage("more_end")
    item.tag = NESocialMoreInternalTag.end.rawValue
    item.action = action
    item.title = NESocialBundle.localized("End_Live")
    return item
  }
}

class NESocialMoreCell: UICollectionViewCell {
  weak var item: NESocialMoreItem?

  override init(frame: CGRect) {
    super.init(frame: frame)
    contentView.addSubview(imageButton)
    imageButton.frame = contentView.bounds
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func setup(item: NESocialMoreItem) {
    imageButton.setTitle(item.title, for: .normal)
    imageButton.setImage(item.image, for: .normal)
    imageButton.setImage(item.selectedImage, for: .selected)
    imageButton.setTitle(item.selectedtitle, for: .selected)
    imageButton.isSelected = item.isSelected
    imageButton.isEnabled = item.isEnabled

    self.item = item
  }

  lazy var imageButton: NESocialImageButton = {
    let btn = NESocialImageButton()
    btn.addTarget(self, action: #selector(btnClicked), for: .touchUpInside)
    return btn
  }()

  @objc private func btnClicked() {
    if let item = item {
      item.action?(item)
    }
  }
}

public class NESocialMoreViewController: UIViewController {
  private static var navController: NEActionSheetController?

  /// 弹出更多视图控制器
  /// - Parameters:
  ///   - viewController: 父视图控制器
  ///   - dataSource: 数据源，Swift的list是值类型，这里只支持修改NESocialMoreItem的属性，不支持动态增删item，如有需要后续改为引用类型
  public static func show(in viewController: UIViewController, dataSource: [NESocialMoreItem]?) {
    let more = NESocialMoreViewController(dataSource: dataSource)
    let vc = NEActionSheetController(rootViewController: more)
    viewController.present(vc, animated: true)
    navController = vc
  }

  init(dataSource: [NESocialMoreItem]?) {
    super.init(nibName: nil, bundle: nil)
    self.dataSource = dataSource
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public static func dismiss() {
    navController?.dismiss(animated: true)
    navController = nil
  }

  var dataSource: [NESocialMoreItem]?
  /// 过滤掉隐藏的item
  var realDataSource: [NESocialMoreItem]? {
    dataSource?.filter { $0.isHidden == false }
  }

  override public func viewDidLoad() {
    super.viewDidLoad()

    title = NESocialBundle.localized("More")
    view.addSubview(collectionView)
    collectionView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    reload()
  }

  private func reload() {
    dataSource?.forEach { item in
      // item的选中状态和可点击状态改变之后刷新页面
      item.selectChanged = { [weak self] _ in
        if let row = self?.realDataSource?.firstIndex(of: item) {
          UIView.performWithoutAnimation {
            self?.collectionView.reloadItems(at: [IndexPath(row: row, section: 0)])
          }
        }
      }
      item.enableChanged = { [weak self] _ in
        if let row = self?.realDataSource?.firstIndex(of: item) {
          UIView.performWithoutAnimation {
            self?.collectionView.reloadItems(at: [IndexPath(row: row, section: 0)])
          }
        }
      }
    }
    collectionView.reloadData()
  }

  override public var preferredContentSize: CGSize {
    get {
      var preferedHeight: CGFloat = 0
      if #available(iOS 11.0, *) {
        let safeAreaBottom: CGFloat = UIApplication.shared.keyWindow?.rootViewController?.view.safeAreaInsets.bottom ?? 0
        preferedHeight += safeAreaBottom
      }
      let preferredWidth = navigationController?.view.frame.width ?? 0
      if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
        let count = realDataSource?.count ?? 0
        let wholeWidth: CGFloat = preferredWidth - flowLayout.sectionInset.left - flowLayout.sectionInset.right + flowLayout.minimumInteritemSpacing
        let perWidth: CGFloat = flowLayout.itemSize.width + flowLayout.minimumInteritemSpacing
        let itemsPerLine = Int(wholeWidth / perWidth)
        let lineCount = CGFloat(count / itemsPerLine + (count % itemsPerLine > 0 ? 1 : 0))
        preferedHeight += lineCount * flowLayout.itemSize.height
        preferedHeight += flowLayout.sectionInset.top
        preferedHeight += flowLayout.sectionInset.bottom
        preferedHeight += (lineCount - 1) * flowLayout.minimumLineSpacing
        return CGSizeMake(preferredWidth, preferedHeight)
      }
      return CGSize.zero
    }
    set {
      super.preferredContentSize = newValue
    }
  }

  lazy var collectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.minimumLineSpacing = 16
    layout.itemSize = CGSizeMake(70, 94)
    layout.sectionInset = UIEdgeInsets(top: 16, left: 30, bottom: 16, right: 30)
    let view = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
    view.backgroundColor = .white
    view.isScrollEnabled = false
    view.dataSource = self
    view.register(NESocialMoreCell.self, forCellWithReuseIdentifier: NESocialMoreCell.description())
    return view
  }()
}

extension NESocialMoreViewController: UICollectionViewDataSource {
  public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    realDataSource?.count ?? 0
  }

  public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NESocialMoreCell.description(), for: indexPath) as? NESocialMoreCell {
      if let dataSource = realDataSource,
         indexPath.row < dataSource.count {
        let data = dataSource[indexPath.row]
        cell.setup(item: data)
      }
      return cell
    }
    return UICollectionViewCell()
  }
}
