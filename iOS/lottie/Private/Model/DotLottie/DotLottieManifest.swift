// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Foundation

/// Manifest model for .lottie File
struct DotLottieManifest: Codable {
  // MARK: Lifecycle

  init(animations: [DotLottieAnimation], version: String, author: String, generator: String) {
    self.animations = animations
    self.version = version
    self.author = author
    self.generator = generator
  }

  // MARK: Internal

  var animations: [DotLottieAnimation]
  var version: String
  var author: String
  var generator: String

  /// Decodes data to Manifest model
  /// - Parameter data: Data to decode
  /// - Throws: Error
  /// - Returns: .lottie Manifest model
  static func decode(from data: Data) throws -> DotLottieManifest {
    try JSONDecoder().decode(DotLottieManifest.self, from: data)
  }

  /// Loads manifest from given URL
  /// - Parameter path: URL path to Manifest
  /// - Returns: Manifest Model
  static func load(from url: URL) throws -> DotLottieManifest {
    let data = try Data(contentsOf: url)
    return try decode(from: data)
  }

  /// Encodes to data
  /// - Parameter encoder: JSONEncoder
  /// - Throws: Error
  /// - Returns: encoded Data
  func encode(with encoder: JSONEncoder = JSONEncoder()) throws -> Data {
    try encoder.encode(self)
  }
}
