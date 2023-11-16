// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import UIKit
import NESocialUIKit
import NEVoiceRoomKit
import MJRefresh

public class NEVRBaseRoomListCell: UICollectionViewCell {
  static func cell(collectionView: UICollectionView, indexPath: IndexPath, viewModel: NEVoiceRoomInfo) -> NEVRBaseRoomListCell {
    if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(NEVRBaseRoomListCell.self), for: indexPath) as? NEVRBaseRoomListCell {
      cell.setupViews(viewModel: viewModel)
      return cell
    }
    return NEVRBaseRoomListCell(frame: .zero)
  }

  override public init(frame: CGRect) {
    super.init(frame: frame)

    contentView.backgroundColor = .clear

    contentView.addSubview(coverImageView)
    contentView.addSubview(roomNameLabel)
    contentView.addSubview(anchorNameLabel)
    contentView.addSubview(memberCountLabel)
    contentView.addSubview(gameNameView)

    coverImageView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
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

    gameNameView.snp.makeConstraints { make in
      make.size.equalTo(CGSize(width: 70, height: 25))
      make.top.right.equalToSuperview()
    }

    gameNameView.addSubview(gameNameLabel)
    gameNameLabel.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }

    contentView.layer.masksToBounds = true
    contentView.layer.cornerRadius = 10
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func setupViews(viewModel: NEVoiceRoomInfo) {
    if let str = viewModel.liveModel?.cover,
       let url = URL(string: str) {
      coverImageView.sd_setImage(with: url)
    }
    if let roomName = viewModel.liveModel?.liveTopic {
      roomNameLabel.isHidden = false
      roomNameLabel.text = roomName
    } else {
      roomNameLabel.isHidden = true
    }
    if let anchorName = viewModel.anchor?.userName {
      anchorNameLabel.isHidden = false
      anchorNameLabel.text = anchorName
    } else {
      anchorNameLabel.isHidden = true
    }
    if let memberCount = viewModel.liveModel?.audienceCount {
      memberCountLabel.isHidden = false
      memberCountLabel.text = String(memberCount + 1) + " " + NEVRBaseBundle.localized("Online_Count")
    } else {
      memberCountLabel.isHidden = true
    }
    if let gameName = viewModel.liveModel?.gameName,
       !gameName.isEmpty {
      gameNameView.isHidden = false
      gameNameLabel.text = gameName
    } else {
      gameNameView.isHidden = true
    }
  }

  // MARK: lazy

  lazy var coverImageView: UIImageView = {
    let view = UIImageView()
    view.contentMode = .top
    return view
  }()

  lazy var roomNameLabel: UILabel = {
    let view = UILabel()
    view.textColor = .white
    view.font = UIFont(name: "PingFangSC-Regular", size: 13)
    view.layer.cornerRadius = 2
    return view
  }()

  lazy var anchorNameLabel: UILabel = {
    let view = UILabel()
    view.textColor = .white
    view.font = UIFont(name: "PingFangSC-Regular", size: 12)
    view.layer.cornerRadius = 2
    return view
  }()

  lazy var memberCountLabel: UILabel = {
    let view = UILabel()
    view.textColor = .white
    view.font = UIFont(name: "PingFangSC-Regular", size: 12)
    view.layer.cornerRadius = 2
    return view
  }()

  lazy var gameNameView: UIView = {
    let view = UIView()
    let gradientLayer = CAGradientLayer()
    gradientLayer.colors = [
      UIColor(red: 0.196, green: 0.373, blue: 1, alpha: 1).cgColor,
      UIColor(red: 0.175, green: 0.604, blue: 1, alpha: 1).cgColor,
    ]
    gradientLayer.locations = [0, 1]
    gradientLayer.startPoint = CGPoint(x: 0.25, y: 0.5)
    gradientLayer.endPoint = CGPoint(x: 0.75, y: 0.5)
    gradientLayer.frame = CGRect(x: 0, y: 0, width: 70, height: 25)
    gradientLayer.cornerRadius = 10
    // 实际主工程也只需要支持11.0了，现在podspec的最低版本还在10，不适配10了
    if #available(iOS 11, *) {
      gradientLayer.maskedCorners = [.layerMinXMaxYCorner]
    }
    view.layer.insertSublayer(gradientLayer, at: 0)
    return view
  }()

  lazy var gameNameLabel: UILabel = {
    let view = UILabel()
    view.font = UIFont(name: "PingFangSC-Regular", size: 12)
    view.textColor = .white
    view.textAlignment = .center
    return view
  }()
}

open class NEVRBaseRoomListViewController: UIViewController {
  var liveType: NEVoiceRoomLiveRoomType = .multiAudio

  public init(liveType: NEVoiceRoomLiveRoomType) {
    super.init(nibName: nil, bundle: nil)
    self.liveType = liveType
  }

  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override public func viewDidLoad() {
    super.viewDidLoad()

    switch liveType {
    case .multiAudio:
      title = NEVRBaseBundle.localized("Voice_Room")
    case .listenTogether:
      title = NEVRBaseBundle.localized("Listen_Room")
    case .game:
      title = NEVRBaseBundle.localized("Gaming_Room")
    default:
      title = NEVRBaseBundle.localized("Voice_Room")
    }
    view.backgroundColor = .white

    view.addSubview(createBtn)
    createBtn.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(17)
      make.right.equalToSuperview().offset(-17)
      make.bottom.equalToSuperview().offset(-25)
      make.height.equalTo(48)
    }

    view.addSubview(collectionView)
    collectionView.snp.makeConstraints { make in
      if #available(iOS 11.0, *) {
        make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
      } else {
        make.top.equalTo(view).offset(10)
      }
      make.left.right.equalToSuperview()
      make.bottom.equalTo(createBtn.snp.top)
    }

    collectionView.addSubview(emptyView)
    emptyView.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.centerY.equalToSuperview().offset(-100)
    }
  }

  override open func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    getNewList()
  }

  lazy var viewModel: NEVRBaseRoomListViewModel = {
    let model = NEVRBaseRoomListViewModel(liveType: liveType)
    model.datasChanged = { [weak self] datas in
      self?.collectionView.reloadData()
      self?.emptyView.isHidden = datas.count > 0
    }
    model.isLoadingChanged = { [weak self] isLoading in
      if !isLoading {
        self?.collectionView.mj_header?.endRefreshing()
        self?.collectionView.mj_footer?.endRefreshing()
      }
    }
    model.errorChanged = { [weak self] error in
      guard let error = error else {
        return
      }
      if error.code == NEVRBaseRoomListViewModel.EMPTY_LIST_ERROR {
        self?.showToastInWindow(NEVRBaseBundle.localized("Room_List_Empty"))
      } else if error.code == NEVRBaseRoomListViewModel.NO_NETWORK_ERROR {
        self?.showToastInWindow(NEVRBaseBundle.localized("Net_Error"))
      } else {
        if let msg = error.userInfo[NSLocalizedDescriptionKey] as? String {
          self?.showToastInWindow(msg)
        } else {
          self?.showToastInWindow(NEVRBaseBundle.localized("Room_List_Error"))
        }
      }
    }
    return model
  }()

  func getNewList() {
    viewModel.requestNewData()
  }

  func getMoreList() {
    viewModel.requestMoreData()
  }

  lazy var emptyView: NESocialRoomListEmptyView = .init()

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
    view.register(NEVRBaseRoomListCell.self, forCellWithReuseIdentifier: NSStringFromClass(NEVRBaseRoomListCell.self))
    if #available(iOS 11.0, *) {
      view.contentInsetAdjustmentBehavior = .never
    }
    let mjHeader = MJRefreshGifHeader { [weak self] in
      self?.getNewList()
    }
    mjHeader.setTitle(NEVRBaseBundle.localized("Room_List_Update"), for: .idle)
    mjHeader.setTitle(NEVRBaseBundle.localized("Room_List_Update"), for: .pulling)
    mjHeader.setTitle(NEVRBaseBundle.localized("Room_List_Updating"), for: .refreshing)
    mjHeader.lastUpdatedTimeLabel?.isHidden = true
    mjHeader.tintColor = .white
    view.mj_header = mjHeader
    view.mj_footer = MJRefreshFooter(refreshingBlock: { [weak self] in
      if let isEnd = self?.viewModel.isEnd,
         isEnd {
        self?.showToastInWindow(NEVRBaseBundle.localized("Room_List_No_More"))
        self?.collectionView.mj_header?.endRefreshing()
      } else {
        self?.getMoreList()
      }
    })
    return view
  }()

  lazy var createBtn: UIButton = {
    let btn = UIButton()
    btn.setTitle(NEVRBaseBundle.localized("Create_Room_Title"), for: .normal)
    btn.backgroundColor = UIColor(red: 0.2, green: 0.494, blue: 1, alpha: 1)
    btn.layer.cornerRadius = 24
    btn.clipsToBounds = true
    btn.addTarget(self, action: #selector(createRoom), for: .touchUpInside)
    return btn
  }()

  public func createAction(params: NECreateVoiceRoomParams, button: UIButton) {
    NESocialToast.showLoading()
    NEVoiceRoomKit.getInstance().createRoom(params, options: NECreateVoiceRoomOptions()) { [weak self] code, msg, obj in
      DispatchQueue.main.async {
        NESocialToast.hideLoading()
        button.isEnabled = true
        if code == 0,
           let obj = obj {
          self?.pushToRoomViewController(obj, isHost: true)
        } else if code == 2001 {
          // 需要实名认证
          let view = NESocialAuthenticationViewController()
          view.authenticateAction = { name, cardNo in
            guard let name = name,
                  let cardNo = cardNo else {
              return
            }
            NEVoiceRoomKit.getInstance().authenticate(name: name, cardNo: cardNo) { [weak view] code, msg, obj in
              DispatchQueue.main.async {
                if code == 0 {
                  view?.showSucc(succ: nil)
                } else if code == NSURLErrorNotConnectedToInternet {
                  self?.showToastInWindow(NEVRBaseBundle.localized("Net_Error"))
                } else {
                  view?.showError(error: nil)
                }
              }
            }
          }
          self?.navigationController?.pushViewController(view, animated: true)
        } else {
          // 加入房间失败
          self?.showToastInWindow(NEVRBaseBundle.localized("Join_Room_Failed"))
        }
      }
    }
  }

  // 继承之后实现自己的跳转主页面逻辑
  open func pushToRoomViewController(_ roomInfoModel: NEVoiceRoomInfo, isHost: Bool) {}

  // 继承之后实现自己的跳转房间页面逻辑
  @objc open func createRoom() {}
}

extension NEVRBaseRoomListViewController: UICollectionViewDelegate {
  public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let roomInfoModel = viewModel.datas[indexPath.row]
    if NESocialFloatWindow.instance.hasFloatWindow {
      if NESocialFloatWindow.instance.roomUuid == roomInfoModel.liveModel?.roomUuid {
        // 已经小窗在当前房间
        NESocialFloatWindow.instance.button.clickAction?()
      } else {
        let alert = UIAlertController(title: NEVRBaseBundle.localized("Tips"), message: NEVRBaseBundle.localized("Leave_Room_Check"), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NEVRBaseBundle.localized("Cancel"), style: .cancel))
        alert.addAction(UIAlertAction(title: NEVRBaseBundle.localized("Comfirm"), style: .default, handler: { action in
          NESocialFloatWindow.instance.closeAction?({ [weak self] in
            DispatchQueue.main.async {
              self?.pushToRoomViewController(roomInfoModel, isHost: false)
            }
          })
        }))
      }
    } else {
      pushToRoomViewController(roomInfoModel, isHost: false)
    }
  }
}

extension NEVRBaseRoomListViewController: UICollectionViewDataSource {
  public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    viewModel.datas.count
  }

  public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    NEVRBaseRoomListCell.cell(collectionView: collectionView, indexPath: indexPath, viewModel: viewModel.datas[indexPath.row])
  }
}
