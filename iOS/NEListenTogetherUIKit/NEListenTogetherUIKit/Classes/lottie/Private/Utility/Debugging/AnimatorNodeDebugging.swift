// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Foundation

extension AnimatorNode {
  func printNodeTree() {
    parentNode?.printNodeTree()
    LottieLogger.shared.info(String(describing: type(of: self)))

    if let group = self as? GroupNode {
      LottieLogger.shared.info("* |Children")
      group.rootNode?.printNodeTree()
      LottieLogger.shared.info("*")
    } else {
      LottieLogger.shared.info("|")
    }
  }
}
