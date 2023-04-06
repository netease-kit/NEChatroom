// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Foundation
import NERoomKit

let kitTag = "NEListenTogetherKit"
@objcMembers
public class NEListenTogetherKit: NSObject {
  // MARK: - ------------------------- Public method --------------------------

  /// 伴奏effectId
  public static let AccompanyEffectId: UInt32 = 1001
  /// 原唱 effectId
  public static let OriginalEffectId: UInt32 = 1000

  /// 单例初始化
  /// - Returns: 单例对象
  public static func getInstance() -> NEListenTogetherKit {
    instance
  }

  /// 本端成员信息
  /// 加入房间后获取
  public var localMember: NEListenTogetherMember? {
    Judge.syncResult {
      NEListenTogetherMember(self.roomContext!.localMember)
    }
  }

  /// 所有成员信息(包含本端)
  /// 加入房间后获取
  public var allMemberList: [NEListenTogetherMember] {
    Judge.syncResult {
      var allMembers = [NERoomMember]()
      allMembers.append(self.roomContext!.localMember)
      self.roomContext!.remoteMembers.forEach { allMembers.append($0) }
      return allMembers.map { NEListenTogetherMember($0) }
    } ?? []
  }

  /// NEListenTogetherKit 初始化
  /// - Parameters:
  ///   - config: 初始化配置
  ///   - callback: 回调
  public func initialize(config: NEListenTogetherKitConfig,
                         callback: NEListenTogetherCallback<AnyObject>? = nil) {
    NEListenTogetherLog.setUp(config.appKey)
    NEListenTogetherLog.apiLog(kitTag, desc: "Initialize")
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
    options.extras = config.extras
    options.APNSCerName = config.APNSCerName
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
        NEListenTogetherLog.successLog(kitTag, desc: "Successfully initialize.")
      } else {
        NEListenTogetherLog.errorLog(kitTag, desc: "Failed to initialize. Code: \(code)")
      }
      callback?(code, str, nil)
    }
  }

  /// 初始化状态
  public var isInitialized: Bool = false

  /// 添加房间监听
  /// - Parameter listener: 事件监听

  public func addVoiceRoomListener(_ listener: NEListenTogetherListener) {
    NEListenTogetherLog.apiLog(kitTag, desc: "Add VoiceRoom listener.")
    listeners.addWeakObject(listener)
  }

  /// 移除房间监听
  /// - Parameter listener: 事件监听
  public func removeVoiceRoomListener(_ listener: NEListenTogetherListener) {
    NEListenTogetherLog.apiLog(kitTag, desc: "Remove VoiceRoom listener.")
    listeners.removeWeakObject(listener)
  }

  /*
   /// 主播开播详情
   public var liveDetail: NEListenTogetherRoomInfo {
     NEListenTogetherRoomInfo(create: liveInfo)
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

  private static let instance = NEListenTogetherKit()
  // 房间监听器数组
  var listeners = NSPointerArray.weakObjects()
  // 登录监听器数组
  var authListeners = NSPointerArray.weakObjects()
  var config: NEListenTogetherKitConfig?
  var isDebug: Bool = false
  /// 是否出海
  var isOversea: Bool = false
  // 维护房间上下文
  var roomContext: NERoomContext?

  // 房间服务
  private var _roomService = NEListenTogetherRoomService()
  internal var roomService: NEListenTogetherRoomService { _roomService }
  // 播放服务
  internal var _audioPlayService: NEListenTogetherAudioPlayService?
  internal var audioPlayService: NEListenTogetherAudioPlayService? { _audioPlayService }
  // 唱歌服务
  internal var musicService: NEListenTogetherMusicService?

  // 版权服务
  internal var _copyrightedMediaService = NEListenTogetherCopyrightedMediaService()
  internal var copyrightedMediaService: NEListenTogetherCopyrightedMediaService? {
    _copyrightedMediaService
  }

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
