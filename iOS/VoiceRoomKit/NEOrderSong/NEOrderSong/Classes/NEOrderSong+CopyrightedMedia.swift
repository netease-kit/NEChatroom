// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Foundation
import NECopyrightedMedia

extension NEOrderSong: NECopyrightedEventHandler, NESongPreloadProtocol {
  public func onTokenExpired() {
    guard let eventHandler = copyrightedEventMediaHandler as? NEOrderSongCopyrightedMediaEventHandler
    else {
      return
    }
    NEOrderSong.getInstance().copyrightedMediaService?
      .getSongDynamicTokenUntilSuccess(success: { dynamicToken in
        guard let token = dynamicToken?.accessToken else {
          return
        }

        self.renewToken(token)

        guard let expiresIn = dynamicToken?.expiresIn else {
          return
        }
        NEOrderSong.getInstance().copyrightedMediaService?.calculateExpiredTime(timeExpired: expiresIn)
      })
    if eventHandler.responds(to: #selector(onTokenExpired)) {
      eventHandler.onTokenExpired?()
    }
  }

  public func onPreloadStart(_ songId: String, channel: SongChannel) {
    for pointerListener in preloadProtocolListeners.allObjects {
      guard pointerListener is NEOrderSongCopyrightedMediaListener, let listener = pointerListener as? NEOrderSongCopyrightedMediaListener else { continue }
      if listener
        .responds(to: #selector(NEOrderSongCopyrightedMediaListener.onPreloadStart(_:channel:))) {
        listener.onPreloadStart?(songId, channel: channel)
      }
    }
  }

  public func onPreloadProgress(_ songId: String, channel: SongChannel, progress: Float) {
    for pointerListener in preloadProtocolListeners.allObjects {
      guard pointerListener is NEOrderSongCopyrightedMediaListener, let listener = pointerListener as? NEOrderSongCopyrightedMediaListener else { continue }

      if listener
        .responds(to: #selector(NEOrderSongCopyrightedMediaListener.onPreloadProgress(_:channel:progress:))) {
        listener.onPreloadProgress?(songId, channel: channel, progress: progress)
      }
    }
  }

  public func onPreloadComplete(_ songId: String, channel: SongChannel, error: Error?) {
    for pointerListener in preloadProtocolListeners.allObjects {
      guard pointerListener is NEOrderSongCopyrightedMediaListener, let listener = pointerListener as? NEOrderSongCopyrightedMediaListener else { continue }

      if listener
        .responds(to: #selector(NEOrderSongCopyrightedMediaListener.onPreloadComplete(_:channel:error:))) {
        listener.onPreloadComplete?(songId, channel: channel, error: error)
      }
    }
  }

  /// 设置版权过期监听对象
  /// - Parameter listener: 对象
  public func setCopyrightedMediaEventHandler(_ eventHandler: NEOrderSongCopyrightedMediaEventHandler?) {
    NEOrderSongLog.apiLog(kitTag, desc: "Add copyrighted event handle.")
    guard let eventHandler = eventHandler else {
      NEOrderSongLog.apiLog(kitTag, desc: "Add copyrighted event handle nil.")
      return
    }
    copyrightedEventMediaHandler = eventHandler
    NECopyrightedMedia.getInstance().setEventHandler(self)
  }

  /// 版权初始化
  /// - Parameters:
  ///   - appkey:appkey
  ///   - token: token
  ///   - userUuid: userUuid
  ///   - extras: extras
  ///   - success: 成功回调
  ///   - failure: 失败回调
  func initializeCopyrightedMedia(_ appkey: String, token: String, userUuid: String?,
                                  extras: [String: Any]? = nil, success: (() -> Void)? = nil,
                                  failure: ((NSError?) -> Void)? = nil) {
    NECopyrightedMedia.getInstance()
      .initialize(appkey, token: token, userUuid: userUuid, extras: extras) { error in
        if let err = error as NSError? {
          guard let failure = failure else {
            return
          }
          failure(err)
        } else {
          guard let success = success else {
            return
          }
          NECopyrightedMedia.getInstance().setSongScene(TYPE_LISTENING_TO_MUSIC)
          success()
        }
      }
  }

  /**
   * 预加载 Song 数据
   *
   * @param songId 歌曲id
   * @param channel 渠道
   * @param observe 观察者
   */
  public func preloadSong(_ songId: String, channel: SongChannel,
                          observe: NEOrderSongCopyrightedMediaListener?) {
    guard let observe = observe else {
      NECopyrightedMedia.getInstance().preloadSong(songId, channel: channel, observe: nil)
      return
    }
    NEOrderSongLog.apiLog(kitTag, desc: "Add copyrighted listener.")
    if !preloadProtocolListeners.allObjects.contains(where: { item in
      if let item = item as? NEOrderSongCopyrightedMediaListener,
         item.isEqual(observe) {
        return true
      }
      return false
    }) {
      preloadProtocolListeners.addPointer(Unmanaged.passUnretained(observe).toOpaque())
    }

    NECopyrightedMedia.getInstance().preloadSong(songId, channel: channel, observe: self)
  }

  /// 预加载歌词
  /// @param songId  音乐ID
  /// @param callback 回调
  public func preloadSongLyric(_ songId: String, channel: SongChannel,
                               callback: @escaping (String?, String?, Error?) -> Void) {
    NECopyrightedMedia.getInstance()
      .preloadSongLyric(songId, channel: channel) { content, lyricType, error in
        callback(content, lyricType, error)
      }
  }

  /// 更新Token
  /// @param token Token
  public func renewToken(_ token: String?) {
    guard let token = token else {
      return
    }
    NECopyrightedMedia.getInstance().renewToken(token)
  }

  /**
   * 原唱&伴奏：传给 NERtc 播放的 URI
   *
   * @param songId           音乐 ID
   * @param channel         渠道
   * @param songResType           1：原唱，2：伴奏
   * @return 返回资源的本地路径
   */

  public func getSongURI(_ songId: String, channel: SongChannel,
                         songResType: SongResType) -> String? {
    NECopyrightedMedia.getInstance()
      .getSongURI(songId, channel: channel, songResType: songResType)
  }

  /**
   * 歌词
   * @param songId           音乐 ID
   * @param channel         渠道
   * @return 歌词内容
   */
  public func getLyric(_ songId: String, channel: SongChannel) -> String? {
    NECopyrightedMedia.getInstance().getLyric(songId, channel: channel)
  }

  /**
   * 打分
   * @param songId           音乐 ID
   * @param channel 渠道
   * @return 打分内容
   */
  public func getPitch(_ songId: String, channel: SongChannel) -> String? {
    NECopyrightedMedia.getInstance().getPitch(songId, channel: channel)
  }

  /**
   * 歌曲列表
   * @param tags 设置nil 预留字段
   * @param channel 渠道 SongChannel: 可为空
   * @param pageNum 页码
   * @param pageSize 页面size 默认 20
   * @param callback 回调
   */
  public func getSongList(_ tags: [String]?, channel: NSNumber?, pageNum: NSNumber?,
                          pageSize: NSNumber?,
                          callback: @escaping ([NECopyrightedSong]?, Error?) -> Void) {
    NECopyrightedMedia.getInstance()
      .getSongList(tags, channel: channel, pageNum: pageNum,
                   pageSize: pageSize) { songList, error in
        callback(songList, error)
      }
  }

  /// 搜索歌曲
  /// @param keyword 搜索关键词
  /// @param channel 渠道 SongChannel: 可为空
  /// @param pageNum 页码
  /// @param pageSize 每页数据大小
  /// @param callback 回调
  public func searchSong(_ keyword: String, channel: NSNumber?, pageNum: NSNumber?,
                         pageSize: NSNumber?,
                         callback: @escaping ([NECopyrightedSong]?, Error?) -> Void) {
    NECopyrightedMedia.getInstance()
      .searchSong(keyword, channel: channel, pageNum: pageNum,
                  pageSize: pageSize) { songList, error in
        callback(songList, error)
      }
  }

  public func isSongPreloaded(_ songId: String, channel: SongChannel) -> Bool {
    NECopyrightedMedia.getInstance().isSongPreloaded(songId, channel: channel)
  }
}
