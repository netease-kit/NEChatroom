// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import UIKit
import SnapKit
import NEVoiceRoomKit

@objcMembers
public class NEVRBaseCreateViewController: UIViewController {
  // 创建动作先让各业务自己去完成，点击后按钮置为不可点，完成加入后由调用方打开enable
  public var createAction: ((String, String, UIButton) -> Void)?

  override public func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.setNavigationBarHidden(true, animated: true)
  }

  override public func viewDidLoad() {
    super.viewDidLoad()

    title = NEVRBaseBundle.localized("Create_Room_Title")

    view.addSubview(backgroundImage)
    view.addSubview(nameLabel)
    view.addSubview(nameInputView)
    view.addSubview(backgroundLabel)
    view.addSubview(collectionView)
    view.addSubview(createBtn)
    nameInputView.addSubview(randomBtn)
    nameInputView.addSubview(nameTextView)
    view.addSubview(backButton)
    view.addSubview(titleLabel)

    backButton.snp.makeConstraints { make in
      make.width.height.equalTo(24)
      make.left.equalToSuperview().offset(20)
      if #available(iOS 11.0, *) {
        make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
      } else {
        make.top.equalToSuperview().offset(10)
      }
    }

    titleLabel.snp.makeConstraints { make in
      make.height.equalTo(30)
      make.centerX.equalToSuperview()
      make.centerY.equalTo(backButton)
    }

    backgroundImage.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    nameLabel.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(20)
      make.top.equalTo(titleLabel.snp.bottom).offset(44)
      make.right.equalToSuperview()
    }
    nameInputView.snp.makeConstraints { make in
      make.top.equalTo(nameLabel.snp.bottom).offset(12)
      make.left.equalTo(nameLabel)
      make.right.equalToSuperview().offset(-20)
      make.height.equalTo(100)
    }
    backgroundLabel.snp.makeConstraints { make in
      make.left.equalTo(nameLabel)
      make.top.equalTo(nameInputView.snp.bottom).offset(30)
      make.right.equalToSuperview()
    }
    createBtn.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(17)
      make.right.equalToSuperview().offset(-17)
      make.height.equalTo(48)
      make.bottom.equalToSuperview().offset(-25)
    }
    collectionView.snp.makeConstraints { make in
      make.left.right.equalTo(nameInputView)
      make.top.equalTo(backgroundLabel.snp.bottom).offset(12)
      make.bottom.equalTo(createBtn.snp.top).offset(-50)
    }
    randomBtn.snp.makeConstraints { make in
      make.top.equalToSuperview().offset(10)
      make.right.equalToSuperview().offset(-10)
      make.width.height.equalTo(24)
    }
    nameTextView.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.left.equalToSuperview().offset(13)
      make.bottom.equalToSuperview().offset(-13)
      make.right.equalTo(randomBtn.snp.left).offset(-13)
    }

    randomLiveInfo()
  }

  func randomLiveInfo() {
    NEVoiceRoomKit.getInstance().getCreateRoomDefaultInfo { [weak self] code, msg, obj in
      if code == 0 {
        DispatchQueue.main.async {
          if let name = obj?.topic {
            self?.nameTextView.text = name
          }
          if let backgroudImages = obj?.defaultPictures {
            self?.backgroudImages = backgroudImages
            if backgroudImages.count > 0 {
              if let selectedImage = self?.selectedImage,
                 backgroudImages.contains(selectedImage) {
                for i in 0 ..< backgroudImages.count {
                  if backgroudImages[i] == selectedImage {
                    self?.collectionView.reloadData()
                    self?.collectionView.selectItem(at: IndexPath(row: i, section: 0), animated: false, scrollPosition: .top)
                  }
                }
              } else {
                self?.selectedImage = backgroudImages.first
                self?.collectionView.reloadData()
                self?.collectionView.selectItem(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .top)
              }
            }
          }
        }
      }
    }
  }

  lazy var backgroundImage: UIImageView = {
    let view = UIImageView()
    view.backgroundColor = UIColor(red: 30.0 / 255.0, green: 28.0 / 255.0, blue: 43.0 / 255.0, alpha: 1)
    return view
  }()

  lazy var createBtn: UIButton = {
    let btn = UIButton()
    btn.setTitle(NEVRBaseBundle.localized("Create_Room"), for: .normal)
    btn.setTitleColor(.white, for: .normal)
    btn.backgroundColor = UIColor(red: 0.2, green: 0.494, blue: 1, alpha: 1)
    btn.layer.cornerRadius = 24
    btn.clipsToBounds = true
    btn.addTarget(self, action: #selector(createRoom), for: .touchUpInside)
    return btn
  }()

  func createRoom() {
    guard let name = nameTextView.text,
          !name.isEmpty else {
      showToast(NEVRBaseBundle.localized("Room_Name_Empty"))
      return
    }
    guard isValidRoomName(name) else {
      showToast(NEVRBaseBundle.localized("Room_Name_Invalid"))
      return
    }
    guard let image = selectedImage else {
      showToast(NEVRBaseBundle.localized("Room_Image_Empty"))
      return
    }
    createBtn.isEnabled = false
    createAction?(name, image, createBtn)
  }

  private func isValidRoomName(_ roomName: String) -> Bool {
    let regex = "^[a-zA-Z0-9\\u4e00-\\u9fa5,\\s+]{1,20}$"
    let pred = NSPredicate(format: "SELF MATCHES %@", regex)
    if pred.evaluate(with: roomName) {
      return true
    }
    if let language = NSLocale.preferredLanguages.first,
       language.hasPrefix("en") {
      return true
    }
    return false
  }

  lazy var titleLabel: UILabel = {
    let view = UILabel()
    view.textColor = .white
    view.font = UIFont(name: "PingFangSC-Medium", size: 17)
    view.text = NEVRBaseBundle.localized("Create_Room_Title")
    return view
  }()

  lazy var nameLabel: UILabel = {
    let label = UILabel()
    label.text = NEVRBaseBundle.localized("Create_Room_Name")
    label.font = UIFont(name: "PingFangSC-Regular", size: 14)
    label.textColor = .white
    return label
  }()

  lazy var backgroundLabel: UILabel = {
    let label = UILabel()
    label.text = NEVRBaseBundle.localized("Create_Room_Background")
    label.font = UIFont(name: "PingFangSC-Regular", size: 14)
    label.textColor = .white
    return label
  }()

  lazy var nameInputView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor(red: 39.0 / 255.0, green: 37.0 / 255.0, blue: 52.0 / 255.0, alpha: 0.5)
    view.layer.cornerRadius = 8
    view.clipsToBounds = true
    return view
  }()

  lazy var nameTextView: UITextView = {
    let view = UITextView()
    view.font = UIFont(name: "PingFangSC-Semibold", size: 16)
    view.textColor = .white
    view.backgroundColor = .clear
    view.delegate = self
    return view
  }()

  lazy var randomBtn: UIButton = {
    let btn = UIButton()
    btn.setImage(NEVRBaseBundle.loadImage("create_random"), for: .normal)
    btn.addTarget(self, action: #selector(randomLiveInfo), for: .touchUpInside)
    return btn
  }()

  lazy var backButton: UIButton = {
    let btn = UIButton()
    btn.setImage(NEVRBaseBundle.loadImage("homePage_backIcon"), for: .normal)
    btn.addTarget(self, action: #selector(popViewController), for: .touchUpInside)
    return btn
  }()

  func popViewController() {
    navigationController?.popViewController(animated: true)
  }

  var backgroudImages: [String]?
  public var selectedImage: String? {
    didSet {
      if let image = selectedImage,
         let url = URL(string: image) {
        backgroundImage.sd_setImage(with: url)
      }
    }
  }

  lazy var collectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.minimumLineSpacing = 10
    layout.minimumInteritemSpacing = 10
    let itemWidth = (view.width - 50) / 2
    layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
    let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
    view.backgroundColor = .clear
    view.dataSource = self
    view.delegate = self
    view.register(NEVRBaseCreateBackgroundCell.self, forCellWithReuseIdentifier: "NEVRBaseCreateBackgroundCell")
    view.allowsMultipleSelection = false
    view.allowsSelection = true
    return view
  }()

  override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    view.endEditing(true)
  }
}

extension NEVRBaseCreateViewController: UITextViewDelegate {
  public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    if text == "\n" {
      textView.resignFirstResponder()
      return false
    }
    return textView.text.count + (text.count - range.length) <= 20
  }
}

extension NEVRBaseCreateViewController: UICollectionViewDelegate {
  public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    if let dataSource = backgroudImages {
      selectedImage = dataSource[indexPath.row]
    }
  }
}

extension NEVRBaseCreateViewController: UICollectionViewDataSource {
  public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    backgroudImages?.count ?? 0
  }

  public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NEVRBaseCreateBackgroundCell", for: indexPath) as? NEVRBaseCreateBackgroundCell {
      if let dataSource = backgroudImages,
         indexPath.row < dataSource.count,
         let url = URL(string: dataSource[indexPath.row]) {
        cell.imageView.sd_setImage(with: url)
      }
      return cell
    }
    return UICollectionViewCell()
  }
}

class NEVRBaseCreateBackgroundCell: UICollectionViewCell {
  override init(frame: CGRect) {
    super.init(frame: frame)
    addSubview(imageView)
    addSubview(checkImage)

    imageView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    checkImage.snp.makeConstraints { make in
      make.right.equalToSuperview().offset(-10)
      make.top.equalToSuperview().offset(10)
      make.width.height.equalTo(24)
    }
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  lazy var imageView: UIImageView = {
    let view = UIImageView()
    view.layer.borderColor = UIColor.white.cgColor
    view.layer.borderWidth = 0
    view.layer.cornerRadius = 6
    view.clipsToBounds = true
    view.contentMode = .top
    return view
  }()

  lazy var checkImage: UIImageView = {
    let image = UIImageView(image: NEVRBaseBundle.loadImage("background_checked"))
    image.isHidden = true
    return image
  }()

  override var isSelected: Bool {
    didSet {
      checkImage.isHidden = !isSelected
      imageView.layer.borderWidth = isSelected ? 1 : 0
    }
  }
}
