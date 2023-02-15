// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Foundation

class NEOrderSongRoomService {
  /// 获取实时Tokne
  /// - Parameters:
  ///   - success: 成功回调
  ///   - failure: 失败回调

  func getSongToken(_ success: ((NEOrderSongDynamicToken?) -> Void)? = nil,
                    failure: ((NSError) -> Void)? = nil) {
    NEAPI.PickSong.getMusicToken().request(returnType: NEOrderSongDynamicToken.self,
                                           success: { resp in
                                             success?(resp)
                                           }, failed: failure)
  }
}
