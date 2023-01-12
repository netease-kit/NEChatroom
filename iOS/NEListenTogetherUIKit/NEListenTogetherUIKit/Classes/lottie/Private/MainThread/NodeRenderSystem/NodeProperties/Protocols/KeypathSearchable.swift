// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Foundation
import QuartzCore

/// Protocol that provides keypath search functionality. Returns all node properties associated with a keypath.
protocol KeypathSearchable {
  /// The name of the Keypath
  var keypathName: String { get }

  /// A list of properties belonging to the keypath.
  var keypathProperties: [String: AnyNodeProperty] { get }

  /// Children Keypaths
  var childKeypaths: [KeypathSearchable] { get }

  var keypathLayer: CALayer? { get }
}
