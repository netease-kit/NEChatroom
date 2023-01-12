// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import QuartzCore

extension CAShapeLayer {
  /// Adds animations for the given `CombinedShapeItem` to this `CALayer`
  @nonobjc
  func addAnimations(for combinedShapes: CombinedShapeItem,
                     context: LayerAnimationContext,
                     pathMultiplier: PathMultiplier)
    throws {
    try addAnimation(
      for: .path,
      keyframes: combinedShapes.shapes.keyframes,
      value: { paths in
        let combinedPath = CGMutablePath()
        for path in paths {
          combinedPath.addPath(path.cgPath().duplicated(times: pathMultiplier))
        }
        return combinedPath
      },
      context: context
    )
  }
}

// MARK: - CombinedShapeItem

/// A custom `ShapeItem` subclass that combines multiple `Shape`s into a single `KeyframeGroup`
final class CombinedShapeItem: ShapeItem {
  // MARK: Lifecycle

  init(shapes: KeyframeGroup<[BezierPath]>, name: String) {
    self.shapes = shapes
    super.init(name: name, type: .shape, hidden: false)
  }

  required init(from _: Decoder) throws {
    fatalError("init(from:) has not been implemented")
  }

  required init(dictionary _: [String: Any]) throws {
    fatalError("init(dictionary:) has not been implemented")
  }

  // MARK: Internal

  let shapes: KeyframeGroup<[BezierPath]>
}

extension CombinedShapeItem {
  /// Manually combines the given shape keyframes by manually interpolating at each frame
  static func manuallyInterpolating(shapes: [KeyframeGroup<BezierPath>],
                                    name: String)
    -> CombinedShapeItem {
    let interpolators = shapes.map { shape in
      KeyframeInterpolator(keyframes: shape.keyframes)
    }

    let times = shapes.flatMap { $0.keyframes.map(\.time) }

    let minimumTime = times.min() ?? 0
    let maximumTime = times.max() ?? 0
    let animationLocalTimeRange = Int(minimumTime) ... Int(maximumTime)

    let interpolatedKeyframes = animationLocalTimeRange.map { localTime in
      Keyframe(
        value: interpolators.compactMap { interpolator in
          interpolator.value(frame: AnimationFrameTime(localTime)) as? BezierPath
        },
        time: AnimationFrameTime(localTime)
      )
    }

    return CombinedShapeItem(
      shapes: KeyframeGroup(keyframes: ContiguousArray(interpolatedKeyframes)),
      name: name
    )
  }
}
