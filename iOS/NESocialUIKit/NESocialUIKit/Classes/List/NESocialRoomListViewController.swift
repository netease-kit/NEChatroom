// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import UIKit
import SnapKit

@objcMembers public class NESocialRoomListViewController: UIViewController {
  override public func viewDidLoad() {
    super.viewDidLoad()

    view.addSubview(collectionView)
    view.addSubview(bottomView)
    collectionView.addSubview(refreshControl)

    bottomView.snp.makeConstraints { make in
      if #available(iOS 11.0, *) {
        make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-10)
      } else {
        make.bottom.equalTo(view).offset(-10)
      }
      make.left.right.equalToSuperview()
      make.height.equalTo(bottomViewHeight)
    }

    collectionView.snp.makeConstraints { make in
      if #available(iOS 11.0, *) {
        make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
      } else {
        make.top.equalTo(view).offset(10)
      }
      make.left.right.equalToSuperview()
      make.bottom.equalTo(bottomView.snp.top)
    }

    mock()
  }

  // 通过重写来设置底部视图的高度
  open var bottomViewHeight: CGFloat = 44

  lazy var bottomView: UIView = {
    let view = UIView()
    view.backgroundColor = .red
    return view
  }()

  // MARK: UICollectionView

  lazy var collectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.minimumLineSpacing = 8
    layout.minimumInteritemSpacing = 8
    let length = (view.frame.width - 24) / 2.0
    layout.itemSize = CGSize(width: length, height: length)
    layout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
    view.delegate = self
    view.dataSource = self
    view.alwaysBounceVertical = true
    view.backgroundColor = .white
    view.register(NESocialRoomListCell.self, forCellWithReuseIdentifier: NESocialRoomListCell.description())
    if #available(iOS 11.0, *) {
      view.contentInsetAdjustmentBehavior = .never
    }
    return view
  }()

  lazy var refreshControl: UIRefreshControl = {
    let control = UIRefreshControl()
    control.addTarget(self, action: #selector(refreshData), for: .valueChanged)
    return control
  }()

  open func refreshData() {
    // TODO: Refresh data
    refreshControl.endRefreshing()
  }

  open func loadMoreData() {
    // TODO: Load more
    mock()
    isWaiting = false
  }

  var dataSource: [NESocialRoomViewModel] = []
  var isWaiting: Bool = false

  // MARK: Mock data

  func mock() {
    for i in 0 ..< 10 {
      let model = NESocialRoomViewModel()
      model.memberCount = "100人"
      model.anchorName = "房主昵称房主昵称房主昵称房主昵称 \(i)"
      model.roomName = "房间名称房间名称房间名称房间名称房间名称房间名称房间名称房间名称"
      model.isOnline = i % 2 == 0
      model.onlineText = "在线"
      dataSource.append(model)
    }
    collectionView.reloadData()
  }
}

extension NESocialRoomListViewController: UICollectionViewDelegate {}

extension NESocialRoomListViewController: UICollectionViewDataSource {
  public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    dataSource.count
  }

  public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    NESocialRoomListCell.cell(collectionView: collectionView, indexPath: indexPath, viewModel: dataSource[indexPath.row])
  }

  public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    if indexPath.row == dataSource.count - 1,
       !isWaiting {
      isWaiting = true
      loadMoreData()
    }
  }
}
