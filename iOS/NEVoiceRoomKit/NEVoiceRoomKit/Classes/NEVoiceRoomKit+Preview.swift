// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Foundation
import NERoomKit

public extension NEVoiceRoomKit {
  /// 添加预操作监听
  /// - Parameter listener: 监听器
  func addPreviewListener(_ listener: NEVoiceRoomPreviewListener) {
    NEVoiceRoomLog.apiLog(kitTag, desc: "Add preview listener.")
    previewListeners.addWeakObject(listener)
  }

  /// 移除预操作监听
  /// - Parameter listener: 监听器
  func removePreviewListener(_ listener: NEVoiceRoomPreviewListener) {
    NEVoiceRoomLog.apiLog(kitTag, desc: "Remove preview listener.")
    previewListeners.removeWeakObject(listener)
  }

  /// 房间预览
  /// - Parameters:
  ///   - params: 房间预览参数
  ///   - callback: 回调闭包
  internal func previewRoom(_: NEPreviewVoiceRoomParams = NEPreviewVoiceRoomParams(),
                            options _: NEPreviewVoiceRoomOptions = NEPreviewVoiceRoomOptions(),
                            callback: NEVoiceRoomCallback<AnyObject>? = nil) {
    NEVoiceRoomLog.apiLog(kitTag, desc: "🚰  Preview voice room.")
    // 创建 previewRoomContext并返回
    NERoomKit.shared().roomService.previewRoom { code, str, context in
      if let context = context {
        self.previewRoomContext = context
        self.previewRoomContext?.addPreviewRoomListener(listener: self)
      }
      callback?(code, str, nil)
    }
  }

  @discardableResult
  // 开始通话前网络质量探测。
  func startLastmileProbeTest(config: NEVoiceRoomRtcLastmileProbeConfig?) -> Int {
    Judge.syncPreviewCondition {
      var roomConfig: NERoomRtcLastmileProbeConfig?
      if let config = config {
        roomConfig = NERoomRtcLastmileProbeConfig()
        guard let roomConfig = roomConfig else { return -1 }
        roomConfig.probeUplink = config.probeUplink
        roomConfig.probeDownlink = config.probeUplink
        roomConfig.expectedUplinkBitrate = config.expectedUplinkBitrate
        roomConfig.expectedDownlinkBitrate = config.expectedDownlinkBitrate
      }
      return Int(self.previewRoomContext!.previewController.startLastmileProbeTest(config: roomConfig))
    }
  }

  @discardableResult
  // 停止通话前网络质量探测。
  func stopLastmileProbeTest() -> Int {
    Judge.syncPreviewCondition {
      Int(self.previewRoomContext!.previewController.stopLastmileProbeTest())
    }
  }
}

extension NEVoiceRoomKit: NEPreviewRoomListener {
  public func onRtcLastmileQuality(_ quality: NERoomRtcNetworkStatusType) {
    DispatchQueue.main.async {
      for pointerListener in self.previewListeners.allObjects {
        if let listener = pointerListener as? NEVoiceRoomPreviewListener,
           listener
           .responds(to: #selector(NEVoiceRoomPreviewListener.onVoiceRoomRtcLastmileQuality(_:))) {
          listener.onVoiceRoomRtcLastmileQuality?(NEVoiceRoomRtcNetworkStatusType(rawValue: Int(quality.rawValue)) ?? .unknown)
        }
      }
    }
  }

  public func onRtcLastmileProbeResult(_ result: NERoomRtcLastmileProbeResult) {
    DispatchQueue.main.async {
      for pointerListener in self.previewListeners.allObjects {
        if let listener = pointerListener as? NEVoiceRoomPreviewListener,
           listener
           .responds(to: #selector(NEVoiceRoomPreviewListener.onVoiceRoomRtcLastmileProbeResult(_:))) {
          listener.onVoiceRoomRtcLastmileProbeResult?(NEVoiceRoomRtcLastmileProbeTest(result: result))
        }
      }
    }
  }
}
