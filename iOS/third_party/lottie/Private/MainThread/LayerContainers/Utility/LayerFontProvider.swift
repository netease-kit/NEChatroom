// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Foundation

/// Connects a LottieFontProvider to a group of text layers
final class LayerFontProvider {
  // MARK: Lifecycle

  init(fontProvider: AnimationFontProvider) {
    self.fontProvider = fontProvider
    textLayers = []
    reloadTexts()
  }

  // MARK: Internal

  private(set) var textLayers: [TextCompositionLayer]

  var fontProvider: AnimationFontProvider {
    didSet {
      reloadTexts()
    }
  }

  func addTextLayers(_ layers: [TextCompositionLayer]) {
    textLayers += layers
  }

  func reloadTexts() {
    textLayers.forEach {
      $0.fontProvider = fontProvider
    }
  }
}
