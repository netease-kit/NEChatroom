// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import QuartzCore

extension CAShapeLayer {
  /// Adds animations for the given `Rectangle` to this `CALayer`
  @nonobjc
  func addAnimations(for rectangle: Rectangle,
                     context: LayerAnimationContext,
                     pathMultiplier: PathMultiplier,
                     roundedCorners: RoundedCorners?)
    throws {
    try addAnimation(
      for: .path,
      keyframes: rectangle.combinedKeyframes(roundedCorners: roundedCorners).keyframes,
      value: { keyframe in
        BezierPath.rectangle(
          position: keyframe.position.pointValue,
          size: keyframe.size.sizeValue,
          cornerRadius: keyframe.cornerRadius.cgFloatValue,
          direction: rectangle.direction
        )
        .cgPath()
        .duplicated(times: pathMultiplier)
      },
      context: context
    )
  }
}

extension Rectangle {
  /// Data that represents how to render a rectangle at a specific point in time
  struct Keyframe {
    let size: LottieVector3D
    let position: LottieVector3D
    let cornerRadius: LottieVector1D
  }

  /// Creates a single array of animatable keyframes from the separate arrays of keyframes in this Rectangle
  func combinedKeyframes(roundedCorners: RoundedCorners?) throws -> KeyframeGroup<Rectangle.Keyframe> {
    let cornerRadius = roundedCorners?.radius ?? cornerRadius
    return Keyframes.combined(
      size, position, cornerRadius,
      makeCombinedResult: Rectangle.Keyframe.init
    )
  }
}
