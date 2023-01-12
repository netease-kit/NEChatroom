// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Foundation
import NERoomKit

extension NEOrderSong: NEOrderSongPlayStateChangeCallback {
  func onReceiveSongPosition(_ actionType: NEOrderSongCustomAction,
                             data: [String: Any]?) {
    DispatchQueue.main.async {
      for pointerListener in self.listeners.allObjects {
        guard pointerListener is NEOrderSongListener, let listener = pointerListener as? NEOrderSongListener
        else { continue }

        if listener.responds(to: #selector(NEOrderSongListener.onReceiveSongPosition(_:data:))) {
          listener.onReceiveSongPosition?(actionType, data: data)
        }
      }
    }
  }
}
