// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Foundation

/// A layer that holds an image.
final class ImageLayerModel: LayerModel {
  // MARK: Lifecycle

  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: ImageLayerModel.CodingKeys.self)
    referenceID = try container.decode(String.self, forKey: .referenceID)
    try super.init(from: decoder)
  }

  required init(dictionary: [String: Any]) throws {
    referenceID = try dictionary.value(for: CodingKeys.referenceID)
    try super.init(dictionary: dictionary)
  }

  // MARK: Internal

  /// The reference ID of the image.
  let referenceID: String

  override func encode(to encoder: Encoder) throws {
    try super.encode(to: encoder)
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(referenceID, forKey: .referenceID)
  }

  // MARK: Private

  private enum CodingKeys: String, CodingKey {
    case referenceID = "refId"
  }
}
