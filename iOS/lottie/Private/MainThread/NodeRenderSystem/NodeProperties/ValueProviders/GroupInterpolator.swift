// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import CoreGraphics
import Foundation

/// A value provider that produces an array of values from an array of Keyframe Interpolators
final class GroupInterpolator<ValueType>: ValueProvider where ValueType: Interpolatable {
  // MARK: Lifecycle

  /// Initialize with an array of array of keyframes.
  init(keyframeGroups: ContiguousArray<ContiguousArray<Keyframe<ValueType>>>) {
    keyframeInterpolators = ContiguousArray(keyframeGroups.map { KeyframeInterpolator(keyframes: $0) })
  }

  // MARK: Internal

  let keyframeInterpolators: ContiguousArray<KeyframeInterpolator<ValueType>>

  var valueType: Any.Type {
    [ValueType].self
  }

  var storage: ValueProviderStorage<[ValueType]> {
    .closure { frame in
      self.keyframeInterpolators.map { $0.value(frame: frame) as! ValueType }
    }
  }

  func hasUpdate(frame: CGFloat) -> Bool {
    let updated = keyframeInterpolators.first(where: { $0.hasUpdate(frame: frame) })
    return updated != nil
  }
}
