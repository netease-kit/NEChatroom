// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import QuartzCore

// MARK: - LayerContext

/// Context available when constructing an `AnimationLayer`
struct LayerContext {
  let animation: LottieAnimation
  let imageProvider: AnimationImageProvider
  let textProvider: AnimationTextProvider
  let fontProvider: AnimationFontProvider
  let compatibilityTracker: CompatibilityTracker
  var layerName: String

  func forLayer(_ layer: LayerModel) -> LayerContext {
    var context = self
    context.layerName = layer.name
    return context
  }
}

// MARK: - LayerModel + makeAnimationLayer

extension LayerModel {
  /// Constructs an `AnimationLayer` / `CALayer` that represents this `LayerModel`
  func makeAnimationLayer(context: LayerContext) throws -> BaseCompositionLayer? {
    let context = context.forLayer(self)

    if hidden {
      return TransformLayer(layerModel: self)
    }

    switch (type, self) {
    case let (.precomp, preCompLayerModel as PreCompLayerModel):
      let preCompLayer = PreCompLayer(preCompLayer: preCompLayerModel)
      try preCompLayer.setup(context: context)
      return preCompLayer

    case let (.solid, solidLayerModel as SolidLayerModel):
      return SolidLayer(solidLayerModel)

    case let (.shape, shapeLayerModel as ShapeLayerModel):
      return try ShapeLayer(shapeLayer: shapeLayerModel, context: context)

    case let (.image, imageLayerModel as ImageLayerModel):
      return ImageLayer(imageLayer: imageLayerModel, context: context)

    case let (.text, textLayerModel as TextLayerModel):
      return try TextLayer(textLayerModel: textLayerModel, context: context)

    case (.null, _):
      return TransformLayer(layerModel: self)

    default:
      try context.logCompatibilityIssue("""
      Unexpected layer type combination ("\(type)" and "\(Swift.type(of: self))")
      """)

      return nil
    }
  }
}
