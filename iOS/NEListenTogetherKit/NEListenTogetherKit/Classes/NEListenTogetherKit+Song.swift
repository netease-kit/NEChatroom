// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Foundation
import NERoomKit

extension NEListenTogetherKit: NEListenTogetherPlayStateChangeCallback {
  func onSongPlayPosition(_ postion: UInt64) {
    DispatchQueue.main.async {
      for pointerListener in self.listeners.allObjects {
        guard pointerListener is NEListenTogetherListener, let listener = pointerListener as? NEListenTogetherListener
        else { continue }

        if listener.responds(to: #selector(NEListenTogetherListener.onSongPlayingPosition(_:))) {
          listener.onSongPlayingPosition?(postion)
        }
      }
    }
  }

  func onReceiveSongPosition(_ actionType: NEListenTogetherCustomAction,
                             data: [String: Any]?) {
    DispatchQueue.main.async {
      for pointerListener in self.listeners.allObjects {
        guard pointerListener is NEListenTogetherListener, let listener = pointerListener as? NEListenTogetherListener
        else { continue }

        if listener.responds(to: #selector(NEListenTogetherListener.onReceiveSongPosition(_:data:))) {
          listener.onReceiveSongPosition?(actionType, data: data)
        }
      }
    }
  }
}
