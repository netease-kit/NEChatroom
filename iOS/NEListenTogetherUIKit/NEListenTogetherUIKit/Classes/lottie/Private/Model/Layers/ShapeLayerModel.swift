// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Foundation

/// A layer that holds vector shape objects.
final class ShapeLayerModel: LayerModel {
  // MARK: Lifecycle

  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: ShapeLayerModel.CodingKeys.self)
    items = try container.decode([ShapeItem].self, ofFamily: ShapeType.self, forKey: .items)
    try super.init(from: decoder)
  }

  required init(dictionary: [String: Any]) throws {
    let itemDictionaries: [[String: Any]] = try dictionary.value(for: CodingKeys.items)
    items = try [ShapeItem].fromDictionaries(itemDictionaries)
    try super.init(dictionary: dictionary)
  }

  // MARK: Internal

  /// A list of shape items.
  let items: [ShapeItem]

  override func encode(to encoder: Encoder) throws {
    try super.encode(to: encoder)
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(items, forKey: .items)
  }

  // MARK: Private

  private enum CodingKeys: String, CodingKey {
    case items = "shapes"
  }
}
