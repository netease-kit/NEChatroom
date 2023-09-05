// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import QuartzCore

extension CAShapeLayer {
  /// Adds animations for the given `Ellipse` to this `CALayer`
  @nonobjc
  func addAnimations(for ellipse: Ellipse,
                     context: LayerAnimationContext,
                     pathMultiplier: PathMultiplier)
    throws {
    try addAnimation(
      for: .path,
      keyframes: ellipse.combinedKeyframes().keyframes,
      value: { keyframe in
        BezierPath.ellipse(
          size: keyframe.size.sizeValue,
          center: keyframe.position.pointValue,
          direction: ellipse.direction
        )
        .cgPath()
        .duplicated(times: pathMultiplier)
      },
      context: context
    )
  }
}

extension Ellipse {
  /// Data that represents how to render an ellipse at a specific point in time
  struct Keyframe {
    let size: LottieVector3D
    let position: LottieVector3D
  }

  /// Creates a single array of animatable keyframes from the separate arrays of keyframes in this Ellipse
  func combinedKeyframes() throws -> KeyframeGroup<Ellipse.Keyframe> {
    Keyframes.combined(
      size, position,
      makeCombinedResult: Ellipse.Keyframe.init
    )
  }
}
