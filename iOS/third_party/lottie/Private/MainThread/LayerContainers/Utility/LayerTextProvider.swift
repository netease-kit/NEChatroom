// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Foundation

/// Connects a LottieTextProvider to a group of text layers
final class LayerTextProvider {
  // MARK: Lifecycle

  init(textProvider: AnimationTextProvider) {
    self.textProvider = textProvider
    textLayers = []
    reloadTexts()
  }

  // MARK: Internal

  private(set) var textLayers: [TextCompositionLayer]

  var textProvider: AnimationTextProvider {
    didSet {
      reloadTexts()
    }
  }

  func addTextLayers(_ layers: [TextCompositionLayer]) {
    textLayers += layers
  }

  func reloadTexts() {
    textLayers.forEach {
      $0.textProvider = textProvider
    }
  }
}
