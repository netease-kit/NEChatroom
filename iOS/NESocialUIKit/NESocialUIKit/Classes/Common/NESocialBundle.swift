// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import UIKit

@objcMembers public class NESocialBundle: NSObject {
  public static func bundle() -> Bundle {
    Bundle(for: NESocialBundle.self)
  }
}
