// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Foundation
import NERoomKit

let kitTag = "NEVoiceRoomKit"
@objcMembers
public class NEVoiceRoomKit: NSObject {
  // MARK: - ------------------------- Public method --------------------------

  /// 伴奏effectId
  public static let AccompanyEffectId: UInt32 = 1001
  /// 原唱 effectId
  public static let OriginalEffectId: UInt32 = 1000

  /// 单例初始化
  /// - Returns: 单例对象
  public static func getInstance() -> NEVoiceRoomKit {
    instance
  }

  /// 本端成员信息
  /// 加入房间后获取
  public var localMember: NEVoiceRoomMember? {
    Judge.syncResult {
      NEVoiceRoomMember(self.roomContext!.localMember)
    }
  }

  /// 所有成员信息(包含本端)
  /// 加入房间后获取
  public var allMemberList: [NEVoiceRoomMember] {
    Judge.syncResult {
      var allMembers = [NERoomMember]()
      allMembers.append(self.roomContext!.localMember)
      self.roomContext!.remoteMembers.forEach { allMembers.append($0) }
      return allMembers.map { NEVoiceRoomMember($0) }
    } ?? []
  }

  /// NEVoiceRoomKit 初始化
  /// - Parameters:
  ///   - config: 初始化配置
  ///   - callback: 回调
  public func initialize(config: NEVoiceRoomKitConfig,
                         callback: NEVoiceRoomCallback<AnyObject>? = nil) {
    NEVoiceRoomLog.setUp(config.appKey)
    NEVoiceRoomLog.apiLog(kitTag, desc: "Initialize")
    self.config = config

    /// 非私有化 且要出海 使用默认海外环境
    var overseaAndNotPrivte = false
    if let serverUrl = config.extras["serverUrl"] {
      isDebug = serverUrl == "test"
      isOversea = serverUrl == "oversea"
      if !serverUrl.contains("http"), isOversea {
        overseaAndNotPrivte = true
        NE.config.customUrl = "https://roomkit-sg.netease.im"
        config.extras["serverUrl"] = "https://roomkit-sg.netease.im"
      }
    }
    NE.config.isDebug = isDebug
    let options = NERoomKitOptions(appKey: config.appKey)
    options.reuseIM = config.reuseIM
    options.APNSCerName = config.APNSCerName
    options.extras = config.extras
    if overseaAndNotPrivte {
      let serverConfig = NEServerConfig()
      serverConfig.imServerConfig = NEIMServerConfig()
      serverConfig.roomKitServerConfig = NERoomKitServerConfig()
      serverConfig.roomKitServerConfig?.roomServer = "https://roomkit-sg.netease.im"
      serverConfig.imServerConfig?.lbs = "https://lbs.netease.im/lbs/conf.jsp"
      serverConfig.imServerConfig?.link = "link-sg.netease.im:7000"
      options.serverConfig = serverConfig
    }
    NERoomKit.shared().initialize(options: options) { code, str, _ in
      if code == 0 {
        self.isInitialized = true
        NEVoiceRoomLog.successLog(kitTag, desc: "Successfully initialize.")
      } else {
        NEVoiceRoomLog.errorLog(kitTag, desc: "Failed to initialize. Code: \(code)")
      }
      callback?(code, str, nil)
    }
  }

  /// 初始化状态
  public var isInitialized: Bool = false

  /// 添加房间监听
  /// - Parameter listener: 事件监听

  public func addVoiceRoomListener(_ listener: NEVoiceRoomListener) {
    NEVoiceRoomLog.apiLog(kitTag, desc: "Add VoiceRoom listener.")
    listeners.addWeakObject(listener)
  }

  /// 移除房间监听
  /// - Parameter listener: 事件监听
  public func removeVoiceRoomListener(_ listener: NEVoiceRoomListener) {
    NEVoiceRoomLog.apiLog(kitTag, desc: "Remove VoiceRoom listener.")
    listeners.removeWeakObject(listener)
  }

  // 上传日志
  public func uploadLog() {
    NERoomKit.shared().uploadLog()
  }

  /*
   /// 主播开播详情
   public var liveDetail: NEVoiceRoomRoomInfo {
     NEVoiceRoomRoomInfo(create: liveInfo)
   }
   */

  // MARK: - ------------------------- Private method --------------------------

  override init() {
    super.init()
    NERoomKit.shared().authService.addAuthListener(self)
  }

  deinit {
    NERoomKit.shared().authService.removeAuthListener(self)
  }

  private static let instance = NEVoiceRoomKit()
  // 房间监听器数组
  var listeners = NSPointerArray.weakObjects()
  // 登录监听器数组
  var authListeners = NSPointerArray.weakObjects()
  // preview监听器数组
  var previewListeners = NSPointerArray.weakObjects()
  var config: NEVoiceRoomKitConfig?
  var isDebug: Bool = false
  /// 是否出海
  var isOversea: Bool = false
  // 维护房间上下文
  var roomContext: NERoomContext?
  // 维护预览房间上下文
  var previewRoomContext: NEPreviewRoomContext?

  // 房间服务
  private var _roomService = NEVoiceRoomRoomService()
  internal var roomService: NEVoiceRoomRoomService { _roomService }
  // 播放服务
  internal var _audioPlayService: NEVoiceRoomAudioPlayService?
  internal var audioPlayService: NEVoiceRoomAudioPlayService? { _audioPlayService }

  // 版权监听器数组
  internal var preloadProtocolListeners = NSPointerArray.weakObjects()
  // 版权接口过期监听对象
  internal var copyrightedEventMediaHandler: AnyObject?

  // 直播信息
  var liveInfo: _NECreateLiveResponse?
  /// 人声音量 默认: 100
  var recordVolume: UInt32 = 100
  /// 伴奏音量 默认: 100
  var mixingVolume: UInt32 = 100
  /// 音效音量 默认: 100
  var effectVolume: UInt32 = 100
}
