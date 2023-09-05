// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Foundation

/// An item that define a a group of shape items
final class Group: ShapeItem {
  // MARK: Lifecycle

  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: Group.CodingKeys.self)
    items = try container.decode([ShapeItem].self, ofFamily: ShapeType.self, forKey: .items)
    try super.init(from: decoder)
  }

  required init(dictionary: [String: Any]) throws {
    let itemDictionaries: [[String: Any]] = try dictionary.value(for: CodingKeys.items)
    items = try [ShapeItem].fromDictionaries(itemDictionaries)
    try super.init(dictionary: dictionary)
  }

  init(items: [ShapeItem], name: String) {
    self.items = items
    super.init(name: name, type: .group, hidden: false)
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
    case items = "it"
  }
}
