// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import UIKit
import SnapKit

class NPTAIGCSwitchView: UIView {
  override init(frame: CGRect) {
    super.init(frame: frame)

    layer.cornerRadius = 8
    backgroundColor = .white

    addSubview(titleLabel)
    addSubview(aigcSwitch)

    aigcSwitch.snp.makeConstraints { make in
      make.right.equalToSuperview().offset(-16)
      make.centerY.equalToSuperview()
    }

    titleLabel.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(16)
      make.centerY.equalToSuperview()
      make.right.equalTo(aigcSwitch.snp.left)
    }
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  lazy var titleLabel: UILabel = {
    let view = UILabel()
    view.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
    view.font = UIFont(name: "PingFangSC-Regular", size: 16)
    return view
  }()

  lazy var aigcSwitch: UISwitch = {
    let view = UISwitch()
    view.onTintColor = UIColor(red: 0.35, green: 0.587, blue: 1, alpha: 1)
    return view
  }()
}

class NPTAIGCViewController: UIViewController {
  override func viewDidLoad() {
    super.viewDidLoad()

    title = "Setting_AI".localized
    view.backgroundColor = UIColor.partyBackground

    view.addSubview(assistantSwitch)
    view.addSubview(roomListenerSwitch)

    let textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
    let font = UIFont.systemFont(ofSize: 12)
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.lineSpacing = 5
    let aiTextView = UITextView()
    aiTextView.attributedText = NSAttributedString(string: "“AI畅聊”是一位智能助理，可以帮助您在聊天中更加便捷、高效地获取信息、推荐内容和解决问题，您可以在消息聊天中体验。\n包括以下功能：\n1、\"开场话术\" 是指AI畅聊用于引起聊天兴趣和建立对话的一些问候或介绍语句，例如“你好，欢迎来和我聊天！”\n2、\"话题推荐\" 是指AI畅聊根据用户的兴趣和偏好，提供一些可能感兴趣的话题或建议，例如“你喜欢音乐吗？我们可以聊聊最近的流行歌曲。”\n3、\"聊天技巧\" 是指AI畅聊提供的一些聊天技巧和建议，例如如何保持对话流畅、如何回应对方等，以帮助用户更好地与对话对象交流。\n4、\"对话回复功能\" 是指AI畅聊可以根据用户的输入和上下文，智能地回复相应的信息和建议，以保持对话的连贯性和有意义性。", attributes: [.paragraphStyle: paragraphStyle, .foregroundColor: textColor, .font: font])
    aiTextView.backgroundColor = .clear
    view.addSubview(aiTextView)

    let roomTextView = UITextView()
    roomTextView.attributedText = NSAttributedString(string: "该功能体验暂不支持iOS端，请在云信官网下载Android端体验\n超级听房师是一个语聊房内容分析系统，凭借AI能力，结合关键用户行为，对房中的语音聊天内容进行分析，帮助您更好地进行语聊房运营。\n包括以下功能：\n1. 实时监控用户的关键行为动作和时间点，如进出房、送礼打赏、上麦下麦等；\n2. 可以异步根据时间段，查询某一关键节点前后用户地沟通内容总结，分析主播的话术动作和关键行为之间的关联关系\n3. 可以概览式分析某一房间内用户的聊天内容，包括主播违规性、诱导去其他平台，房间沟通氛围等，以便运营对房间进行整体业务把控。", attributes: [.paragraphStyle: paragraphStyle, .foregroundColor: textColor, .font: font])
    roomTextView.backgroundColor = .clear
    roomTextView.isHidden = true
    view.addSubview(roomTextView)

    assistantSwitch.snp.makeConstraints { make in
      if #available(iOS 11.0, *) {
        make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
      } else {
        make.top.equalTo(view).offset(20)
      }
      make.left.equalToSuperview().offset(20)
      make.right.equalToSuperview().offset(-20)
      make.height.equalTo(50)
    }

    // 控件之间边距20，Switch高度50
    let height = (view.bounds.height - 180) / 2
    let newSize = aiTextView.sizeThatFits(CGSize(width: view.bounds.width - 40, height: CGFloat.greatestFiniteMagnitude))
    let aiTexHeight = min(height, newSize.height) + 1
    aiTextView.snp.makeConstraints { make in
      make.height.equalTo(aiTexHeight)
      make.top.equalTo(assistantSwitch.snp.bottom).offset(20)
      make.left.right.equalTo(assistantSwitch)
    }

    roomListenerSwitch.snp.makeConstraints { make in
      make.top.equalTo(aiTextView.snp.bottom).offset(20)
      make.left.right.equalTo(assistantSwitch)
      make.height.equalTo(50)
    }

    roomTextView.snp.makeConstraints { make in
      make.top.equalTo(roomListenerSwitch.snp.bottom).offset(20)
      make.left.right.equalTo(assistantSwitch)
      if #available(iOS 11.0, *) {
        make.bottom.equalTo(view.safeAreaLayoutGuide)
      } else {
        make.bottom.equalTo(view)
      }
    }
  }

  lazy var assistantSwitch: NPTAIGCSwitchView = {
    let view = NPTAIGCSwitchView()
    view.titleLabel.text = "AI_Assistant".localized + "(Beta)"
    view.aigcSwitch.isOn = Configs.isSupportAIGC
    view.aigcSwitch.addTarget(self, action: #selector(switchValueChanged(sender:)), for: .valueChanged)
    return view
  }()

  lazy var roomListenerSwitch: NPTAIGCSwitchView = {
    let view = NPTAIGCSwitchView()
    view.titleLabel.text = "AI_Room_Listener".localized
    view.aigcSwitch.isOn = false
    view.aigcSwitch.isEnabled = false
    view.isHidden = true
    return view
  }()

  @objc func switchValueChanged(sender: UISwitch) {
    if sender == assistantSwitch.aigcSwitch {
      Configs.isSupportAIGC = sender.isOn
    }
  }
}
