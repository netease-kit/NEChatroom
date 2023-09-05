// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import UIKit

/// 基础消息类型
@objcMembers public class NESocialChatroomMessage: NSObject {
  var size: CGSize = .zero
  var attributedContent: NSAttributedString?

  /// 用户头像
  public var icon: UIImage?

  /// 自定义头像大小，如果不设置则取icon自身大小
  public var iconSize: CGSize = .zero

  /// 文本大小，默认 UIFont.systemFont(ofSize: 14)
  public var textFont = UIFont.systemFont(ofSize: 14)

  /// 文本颜色，默认 UIColor.white
  public var foregroundColor = UIColor.white

  /// 根据富文本内容来计算cell的size
  /// - Parameter maxWidth: 最大宽度，即整个NESocialChatroomView的宽度
  func caculateCellSize(maxWidth: CGFloat) {
    DispatchQueue.main.sync(execute: DispatchWorkItem { [weak self] in
      let label = UILabel(frame: CGRect.zero)
      label.attributedText = self?.attributedContent
      label.numberOfLines = 0
      self?.size = label.sizeThatFits(CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude))
    })
  }

  /// 添加头像
  /// - Parameter mutableString: 富文本内容
  func addIcon(mutableString: NSMutableAttributedString) {
    // 如果有头像就把头像加进去
    if let icon = icon {
      let attachment = NSTextAttachment()
      attachment.image = icon
      var iconSize = icon.size
      if self.iconSize.width > 0,
         self.iconSize.height > 0 {
        iconSize = CGSize(width: self.iconSize.width, height: self.iconSize.height)
      }
      attachment.bounds = CGRect(x: 0, y: (textFont.capHeight - iconSize.height) / 2, width: iconSize.width, height: iconSize.height)
      mutableString.append(NSAttributedString(attachment: attachment))
      mutableString.append(NSAttributedString(string: " "))
    }
  }
}

/// 文本消息
@objcMembers public class NESocialChatroomTextMessage: NESocialChatroomMessage {
  /// 文本内容
  public var text: String?

  /// 消息发送者昵称
  public var sender: String?

  /// 打赏者昵称部分颜色
  public var senderColor = UIColor(white: 1, alpha: 0.6)

  /// 根据富文本内容来计算cell的size
  /// - Parameter maxWidth: 最大宽度，即整个NESocialChatroomView的宽度
  override func caculateCellSize(maxWidth: CGFloat) {
    let mutableString = NSMutableAttributedString()
    addIcon(mutableString: mutableString)
    if let name = sender {
      let nameString = NSAttributedString(string: "\(name): ", attributes: [.foregroundColor: senderColor, .font: textFont])
      mutableString.append(nameString)
    }
    if let text = text {
      let nameString = NSAttributedString(string: text, attributes: [.foregroundColor: foregroundColor, .font: textFont])
      mutableString.append(nameString)
    }
    attributedContent = mutableString
    super.caculateCellSize(maxWidth: maxWidth)
  }
}

/// 打赏消息
@objcMembers public class NESocialChatroomRewardMessage: NESocialChatroomMessage {
  /// 打赏者昵称
  public var sender: String?

  /// 接收者昵称
  public var receiver: String?

  /// 礼物图标
  public var giftImage: UIImage?

  /// 自定义礼物图标大小，如果不设置则取giftImage自身大小
  public var giftImageSize: CGSize = .zero

  /// 礼物名称
  public var giftName: String?

  /// 礼物数量
  public var giftCount = 1

  /// 打赏文案，默认 "送出礼物"
  public var rewardText = "送出礼物"

  /// 打赏者昵称部分颜色
  public var senderColor = UIColor(white: 1, alpha: 0.6)

  /// 打赏文案部分颜色
  public var rewardColor = UIColor.white

  /// 接收者昵称部分颜色
  public var receiverColor = UIColor(red: 0, green: 0.667, blue: 1, alpha: 1)

  /// 礼物部分颜色
  public var giftColor = UIColor.white

  /// 根据富文本内容来计算cell的size
  /// - Parameter maxWidth: 最大宽度，即整个NESocialChatroomView的宽度
  override func caculateCellSize(maxWidth: CGFloat) {
    let mutableString = NSMutableAttributedString()
    addIcon(mutableString: mutableString)
    if let name = sender {
      let nameString = NSAttributedString(string: "\(name) ", attributes: [.foregroundColor: senderColor, .font: textFont])
      mutableString.append(nameString)
    }
    let rewardString = NSAttributedString(string: "\(rewardText)", attributes: [.foregroundColor: rewardColor, .font: textFont])
    mutableString.append(rewardString)
    if let receiver = receiver {
      let recvString = NSAttributedString(string: " \(receiver) ", attributes: [.foregroundColor: receiverColor, .font: textFont])
      mutableString.append(recvString)
    }
    if let giftName = giftName {
      let giftString = NSAttributedString(string: "\(giftName)", attributes: [.foregroundColor: giftColor, .font: textFont])
      mutableString.append(giftString)
    }
    let countString = NSAttributedString(string: "x\(giftCount)", attributes: [.foregroundColor: giftColor, .font: textFont])
    mutableString.append(countString)

    if let giftImage = giftImage {
      let attachment = NSTextAttachment()
      attachment.image = giftImage
      var giftImageSize = giftImage.size
      if self.giftImageSize.width > 0,
         self.giftImageSize.height > 0 {
        giftImageSize = CGSize(width: self.giftImageSize.width, height: self.giftImageSize.height)
      }
      attachment.bounds = CGRect(x: 0, y: (textFont.capHeight - giftImageSize.height) / 2, width: giftImageSize.width, height: giftImageSize.height)
      mutableString.append(NSAttributedString(attachment: attachment))
    }

    attributedContent = mutableString
    super.caculateCellSize(maxWidth: maxWidth)
  }
}

/// 通知消息
@objcMembers public class NESocialChatroomNotiMessage: NESocialChatroomMessage {
  /// 通知消息内容
  public var notification: String?

  /// 根据富文本内容来计算cell的size
  /// - Parameter maxWidth: 最大宽度，即整个NESocialChatroomView的宽度
  override func caculateCellSize(maxWidth: CGFloat) {
    let mutableString = NSMutableAttributedString()
    addIcon(mutableString: mutableString)
    if let notification = notification {
      let notifiString = NSAttributedString(string: notification, attributes: [.foregroundColor: foregroundColor, .font: textFont])
      mutableString.append(notifiString)
    }
    attributedContent = mutableString
    super.caculateCellSize(maxWidth: maxWidth)
  }
}

class NESocialChatroomCell: UITableViewCell {
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    selectionStyle = .none
    backgroundColor = .clear
    contentView.addSubview(bubbleView)
    contentView.addSubview(label)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  lazy var label: UILabel = {
    let label = UILabel(frame: CGRect.zero)
    label.numberOfLines = 0
    return label
  }()

  lazy var bubbleView: UIView = {
    let view = UIView(frame: CGRect.zero)
    return view
  }()

  private var _message: NESocialChatroomMessage?
  var message: NESocialChatroomMessage? {
    get {
      _message
    }
    set {
      _message = newValue

      DispatchQueue.main.async {
        if let size = newValue?.size {
          self.label.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
          self.label.attributedText = newValue?.attributedContent

          self.bubbleView.frame = CGRect(x: 0, y: 5, width: size.width + 10, height: size.height + 10)
          self.label.center = self.bubbleView.center
        }
        if let m = newValue,
           m.isKind(of: NESocialChatroomNotiMessage.self) {
          self.bubbleView.backgroundColor = UIColor.clear
        } else {
          self.bubbleView.backgroundColor = UIColor(white: 0, alpha: 0.6)
          self.bubbleView.layer.cornerRadius = 10.0
        }
      }
    }
  }
}

/// 聊天室消息列表视图
@objcMembers public class NESocialChatroomView: UIView {
  /// 当前的消息列表
  public private(set) var messages: [NESocialChatroomMessage] = .init()

  override public init(frame: CGRect) {
    super.init(frame: frame)
    addSubview(tableView)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  /// 添加多条消息
  /// - Parameter messages: 消息列表
  public func addMessages(_ messages: [NESocialChatroomMessage]) {
    caculateCellSize(messages)
  }

  /// 添加单条消息
  /// - Parameter message: 单条消息
  public func addMessage(_ message: NESocialChatroomMessage) {
    caculateCellSize([message])
  }

  /// 子线程串行去计算
  private let caculateQueue: DispatchQueue = .init(label: "recreation.chatroom.caculate")
  func caculateCellSize(_ messages: [NESocialChatroomMessage]) {
    let width = frame.width
    caculateQueue.async {
      messages.forEach { message in
        message.caculateCellSize(maxWidth: width - 10)
        self.messages.append(message)
      }
      DispatchQueue.main.async {
        self.tableView.reloadData()
        let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
        self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
      }
    }
  }

  private let CellReuseIdentifier = "CellReuseIdentifier"
  lazy var tableView: UITableView = {
    let tableView = UITableView(frame: frame)
    tableView.delegate = self
    tableView.dataSource = self
    tableView.backgroundColor = .clear
    tableView.showsHorizontalScrollIndicator = false
    tableView.showsVerticalScrollIndicator = false
    tableView.register(NESocialChatroomCell.self, forCellReuseIdentifier: CellReuseIdentifier)
    tableView.separatorStyle = .none
    return tableView
  }()

  override public func layoutSubviews() {
    super.layoutSubviews()
    tableView.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
  }
}

extension NESocialChatroomView: UITableViewDelegate, UITableViewDataSource {
  public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    let message = messages[indexPath.row]
    return message.size.height + 10 + 10
  }

  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    messages.count
  }

  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell: NESocialChatroomCell = tableView.dequeueReusableCell(withIdentifier: CellReuseIdentifier) as? NESocialChatroomCell ?? NESocialChatroomCell(style: .default, reuseIdentifier: CellReuseIdentifier)
    cell.message = messages[indexPath.row]
    return cell
  }
}
