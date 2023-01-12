// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Foundation

/// A time marker
final class Marker: Codable, DictionaryInitializable {
  // MARK: Lifecycle

  init(dictionary: [String: Any]) throws {
    name = try dictionary.value(for: CodingKeys.name)
    frameTime = try dictionary.value(for: CodingKeys.frameTime)
    durationFrameTime = try dictionary.value(for: CodingKeys.durationFrameTime)
  }

  // MARK: Internal

  enum CodingKeys: String, CodingKey {
    case name = "cm"
    case frameTime = "tm"
    case durationFrameTime = "dr"
  }

  /// The Marker Name
  let name: String

  /// The Frame time of the marker
  let frameTime: AnimationFrameTime

  /// The duration of the marker, in frames.
  let durationFrameTime: AnimationFrameTime
}
