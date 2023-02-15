// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Foundation
#if canImport(UIKit)
  import UIKit
#elseif canImport(AppKit)
  import AppKit
#endif

extension Data {
  static func jsonData(from assetName: String, in bundle: Bundle) -> Data? {
    #if canImport(UIKit)
      return NSDataAsset(name: assetName, bundle: bundle)?.data
    #else
      if #available(macOS 10.11, *) {
        return NSDataAsset(name: assetName, bundle: bundle)?.data
      }
      return nil
    #endif
  }
}
