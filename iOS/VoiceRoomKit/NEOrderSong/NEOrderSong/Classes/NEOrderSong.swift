// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Foundation
import NERoomKit

let kitTag = "NEOrderSong"
@objcMembers
public class NEOrderSong: NSObject {
  // MARK: - ------------------------- Public method --------------------------

  /// 伴奏effectId
  public static let AccompanyEffectId: UInt32 = 1001
  /// 原唱 effectId
  public static let OriginalEffectId: UInt32 = 1000

  /// 单例初始化
  /// - Returns: 单例对象
  public static func getInstance() -> NEOrderSong {
    instance
  }

  /// NEOrderSong 初始化
  /// - Parameters:
  ///   - config: 初始化配置
  ///   - callback: 回调
  public func initialize(config: NEOrderSongConfig,
                         callback: NEOrderSongCallback<AnyObject>? = nil) {
    NEOrderSongLog.setUp(config.appKey)
    NEOrderSongLog.apiLog(kitTag, desc: "Initialize")
    self.config = config

    if let baseUrl = config.extras["baseUrl"] {
      NE.config.customUrl = baseUrl
    }

    /// 非私有化 且要出海 使用默认海外环境
    var overseaAndNotPrivte = false
    if let serverUrl = config.extras["serverUrl"] {
      isDebug = serverUrl == "test"
      isOversea = serverUrl == "oversea"
      if !serverUrl.contains("http"), isOversea {
        overseaAndNotPrivte = true
        config.extras["serverUrl"] = "https://roomkit-sg.netease.im"
      }
    }
    NE.config.isDebug = isDebug
    NE.config.isOverSea = isOversea
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
        NEOrderSongLog.successLog(kitTag, desc: "Successfully initialize.")
      } else {
        NEOrderSongLog.errorLog(kitTag, desc: "Failed to initialize. Code: \(code)")
      }
      callback?(code, str, nil)
    }
  }

  /// 初始化状态
  public var isInitialized: Bool = false

  /// 添加房间监听
  /// - Parameter listener: 事件监听

  public func addOrderSongListener(_ listener: NEOrderSongListener) {
    NEOrderSongLog.apiLog(kitTag, desc: "Add NEOrderSong listener.")
    listeners.addWeakObject(listener)
  }

  /// 移除房间监听
  /// - Parameter listener: 事件监听
  public func removeOrderSongListener(_ listener: NEOrderSongListener) {
    NEOrderSongLog.apiLog(kitTag, desc: "Remove NEOrderSong listener.")
    listeners.removeWeakObject(listener)
  }

  // MARK: - ------------------------- Private method --------------------------

  private static let instance = NEOrderSong()
  // 房间监听器数组
  var listeners = NSPointerArray.weakObjects()

  var config: NEOrderSongConfig?
  var isDebug: Bool = false
  /// 是否出海
  var isOversea: Bool = false
  // 维护房间上下文
  var roomContext: NERoomContext?

  // 房间服务
  private var _roomService = NEOrderSongRoomService()
  var roomService: NEOrderSongRoomService { _roomService }

  // 播放服务（只做监听）
  var _audioPlayService: NEOrderSongAudioPlayService?
  var audioPlayService: NEOrderSongAudioPlayService? { _audioPlayService }

  // 唱歌服务
  var musicService: NEOrderSongMusicService?

  // 版权服务
  var _copyrightedMediaService = NEOrderSongCopyrightedMediaService()
  var copyrightedMediaService: NEOrderSongCopyrightedMediaService? {
    _copyrightedMediaService
  }

  // 版权监听器数组
  var preloadProtocolListeners = NSPointerArray.weakObjects()
  // 版权接口过期监听对象
  var copyrightedEventMediaHandler: AnyObject?
}
