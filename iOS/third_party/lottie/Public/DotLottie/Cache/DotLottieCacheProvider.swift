// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import Foundation

/// `DotLottieCacheProvider` is a protocol that describes a DotLottie Cache.
/// DotLottie Cache is used when loading `DotLottie` models. Using a DotLottie Cache
/// can increase performance when loading an animation multiple times.
///
/// Lottie comes with a prebuilt LRU DotLottie Cache.
public protocol DotLottieCacheProvider {
  func file(forKey: String) -> DotLottieFile?

  func setFile(_ lottie: DotLottieFile, forKey: String)

  func clearCache()
}
