// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import UIKit
import NEVoiceRoomKit
import NESocialUIKit

@objcMembers public class NEVRBaseRoomListViewModel: NSObject {
  // 无网络
  public static let NO_NETWORK_ERROR = -1005
  // 无列表数据
  public static let EMPTY_LIST_ERROR = 1003

  public var datas: [NEVoiceRoomInfo] = [] {
    didSet {
      datasChanged?(datas)
    }
  }

  public var isEnd: Bool = false
  public var isLoading: Bool = false {
    didSet {
      isLoadingChanged?(isLoading)
    }
  }

  public var error: NSError? {
    didSet {
      errorChanged?(error)
    }
  }

  public var pageNum: Int = 1
  public var pageSize: Int = 20

  public var liveType: NEVoiceRoomLiveRoomType = .multiAudio

  public var datasChanged: (([NEVoiceRoomInfo]) -> Void)?
  public var isLoadingChanged: ((Bool) -> Void)?
  public var errorChanged: ((NSError?) -> Void)?

  public init(liveType: NEVoiceRoomLiveRoomType) {
    super.init()
    self.liveType = liveType

    try? reachability?.startNotifier()
  }

  public lazy var reachability: NESocialReachability? = {
    let reachability = try? NESocialReachability(hostname: "163.com")
    return reachability
  }()

  func checkNetwork() -> Bool {
    if reachability?.connection == .cellular || reachability?.connection == .wifi {
      return true
    }
    return false
  }

  public func requestNewData() {
    if !checkNetwork() {
      isLoading = false
      error = NSError(domain: NSCocoaErrorDomain, code: NEVRBaseRoomListViewModel.NO_NETWORK_ERROR)
      return
    }
    isLoading = true
    NEVoiceRoomKit.getInstance().getRoomList(.live, type: liveType.rawValue, pageNum: pageNum, pageSize: pageSize) { [weak self] code, msg, data in
      DispatchQueue.main.async {
        if code != 0 {
          self?.datas = []
          self?.error = NSError(domain: NSCocoaErrorDomain, code: code, userInfo: [NSLocalizedDescriptionKey: msg ?? ""])
          self?.isEnd = true
        } else if let data = data {
          self?.datas = data.list ?? []
          self?.error = nil
          self?.isEnd = (data.list?.count ?? 0 < self?.pageSize ?? 0)
        }
        self?.isLoading = false
      }
    }
  }

  public func requestMoreData() {
    if !checkNetwork() {
      isLoading = false
      error = NSError(domain: NSCocoaErrorDomain, code: NEVRBaseRoomListViewModel.NO_NETWORK_ERROR)
      return
    }
    if isEnd {
      return
    }

    isLoading = true
    pageNum += 1
    NEVoiceRoomKit.getInstance().getRoomList(.live, type: liveType.rawValue, pageNum: pageNum, pageSize: pageSize) { [weak self] code, msg, data in
      DispatchQueue.main.async {
        if code != 0 {
          self?.datas = []
          self?.error = NSError(domain: NSCocoaErrorDomain, code: code, userInfo: [NSLocalizedDescriptionKey: msg ?? ""])
          self?.isEnd = true
        } else if let data = data {
          var temp = self?.datas ?? []
          temp.append(contentsOf: data.list ?? [])
          self?.datas = temp
          self?.error = nil
          self?.isEnd = (data.list?.count ?? 0 < self?.pageSize ?? 0)
        }
        self?.isLoading = false
      }
    }
  }
}
