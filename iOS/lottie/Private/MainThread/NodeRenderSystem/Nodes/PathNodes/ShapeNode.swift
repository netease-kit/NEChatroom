// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import CoreGraphics
import Foundation

// MARK: - ShapeNodeProperties

final class ShapeNodeProperties: NodePropertyMap, KeypathSearchable {
  // MARK: Lifecycle

  init(shape: Shape) {
    keypathName = shape.name
    path = NodeProperty(provider: KeyframeInterpolator(keyframes: shape.path.keyframes))
    keypathProperties = [
      "Path": path,
    ]
    properties = Array(keypathProperties.values)
  }

  // MARK: Internal

  var keypathName: String

  let path: NodeProperty<BezierPath>
  let keypathProperties: [String: AnyNodeProperty]
  let properties: [AnyNodeProperty]
}

// MARK: - ShapeNode

final class ShapeNode: AnimatorNode, PathNode {
  // MARK: Lifecycle

  init(parentNode: AnimatorNode?, shape: Shape) {
    pathOutput = PathOutputNode(parent: parentNode?.outputNode)
    properties = ShapeNodeProperties(shape: shape)
    self.parentNode = parentNode
  }

  // MARK: Internal

  let properties: ShapeNodeProperties

  let pathOutput: PathOutputNode

  let parentNode: AnimatorNode?
  var hasLocalUpdates = false
  var hasUpstreamUpdates = false
  var lastUpdateFrame: CGFloat?

  // MARK: Animator Node

  var propertyMap: NodePropertyMap & KeypathSearchable {
    properties
  }

  var isEnabled = true {
    didSet {
      pathOutput.isEnabled = isEnabled
    }
  }

  func rebuildOutputs(frame: CGFloat) {
    pathOutput.setPath(properties.path.value, updateFrame: frame)
  }
}
