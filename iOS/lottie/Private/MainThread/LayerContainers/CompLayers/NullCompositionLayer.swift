// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Foundation

final class NullCompositionLayer: CompositionLayer {
  init(layer: LayerModel) {
    super.init(layer: layer, size: .zero)
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override init(layer: Any) {
    /// Used for creating shadow model layers. Read More here: https://developer.apple.com/documentation/quartzcore/calayer/1410842-init
    guard let layer = layer as? NullCompositionLayer else {
      fatalError("init(layer:) Wrong Layer Class")
    }
    super.init(layer: layer)
  }
}
